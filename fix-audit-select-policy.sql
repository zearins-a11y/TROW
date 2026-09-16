-- FIX: Criar policy de SELECT para audit_logs
-- Garante que qualquer usuário autenticado pode ler logs de auditoria
-- (toda a lógica de visibilidade já está no frontend via filtros)

CREATE POLICY IF NOT EXISTS "audit_logs_select"
  ON audit_logs FOR SELECT
  TO authenticated
  USING (true);

-- Verificar resultado
SELECT policyname, cmd, permissive
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'audit_logs';
