import azure.functions as func
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential
from azure.core.exceptions import HttpResponseError as KeyVaultHttpResponseError
import psycopg2
from psycopg2 import OperationalError, ProgrammingError, DatabaseError
import logging
import string
import secrets

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

@app.route(route="db_secret")
def db_user_secret_rotate(req: func.HttpRequest) -> func.HttpResponse:
    def generate_password(length=16):
        """Generate a random password with letters, digits, and punctuation."""
        alphabet = string.ascii_letters + string.digits + string.punctuation
        while True:
            password = ''.join(secrets.choice(alphabet) for i in range(length))
            if (any(c.islower() for c in password) and 
                any(c.isupper() for c in password) and
                any(c.isdigit() for c in password) and
                any(c in string.punctuation for c in password)):
                break
        return password
    
    # Initialize variables for proper cleanup
    connection = None
    key_vault_error = None
    db_error = None
    
    try:
        keyVaultName = "ZeDrupalVault"
        KVUri = f"https://{keyVaultName}.vault.azure.net"
        credential = DefaultAzureCredential()
        client = SecretClient(vault_url=KVUri, credential=credential)
        
        try:
            retrieved_secret = client.get_secret("postgres-db-password").value
        except KeyVaultHttpResponseError as kv_error:
            key_vault_error = f"Key Vault Error: {str(kv_error)}"
            logging.error(key_vault_error)
            return func.HttpResponse(key_vault_error, status_code=500)
        except Exception as kv_general_error:
            key_vault_error = f"Unexpected Key Vault Error: {str(kv_general_error)}"
            logging.error(key_vault_error)
            return func.HttpResponse(key_vault_error, status_code=500)

        # Database Connection
        try:
            connection = psycopg2.connect(
                user="drupaldbadm",
                password=retrieved_secret,
                host="drupal-db-server.postgres.database.azure.com", 
                port=5432, 
                database="postgres",
                sslmode='require'
            )
        except OperationalError as op_err:
            db_error = f"Connection Error: {str(op_err)}"
            logging.error(db_error)
            return func.HttpResponse(db_error, status_code=500)

        # Database Operation
        try:
            with connection.cursor() as cursor:
                # Generate a new secret
                new_secret = generate_password()
                client.set_secret("postgres-db-password", new_secret)
                # Use parameterized query to prevent SQL injection
                cursor.execute(
                    "ALTER ROLE drupaldbadm WITH PASSWORD %s;", 
                    (new_secret,)
                )
                # Add VALID_UNTIL clause if needed
                # cursor.execute("ALTER ROLE drupaldbadm WITH PASSWORD %s VALID UNTIL %s;", 
                #              (retrieved_secret, valid_until_date))
                
            connection.commit()
            
        except (ProgrammingError, DatabaseError) as db_exec_error:
            db_error = f"Database Execution Error: {str(db_exec_error)}"
            logging.error(db_error)
            return func.HttpResponse(db_error, status_code=500)
            
    except Exception as unexpected_error:
        error_msg = f"Unexpected Error: {str(unexpected_error)}"
        logging.error(error_msg)
        return func.HttpResponse(error_msg, status_code=500)
        
    finally:
        # Ensure proper cleanup of database connection
        if connection:
            try:
                connection.close()
            except Exception as close_error:
                logging.error(f"Connection Close Error: {str(close_error)}")

    return func.HttpResponse(
        f"Successfully rotated password.\n"
        "This HTTP triggered function executed successfully.",
        status_code=200
    )
