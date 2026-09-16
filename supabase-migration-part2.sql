-- ============================================
-- AIOS Command Center - Part 2: Triggers & RLS
-- ============================================

-- Trigger function: create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function: accept invitation (creates team_member)
CREATE OR REPLACE FUNCTION public.accept_invitation(p_token TEXT)
RETURNS VOID AS $$
DECLARE
  v_invitation RECORD;
  v_user_id UUID;
BEGIN
  SELECT * INTO v_invitation FROM public.invitations WHERE token = p_token AND status = 'pending' AND expires_at > NOW();
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invalid or expired invitation';
  END IF;

  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Add user to team
  INSERT INTO public.team_members (team_id, user_id, role_id, assigned_by)
  VALUES (v_invitation.team_id, v_user_id, v_invitation.role_id, v_invitation.invited_by)
  ON CONFLICT (team_id, user_id) DO UPDATE SET role_id = EXCLUDED.role_id;

  -- Mark invitation as accepted
  UPDATE public.invitations SET status = 'accepted' WHERE id = v_invitation.id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: create audit log entry
CREATE OR REPLACE FUNCTION public.create_audit_log(
  p_action TEXT,
  p_module TEXT,
  p_resource_type TEXT,
  p_resource_id UUID,
  p_old_value JSONB,
  p_new_value JSONB
)
RETURNS UUID AS $$
DECLARE
  v_log_id UUID;
BEGIN
  INSERT INTO public.audit_logs (user_id, action, module, resource_type, resource_id, old_value, new_value)
  VALUES (auth.uid(), p_action, p_module, p_resource_type, p_resource_id, p_old_value, p_new_value)
  RETURNING id INTO v_log_id;
  RETURN v_log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- Row Level Security Policies
-- ============================================

-- user_profiles: users can read all profiles, but only update their own
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "user_profiles_read_all" ON user_profiles;
CREATE POLICY "user_profiles_read_all" ON user_profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "user_profiles_update_own" ON user_profiles;
CREATE POLICY "user_profiles_update_own" ON user_profiles FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "user_profiles_insert_own" ON user_profiles;
CREATE POLICY "user_profiles_insert_own" ON user_profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- workspaces: owner can do everything, members can read
ALTER TABLE workspaces ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "workspaces_owner_all" ON workspaces;
CREATE POLICY "workspaces_owner_all" ON workspaces FOR ALL USING (owner_id = auth.uid());

DROP POLICY IF EXISTS "workspaces_read_member" ON workspaces;
CREATE POLICY "workspaces_read_member" ON workspaces FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM team_members tm
    JOIN teams t ON t.id = tm.team_id
    JOIN projects p ON p.id = t.project_id
    WHERE p.workspace_id = workspaces.id AND tm.user_id = auth.uid()
  )
);

-- projects: workspace owner and team members can access
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "projects_owner_all" ON projects;
CREATE POLICY "projects_owner_all" ON projects FOR ALL USING (
  EXISTS (SELECT 1 FROM workspaces WHERE id = projects.workspace_id AND owner_id = auth.uid())
);

DROP POLICY IF EXISTS "projects_read_member" ON projects;
CREATE POLICY "projects_read_member" ON projects FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM team_members tm
    JOIN teams t ON t.id = tm.team_id
    WHERE t.project_id = projects.id AND tm.user_id = auth.uid()
  )
);

-- teams: project owner and team members can access
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "teams_owner_all" ON teams;
CREATE POLICY "teams_owner_all" ON teams FOR ALL USING (
  EXISTS (
    SELECT 1 FROM projects p
    JOIN workspaces w ON w.id = p.workspace_id
    WHERE p.id = teams.project_id AND w.owner_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "teams_read_member" ON teams;
CREATE POLICY "teams_read_member" ON teams FOR SELECT USING (
  EXISTS (SELECT 1 FROM team_members WHERE team_id = teams.id AND user_id = auth.uid())
);

-- roles: everyone can read system roles
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "roles_read_all" ON roles;
CREATE POLICY "roles_read_all" ON roles FOR SELECT USING (true);

-- role_permissions: everyone can read
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "role_perms_read_all" ON role_permissions;
CREATE POLICY "role_perms_read_all" ON role_permissions FOR SELECT USING (true);

DROP POLICY IF EXISTS "role_perms_admin_write" ON role_permissions;
CREATE POLICY "role_perms_admin_write" ON role_permissions FOR ALL USING (
  EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND id IN (
    SELECT user_id FROM team_members tm
    JOIN roles r ON r.id = tm.role_id
    WHERE r.name IN ('super_admin', 'admin')
  ))
);

-- team_members: users can see their own memberships, project owners can manage
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "team_members_read_self" ON team_members;
CREATE POLICY "team_members_read_self" ON team_members FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "team_members_read_team" ON team_members;
CREATE POLICY "team_members_read_team" ON team_members FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM team_members tm2
    WHERE tm2.team_id = team_members.team_id AND tm2.user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "team_members_owner_manage" ON team_members;
CREATE POLICY "team_members_owner_manage" ON team_members FOR ALL USING (
  EXISTS (
    SELECT 1 FROM teams t
    JOIN projects p ON p.id = t.project_id
    JOIN workspaces w ON w.id = p.workspace_id
    WHERE t.id = team_members.team_id AND w.owner_id = auth.uid()
  )
);

-- invitations: invited user and team owner can read
ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "invitations_read_self" ON invitations;
CREATE POLICY "invitations_read_self" ON invitations FOR SELECT USING (email = (SELECT email FROM auth.users WHERE id = auth.uid()));

DROP POLICY IF EXISTS "invitations_owner_manage" ON invitations;
CREATE POLICY "invitations_owner_manage" ON invitations FOR ALL USING (
  EXISTS (
    SELECT 1 FROM teams t
    JOIN projects p ON p.id = t.project_id
    JOIN workspaces w ON w.id = p.workspace_id
    WHERE t.id = invitations.team_id AND w.owner_id = auth.uid()
  )
);

-- audit_logs: users see their own, admins see all
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "audit_logs_read_self" ON audit_logs;
CREATE POLICY "audit_logs_read_self" ON audit_logs FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "audit_logs_admin_read" ON audit_logs;
CREATE POLICY "audit_logs_admin_read" ON audit_logs FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM team_members tm
    JOIN roles r ON r.id = tm.role_id
    WHERE tm.user_id = auth.uid() AND r.name IN ('super_admin', 'admin')
  )
);

-- Grant execute on functions
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO supabase_auth_admin;
GRANT EXECUTE ON FUNCTION public.accept_invitation(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_audit_log(TEXT, TEXT, TEXT, UUID, JSONB, JSONB) TO authenticated;
