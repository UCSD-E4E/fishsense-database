import datetime
from os import makedirs, getenv
import os
from pathlib import Path
from psycopg2 import IntegrityError, connect, OperationalError
from typing import Dict, Set

import backoff
import psycopg2
import git
from enum import Enum

class HTTP_CODES(Enum):
    GET = 1
    POST = 2
    PUT = 3
    PATCH = 4
    DELETE = 5

class Database:
    def __init__(self) -> None:
        # self._path = path # make a parameter, might need for mobile
        self._connection = None
        self._cursor = None
        self.time = None
        
    def load_config(self):
    
        config = {}

        config["db_host"] = getenv('DB_HOST')
        config["db_name"] = getenv('DB_NAME')
        config["db_user"] = getenv('DB_USER')
        config["db_password"] = getenv('DB_PASSWORD')
        config["db_port"] = getenv('DB_PORT', 5432)  

        return config

    def connect(self):
        
        config = self.load_config()
        print(f"Connecting to database at {config['db_host']} with user \"{config['db_user']}\"")
        
        try:
            conn = psycopg2.connect(
                host=config["db_host"],
                database=config["db_name"],
                user=config["db_user"],
                password=config["db_password"],
                port=config["db_port"]
                
            )
            print("Connected to the database")
            return conn
        except (psycopg2.DatabaseError, Exception) as e:
            print(e)
            return None
        
    def __enter__(self):
        # if not self._path.parent.exists():
        #     makedirs(self._path.parent.absolute().as_posix(), exist_ok=True)
        
        # directories = [
        #     './data',
        #     './results',
        #     './data/data_img',
        #     './data/laser_img',
        #     './data/lens_img',
        #     './results/laser_res',
        #     './results/lens_res'
        # ]
        
        # for directory in directories:
        #     os.makedirs(directory, exist_ok=True)

        

        self._connection = self.connect()
        self._cursor = self._connection.cursor()
    
        # self._create_metadata_table()
        
        # self._create_user_table()
        # self._create_data_table()
        # self._create_laser_table()
        # self._create_lens_table()

        return self

    def __exit__(self, exception_type, exception_value, exception_traceback):

        self._cursor.close()
        self._connection.close()

        return True
    
    def init(self):
        self._connection = self.connect()
        self._cursor = self._connection.cursor()
        
        self._cursor.execute(open("fishsense-database/scripts/init_database.sql", "r").read())
        self._connection.commit()
        
        self._cursor.close()
        self._connection.close()
        
        if not self.time:
            self.time = datetime.datetime(2020, 1, 1, 0, 0, 0, tzinfo=datetime.timezone.utc)  # Set self.time to January 1, 2020 0:00 UTC
        
    def delete(self):
        self._connection = self.connect()
        self._cursor = self._connection.cursor()
        
        self._cursor.execute(open("fishsense-database/scripts/delete_database.sql", "r").read())
        self._connection.commit()
        
        self._cursor.close()
        self._connection.close()
        
    def exec_script(self, file_path : str, http_code : int, parameters= None):
            
        try:  
            sql_script = open(file_path, "r").read()

            self._cursor.execute(sql_script, parameters)
            self._connection.commit()
            
            if http_code == HTTP_CODES.GET.value:
                return self._cursor.fetchall()

            else:
                return True
        
        except IntegrityError as e:
            print("IntegrityError caught with ", file_path, e)
            return None
        
        except Exception as e:
            print("Exception caught with ", file_path, e)
            return None
           
            
         
        


    # @backoff.on_exception(backoff.expo, OperationalError)
    # def _create_metadata_table(self):
    #     self._cursor.execute(
    #         """CREATE TABLE IF NOT EXISTS metadata
    #            (key text, value text)
    #         """
    #     )
    #     self._connection.commit()

    # @backoff.on_exception(backoff.expo, OperationalError)
    # def _create_data_table(self):
    #     self._cursor.execute(
    #         """CREATE TABLE IF NOT EXISTS data (
    #             id SERIAL PRIMARY KEY,
    #             name VARCHAR(100),
    #             image TEXT NOT NULL,
    #             uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    #             user_id INTEGER REFERENCES users(id),
    #             length FLOAT,
    #             units VARCHAR(50),
    #             dataset_name VARCHAR(100) UNIQUE NOT NULL,
    #             lens_calibration_id references lens_calibration(id),
    #             laser_calibration_id references laser_calibration(id),
    #             version_num INTEGER
    #         )
    #         """
    #     )
    #     self._connection.commit()
    
    # @backoff.on_exception(backoff.expo, OperationalError)
    # def _create_user_table(self):
    #     self._cursor.execute(
    #         """
    #         CREATE TABLE IF NOT EXISTS users (
    #             id SERIAL PRIMARY KEY,                  
    #             username VARCHAR(50) UNIQUE NOT NULL,   
    #             email VARCHAR(100) UNIQUE NOT NULL,   
    #             created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,                    
    #         )
    #         """
    #     )
    #     self._connection.commit()
    
    # @backoff.on_exception(backoff.expo, OperationalError)
    # def _create_laser_table(self):
    #     self._cursor.execute(
    #         """
    #         CREATE TABLE IF NOT EXISTS laser_calibration (
    #             id SERIAL PRIMARY KEY, 
    #             laser_path TEXT NOT NULL,
    #             result_path TEXT NOT NULL,
    #             dataset_name VARCHAR(100) UNIQUE NOT NULL,
    #             slate_scan TEXT NOT NULL,
    #             square_size FLOAT NOT NULL,
    #             rows INTEGER NOT NULL,
    #             cols INTEGER NOT NULL,
    #             created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    #             version_num INTEGER,
    #             user_id INTEGER REFERENCES users(id)                 
                                 
    #         )
    #         """
    #     )
    #     self._connection.commit()
        
    # @backoff.on_exception(backoff.expo, OperationalError)
    # def _create_lens_table(self):
    #     self._cursor.execute(
    #         """
    #         CREATE TABLE IF NOT EXISTS lens_calibration (
    #             id SERIAL PRIMARY KEY, 
    #             lens_path TEXT NOT NULL,
    #             result_path TEXT NOT NULL,
    #             dataset_name VARCHAR(100) UNIQUE NOT NULL,
    #             created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    #             version_num INTEGER,
    #             user_id INTEGER REFERENCES users(id)                
                                 
    #         )
    #         """
    #     )
    #     self._connection.commit()

    # @backoff.on_exception(backoff.expo, OperationalError)
    # def _insert_start_metadata(self):
    #     repo = git.Repo(".")
    #     sha = repo.head.object.hexsha

    #     self.insert_metadata(
    #         {
    #             "start_time": datetime.datetime.now(datetime.UTC),
    #             "git_commit": sha,
    #             # "version": fishsense_lite.__version__, //TODO fishsense lite version
    #         }
    #     )

    #     self._connection.commit()

    # @backoff.on_exception(backoff.expo, OperationalError)
    # def _insert_end_metadata(self):
    #     self.insert_metadata(
    #         {
    #             "end_time": datetime.datetime.now(datetime.UTC),
    #         }
    #     )

    #     self._connection.commit()

    # @backoff.on_exception(backoff.expo, OperationalError)
    # def insert_metadata(self, metadata: Dict[str, str]):
    #     self._cursor.executemany(
    #         "INSERT INTO metadata VALUES (?, ?)",
    #         list(metadata.items()),
    #     )
    #     self._connection.commit()

    # @backoff.on_exception(backoff.expo, OperationalError)
    # def insert_data(self, file: Path, result_status: ResultStatus, length: float):
    #     self._cursor.execute(
    #         "INSERT INTO data VALUES (?, ?, ?, ?)",
    #         (
    #             datetime.datetime.now(datetime.UTC),
    #             file.as_posix(),
    #             result_status.name,
    #             length,
    #         ),
    #     )
    #     self._connection.commit()

    # @backoff.on_exception(backoff.expo, OperationalError)
    # def get_files(self) -> Set[Path] | None:
    #     """Returns a set of Pathlib Paths which we have previously executed on.

    #     Returns:
    #         Set[Path] | None: A set of Pathlib paths we have previously executed on.
    #     """
    #     results = self._cursor.execute("SELECT file FROM data")

    #     if results:
    #         return {Path(row[0]) for row in results}

    #     return None