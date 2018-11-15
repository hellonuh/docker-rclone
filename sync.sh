#!/bin/sh

set -e

echo "INFO: Starting sync.sh pid $$ $(date)"

if [ `lsof | grep $0 | wc -l | tr -d ' '` -gt 1 ]
then
  echo "WARNING: A previous sync is still running. Skipping new sync command."
else

echo $$ > /tmp/sync.pid

if test "$(rclone ls $SYNC_SRC $RCLONE_OPTS)"; then

  if [ -z "$SYNC_SRC_ZIP_NAME" ]
  then
    echo "Zip option available"
    echo "zipping source dir"
    cd $SYNC_SRC && tar -zcvf $SYNC_SRC_ZIP_NAME . && mv $SYNC_SRC_ZIP_NAME /tmp/
    echo "Zip complete"
    rclone copy /tmp/$SYNC_SRC_ZIP_NAME $SYNC_DEST $RCLONE_OPTS $SYNC_OPTS
  else
    # the source directory is not empty
    # it can be synced without clear data loss
    echo "INFO: Starting rclone sync $SYNC_SRC $SYNC_DEST $RCLONE_OPTS $SYNC_OPTS"
    rclone sync $SYNC_SRC $SYNC_DEST $RCLONE_OPTS $SYNC_OPTS
  fi  

  if [ -z "$CHECK_URL" ]
  then
    echo "INFO: Define CHECK_URL with https://healthchecks.io to monitor sync job"
  else
    wget $CHECK_URL -O /dev/null
  fi
else
  echo "WARNING: Source directory is empty. Skipping sync command."
fi

rm -f /tmp/sync.pid

fi
