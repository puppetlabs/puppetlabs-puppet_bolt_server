#!/bin/bash
DIR=$1
PLAN=$2
cd "$DIR" || exit 1
/usr/local/bin/bolt plan run "$PLAN" --targets localhost
