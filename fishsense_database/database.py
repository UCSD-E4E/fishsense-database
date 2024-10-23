import datetime
from os import makedirs, getenv
from pathlib import Path
from psycopg2 import connect, cursor, OperationalError, Connection
from typing import Dict, Set

import backoff
import psycopg2
import git



class Database:
    def __init__(self, path: Path) -> None:
        self._path = path
        self._connection: Connection = None
        self._cursor: cursor = None
        
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
        if not self._path.parent.exists():
            makedirs(self._path.parent.absolute().as_posix(), exist_ok=True)

        self._connection = self.connect()
        self._cursor = self._connection.cursor()

        self._create_metadata_table()

        self._create_data_table()
        self._create_user_table()

        return self

    def __exit__(self, exception_type, exception_value, exception_traceback):

        self._cursor.close()
        self._connection.close()

        return True

    @backoff.on_exception(backoff.expo, OperationalError)
    def _create_metadata_table(self):
        self._cursor.execute(
            """CREATE TABLE IF NOT EXISTS metadata
               (key text, value text)
            """
        )
        self._connection.commit()

    @backoff.on_exception(backoff.expo, OperationalError)
    def _create_data_table(self):
        self._cursor.execute(
            """CREATE TABLE IF NOT EXISTS data
                id SERIAL PRIMARY KEY,
                name VARCHAR(100),
                image TEXT NOT NULL,
                file_type VARCHAR(50),
                uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                user_id INTEGER REFERENCES users(id),
                result TEXT,
                length FLOAT
            """
        )
        self._connection.commit()
    
    @backoff.on_exception(backoff.expo, OperationalError)
    def _create_user_table(self):
        self._cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS users (
                id SERIAL PRIMARY KEY,                  
                username VARCHAR(50) UNIQUE NOT NULL,   
                email VARCHAR(100) UNIQUE NOT NULL,   
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP                    
            )
            """
        )
        self._connection.commit()

    @backoff.on_exception(backoff.expo, OperationalError)
    def _insert_start_metadata(self):
        repo = git.Repo(".")
        sha = repo.head.object.hexsha

        self.insert_metadata(
            {
                "start_time": datetime.datetime.now(datetime.UTC),
                "git_commit": sha,
                # "version": fishsense_lite.__version__, //TODO fishsense lite version
            }
        )

        self._connection.commit()

    @backoff.on_exception(backoff.expo, OperationalError)
    def _insert_end_metadata(self):
        self.insert_metadata(
            {
                "end_time": datetime.datetime.now(datetime.UTC),
            }
        )

        self._connection.commit()

    @backoff.on_exception(backoff.expo, OperationalError)
    def insert_metadata(self, metadata: Dict[str, str]):
        self._cursor.executemany(
            "INSERT INTO metadata VALUES (?, ?)",
            list(metadata.items()),
        )
        self._connection.commit()

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