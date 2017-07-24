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
log_file="${HOME}/rails_log"

# Servers with specific needs
redis_sites="mira tufts_concerns"
mysql_sites="mira"
resque_sites="mira"

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

    if [[ " ${mysql_sites[@]} " =~ " ${this_site} " ]]; then
      mysql.server start
    fi

    if [[ " ${redis_sites[@]} " =~ " ${this_site} " ]]; then
      redis-server &
      echo "${!}" > ${rdp}
    fi

    if [[ " ${resque_sites[@]} " =~ " ${this_site} " ]]; then
      bundle exec resque-pool &
      echo "${!}" > ${rep}
    fi

    rails s >${log_file} 2>&1 &
    echo "${!}" > ${rap}
    echo "$(PWD)" > ${rl}

    ;;
  'stop')
    if [ ! -f ${rl} ]; then
      bad_msg "Servers don't appear to be running."
      exit 1
    fi

    if [[ " ${mysql_sites[@]} " =~ " ${this_site} " ]]; then
      mysql.server stop
    fi

    if [ -f ${rdp} ]; then
      kill $(head -n 1 ${rdp})
      rm ${rdp}
    fi

    if [ -f ${rep} ]; then
      kill $(head -n 1 ${rep})
      rm ${rep}
    fi

    if [ -f ${rl}/tmp/pids/server.pid ]; then
      kill $(head -n 1 ${rl}/tmp/pids/server.pid)
    else
      kill $(head -n 1 ${rap})
    fi

    rm ${rap}
    rm ${log_file}
    rm ${rl}
    ;;
  'restart')
    sv stop
    sleep 1
    sv start
    ;;
  *)
    bad_msg "start or stop?" >&3
    ;;
esac

