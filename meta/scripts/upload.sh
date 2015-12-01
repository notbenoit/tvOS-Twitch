#!/bin/bash
set -ex

# This scripts allows you to upload a binary to the iTunes Connect Store and do it for a specific app_id
# Because when you have multiple apps in status for download, xcodebuild upload will complain that multiple apps are in wait status

# Requires application loader to be installed
# See https://developer.apple.com/library/ios/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Chapters/SubmittingTheApp.html
# Itunes Connect username & password
USER=$DELIVER_USER
PASS=$DELIVER_PASSWORD

# App id as in itunes store create, not in your developer account
APP_ID=$APPLE_APP_ID

IPA_FILE="`pwd`/$IPA_NAME.ipa"
MD5=$(md5 -q $IPA_FILE)
BYTESIZE=$(stat -f "%z" $IPA_FILE)

echo "Uploading $IPA_NAME to iTunes Connect"

TEMPDIR=itsmp
# Remove previous temp
test -d ${TEMPDIR} && rm -rf ${TEMPDIR}
mkdir ${TEMPDIR}
mkdir ${TEMPDIR}/mybundle.itmsp

# You can see this debug info when you manually do an app upload with the Application Loader
# It's when you click activity

cat <<EOM > ${TEMPDIR}/mybundle.itmsp/metadata.xml
<?xml version="1.0" encoding="UTF-8"?>
<package version="software5.3" xmlns="http://apple.com/itunes/importer">
    <software_assets apple_id="$APP_ID"
        app_platform="appletvos">
        <asset type="bundle">
            <data_file>
                <file_name>$IPA_FILENAME</file_name>
                <checksum type="md5">$MD5</checksum>
                <size>$BYTESIZE</size>
            </data_file>
        </asset>
    </software_assets>
</package>
EOM

cp ${IPA_FILE} $TEMPDIR/mybundle.itmsp

PATH_TO_ITMS=`xcode-select --print-path`/../Applications/Application\ Loader.app/Contents/itms/bin
"$PATH_TO_ITMS/iTMSTransporter" -m upload -f ${TEMPDIR} -u "$USER" -p "$PASS" -v detailed && exit ${PIPESTATUS[0]}
