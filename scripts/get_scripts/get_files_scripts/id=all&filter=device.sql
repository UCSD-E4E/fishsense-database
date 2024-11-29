SELECT * 
FROM files 
WHERE device_id = %(device_id)s AND (uploader_id = %(user_id)s OR photographer_id = %(user_id)s);