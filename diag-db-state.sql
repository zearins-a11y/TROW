-- Diagnóstico completo do estado atual do banco
-- Cole no Supabase SQL Editor e rode
-- Me envie o resultado dos números

-- 1. Quantas linhas tem cada tabela?
SELECT
  (SELECT COUNT(*) FROM auth.users) AS auth_users,
  (SELECT COUNT(*) FROM user_profiles) AS profiles,
  (SELECT COUNT(*) FROM workspaces) AS workspaces,
  (SELECT COUNT(*) FROM projects) AS projects,
  (SELECT COUNT(*) FROM teams) AS teams,
  (SELECT COUNT(*) FROM team_members) AS memberships,
  (SELECT COUNT(*) FROM roles) AS roles,
  (SELECT COUNT(*) FROM role_permissions) AS role_perms,
  (SELECT COUNT(*) FROM invitations) AS invitations,
  (SELECT COUNT(*) FROM audit_logs) AS audit_logs;

-- 2. Quem são os usuários?
SELECT id, email, created_at FROM auth.users ORDER BY created_at;

-- 3. Quais workspaces existem?
SELECT id, name, owner_id, created_at FROM workspaces ORDER BY created_at;

-- 4. Quais projects existem?
SELECT id, workspace_id, name, created_at FROM projects ORDER BY created_at;

-- 5. Quais teams existem?
SELECT id, project_id, name, created_at FROM teams ORDER BY created_at;

-- 6. Quais memberships?
SELECT tm.id, t.name AS team, up.email AS user_email, r.name AS role, tm.created_at
FROM team_members tm
LEFT JOIN teams t ON t.id = tm.team_id
LEFT JOIN user_profiles up ON up.id = tm.user_id
LEFT JOIN roles r ON r.id = tm.role_id
ORDER BY tm.created_at;

-- 7. RLS policies ativas em cada tabela relevante
SELECT
  schemaname,
  tablename,
  policyname,
  cmd,
  qual
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('user_profiles', 'workspaces', 'projects', 'teams', 'team_members', 'invitations', 'audit_logs', 'role_permissions')
ORDER BY tablename, policyname;

-- 8. RLS está habilitado?
SELECT
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('user_profiles', 'workspaces', 'projects', 'teams', 'team_members', 'invitations', 'audit_logs', 'role_permissions')
ORDER BY tablename;
