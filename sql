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
  'build')
    brew install mysql
    ;;
  'destroy')
    mysql.server stop
    brew uninstall mysql
    rm -r /usr/local/var/mysql
    ;;
  'rebuild')
    mysql.server stop
    brew uninstall mysql
    rm -r /usr/local/var/mysql
    brew install mysql
    mysql.server start
    ;;
  *)
    bad_msg "Please say 'start', 'stop', 'build', 'destroy' or 'rebuild'"
    ;;
esac

