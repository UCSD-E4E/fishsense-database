SELECT create_user(
    :'username',
    :'email',
    :'created_utc',
    :'last_login_utc',
    :'oauth_id',
    :'first_name',
    :'last_name',
    :'DOB',
    :'organization_name'
    -- might need to change to %(___)s for psycopg2
) AS result;
