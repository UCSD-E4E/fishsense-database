SELECT create_user(
    %(username)s,
    %(email)s,
    %(created_utc)s,
    %(last_login_utc)s,
    %(oauth_id)s,
    NULL::%(first_name)s,
    NULL::%(last_name)s,
    NULL::%(DOB)s,
    NULL::%(organization_name)s
) AS result;