CREATE TABLE IF NOT EXISTS laser_devices ( -- Update to more descriptive name. Is this laser device or laser points?
    id BIGSERIAL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS lens_calibrations ( -- This should have a jsonb for the actual calibration data
    id BIGSERIAL PRIMARY KEY,
    metadata JSONB NOT NULL
);

CREATE TABLE IF NOT EXISTS laser_calibrations ( -- This should have a JSONB for the actual calibration data∂1
    id BIGSERIAL PRIMARY KEY,
    metadata JSONB NOT NULL
);

CREATE TABLE IF NOT EXISTS organizations (
    id BIGSERIAL PRIMARY KEY,
    organization_name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE, -- emails have a max length of 320, local part is 64 char, domain part is 255 char, @ is one, total is 64 + 1 + 255 = 320, rfc3696
    created_utc BIGINT NOT NULL,
    last_login_utc BIGINT,
    oauth_id TEXT UNIQUE,
    first_name TEXT,
    last_name TEXT,
    DOB BIGINT
); -- maybe set of username and email + more is unique

CREATE TABLE IF NOT EXISTS storage_pools (
    id BIGSERIAL PRIMARY KEY,
    storage_name TEXT NOT NULL UNIQUE 
);

CREATE TABLE IF NOT EXISTS device_class (
    id BIGSERIAL PRIMARY KEY,
    device_name TEXT NOT NULL,
    laser_id BIGINT REFERENCES laser_devices(id)
);

CREATE TABLE IF NOT EXISTS devices (
    id BIGSERIAL PRIMARY KEY,
    class_id BIGINT REFERENCES device_class(id) NOT NULL,
    lens_calibration_id BIGINT REFERENCES lens_calibrations(id)
);

CREATE TABLE IF NOT EXISTS organization_users_map (
    id BIGSERIAL PRIMARY KEY,
    organization_id BIGINT REFERENCES organizations(id) NOT NULL,
    user_id BIGINT REFERENCES users(id) NOT NULL
); -- set of user_id and org_id is unique, 

CREATE TABLE IF NOT EXISTS deployments (
    id BIGSERIAL PRIMARY KEY,
    laser_calibration_id BIGINT REFERENCES laser_calibrations(id),
    organization_id BIGINT REFERENCES organizations(id) NOT NULL,
    deployment_name TEXT NOT NULL,
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    timestamp_utc BIGINT NOT NULL,
    notes TEXT
); -- set of org_id and name is unique, multiple indices?

CREATE TABLE IF NOT EXISTS files (
    id BIGSERIAL PRIMARY KEY,
    file_path TEXT NOT NULL,
    mime_type TEXT NOT NULL, -- mimetypes have a max length of 255 per rfs 4288
    captured_date_utc BIGINT,
    upload_date_utc BIGINT NOT NULL,
    uploader_id BIGINT REFERENCES users(id),
    photographer_id BIGINT REFERENCES users(id),
    device_id BIGINT REFERENCES devices(id),
    storage_pool_id BIGINT REFERENCES storage_pools(id),
    deployment_id BIGINT REFERENCES deployments(id)
); -- file path unique

CREATE TABLE IF NOT EXISTS frames (
    id BIGSERIAL PRIMARY KEY,
    file_id BIGINT REFERENCES files(id) NOT NULL,
    frame_index BIGINT NOT NULL,
    storage_pool_id BIGINT REFERENCES storage_pools(id) NOT NULL
);

CREATE TABLE IF NOT EXISTS laser_detection (
    id BIGSERIAL PRIMARY KEY,
    frame_id BIGINT REFERENCES frames(id) NOT NULL,
    x FLOAT NOT NULL,
    y FLOAT NOT NULL,
    generated_time_utc BIGINT NOT NULL 
);

CREATE TABLE IF NOT EXISTS fish_masks (
    id BIGSERIAL PRIMARY KEY,
    frame_id BIGINT REFERENCES frames(id) NOT NULL,
    mask_path TEXT NOT NULL,
    generated_time_utc BIGINT NOT NULL
);

CREATE TABLE IF NOT EXISTS species (
    id BIGSERIAL PRIMARY KEY,
    species_name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS fish_identity (
    id BIGSERIAL PRIMARY KEY,
    identity_name TEXT NOT NULL,
    fingerprint JSONB NOT NULL,
    external_reference JSONB NOT NULL
); -- fingerprint, external_reference  should be unique

CREATE TABLE IF NOT EXISTS fish (
    id BIGSERIAL PRIMARY KEY, -- BIGSERIAL = BIGINT AUTOINCREMENT
    mask_id BIGINT REFERENCES fish_masks(id) NOT NULL,
    head_x FLOAT NOT NULL,
    head_y FLOAT NOT NULL,
    tail_x FLOAT NOT NULL,
    tail_y FLOAT NOT NULL,
    species_id BIGINT REFERENCES species(id) NOT NULL,
    fish_length_cm FLOAT NOT NULL,
    generated_time_utc BIGINT NOT NULL,
    face_id BIGINT REFERENCES fish_identity(id) -- this should probably be nullable?  should we have an unknown fish face?
); -- split later

-- check uniqiuness constraints

-- VARCHAR to TEXT xs