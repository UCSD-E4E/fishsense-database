CREATE TABLE IF NOT EXISTS lasers (
    id BIGSERIAL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS lens_calibrations (
    id BIGSERIAL PRIMARY KEY,
    metadata BYTEA NOT NULL
);

CREATE TABLE IF NOT EXISTS laser_calibrations (
    id BIGSERIAL PRIMARY KEY,
    metadata BYTEA NOT NULL
);

CREATE TABLE IF NOT EXISTS organizations (
    id BIGSERIAL PRIMARY KEY,
    organization_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created_utc BIGINT NOT NULL,
    last_login_utc BIGINT,
    oauth_id TEXT,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    DOB VARCHAR(150)
);

CREATE TABLE IF NOT EXISTS storage_pools (
    id BIGSERIAL PRIMARY KEY,
    storage_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS device_class (
    id BIGSERIAL PRIMARY KEY,
    device_name VARCHAR(255) NOT NULL,
    laser_id BIGINT REFERENCES lasers(id)
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
);

CREATE TABLE IF NOT EXISTS deployments (
    id BIGSERIAL PRIMARY KEY,
    laser_calibration_id BIGINT REFERENCES laser_calibrations(id),
    organization_id BIGINT REFERENCES organizations(id) NOT NULL,
    deployment_name VARCHAR(255) NOT NULL,
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    timestamp_utc BIGINT NOT NULL,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS files (
    id BIGSERIAL PRIMARY KEY,
    file_path TEXT NOT NULL,
    mime_type TEXT NOT NULL,
    captured_date_utc BIGINT,
    upload_date_utc BIGINT NOT NULL,
    uploader_id BIGINT REFERENCES users(id),
    photographer_id BIGINT REFERENCES users(id),
    device_id BIGINT REFERENCES devices(id),
    storage_pool_id BIGINT REFERENCES storage_pools(id),
    deployment_id BIGINT REFERENCES deployments(id)
);

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
    gen_utc BIGINT NOT NULL
);

CREATE TABLE IF NOT EXISTS fish_masks (
    id BIGSERIAL PRIMARY KEY,
    frame_id BIGINT REFERENCES frames(id) NOT NULL,
    mask_path TEXT NOT NULL,
    gen_utc BIGINT NOT NULL
);

CREATE TABLE IF NOT EXISTS species (
    id BIGSERIAL PRIMARY KEY,
    species_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS fish_identity (
    id BIGSERIAL PRIMARY KEY,
    identity_name VARCHAR(255) NOT NULL,
    fingerprint BYTEA NOT NULL,
    external_reference TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS fish (
    id BIGSERIAL PRIMARY KEY,
    mask_id BIGINT REFERENCES fish_masks(id) NOT NULL,
    head_x FLOAT NOT NULL,
    head_y FLOAT NOT NULL,
    tail_x FLOAT NOT NULL,
    tail_y FLOAT NOT NULL,
    species_id BIGINT REFERENCES species(id) NOT NULL,
    fish_length_cm FLOAT NOT NULL,
    gen_utc BIGINT NOT NULL,
    face_id BIGINT REFERENCES fish_identity(id) NOT NULL
);
