from psycopg2 import IntegrityError
from database import Database

def get_user(user=None, email=None) -> list:
    """
    Get specific users from the database.
    """
    with Database() as db:
        try:
            if user is not None:
                db._cursor.execute(
                    """
                    SELECT * FROM users
                    WHERE username = %s;
                    """,
                    (user,)
                )
                
            elif email is not None:
                db._cursor.execute(
                    """
                    SELECT * FROM users
                    WHERE email = %s;
                    """,
                    (email,)
                )
            else:
                raise ValueError("Must provide either a username or email.")
            
            users = db._cursor.fetchall()
            print("Users: ", users)
            return users if users else []
        
        except ValueError:
            return None
        
def get_all_users() -> list:
    """
    Get all users from the database.
    """
    with Database() as db:
        db._cursor.execute(
            """
            SELECT * FROM users;
            """
        )
        return db._cursor.fetchall()

def create_user(username: str, email: str)-> int:
    """
    Create a new user in the database.
    """
    print("Creating user...")
    with Database() as db:
        
        try:
            print("Inserting user...")
            db._cursor.execute(
                """
                INSERT INTO users (username, email)
                VALUES (%s, %s)
                RETURNING id;
                """,
                (username, email)
            )
            print("User inserted.")
            user_id = db._cursor.fetchone()[0]
            print("User ID: ", user_id)
            db._connection.commit()
            return user_id

        except IntegrityError as e:
            print("IntegrityError caught in create_user: ", e)
            db._connection.rollback()  # Rollback the transaction
            return None
 

def update_user(username: str, email: str) -> None:
    """
    Update a user in the database.
    """
    
    if not username and not email:
        raise ValueError("Must provide a username and email.")
        
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
    
    with Database() as db:
        db._cursor.execute(
            """
            DELETE FROM users
            WHERE username = %s;
            """,
            (username,)
        )
        db._connection.commit()
        return True