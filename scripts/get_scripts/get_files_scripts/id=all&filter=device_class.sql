SELECT files.*
FROM files
JOIN devices ON files.device_id = devices.id
JOIN device_class ON devices.class_id = device_class.id
WHERE device_class.device_name = %(device_name)s 
AND (files.uploader_id = %(user_id)s OR files.photographer_id = %(user_id)s);
