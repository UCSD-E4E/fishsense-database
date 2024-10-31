from user import get_user
from database import Database

def upload_img(username: str, img: str, img_name:str, file_type:str, result_txt:str, length = None, email = None) -> bool:
    
    existing_check = get_user(username, email)
    if len(existing_check) == 0:
        print("User does not exist")
        raise ValueError("User does not exist")
    
    user_id = existing_check[0][0]
    
    with Database() as db:
        # db._insert_start_metadata()
        
        db._cursor.execute(
            """
            INSERT INTO data (user_id, image, img_name, file_type, length, result)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """,
            (user_id, img, img_name, file_type, length, result_txt)
        )
        db._connection.commit()
        
        # db._insert_end_metadata()
        
        return True
    
def get_all_user_imgs(username: str, email = None) -> list:
    
    existing_check = get_user(username, email)
    if len(existing_check) == 0:
        print("User does not exist")
        raise ValueError("User does not exist")
    
    user_id = existing_check[0][0]
    
    with Database() as db:
        
        db._cursor.execute(
            """
            SELECT img_name, file_type
            FROM data
            WHERE user_id = %s;
            """,
            (user_id)
        )
        
        return db._cursor.fetchall()
    

def get_img(username: str, img_name: str, email = None) -> bytes:
    
    existing_check = get_user(username, email)
    if len(existing_check) == 0:
        print("User does not exist")
        raise ValueError("User does not exist")
    
    user_id = existing_check[0][0]
    
    with Database() as db:
        
        db._cursor.execute(
            """
            SELECT image
            FROM data
            WHERE user_id = %s AND img_name = %s;
            """,
            (user_id, img_name)
        )
        
        img = db._cursor.fetchone()
        
        if img:
            return img[0]
        else:
            return None
        
        
def delete_img(username: str, img_name: str, email = None) -> bool:
    
    existing_check = get_user(username, email)
    if len(existing_check) == 0:
        print("User does not exist")
        raise ValueError("User does not exist")
    
    user_id = existing_check[0][0]
    
    with Database() as db:
        
        db._cursor.execute(
            """
            DELETE FROM data
            WHERE user_id = %s AND img_name = %s;
            """,
            (user_id, img_name)
        )
        db._connection.commit()
        
        return True
        
    
def update_length(username: str, img_name: str, length: float, email = None) -> bool:
    
    existing_check = get_user(username, email)
    if len(existing_check) == 0:
        print("User does not exist")
        raise ValueError("User does not exist")
    
    if get_img(username, img_name, email) is None:
        print("Image does not exist")
        raise ValueError("Image does not exist")
    
    if not length: 
        raise ValueError("Must provide a length.")
    
    user_id = existing_check[0][0]
    
    with Database() as db:
        
        db._cursor.execute(
            """
            UPDATE data
            SET length = %s
            WHERE user_id = %s AND img_name = %s;
            """,
            (length, user_id, img_name)
        )
        db._connection.commit()
        
        return True
    
