SELECT create_user(
    %(username)s,
    %(email)s,
    %(created_utc)s,
    %(last_login_utc)s,
    %(oauth_id)s,
    TEXT::%(first_name)s,
    TEXT::%(last_name)s,
    BIGINT::%(DOB)s,
    TEXT::%(organization_name)s
) AS result;