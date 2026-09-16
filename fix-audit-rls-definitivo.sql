-- ============================================================
-- FIX DEFINITIVO: policy de SELECT para audit_logs
-- ============================================================

-- 1. Remover TODAS as policies antigas (se houver) que possam bloquear
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN
    SELECT policyname FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'audit_logs'
      AND cmd IN ('SELECT', 'r')
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON audit_logs', pol.policyname);
    RAISE NOTICE 'Dropped policy: %', pol.policyname;
  END LOOP;
END $$;

-- 2. Criar policy de SELECT permissiva
CREATE POLICY "allow_select_authenticated"
  ON audit_logs
  FOR SELECT
  TO authenticated
  USING (true);

-- 3. Verificar resultado
SELECT policyname, cmd, permissive, roles, qual
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'audit_logs';

-- 4. Teste de leitura (deve retornar 6+ linhas)
SELECT COUNT(*) AS total_logs FROM audit_logs;
