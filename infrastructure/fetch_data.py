import traceback
from azure.identity import DefaultAzureCredential
import psycopg2
from psycopg2 import OperationalError, ProgrammingError, DatabaseError

def log_error(error_message):
    """Centralized error logging"""
    with open(LOG_PATH, "a") as log:
        log.write(f"ERROR: {error_message}\n")
        log.write(traceback.format_exc() + "\n")

def get_azure_ad_token():
    """Acquire Azure AD access token for PostgreSQL"""
    credential = DefaultAzureCredential()
    return credential.get_token("https://ossrdbms-aad.database.windows.net/.default").token

# configuration
DB_HOST = "drupal-db-srv.postgres.database.azure.com"
DB_NAME = "drupal"
DB_USER = "Drupal-Scale-Set"
LOG_PATH = "/var/log/python_error.log"
MODULES_FILE = "/drupal/modules.txt"
GRADES_FILE = "/drupal/grades.txt"

conn = None

try:
    # get Azure AD token
    try:
        aad_token = get_azure_ad_token()
    except Exception as token_error:
        log_error(f"Token Acquisition Error: {str(token_error)}")
        raise

    # connect using Azure AD token
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            dbname=DB_NAME,
            user=DB_USER,
            password=aad_token,
            sslmode="require",
            connect_timeout=10
        )
    except OperationalError as op_err:
        log_error(f"Connection Error: {str(op_err)}")
        raise

    # database operations
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM cs_modules;")
            with open(MODULES_FILE, "w") as file:
                for module in cur.fetchall():
                    file.write(f"Module ID: {module[0]} | Name: {module[1]}\n")

            cur.execute("SELECT * FROM grades;")
            with open(GRADES_FILE, "w") as file:
                for grade in cur.fetchall():
                    file.write(f"Module ID: {grade[0]} | Grade: {grade[1]}\n")

    except (ProgrammingError, DatabaseError) as db_exec_error:
        log_error(f"Database Execution Error: {str(db_exec_error)}")
        raise

except Exception as e:
    log_error(f"Unexpected Error: {str(e)}")
    raise

finally:
    if conn:
        try:
            conn.close()
        except Exception as close_error:
            log_error(f"Connection Close Error: {str(close_error)}")

