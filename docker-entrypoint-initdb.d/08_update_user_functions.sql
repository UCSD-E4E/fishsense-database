CREATE OR REPLACE FUNCTION update_last_login (
    user_id_param TEXT,
    last_login_utc_param BIGINT
)
RETURNS BOOLEAN as $$
BEGIN
    UPDATE users
    SET last_login_utc = last_login_utc_param
    WHERE id = user_id_param;

    RETURN TRUE;
    
END;
$$ LANGUAGE plpgsql;
