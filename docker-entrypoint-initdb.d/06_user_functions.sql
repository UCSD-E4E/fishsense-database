
CREATE OR REPLACE FUNCTION create_user (
    username_param TEXT,
    email_param TEXT,
    created_utc_param BIGINT,
    last_login_utc_param BIGINT,
    oauth_id_param TEXT,
    first_name_param TEXT,
    last_name_param TEXT,
    DOB_param BIGINT,
    organization_name_param TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
    user_id BIGINT;
    org_id BIGINT;
    result BIGINT; 
BEGIN
    SELECT insert_user(
        username_param,
        email_param,
        created_utc_param,
        last_login_utc_param,
        oauth_id_param,
        first_name_param,
        last_name_param,
        DOB_param
    ) INTO user_id;

    IF user_id = -1 THEN
        RAISE EXCEPTION 'User Unique Violation';
        RETURN FALSE;
    END IF;
    
    IF organization_name_param IS NOT NULL THEN 

        SELECT o_id
        FROM get_org(organization_name_param)
        INTO org_id;

        IF org_id IS NULL THEN
            RAISE NOTICE 'Organization not found';
        ELSE
            SELECT insert_org_user_mapping(org_id, user_id) INTO result;

            IF result IS NULL THEN
                RAISE EXCEPTION 'Organization User Mapping not created: Invalid Input';
                RETURN FALSE;
            END IF;
        END IF;
    
    END IF;

    SELECT o_id
    FROM get_org('default')
    INTO org_id;

    SELECT insert_org_user_mapping(org_id, user_id) INTO result;

    IF result IS NULL THEN
        RAISE EXCEPTION 'Organization User Mapping default not created';
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_user_to_org (
    email_param TEXT,
    organization_name_param TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
    user_id BIGINT;
    org_id BIGINT;
    result BIGINt;
BEGIN
    
    SELECT u_id
    FROM get_user_by_email(email_param)
    INTO user_id;

    IF user_id IS NULL THEN
        RAISE EXCEPTION 'User not found';
        RETURN FALSE;
    END IF;

    SELECT o_id
    FROM get_org(organization_name_param)
    INTO org_id;

    IF org_id IS NULL THEN
        RAISE EXCEPTION 'Organization not found';
        RETURN FALSE;
    END IF;

    SELECT insert_org_user_mapping(org_id, user_id) INTO result;

    IF result IS NULL THEN
        RAISE EXCEPTION 'Organization User Mapping not created: Invalid Input';
        RETURN FALSE;
    END IF;

    RETURN TRUE;

END;
$$ LANGUAGE plpgsql;
