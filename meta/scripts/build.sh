#!/bin/sh
gym \
-w $WORKSPACE_PATH \
-s $SCHEME_NAME \
-d generic/platform=tvOS \
-c \
-o ./ \
-z \
-n $IPA_NAME \
-i "$DEVELOPER_NAME"
