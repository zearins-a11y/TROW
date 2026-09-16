-- Diagnóstico em UM único SELECT
-- Cole no Supabase SQL Editor, rode e me envie o print

SELECT
  (SELECT COUNT(*) FROM auth.users)                              AS auth_users,
  (SELECT COUNT(*) FROM user_profiles)                           AS profiles,
  (SELECT COUNT(*) FROM workspaces)                              AS workspaces,
  (SELECT COUNT(*) FROM projects)                                AS projects,
  (SELECT COUNT(*) FROM teams)                                   AS teams,
  (SELECT COUNT(*) FROM team_members)                            AS memberships,
  (SELECT COUNT(*) FROM invitations)                             AS invitations,
  (SELECT COUNT(*) FROM audit_logs)                              AS audit_logs,
  (SELECT COUNT(*) FROM role_permissions)                        AS role_perms,
  (SELECT COUNT(*) FROM roles)                                   AS roles;
