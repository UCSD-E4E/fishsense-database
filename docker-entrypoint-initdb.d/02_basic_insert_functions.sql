CREATE OR REPLACE FUNCTION insert_user (
    username_param TEXT,
    email_param TEXT,
    created_param BIGINT,
    last_login_param BIGINT,
    oauth_id_param TEXT,
    first_name_param TEXT,
    last_name_param TEXT,
    DOB_param BIGINT
)
RETURNS BIGINT AS $$
DECLARE
    user_added RECORD;
BEGIN

    INSERT INTO users (username, email, created_utc, last_login_utc, oauth_id, first_name, last_name, DOB)
    VALUES (username_param, 
            email_param, 
            created_param, 
            last_login_param, 
            oauth_id_param, 
            first_name_param, 
            last_name_param,
            DOB_param)
    RETURNING * INTO user_added;

    RETURN user_added;

EXCEPTION
    WHEN unique_violation THEN
        RETURN NONE;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_storage_pool (
    storage_name_param TEXT
)
RETURNS BIGINT as $$
DECLARE
    storage_id BIGINT;
BEGIN
    
    INSERT INTO storage_pools (storage_name)
    VALUES (storage_name_param)
    RETURNING id INTO storage_id;

    RETURN storage_id;

EXCEPTION
    WHEN unique_violation THEN
        RETURN -1;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION insert_organization (
    organization_name_param TEXT
)
RETURNS BIGINT as $$
DECLARE
    organization_added RECORD;
BEGIN
    
    INSERT INTO organizations (organization_name)
    VALUES (organization_name_param)
    RETURNING * INTO organization_added;

    RETURN organization_added;

EXCEPTION
    WHEN unique_violation THEN
        RETURN NONE;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_org_user_mapping (
    organization_id_param BIGINT,
    user_id_param BIGINT
)
RETURNS BIGINT as $$
DECLARE
    org_user_map_id BIGINT;
BEGIN
    
        INSERT INTO organization_users_map (organization_id, user_id)
        VALUES (organization_id_param, user_id_param)
        RETURNING id INTO org_user_map_id;
    
        RETURN org_user_map_id;

EXCEPTION
    WHEN unique_violation THEN
        RETURN -1;

END;   
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_device_class (
    device_name_param TEXT,
    laser_id_param BIGINT
)
RETURNS BIGINT as $$
DECLARE
    device_class_id BIGINT;

BEGIN
    
    INSERT INTO device_class (device_name, laser_id)
    VALUES (device_name_param, laser_id_param)
    RETURNING id INTO device_class_id;

    RETURN device_class_id;

EXCEPTION
    WHEN unique_violation THEN
        RETURN -1;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_device (
    class_id_param BIGINT,
    lens_calibration_id_param BIGINT
)
RETURNS BIGINT as $$
DECLARE
    device_id BIGINT;

BEGIN
        
    INSERT INTO devices (class_id, lens_calibration_id)
    VALUES (class_id_param, lens_calibration_id_param)
    RETURNING id INTO device_id;

    RETURN device_id;

EXCEPTION
    WHEN unique_violation THEN
        RETURN -1;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_deployment (
    laser_calibration_id_param BIGINT,
    organization_id_param BIGINT,
    deployment_name_param TEXT,
    latitude_param FLOAT,
    longitude_param FLOAT,
    timestamp_utc_param BIGINT,
    notes_param TEXT
)
RETURNS BIGINT as $$
DECLARE
    deployment_id BIGINT;

BEGIN

    INSERT INTO deployments (laser_calibration_id, organization_id, deployment_name, latitude, longitude, timestamp_utc, notes)
    VALUES (laser_calibration_id_param, 
            organization_id_param, 
            deployment_name_param, 
            latitude_param, 
            longitude_param, 
            timestamp_utc_param, 
            notes_param)
    RETURNING id INTO deployment_id;

    RETURN deployment_id;

EXCEPTION
    WHEN unique_violation THEN
        RETURN -1;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_lens_calibration (
    metadata_param JSONB
)
RETURNS BIGINT as $$
DECLARE
    lens_calibration_id BIGINT;

BEGIN
    
        INSERT INTO lens_calibrations (metadata)
        VALUES (metadata_param)
        RETURNING id INTO lens_calibration_id;
    
        RETURN lens_calibration_id;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_laser_calibration (
    metadata_param JSONB
)
RETURNS BIGINT as $$
DECLARE
    laser_calibration_id BIGINT;

