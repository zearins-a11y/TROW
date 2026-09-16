-- Cleanup duplicatas de times (rodar após o bug do trigger ter criado vários)
-- Mantém apenas a equipe mais recente de cada (project_id, name)
DO $$
DECLARE
  v_user_id UUID;
  v_workspace_keep UUID;
  v_project_keep UUID;
  v_count_deleted INT := 0;
BEGIN
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'zearins@gmail.com';

  -- Keep newest workspace for the user
  SELECT id INTO v_workspace_keep
  FROM public.workspaces
  WHERE owner_id = v_user_id
  ORDER BY created_at DESC
  LIMIT 1;

  IF v_workspace_keep IS NOT NULL THEN
    DELETE FROM public.workspaces
    WHERE owner_id = v_user_id
      AND id != v_workspace_keep;
    GET DIAGNOSTICS v_count_deleted = ROW_COUNT;
    RAISE NOTICE 'Workspaces duplicados removidos: %', v_count_deleted;
  END IF;

  -- Keep newest project per workspace
  DELETE FROM public.projects p
  WHERE p.workspace_id = v_workspace_keep
    AND p.id NOT IN (
      SELECT id FROM (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY workspace_id ORDER BY created_at DESC) AS rn
        FROM public.projects
        WHERE workspace_id = v_workspace_keep
      ) t WHERE rn = 1
    );
  GET DIAGNOSTICS v_count_deleted = ROW_COUNT;
  RAISE NOTICE 'Projetos duplicados removidos: %', v_count_deleted;

  -- Keep newest team per (project_id, name) — but only if no membership references the older ones
  DELETE FROM public.teams t
  WHERE t.project_id IN (SELECT id FROM public.projects WHERE workspace_id = v_workspace_keep)
    AND t.id NOT IN (
      -- Keep the most recent team per (project_id, name) combination
      SELECT id FROM (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY project_id, name ORDER BY created_at DESC) AS rn
        FROM public.teams
        WHERE project_id IN (SELECT id FROM public.projects WHERE workspace_id = v_workspace_keep)
      ) ranked WHERE rn = 1
    );
  GET DIAGNOSTICS v_count_deleted = ROW_COUNT;
  RAISE NOTICE 'Times duplicados removidos: %', v_count_deleted;

  -- Remove memberships pointing to deleted teams
  DELETE FROM public.team_members tm
  WHERE tm.team_id NOT IN (SELECT id FROM public.teams);
  GET DIAGNOSTICS v_count_deleted = ROW_COUNT;
  RAISE NOTICE 'Memberships órfãs removidas: %', v_count_deleted;

  -- Keep only one membership per (team_id, user_id)
  DELETE FROM public.team_members tm
  WHERE tm.id NOT IN (
    SELECT id FROM (
      SELECT id, ROW_NUMBER() OVER (PARTITION BY team_id, user_id ORDER BY created_at ASC) AS rn
      FROM public.team_members
    ) ranked WHERE rn = 1
  );
  GET DIAGNOSTICS v_count_deleted = ROW_COUNT;
  RAISE NOTICE 'Memberships duplicadas removidas: %', v_count_deleted;
END $$;

-- Resultado final
SELECT
  (SELECT COUNT(*) FROM workspaces)               AS workspaces,
  (SELECT COUNT(*) FROM projects)                 AS projects,
  (SELECT COUNT(*) FROM teams)                    AS teams,
  (SELECT COUNT(*) FROM team_members)             AS memberships;
