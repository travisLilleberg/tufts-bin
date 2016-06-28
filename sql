#!/bin/bash

# @file
# Defines some mysql shortcuts just for me.

source ${HOME}/.bash_functions/msgs

# Rebuilds MySQL
case "${1}" in
  'start')
    mysql.server start
    ;;
  'stop')
    mysql.server stop
    ;;
  *)
    bad_msg "Please say 'start', 'stop', 'build', 'destroy' or 'rebuild'"
    ;;
esac

