-- ============================================================
-- Diagnóstico completo para reconciliar
-- ============================================================

-- A) Policies RLS atualmente ativas em audit_logs
SELECT
  policyname,
  cmd AS command,
  roles,
  permissive,
  qual AS using_expression,
  with_check AS with_check_expression
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'audit_logs';

-- B) Definição atual do RPC create_audit_log
SELECT
  p.proname AS function_name,
  pg_get_functiondef(p.oid) AS definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname = 'create_audit_log';

-- C) Trigger que preenche user_profiles (caso exista)
SELECT
  trigger_name,
  event_manipulation,
  action_timing,
  action_statement
FROM information_schema.triggers
WHERE event_object_schema = 'public'
  AND event_object_table = 'audit_logs';

-- D) Sample REAL de log (apenas 2 linhas)
SELECT *
FROM audit_logs
LIMIT 2;
