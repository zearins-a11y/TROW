-- Bootstrap: create profile/workspace for ALL existing users who don't have one yet
-- Run this ONCE after enabling the trigger

DO $$
DECLARE
  v_user RECORD;
  v_workspace_id UUID;
  v_project_id UUID;
  v_team_id UUID;
  v_role_id UUID;
BEGIN
  -- Get super_admin role
  SELECT id INTO v_role_id FROM public.roles WHERE name = 'super_admin' LIMIT 1;

  -- Loop through auth.users (note: needs permission to read auth schema)
  FOR v_user IN
    SELECT id, email, raw_user_meta_data
    FROM auth.users
  LOOP
    -- Check if profile already exists
    IF NOT EXISTS (SELECT 1 FROM public.user_profiles WHERE id = v_user.id) THEN
      INSERT INTO public.user_profiles (id, email, full_name, avatar_url, created_at, updated_at)
      VALUES (
        v_user.id,
        v_user.email,
        COALESCE(v_user.raw_user_meta_data->>'full_name', v_user.raw_user_meta_data->>'name', split_part(v_user.email, '@', 1)),
        v_user.raw_user_meta_data->>'avatar_url',
        NOW(), NOW()
      );
    END IF;

    -- Check if user has workspace
    SELECT id INTO v_workspace_id FROM public.workspaces WHERE owner_id = v_user.id LIMIT 1;

    IF v_workspace_id IS NULL THEN
      INSERT INTO public.workspaces (name, description, owner_id, created_at, updated_at)
      VALUES (
        COALESCE(v_user.raw_user_meta_data->>'full_name', split_part(v_user.email, '@', 1)) || '''s Workspace',
        'Workspace padrão',
        v_user.id, NOW(), NOW()
      )
      RETURNING id INTO v_workspace_id;
    END IF;

    -- Create default project
    SELECT id INTO v_project_id FROM public.projects WHERE workspace_id = v_workspace_id LIMIT 1;
    IF v_project_id IS NULL THEN
      INSERT INTO public.projects (workspace_id, name, description, created_at, updated_at)
      VALUES (v_workspace_id, 'Projeto Principal', 'Default project', NOW(), NOW())
      RETURNING id INTO v_project_id;
    END IF;

    -- Create default team
    SELECT id INTO v_team_id FROM public.teams WHERE project_id = v_project_id LIMIT 1;
    IF v_team_id IS NULL THEN
      INSERT INTO public.teams (project_id, name, description, created_at, updated_at)
      VALUES (v_project_id, 'Equipe Principal', 'Default team', NOW(), NOW())
      RETURNING id INTO v_team_id;
    END IF;

    -- Add as super_admin member
    IF NOT EXISTS (SELECT 1 FROM public.team_members WHERE team_id = v_team_id AND user_id = v_user.id) THEN
      INSERT INTO public.team_members (team_id, user_id, role_id, created_at)
      VALUES (v_team_id, v_user.id, v_role_id, NOW());
    END IF;
  END LOOP;
END $$;

SELECT
  (SELECT COUNT(*) FROM user_profiles) AS profiles,
  (SELECT COUNT(*) FROM workspaces) AS workspaces,
  (SELECT COUNT(*) FROM projects) AS projects,
  (SELECT COUNT(*) FROM teams) AS teams,
  (SELECT COUNT(*) FROM team_members) AS memberships;
