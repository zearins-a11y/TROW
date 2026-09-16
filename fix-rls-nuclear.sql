-- NUCLEAR FIX: Drop ALL policies on problematic tables and rebuild simply

-- Workspaces: drop and rebuild
ALTER TABLE workspaces DISABLE ROW LEVEL SECURITY;
DO $$
DECLARE pol RECORD;
BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE schemaname='public' AND tablename='workspaces' LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.workspaces', pol.policyname);
  END LOOP;
END $$;
CREATE POLICY "workspaces_all" ON workspaces FOR ALL TO authenticated USING (true) WITH CHECK (true);
ALTER TABLE workspaces ENABLE ROW LEVEL SECURITY;

-- Teams: drop and rebuild
ALTER TABLE teams DISABLE ROW LEVEL SECURITY;
DO $$
DECLARE pol RECORD;
BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE schemaname='public' AND tablename='teams' LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.teams', pol.policyname);
  END LOOP;
END $$;
CREATE POLICY "teams_all" ON teams FOR ALL TO authenticated USING (true) WITH CHECK (true);
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;

-- team_members: drop ALL and rebuild (had recursive policy)
ALTER TABLE team_members DISABLE ROW LEVEL SECURITY;
DO $$
DECLARE pol RECORD;
BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE schemaname='public' AND tablename='team_members' LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.team_members', pol.policyname);
  END LOOP;
END $$;
CREATE POLICY "team_members_all" ON team_members FOR ALL TO authenticated USING (true) WITH CHECK (true);
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;

-- role_permissions
ALTER TABLE role_permissions DISABLE ROW LEVEL SECURITY;
DO $$
DECLARE pol RECORD;
BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE schemaname='public' AND tablename='role_permissions' LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.role_permissions', pol.policyname);
  END LOOP;
END $$;
CREATE POLICY "role_permissions_all" ON role_permissions FOR ALL TO authenticated USING (true) WITH CHECK (true);
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;

-- user_profiles
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;
DO $$
DECLARE pol RECORD;
BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE schemaname='public' AND tablename='user_profiles' LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.user_profiles', pol.policyname);
  END LOOP;
END $$;
CREATE POLICY "user_profiles_all" ON user_profiles FOR ALL TO authenticated USING (true) WITH CHECK (true);
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- roles
ALTER TABLE roles DISABLE ROW LEVEL SECURITY;
DO $$
DECLARE pol RECORD;
BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE schemaname='public' AND tablename='roles' LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.roles', pol.policyname);
  END LOOP;
END $$;
CREATE POLICY "roles_all" ON roles FOR ALL TO authenticated USING (true) WITH CHECK (true);
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;

-- invitations
ALTER TABLE invitations DISABLE ROW LEVEL SECURITY;
DO $$
DECLARE pol RECORD;
BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE schemaname='public' AND tablename='invitations' LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.invitations', pol.policyname);
  END LOOP;
END $$;
CREATE POLICY "invitations_all" ON invitations FOR ALL TO authenticated USING (true) WITH CHECK (true);
ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;

-- audit_logs
ALTER TABLE audit_logs DISABLE ROW LEVEL SECURITY;
DO $$
DECLARE pol RECORD;
BEGIN
  FOR pol IN SELECT policyname FROM pg_policies WHERE schemaname='public' AND tablename='audit_logs' LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.audit_logs', pol.policyname);
  END LOOP;
END $$;
CREATE POLICY "audit_logs_all" ON audit_logs FOR ALL TO authenticated USING (true) WITH CHECK (true);
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Also projects table if exists
DO $$
DECLARE pol RECORD;
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='projects') THEN
    ALTER TABLE projects DISABLE ROW LEVEL SECURITY;
    FOR pol IN SELECT policyname FROM pg_policies WHERE schemaname='public' AND tablename='projects' LOOP
      EXECUTE format('DROP POLICY IF EXISTS %I ON public.projects', pol.policyname);
    END LOOP;
    CREATE POLICY "projects_all" ON projects FOR ALL TO authenticated USING (true) WITH CHECK (true);
    ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
  END IF;
END $$;

SELECT 'ALL POLICIES RESET!' AS status;
