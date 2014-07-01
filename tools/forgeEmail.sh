#!/bin/bash
subject=`date '+%H:%M'`
if [[ $3 ]]; then
  subject=$3
fi

mutt -H - "$2" <<EOF
From: $1
To: $2
Subject: $subject

Hey
EOF
echo $subject
