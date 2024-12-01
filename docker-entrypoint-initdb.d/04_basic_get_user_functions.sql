CREATE OR REPLACE FUNCTION get_user_by_username(
    username_param TEXT
) RETURNS TABLE (
    u_id BIGINT,
    u_username TEXT,
    u_email TEXT,
    u_created BIGINT,
    u_last_login BIGINT,
    u_oauth_id TEXT,
    u_first_name TEXT,
    u_last_name TEXT,
    u_DOB BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        id,
        username,
        email,
        created_utc,
        last_login_utc,
        oauth_id,
        first_name,
        last_name,
        DOB
    FROM
        users
    WHERE
        username = username_param;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_user_by_email(
    email TEXT
) RETURNS TABLE (
    u_id BIGINT,
    u_username TEXT,
    u_email TEXT,
    u_created BIGINT,
    u_last_login BIGINT,
    u_oauth_id TEXT,
    u_first_name TEXT,
    u_last_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        id,
        username,
        email,
        created,
        last_login,
        oauth_id,
        first_name,
        last_name
    FROM
        users
    WHERE
        email = email;
END;
$$ LANGUAGE plpgsql;
