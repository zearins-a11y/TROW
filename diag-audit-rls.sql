-- Diagnóstico: policies RLS da tabela audit_logs + sample data
-- Cole no Supabase SQL Editor

-- 1. Ver policies de audit_logs
SELECT
  policyname,
  cmd AS command,
  roles,
  qual AS using_expression,
  with_check AS with_check_expression,
  permissive
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'audit_logs';

-- 2. Ver sample dos logs existentes (para checar estrutura)
SELECT
  id,
  user_id,
  team_id,
  action,
  module,
  resource_type,
  created_at
FROM audit_logs
LIMIT 3;

-- 3. Ver se existe algum trigger que bloqueia SELECT
SELECT
  trigger_name,
  event_manipulation,
  action_statement
FROM information_schema.triggers
WHERE event_object_schema = 'public'
  AND event_object_table = 'audit_logs';
