# Readme File

This script is designed to restore data for the Merck IoT solution TimescaleDB. It can be executed again if it update fails. 

**Arguments:**
- `-r`: Support two restore modes -- `full` or `merck`, representing full backup and only Merck database.
- `-n`: Namespace of phziot and cohesion. 
- `-h`: Show usage

## Steps

### Step 1: Get leader TimescaleDB pod name

1. The script first gets the name of the leader TimescaleDB pod by executing a command via `patronictl`, using the given namespace or the default `phziot`. 

### Step 2: Restore mode

The script has two restore modes: `full` and `merck`.
The script has two namespaces: phziot and cohesion.

#### Full Restore Mode

In this mode, the script restores everything from a full backup file. If the backup file is not found, the script will exit with an error message. 

The following are the steps taken by the script for a full restore:

1. If the backup file exists, the script proceeds with restoring the entire database. It first copies the backup file to the leader pod, using kubectl cp command. If the namespace is specified, it copies the file with the "-n" flag. If the copy operation fails, it exits with an error message.

2. After the backup file is copied to the leader pod, the script executes a PostgreSQL restore command inside the pod using kubectl exec command. If the restore operation fails, it exits with an error message.

3. Copy the full database backup file into the leader TimescaleDB pod.
4. Start to restore the full database file.
5. Delete the full database file inside the leader TimescaleDB pod.

#### MERK Restore Mode

1. In the merck mode, it checks if the backup file exists and exits with an error message if it does not. It then copies the backup file and a drop-merck-db.sql file to the leader timescaledb pod, drops and recreates the merck database, restores the database from the backup file, and grants privileges for application users.

2. The script uses kubectl to copy files to and execute commands on the leader timescaledb pod. The kubectl commands are executed differently depending on whether the NS variable is set or not.
3. Copy the full database backup file into the leader TimescaleDB pod.
4. Start to restore the full database file.
5. Delete the full database file inside the leader TimescaleDB pod.

## Note

Please ensure that you have the necessary permissions to execute this script. Additionally, make sure to take a backup of the database before restoring.