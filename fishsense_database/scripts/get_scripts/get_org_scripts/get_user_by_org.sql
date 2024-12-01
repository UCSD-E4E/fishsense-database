SELECT u.*
FROM users u
JOIN organization_users_map oum ON u.id = oum.user_id
WHERE oum.organization_id = %(organization_id)s;