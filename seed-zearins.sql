-- Direct insert for zearins@gmail.com
DO $$
DECLARE
  v_user_id UUID;
  v_workspace_id UUID;
  v_project_id UUID;
  v_team_id UUID;
  v_role_id UUID;
BEGIN
  -- Get zearins user ID
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'zearins@gmail.com';

  IF v_user_id IS NULL THEN
    RAISE NOTICE 'zearins@gmail.com not found in auth.users';
    RETURN;
  END IF;

  RAISE NOTICE 'Found user: %', v_user_id;

  -- Get super_admin role
  SELECT id INTO v_role_id FROM public.roles WHERE name = 'super_admin' LIMIT 1;

  IF v_role_id IS NULL THEN
    RAISE NOTICE 'super_admin role not found - run seed-roles.sql first';
    RETURN;
  END IF;

  RAISE NOTICE 'Found role: %', v_role_id;

  -- 1. Create profile
  INSERT INTO public.user_profiles (id, email, full_name, created_at, updated_at)
  VALUES (v_user_id, 'zearins@gmail.com', 'José Arins', NOW(), NOW())
  ON CONFLICT (id) DO NOTHING;

  RAISE NOTICE 'Profile created';

  -- 2. Create workspace
  INSERT INTO public.workspaces (name, description, owner_id, created_at, updated_at)
  VALUES ('zearins Workspace', 'Workspace principal', v_user_id, NOW(), NOW())
  RETURNING id INTO v_workspace_id;

  RAISE NOTICE 'Workspace created: %', v_workspace_id;

  -- 3. Create project
  INSERT INTO public.projects (workspace_id, name, description, created_at, updated_at)
  VALUES (v_workspace_id, 'Projeto Principal', 'Projeto padrão', NOW(), NOW())
  RETURNING id INTO v_project_id;

  RAISE NOTICE 'Project created: %', v_project_id;

  -- 4. Create team
  INSERT INTO public.teams (project_id, name, description, created_at, updated_at)
  VALUES (v_project_id, 'Equipe Principal', 'Equipe padrão', NOW(), NOW())
  RETURNING id INTO v_team_id;

  RAISE NOTICE 'Team created: %', v_team_id;

  -- 5. Create membership
  INSERT INTO public.team_members (team_id, user_id, role_id, created_at)
  VALUES (v_team_id, v_user_id, v_role_id, NOW())
  ON CONFLICT DO NOTHING;

  RAISE NOTICE 'Membership created';
END $$;

SELECT
  (SELECT COUNT(*) FROM user_profiles) AS profiles,
  (SELECT COUNT(*) FROM workspaces) AS workspaces,
  (SELECT COUNT(*) FROM projects) AS projects,
  (SELECT COUNT(*) FROM teams) AS teams,
  (SELECT COUNT(*) FROM team_members) AS memberships;
