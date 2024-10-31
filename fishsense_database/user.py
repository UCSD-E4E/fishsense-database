from database import Database

def get_user(user, email) -> list:
    """
    Get specific users from the database.
    """
    with Database() as db:
        if user:
            db._cursor.execute(
                """
                SELECT * FROM users
                WHERE username = %s;
                """,
                (user)
            )
            
        elif email:
            db._cursor.execute(
                """
                SELECT * FROM users
                WHERE email = %s;
                """,
                (email)
            )
        else:
            raise ValueError("Must provide either a username or email.")
            return None
        
        return db._cursor.fetchall()

def create_user(username: str, email: str)-> int:
    """
    Create a new user in the database.
    """
    with Database() as db:
        
        existing_check = get_user(username, email)
        if len(existing_check) > 0:
            print("User already exists")
            user_id = existing_check[0][0]
            raise ValueError("User already exists")
            return user_id
        
        db._cursor.execute(
            """
            INSERT INTO users (username, email)
            VALUES (%s, %s)
            RETURNING id;
            """,
            (username, email)
        )
        
        user_id = db._cursor.fetchone()[0]
        db._connection.commit()
        return user_id
        
def update_user(username: str, email: str) -> None:
    """
    Update a user in the database.
    """
    
    if not username and not email:
        raise ValueError("Must provide a username and email.")
        return False
        
    with Database() as db:
        
        existing_check = get_user(username, email)
        if len(existing_check) == 0:
            print("User does not exist")
            return False
        
        if not username:
            username = existing_check[0][1]
            
        elif not email:
            email = existing_check[0][2]
        
        user_id = existing_check[0][0]
        
        db._cursor.execute(
            """
            UPDATE users
            SET username = %s, email = %s
            WHERE id = %s;
            """,
            (username, email, user_id)
        )
        db._connection.commit()
        return True
    
def delete_user(username:str, email:str) -> bool:
    """
    Delete a user from the database.
    """
    existing_check = get_user(username, email)
    if len(existing_check) == 0:
        print("User does not exist")
        raise ValueError("User does not exist")
        return False
    
    with Database() as db:
        db._cursor.execute(
            """
            DELETE FROM users
            WHERE username = %s;
            """,
            (username)
        )
        db._connection.commit()
        return True