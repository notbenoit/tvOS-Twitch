#!/bin/sh
TIMESTAMP=`date +%y%m%d%H%M%S`
agvtool new-version -all $TIMESTAMP
