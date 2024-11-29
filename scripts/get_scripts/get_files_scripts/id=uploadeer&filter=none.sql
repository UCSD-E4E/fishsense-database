SELECT * 
FROM files 
WHERE uploader_id = %(user_id)s;
