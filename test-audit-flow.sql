-- Teste do fluxo de auditoria: criar convite + log automático
-- Cole este arquivo no Supabase SQL Editor e clique Run

DO $$
DECLARE
  v_team_id UUID;
  v_role_id UUID;
  v_user_id UUID;
  v_inv_id UUID;
  v_token TEXT := 'TEST_' || to_char(now(), 'YYYYMMDDHH24MISS');
BEGIN
  -- Get zearins user, team, role
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'zearins@gmail.com';
  SELECT id INTO v_team_id FROM public.teams WHERE name = 'Equipe Principal' LIMIT 1;
  SELECT id INTO v_role_id FROM public.roles WHERE name = 'membro' LIMIT 1;

  -- 1. Criar convite (igual ao InviteModal faria)
  INSERT INTO public.invitations (team_id, email, role_id, invited_by, token, status, expires_at)
  VALUES (v_team_id, 'teste-audit@aios.app', v_role_id, v_user_id, v_token, 'pending', NOW() + INTERVAL '7 days')
  RETURNING id INTO v_inv_id;

  RAISE NOTICE 'Convite criado: %', v_inv_id;
  RAISE NOTICE 'Token: %', v_token;

  -- 2. Log de auditoria (igual ao logAudit() faria via RPC create_audit_log)
  PERFORM public.create_audit_log(
    'create'::TEXT,           -- action
    'team'::TEXT,             -- module
    'invitation'::TEXT,       -- resource_type
    v_inv_id,                 -- resource_id
    NULL,                     -- old_value
    jsonb_build_object(
      'email', 'teste-audit@aios.app',
      'role_id', v_role_id,
      'team_id', v_team_id,
      'invitation_id', v_inv_id
    )                          -- new_value
  );

  RAISE NOTICE 'Log de auditoria gravado.';
END $$;

-- Resultado: mostra os últimos 3 logs
SELECT
  al.id,
  up.email AS user_email,
  al.action,
  al.module_name,
  al.resource_type,
  al.created_at
FROM public.audit_logs al
LEFT JOIN public.user_profiles up ON up.id = al.user_id
ORDER BY al.created_at DESC
LIMIT 3;
