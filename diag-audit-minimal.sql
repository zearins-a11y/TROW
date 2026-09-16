-- Queries que evitam truncamento

-- A) Policies (sem campos longos)
SELECT
  policyname,
  cmd,
  permissive,
  LENGTH(qual::text) AS using_len,
  LENGTH(with_check::text) AS with_check_len
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'audit_logs';

-- B) Função audit RPC, apenas primeiros 800 chars da definição
SELECT
  SUBSTRING(pg_get_functiondef(p.oid) FROM 1 FOR 800) AS definition_start
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname = 'create_audit_log';

-- C) Sample simples
SELECT id, action, module, resource_type, user_id, created_at
FROM audit_logs
ORDER BY created_at DESC
LIMIT 6;
