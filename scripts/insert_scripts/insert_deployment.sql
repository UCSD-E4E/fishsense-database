-- You will probably want a single query which does multiple adds to ensure that foreign keys are in place.

INSERT INTO deployments (laser_calibration_id, organization_id, deployment_name, latitude, longitude, timestamp_utc, notes)
VALUES (%(laser_calibration_id)s, %(organization_id)s, %(deployment_name)s, %(latitude)s, %(longitude)s, %(timestamp_utc)s, %(notes)s);