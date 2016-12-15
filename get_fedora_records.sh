#!/bin/bash

########################################################################
# @file                                                                #
# Retrieves a tar file from prod with records and imports into fedora3 #
########################################################################

target_file="fedora_files.tgz"

cd ~/Desktop
scp tlille01@tdl-prod-02.uit.tufts.edu:/home/tlille01/${target_file} .
tar -xvf ${target_file}

while read line; do
  echo $line
done <<<"$(ls xml)"

