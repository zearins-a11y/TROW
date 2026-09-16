-- Seed initial data: roles and a default workspace for any user

-- First, insert default system roles (idempotent)
INSERT INTO roles (id, name, description, is_system) VALUES
  (gen_random_uuid(), 'super_admin', 'Administrador total do workspace', true),
  (gen_random_uuid(), 'admin', 'Administrador do projeto', true),
  (gen_random_uuid(), 'gestor', 'Gestor de equipe', true),
  (gen_random_uuid(), 'membro', 'Membro de equipe', true),
  (gen_random_uuid(), 'viewer', 'Visualizador', true)
ON CONFLICT (name) DO NOTHING;

-- Default permissions for each role
INSERT INTO role_permissions (role_id, module_name, can_view, can_create, can_edit, can_delete, can_approve)
SELECT r.id, m.name, true, true, true, true, true
FROM roles r, (VALUES
  ('governance'), ('appeals'), ('strikes'), ('feedback'), ('council'),
  ('evaluations'), ('exceptions'), ('health'), ('regional')
) AS m(name)
WHERE r.name = 'super_admin'
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, module_name, can_view, can_create, can_edit, can_delete, can_approve)
SELECT r.id, m.name, true, true, true, true, true
FROM roles r, (VALUES
  ('governance'), ('appeals'), ('strikes'), ('feedback'), ('council'),
  ('evaluations'), ('exceptions'), ('health'), ('regional')
) AS m(name)
WHERE r.name = 'admin'
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, module_name, can_view, can_create, can_edit, can_delete, can_approve)
SELECT r.id, m.name,
  true,
  m.name IN ('governance','feedback','council','appeals','strikes'),
  m.name IN ('governance','feedback','council','appeals'),
  false,
  m.name IN ('governance','appeals')
FROM roles r, (VALUES
  ('governance'), ('appeals'), ('strikes'), ('feedback'), ('council'),
  ('evaluations'), ('exceptions'), ('health'), ('regional')
) AS m(name)
WHERE r.name = 'gestor'
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, module_name, can_view, can_create, can_edit, can_delete, can_approve)
SELECT r.id, m.name,
  true,
  m.name IN ('feedback'),
  m.name IN ('feedback'),
  false, false
FROM roles r, (VALUES
  ('governance'), ('appeals'), ('strikes'), ('feedback'), ('council'),
  ('evaluations'), ('exceptions'), ('health'), ('regional')
) AS m(name)
WHERE r.name = 'membro'
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, module_name, can_view, can_create, can_edit, can_delete, can_approve)
SELECT r.id, m.name,
  true, false, false, false, false
FROM roles r, (VALUES
  ('governance'), ('appeals'), ('strikes'), ('feedback'), ('council'),
  ('evaluations'), ('exceptions'), ('health'), ('regional')
) AS m(name)
WHERE r.name = 'viewer'
ON CONFLICT DO NOTHING;

SELECT 'Roles and permissions seeded!' AS status,
       (SELECT COUNT(*) FROM roles) AS roles_count,
       (SELECT COUNT(*) FROM role_permissions) AS permissions_count;
