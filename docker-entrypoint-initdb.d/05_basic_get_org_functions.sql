CREATE OR REPLACE FUNCTION get_org (
    organization_name_param TEXT
)
RETURNS TABLE (
    o_id BIGINT,
    o_name TEXT
) AS $$
BEGIN

    RETURN QUERY
    SELECT id, organization_name
    FROM organizations
    WHERE organization_name = organization_name_param;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_mapping_by_org (
    organization_id_param BIGINT
)
RETURNS TABLE (
    om_id BIGINT,
    om_org_id BIGINT,
    om_user_id BIGINT
) AS $$
BEGIN

    RETURN QUERY
    SELECT id, organization_id, user_id
    FROM organization_users_map
    WHERE organization_id = organization_id_param;

END;
$$ LANGUAGE plpgsql;