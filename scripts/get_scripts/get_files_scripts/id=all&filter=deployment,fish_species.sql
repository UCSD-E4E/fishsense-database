SELECT files.* -- do not use select *.  this can enable sql injection and change what is returned if the columns of the table change.
FROM files
JOIN frames ON files.id = frames.file_id
JOIN fish_masks ON frames.id = fish_masks.frame_id
JOIN fish ON fish_masks.id = fish.mask_id
JOIN deployments ON files.deployment_id = deployments.id
WHERE fish.species_id = %(species_id)s AND deployments.id = %(deployment_id)s
AND (files.uploader_id = %(user_id)s OR files.photographer_id = %(user_id)s);
