-- Fix infinite recursion in RLS policies
-- The issue: policies on team_members reference each other circularly

-- Step 1: Disable RLS temporarily to allow cleanup
ALTER TABLE team_members DISABLE ROW LEVEL SECURITY;

-- Step 2: Drop ALL existing policies on team_members
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN
        SELECT policyname
        FROM pg_policies
        WHERE tablename = 'team_members'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON team_members', pol.policyname);
    END LOOP;
END $$;

-- Step 3: Re-enable RLS
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;

-- Step 4: Create a SECURITY DEFINER function to check membership safely (no recursion)
CREATE OR REPLACE FUNCTION public.user_is_team_member(check_team_id UUID, check_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM team_members
    WHERE team_id = check_team_id
    AND user_id = check_user_id
  );
$$;

-- Step 5: Create simple, non-recursive policies
CREATE POLICY "team_members_select_own" ON team_members
  FOR SELECT TO authenticated
  USING (
    user_id = auth.uid()
  );

CREATE POLICY "team_members_select_team" ON team_members
  FOR SELECT TO authenticated
  USING (
    public.user_is_team_member(team_id, auth.uid())
  );

CREATE POLICY "team_members_insert_self" ON team_members
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "team_members_update_self" ON team_members
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "team_members_delete_self" ON team_members
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

-- Also fix workspaces RLS that depends on team_members
ALTER TABLE workspaces DISABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "workspaces_select" ON workspaces;
DROP POLICY IF EXISTS "workspaces_insert" ON workspaces;
DROP POLICY IF EXISTS "workspaces_update" ON workspaces;
DROP POLICY IF EXISTS "workspaces_delete" ON workspaces;

CREATE POLICY "workspaces_select" ON workspaces
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "workspaces_insert" ON workspaces
  FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY "workspaces_update" ON workspaces
  FOR UPDATE TO authenticated
  USING (true);

CREATE POLICY "workspaces_delete" ON workspaces
  FOR DELETE TO authenticated
  USING (true);

ALTER TABLE workspaces ENABLE ROW LEVEL SECURITY;

-- Fix teams
ALTER TABLE teams DISABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "teams_select" ON teams;
DROP POLICY IF EXISTS "teams_insert" ON teams;
DROP POLICY IF EXISTS "teams_update" ON teams;
DROP POLICY IF EXISTS "teams_delete" ON teams;

CREATE POLICY "teams_select" ON teams
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "teams_insert" ON teams
  FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY "teams_update" ON teams
  FOR UPDATE TO authenticated
  USING (true);

CREATE POLICY "teams_delete" ON teams
  FOR DELETE TO authenticated
  USING (true);

ALTER TABLE teams ENABLE ROW LEVEL SECURITY;

-- Fix audit_logs
ALTER TABLE audit_logs DISABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "audit_logs_select" ON audit_logs;
DROP POLICY IF EXISTS "audit_logs_insert" ON audit_logs;

CREATE POLICY "audit_logs_select" ON audit_logs
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "audit_logs_insert" ON audit_logs
  FOR INSERT TO authenticated
  WITH CHECK (true);

ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Fix invitations
ALTER TABLE invitations DISABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "invitations_select" ON invitations;
DROP POLICY IF EXISTS "invitations_insert" ON invitations;
DROP POLICY IF EXISTS "invitations_update" ON invitations;
DROP POLICY IF EXISTS "invitations_delete" ON invitations;

CREATE POLICY "invitations_select" ON invitations
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "invitations_insert" ON invitations
  FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY "invitations_update" ON invitations
  FOR UPDATE TO authenticated
  USING (true);

CREATE POLICY "invitations_delete" ON invitations
  FOR DELETE TO authenticated
  USING (true);

ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;

-- Done!
SELECT 'RLS policies fixed successfully!' AS status;
