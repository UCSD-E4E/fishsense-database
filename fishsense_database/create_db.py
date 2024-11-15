from database import Database

def create_db():
    database = Database()
    database.init()
    
    return database
    
database = create_db()