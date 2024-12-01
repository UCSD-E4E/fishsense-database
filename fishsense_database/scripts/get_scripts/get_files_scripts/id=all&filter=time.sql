SELECT * 
FROM files 
WHERE upload_date_utc >= %(start_date)s AND upload_date_utc <= %(end_date)s AND (uploader_id = %(user_id)s OR photographer_id = %(user_id)s);