SELECT * 
FROM files 
WHERE deployment_id = %(deployment_id)s
AND (uploader_id = %(user_id)s OR photographer_id = %(user_id)s);
