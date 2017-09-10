#!/bin/sh
if [[ $TRAVIS_BRANCH == *"release"* ]]
then
  fastlane pilot upload \
  -p $APPLE_APP_ID
fi