BEGIN
    
    INSERT INTO laser_calibrations (metadata)
    VALUES (metadata_param)
    RETURNING id INTO laser_calibration_id;

    RETURN laser_calibration_id;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_laser_device (
    device_name_param TEXT,
    laser_calibration_id_param BIGINT
)
RETURNS BIGINT as $$
DECLARE
    laser_device_id BIGINT;

BEGIN
        
    INSERT INTO laser_devices (device_name, laser_calibration_id)
    VALUES (device_name_param, laser_calibration_id_param)
    RETURNING id INTO laser_device_id;

    RETURN laser_device_id;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_file (
    file_path_param TEXT,   
    mime_param TEXT,
    captured_param BIGINT,
    upload_param BIGINT,
    uploader_param BIGINT,
    photographer_param BIGINT,
    device_param BIGINT,
    storage_pool_param BIGINT,
    deployment_param BIGINT
)
RETURNS BIGINT as $$
DECLARE
    file_id BIGINT;

BEGIN
        
        INSERT INTO files (file_path, 
                            mime_type, 
                            captured_date_utc, 
                            upload_date_utc, 
                            uploader_id, 
                            photographer_id, 
                            device_id, 
                            storage_pool_id, 
                            deployment_id)
        VALUES (file_path_param, 
                mime_param, 
                captured_param, 
                upload_param, 
                uploader_param, 
                photographer_param, 
                device_param, 
                storage_pool_param, 
                deployment_param)
        RETURNING id INTO file_id;
    
        RETURN file_id;

EXCEPTION
    WHEN unique_violation THEN
        RETURN -1;
    
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_frame (
    file_id_param BIGINT,
    frame_index_param BIGINT,
    storage_pool_param BIGINT
)
RETURNs BIGINT AS $$
DECLARE
    frame_id BIGINT;

BEGIN

    INSERT INTO frames (file_id, frame_index, storage_pool_id)
    VALUES (file_id_param, frame_index_param, storage_pool_param)
    RETURNING id INTO frame_id;

    RETURN frame_id;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_laser_detection (
    frame_id_param BIGINT,
    x_param FLOAT,
    y_param FLOAT,
    generated_param BIGINT
)
RETURNS BIGINT as $$
DECLARE
    laser_detection_id BIGINT;

BEGIN

    INSERT INTO laser_detection (frame_id, x, y, generated_time_utc)
    VALUES (frame_id_param, x_param, y_param, generated_param)
    RETURNING id INTO laser_detection_id;

    RETURN laser_detection_id;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_fish (
    mask_id_param BIGINT,
    head_x_param FLOAT,
    head_y_param FLOAT,
    tail_x_param FLOAT,
    tail_y_param FLOAT,
    species_id_param BIGINT,
    fish_length_param FLOAT,
    generated_time_param BIGINT,
    face_id_param BIGINT
)
RETURNS BIGINT as $$
DECLARE
    fish_id BIGINT;

BEGIN

    INSERT INTO fish (mask_id, 
                    head_x, 
                    head_y, 
                    tail_x, 
                    tail_y, 
                    species_id, 
                    fish_length_cm, 
                    generated_time_utc, 
                    face_id)
    VALUES (mask_id_param, 
            head_x_param, 
            head_y_param, 
            tail_x_param, 
            tail_y_param, 
            species_id_param, 
            fish_length_param, 
            generated_time_param,
            face_id_param)
    RETURNING id INTO fish_id;

    RETURN fish_id;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_fish_mask (
    frame_id_param BIGINT,
    mask_path_param TEXT,
    generated_param BIGINT
)
RETURNS BIGINT as $$
DECLARE
    fish_mask_id BIGINT;

BEGIN

    INSERT INTO fish_masks (frame_id, mask_path, generated_time_utc)
    VALUES (frame_id_param, mask_path_param, generated_param)
    RETURNING id INTO fish_mask_id;

    RETURN fish_mask_id;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_fish_identity (
    name_param TEXT,
    fingerprint_param JSONB,
    external_ref_param JSONB
)
RETURNS BIGINT as $$
DECLARE
    identity_id BIGINT;

BEGIN

    INSERT INTO fish_identity (identity_name, fingerprint, external_reference)
    VALUES (name_param, fingerprint_param, external_ref_param)
    RETURNING id INTO identity_id;

    return identity_id;

EXCEPTION
    WHEN unique_violation THEN
        return -1;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_species (
    name_param TEXT
)
RETURNS BIGINT as $$
DECLARE
    species_id BIGINT;
BEGIN

    INSERT INTO species (species_name)
    VALUES(name_param)
    RETURNING id INTO species_id;

    RETURN species_id;

EXCEPTION
    WHEN unique_violation THEN
        RETURN -1;

END;
$$ LANGUAGE plpgsql;







