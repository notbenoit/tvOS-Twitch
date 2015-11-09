#!/bin/sh
if [[ $TRAVIS_BRANCH == *"release"* ]]
then
  ipa distribute:itunesconnect \
  -i $APPLE_APP_ID \
  -f "$IPA_NAME.ipa" \
  -u
fi
