INSERT INTO file (file_path, mime_type, captured_date_utc, upload_date_utc, uploader_id, photographer_id, device_id, storage_pool_id, deployment_id)
VALUES (%(file_path)s, %(mime_type)s, %(captured_date_utc)s, %(upload_date_utc)s, %(uploader_id)s, %(photographer_id)s, %(device_id)s, %(storage_pool_id)s, %(deployment_id)s);