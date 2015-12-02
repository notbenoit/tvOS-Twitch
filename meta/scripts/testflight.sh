#!/bin/sh
if [[ $TRAVIS_BRANCH == *"release"* ]]
then
  pilot upload \
  -u $DELIVER_USER \
  -p $APPLE_APP_ID
fi
