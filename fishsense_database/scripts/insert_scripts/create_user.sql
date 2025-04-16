SELECT create_user(
    %(username)s::TEXT,
    %(email)s::TEXT,
    %(created_utc)s::BIGINT,
    %(last_login_utc)s::BIGINT,
    %(oauth_id)s::TEXT,
    %(first_name)s::TEXT,
    %(last_name)s::TEXT,
    %(DOB)s::BIGINT,
    %(organization_name)s::TEXT
) AS result;