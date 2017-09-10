#!/bin/sh
fastlane gym \
-w $WORKSPACE_PATH \
-s $SCHEME_NAME \
-c \
-o ./ \
-z \
-n $IPA_NAME \
