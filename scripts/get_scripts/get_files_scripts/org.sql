SELECT files.*
FROM files
JOIN deployments ON files.deployment_id = deployments.id
WHERE deployments.organization_id = %(organization_id)s;
