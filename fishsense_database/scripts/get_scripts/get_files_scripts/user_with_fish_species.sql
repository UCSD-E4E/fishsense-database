SELECT files.*
FROM files
JOIN frames ON files.id = frames.file_id
JOIN fish_masks ON frames.id = fish_masks.frame_id
JOIN fish ON fish_masks.id = fish.mask_id
WHERE (files.uploader_id = %(user_id)s OR files.photographer_id = %(user_id)s) AND fish.species_id = %(species_id)s;
