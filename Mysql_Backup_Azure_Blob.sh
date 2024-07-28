#!/bin/bash

# Configuration
DB_USER="root"
DB_PASS="trzKYKWejNyBSt6f"
DUMP_DIR="/root/mysql_backup"
BLOB_CONTAINER="dev-server-mysql-backups/fileName"
BLOB_ACCOUNT="containerName"
export BLOB_KEY="blobKey=="


# Ensure BLOB_KEY is set in the environment
if [ -z "$BLOB_KEY" ]; then
    echo "Error: BLOB_KEY environment variable is not set."
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p $DUMP_DIR

# Get list of databases
DATABASES=$(mysql -u $DB_USER -p$DB_PASS -e "SHOW DATABASES;" | grep -Ev "^(Database|information_schema|performance_schema|mysql|sys)$")

for DB_NAME in $DATABASES; do
    # Dump each database
    DUMP_FILE="$DUMP_DIR/${DB_NAME}_backup.sql"
    echo "Dumping database: $DB_NAME"
    mysqldump -u $DB_USER -p$DB_PASS $DB_NAME > $DUMP_FILE

    # Check if dump was successful
    if [ $? -ne 0 ]; then
        echo "Error dumping database: $DB_NAME"
        continue
    fi

    # Upload to Azure Blob Storage
    echo "Uploading $DUMP_FILE to Azure Blob Storage"
    az storage blob upload --container-name $BLOB_CONTAINER --name "${DB_NAME}_backup.sql" --file $DUMP_FILE --account-name $BLOB_ACCOUNT --account-key $BLOB_KEY --overwrite

    # Check if upload was successful
    if [ $? -ne 0 ]; then
        echo "Error uploading $DUMP_FILE to Azure Blob Storage"
        continue
    fi

    # Cleanup
    echo "Removing local backup file: $DUMP_FILE"
    rm $DUMP_FILE
done