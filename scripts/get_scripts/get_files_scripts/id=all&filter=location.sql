SELECT files.*
FROM files
JOIN deployments ON files.deployment_id = deployments.id
WHERE deployments.latitude >= %(latitude_min)s AND deployments.latitude <= %(latitude_max)s AND deployments.longitude >= %(longitude_min)s AND deployments.longitude <= %(longitude_max)s
AND (files.uploader_id = %(user_id)s OR files.photographer_id = %(user_id)s);;
