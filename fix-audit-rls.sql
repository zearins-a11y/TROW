-- ============================================================
-- PASSO 1: DIAGNÓSTICO — cole e rode, me mande o resultado
-- ============================================================

-- A) Policies de audit_logs
SELECT
  policyname,
  cmd AS command,
  roles,
  qual AS using_expression,
  permissive
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'audit_logs';

-- B) Sample dos logs existentes
SELECT
  id, user_id, team_id, action, module, resource_type, created_at
FROM audit_logs
LIMIT 3;

-- C) Verificar se a foreign key relationship user_profiles existe
-- (PostgREST usa isso para resolver o join em getAuditLogs)
SELECT
  conname AS constraint_name,
  conrelid::regclass AS source_table,
  confrelid::regclass AS target_table,
  pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE contype = 'f'
  AND conrelid = 'public.audit_logs'::regclass;

-- ============================================================
-- PASSO 2: FIX — cole e rode APÓS ver o resultado do passo 1
-- ============================================================

-- A) Criar policy de SELECT (se não existir)
DROP POLICY IF EXISTS "audit_logs_select" ON audit_logs;
CREATE POLICY "audit_logs_select"
  ON audit_logs FOR SELECT
  TO authenticated
  USING (true);

-- B) Confirmar policies
SELECT policyname, cmd, permissive
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'audit_logs';
