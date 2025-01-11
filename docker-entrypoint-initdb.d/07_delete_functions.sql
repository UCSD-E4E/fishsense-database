CREATE OR REPLACE FUNCTION delete_user (
    email_param TEXT
)
RETURNS BOOLEAN as $$
DECLARE
    success BIGINT;
BEGIN 

    SELECT u_id FROM get_user_by_email(email_param) INTO success;

    DELETE FROM organization_users_map
    WHERE user_id = success;

    DELETE FROM users
    WHERE email = email_param
    RETURNING id INTO success;

    IF success = 0 THEN
        RAISE EXCEPTION 'User not found';
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
    
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_organization (
    organization_name_param TEXT
)
RETURNS BOOLEAN as $$
DECLARE
    success BIGINT;
    row_count BIGINT;
    org_id BIGINT;
BEGIN

    SELECT o_id FROM get_org(organization_name_param) INTO org_id;

    SELECT COUNT(*) INTO row_count
    FROM get_mapping_by_org(org_id);

    IF row_count > 0 THEN
        RAISE EXCEPTION 'Organization has users';
        RETURN FALSE;
    END IF;

    DELETE FROM organizations
    WHERE organization_name = organization_name_param
    RETURNING id INTO success;

    IF success = 0 THEN
        RAISE EXCEPTION 'Organization not found';
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;