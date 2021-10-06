#!/bin/bash

# This script enables the user to upload a file to Google Drive

# fail fast
set -e pipefail

CLIENT_ID=<your-generated-client-id>
CLIENT_SECRET=<your-generated-client-secret>
SCOPE=https://www.googleapis.com/auth/drive.file 

# This is the URL we’ll send the user to first to get their authorization# verify device
VERIFY_DEVICE=`curl -d “client_id=”$CLIENT_ID”&scope=$SCOPE” https://oauth2.googleapis.com/device/code`
echo $VERIFY_DEVICE

# extract device_code value from the json response using jq
DEVICE_CODE=`echo $VERIFY_DEVICE | jq -r ‘.device_code’`
echo $DEVICE_CODE

# pause the script to give the user time to navigate to verification_url and enter the user_code.
sleep 25


# get bearer code
BEARER=`curl -d client_id=$CLIENT_ID \
 -d client_secret=$CLIENT_SECRET \
 -d device_code=$DEVICE_CODE \
 -d grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Adevice_code https://accounts.google.com/o/oauth2/token`#echo $BEARER# extract access_token value from the json response using jq
ACCESS_TOKEN=`echo $BEARER | jq -r ‘.access_token’` 

#echo $ACCESS_TOKEN

echo `curl -X POST -L \
 -H ‘Authorization: Bearer ‘${ACCESS_TOKEN} \
 -F ‘metadata={name : “backup.zip”, parents : [“<Google-Drive-Folder-URL-Here>”]};type=application/json;charset=UTF-8’ \
 -F ‘file=@backup.zip;type=application/zip’ \
 ‘https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart'`
