INSERT INTO users (username, email, created_utc, last_login_utc, oauth_id, first_name, last_name, DOB)
VALUES (%(username)s, %(email)s, %(created_utc)s, %(last_login_utc)s, %(oauth_id)s, %(first_name)s, %(last_name)s, %(DOB)s);
