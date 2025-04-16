SELECT create_user(
    %(username)s,
    %(email)s,
    %(created_utc)s,
    %(last_login_utc)s,
    %(oauth_id)s,
    %(first_name)s::TEXT,
    %(last_name)s::TEXT,
    %(DOB)s::BIGINT,
    %(organization_name)s::TEXT
) AS result;