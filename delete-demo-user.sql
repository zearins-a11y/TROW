-- Delete demo@aios.com user and all related data

DO $$
DECLARE
  v_demo_id UUID;
BEGIN
  -- Find demo user ID from auth.users
  SELECT id INTO v_demo_id FROM auth.users WHERE email = 'demo@aios.com';

  IF v_demo_id IS NULL THEN
    RAISE NOTICE 'demo@aios.com not found';
    RETURN;
  END IF;

  -- Delete from team_members
  DELETE FROM public.team_members WHERE user_id = v_demo_id;

  -- Get teams where demo was the only member and delete
  DELETE FROM public.teams
  WHERE id IN (
    SELECT t.id FROM public.teams t
    WHERE NOT EXISTS (SELECT 1 FROM public.team_members WHERE team_id = t.id)
  );

  -- Delete workspaces owned by demo where there are no other members
  DELETE FROM public.workspaces
  WHERE owner_id = v_demo_id
  AND NOT EXISTS (
    SELECT 1 FROM public.projects p
    JOIN public.teams t ON t.project_id = p.id
    JOIN public.team_members tm ON tm.team_id = t.id
    WHERE p.workspace_id = public.workspaces.id
    AND tm.user_id != v_demo_id
  );

  -- Delete profile
  DELETE FROM public.user_profiles WHERE id = v_demo_id;

  -- Delete audit logs
  DELETE FROM public.audit_logs WHERE user_id = v_demo_id;

  -- Finally delete from auth.users
  DELETE FROM auth.users WHERE id = v_demo_id;

  RAISE NOTICE 'demo@aios.com deleted!';
END $$;

SELECT
  (SELECT COUNT(*) FROM auth.users WHERE email = 'demo@aios.com') AS remaining_demo,
  (SELECT COUNT(*) FROM public.user_profiles WHERE email = 'demo@aios.com') AS remaining_profile;
