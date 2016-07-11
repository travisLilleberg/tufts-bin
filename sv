#!/bin/bash

# @file
# Starts and stops all the servers

source ${HOME}/.bash_functions/msgs
source ${HOME}/.bash_functions/get_site

# Files to save stuff in
rl="${HOME}/.t_dir"
rdp="${HOME}/.t_redis.pid"
rep="${HOME}/.t_resque.pid"
rap="${HOME}/.t_rails.pid"
this_site=$(get_site)

case ${1} in
  'start')
    if [ -f ${rl} ]; then
      bad_msg "Servers already appear to be running."
      exit 1
    fi

    rake -n >/dev/null 2>/dev/null 
    if [ $? -gt 0 ]; then
      bad_msg "You're not in a Rails project."
      exit 1
    fi

    if [ "${this_site}" != "marvel_companion" ]; then
      tc start
    fi

    if [ "${this_site}" == "mira" ]; then
      mysql.server start
      redis-server &
      echo "${!}" > ${rdp}
      bundle exec resque-pool &
      echo "${!}" > ${rep}
    fi

    rails s >/dev/null &
    echo "${!}" > ${rap}
    echo "$(PWD)" > ${rl}

    ;;
  'stop')
    if [ ! -f ${rl} ]; then
      bad_msg "Servers don't appear to be running."
      exit 1
    fi

    tc stop

    if [ -f ${rdp} ]; then
      mysql.server stop
      kill $(head -n 1 ${rdp})
      rm ${rdp}
      kill $(head -n 1 ${rep})
      rm ${rep}
    fi

    if [ -f ${rl}/tmp/pids/server.pid ]; then
      kill $(head -n 1 ${rl}/tmp/pids/server.pid)
    else
      kill $(head -n 1 ${rap})
    fi

    rm ${rap}
    rm ${rl}
    ;;
  'restart')
    servers stop
    sleep 1
    servers start
    ;;
  *)
    bad_msg "start or stop?" >&3
    ;;
esac

