-- Teste da auditoria no banco real
-- Cole no Supabase SQL Editor e rode

-- 1. Verifique se há logs atualmente
SELECT COUNT(*) AS logs_antes FROM audit_logs;

-- 2. Insira um log de teste via RPC (com seu user_id real)
SELECT public.create_audit_log(
  'create'::TEXT,
  'team'::TEXT,
  'invitation'::TEXT,
  NULL,
  NULL,
  '{"email":"teste@aios.app","source":"sql-test"}'::JSONB
) AS log_id;

-- 3. Conte novamente
SELECT COUNT(*) AS logs_depois FROM audit_logs;

-- 4. Mostre os 3 últimos
SELECT
  al.id,
  al.user_id,
  al.action,
  al.module,
  al.resource_type,
  al.new_value,
  al.created_at
FROM audit_logs al
ORDER BY al.created_at DESC
LIMIT 3;
