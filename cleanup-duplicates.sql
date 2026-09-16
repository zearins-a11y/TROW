-- Cleanup duplicates: keep only the most recent workspace/project/team/membership per user
DO $$
DECLARE
  v_user_id UUID;
  v_workspace_keep UUID;
  v_project_keep UUID;
  v_team_keep UUID;
BEGIN
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'zearins@gmail.com';

  -- Keep newest workspace
  SELECT id INTO v_workspace_keep
  FROM public.workspaces
  WHERE owner_id = v_user_id
  ORDER BY created_at DESC
  LIMIT 1;

  IF v_workspace_keep IS NOT NULL THEN
    DELETE FROM public.workspaces WHERE owner_id = v_user_id AND id != v_workspace_keep;
  END IF;

  -- Keep newest project
  SELECT id INTO v_project_keep
  FROM public.projects
  WHERE workspace_id = v_workspace_keep
  ORDER BY created_at DESC
  LIMIT 1;

  IF v_project_keep IS NOT NULL THEN
    DELETE FROM public.projects WHERE workspace_id = v_workspace_keep AND id != v_project_keep;
  END IF;

  -- Keep newest team
  SELECT id INTO v_team_keep
  FROM public.teams
  WHERE project_id = v_project_keep
  ORDER BY created_at DESC
  LIMIT 1;

  IF v_team_keep IS NOT NULL THEN
    DELETE FROM public.teams WHERE project_id = v_project_keep AND id != v_team_keep;
  END IF;

  -- Keep one membership per user
  DELETE FROM public.team_members
  WHERE user_id = v_user_id
  AND team_id != v_team_keep;
END $$;

SELECT
  (SELECT COUNT(*) FROM user_profiles WHERE email = 'zearins@gmail.com') AS profiles,
  (SELECT COUNT(*) FROM workspaces) AS workspaces,
  (SELECT COUNT(*) FROM projects) AS projects,
  (SELECT COUNT(*) FROM teams) AS teams,
  (SELECT COUNT(*) FROM team_members) AS memberships;
