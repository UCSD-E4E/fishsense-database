SELECT create_user(
    %(username)s,
    %(email)s,
    %(created_utc)s,
    %(last_login_utc)s,
    %(first_name)s,
    %(last_name)s,
    %(DOB)s,
    %(organization_name)s
) AS result;