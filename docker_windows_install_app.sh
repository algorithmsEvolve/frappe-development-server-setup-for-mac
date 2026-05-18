#!/bin/bash

# Small bash script to help install frappe app on docker windows
# os.rename does not work, so we need to do this
# ========================= INPUTS ==========================

CONFIRMINPUT=
while [[ $CONFIRMINPUT = "" ]]; do

    APPREPO=
    while [[ $APPREPO = "" ]]; do
        echo -n "Enter the app git repo then press [ENTER] "
        read -n100 -p " " -e APPREPO
    done


    APPNAME=
    while [[ $APPNAME = "" ]]; do
        echo -n "Enter the app name identical to your app's setup.py then press [ENTER] "
        read -n50 -p " " -e APPNAME
    done

    # confirm
    echo -n -e "\n\nApp repo has been set to $APPREPO for this installation"
    echo -n -e "\nApp name has been set to $APPNAME for this installation"
    echo -n -e "\n\nType Y then press [ENTER] to continue or anything to restart: "
    read -n50 -p " " -e CONFIRMINPUT

    if [ "$CONFIRMINPUT" != "Y" ]
    then
        CONFIRMINPUT=""
    fi
done

cd /workspace/frappe-bench
bench get-app "$APPREPO"

ORIGINAL_APP_DIR=$(echo ${APPREPO##*/} | cut -f 1 -d '.')

echo "Original app dir:  $ORIGINAL_APP_DIR"

mv /workspace/frappe-bench/apps/"$ORIGINAL_APP_DIR" /workspace/frappe-bench/apps/"$APPNAME"

/workspace/frappe-bench/env/bin/pip install /workspace/frappe-bench/apps/"$APPNAME"

echo -e "\n$APPNAME" >> /workspace/frappe-bench/sites/apps.txt

bench install-app "$APPNAME"

cd /workspace/frappe-bench/apps/"$APPNAME"

git config core.filemode false
git config core.longpaths true
git config core.autocrlf input

cd /workspace/
