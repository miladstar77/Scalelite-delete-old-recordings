#!/bin/bash
#set -x


N="$1"
#N=5
REC_DIR="/mnt/var/bigbluebutton/published/presentation/"
#working_directory
WD="/root/scripts"
cd $WD
echo "" > $WD/recordings.txt

DATE=$(date -d "$N days ago" '+%Y-%m-%d 23:59:59')

echo "Deleteing recordings before $DATE "
docker exec postgres \
    psql -U postgres -d greenlight-v3-production \
    -At -F ',' \
    -c "SELECT id, record_id FROM recordings where recorded_at <  '$DATE'" \
    > $WD/recordings.txt


while IFS=',' read -r RECORDINGS_ID RECORD_ID; do

    [[ -z "$RECORDINGS_ID" ]] && continue

    echo "table recordings -> recordings_id = $RECORDINGS_ID"
    echo "table recordings -> record_id = $RECORD_ID"

    docker exec postgres \
    psql -U postgres -d greenlight-v3-production \
    -At -F ',' \
    -c "
        SELECT 'formats', id, recording_id
        FROM formats
        WHERE recording_id = '$RECORDINGS_ID';"
#for deleteing uncomment these lines
#    -c "
#        DELETE
#        FROM formats
#        WHERE recording_id = '$RECORDINGS_ID';"
    docker exec postgres \
    psql -U postgres -d greenlight-v3-production \
    -At -F ',' \
    -c "
        SELECT 'recordings', id, record_id
        FROM recordings
        WHERE record_id = '$RECORD_ID'; "
#for deleteing uncomment these lines
#    -c "
#        DELETE
#        FROM recordings
#        WHERE record_id = '$RECORD_ID'; "

#for deleteing uncomment the lines
        #rm -rf  -ltrh $REC_DIR/$RECORD_ID
        ls -ltrh $REC_DIR/$RECORD_ID

done < $WD/recordings.txt
