-- Auto-create user_profile, default workspace, default project, default team
-- when a new user signs up OR logs in via OAuth for the first time

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID;
  v_workspace_id UUID;
  v_project_id UUID;
  v_team_id UUID;
  v_super_admin_role_id UUID;
BEGIN
  v_user_id := NEW.id;

  -- 1. Create user_profile if not exists
  INSERT INTO public.user_profiles (id, email, full_name, avatar_url, created_at, updated_at)
  VALUES (
    v_user_id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
    NEW.raw_user_meta_data->>'avatar_url',
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = COALESCE(EXCLUDED.full_name, public.user_profiles.full_name),
    avatar_url = COALESCE(EXCLUDED.avatar_url, public.user_profiles.avatar_url),
    updated_at = NOW();

  -- 2. Check if user already has a workspace (idempotency)
  SELECT w.id INTO v_workspace_id
  FROM public.workspaces w
  WHERE w.owner_id = v_user_id
  LIMIT 1;

  IF v_workspace_id IS NULL THEN
    -- Create default workspace for new user
    INSERT INTO public.workspaces (name, description, owner_id, created_at, updated_at)
    VALUES (
      COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)) || '''s Workspace',
      'Workspace padrão criado automaticamente',
      v_user_id,
      NOW(),
      NOW()
    )
    RETURNING id INTO v_workspace_id;
  END IF;

  -- 3. Create default project
  INSERT INTO public.projects (workspace_id, name, description, created_at, updated_at)
  VALUES (
    v_workspace_id,
    'Projeto Principal',
    'Projeto padrão criado automaticamente',
    NOW(),
    NOW()
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_project_id;

  IF v_project_id IS NULL THEN
    SELECT id INTO v_project_id
    FROM public.projects
    WHERE workspace_id = v_workspace_id
    LIMIT 1;
  END IF;

  -- 4. Get super_admin role ID
  SELECT id INTO v_super_admin_role_id
  FROM public.roles
  WHERE name = 'super_admin'
  LIMIT 1;

  -- 5. Create default team
  INSERT INTO public.teams (project_id, name, description, created_at, updated_at)
  VALUES (
    v_project_id,
    'Equipe Principal',
    'Equipe padrão criada automaticamente',
    NOW(),
    NOW()
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_team_id;

  IF v_team_id IS NULL THEN
    SELECT id INTO v_team_id
    FROM public.teams
    WHERE project_id = v_project_id
    LIMIT 1;
  END IF;

  -- 6. Add user as super_admin member of the team
  IF v_team_id IS NOT NULL AND v_super_admin_role_id IS NOT NULL THEN
    INSERT INTO public.team_members (team_id, user_id, role_id, created_at)
    VALUES (v_team_id, v_user_id, v_super_admin_role_id, NOW())
    ON CONFLICT DO NOTHING;
  END IF;

  -- 7. Log the event
  INSERT INTO public.audit_logs (user_id, action, module, resource_type, resource_id, created_at)
  VALUES (
    v_user_id,
    'create',
    'auth',
    'user',
    v_user_id,
    NOW()
  );

  RETURN NEW;
END;
$$;

-- Drop old trigger if exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create the trigger on auth.users (fires on signup AND OAuth)
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Also fire on UPDATE (for OAuth metadata updates - in case signup was already done)
DROP TRIGGER IF EXISTS on_auth_user_updated ON auth.users;
CREATE TRIGGER on_auth_user_updated
  AFTER UPDATE ON auth.users
  FOR EACH ROW
  WHEN (OLD.raw_user_meta_data IS DISTINCT FROM NEW.raw_user_meta_data)
  EXECUTE FUNCTION public.handle_new_user();

SELECT 'Auto-profile trigger created!' AS status;
