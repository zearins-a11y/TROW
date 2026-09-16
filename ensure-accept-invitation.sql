-- Ensure accept_invitation RPC exists.
-- Idempotent: safe to re-run.

CREATE OR REPLACE FUNCTION public.accept_invitation(p_token TEXT)
RETURNS VOID AS $$
DECLARE
  v_invitation RECORD;
  v_user_id UUID;
BEGIN
  SELECT * INTO v_invitation
  FROM public.invitations
  WHERE token = p_token
    AND status = 'pending'
    AND expires_at > NOW();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Convite inválido ou expirado';
  END IF;

  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Não autenticado';
  END IF;

  -- Add user to team (or update role if already a member)
  INSERT INTO public.team_members (team_id, user_id, role_id, assigned_by)
  VALUES (v_invitation.team_id, v_user_id, v_invitation.role_id, v_invitation.invited_by)
  ON CONFLICT (team_id, user_id) DO UPDATE SET role_id = EXCLUDED.role_id;

  -- Mark invitation as accepted
  UPDATE public.invitations SET status = 'accepted' WHERE id = v_invitation.id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.accept_invitation(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.accept_invitation(TEXT) TO anon;

-- Quick checks
DO $$
BEGIN
  -- Confirm team_members has UNIQUE(team_id, user_id)
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes
    WHERE schemaname = 'public'
      AND tablename = 'team_members'
      AND indexdef LIKE '%UNIQUE%team_id%user_id%'
  ) THEN
    RAISE NOTICE 'WARNING: team_members does not have UNIQUE(team_id, user_id). The ON CONFLICT in accept_invitation will fail.';
  ELSE
    RAISE NOTICE 'OK: team_members has UNIQUE(team_id, user_id)';
  END IF;

  -- Confirm accept_invitation function exists
  IF EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public' AND p.proname = 'accept_invitation'
  ) THEN
    RAISE NOTICE 'OK: accept_invitation function is registered';
  ELSE
    RAISE NOTICE 'WARNING: accept_invitation function missing';
  END IF;
END $$;
