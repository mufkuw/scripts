#!/bin/bash

# List of container IDs
CONTAINER_IDS=("101" "102" "103")

 
BACKUP_PATH="/var/lib/vz/dump"


for ID in ${CONTAINER_IDS[@]}
do
    echo "Starting backup and transfer for container $ID..."
    
    
    START_TIME=$(date +%s)

    
    vzdump $ID --dumpdir $BACKUP_PATH --mode snapshot --compress lzo

    
    if [ $? -ne 0 ]; then
        echo "Backup for container $ID failed."
        continue
    fi

    # Get the name of the latest backup file
    BACKUP_FILE=$(ls -t $BACKUP_PATH/vzdump-lxc-$ID-*.tar.lzo | head -1)

    # Send the backup to the remote server
    rsync -avz -e "ssh -p 22022 -i /home/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --progress $BACKUP_FILE root@wdstorage.ddns.alherzkuwait.com:/containerbackups

    # Check if rsync was successful
    if [ $? -ne 0 ]; then
        echo "Transfer of backup for container $ID failed."
        continue
    fi

    END_TIME=$(date +%s)

    # Calculate the time it took
    TIME_TAKEN=$((END_TIME - START_TIME))

    echo "Backup and transfer for container $ID completed in $TIME_TAKEN seconds."
done
