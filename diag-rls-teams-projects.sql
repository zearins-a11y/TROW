-- Diagnóstico das RLS policies de teams e projects
-- Cole no SQL Editor e rode

SELECT
  tablename,
  policyname,
  cmd AS command,
  roles,
  qual AS using_expression,
  with_check AS with_check_expression
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('teams', 'projects', 'team_members', 'workspaces')
ORDER BY tablename, cmd, policyname;
