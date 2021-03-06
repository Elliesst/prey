#!/bin/bash
####################################################################
# Prey Client - by Tomas Pollak (bootlog.org)
# URL: http://preyproject.com
# License: GPLv3
####################################################################

# set -u
# set -e

PATH=/bin:$PATH # for windows
readonly base_path=`dirname $0`

####################################################################
# base files inclusion
####################################################################

. $base_path/version
. $base_path/config
if [ ! -f "lang/$lang" ]; then # fallback to english in case the lang is missing
	lang='en'
fi
. $base_path/lang/$lang
. $base_path/core/base
. $base_path/platform/$os/core

echo -e "\E[36m$STRING_START ### `date`\E[0m\n"

####################################################################
# lets check if we're actually connected
# if we're not, lets try to connect to a wifi access point
####################################################################

check_net_status
if [ $connected == 0 ]; then

	if [ "$auto_connect" == "y" ]; then
		echo "$STRING_TRY_TO_CONNECT"
		try_to_connect
	fi

	# ok, lets check again
	check_net_status
	if [ $connected == 0 ]; then
		echo "$STRING_NO_CONNECT_TO_WIFI"
		exit
	fi
fi

####################################################################
# if there's a URL in the config, lets see if it actually exists
# if it doesn't, the program will shut down gracefully
####################################################################

if [ -n "$check_url" ]; then
	echo "$STRING_CHECK_URL"

	check_status
	parse_headers
	process_response

	echo -e "\n -- Got status code $status!"

	if [ "$status" == "$missing_status_code" ]; then
		echo -e "$STRING_PROBLEM"
	else
		echo -e "$STRING_NO_PROBLEM"
		exit 0
	fi
fi

####################################################################
# ok what shall we do then?
# for now lets run every module with an executable run.sh script
####################################################################

create_tmpdir

set +e # error mode off, just continue if a module fails
echo -e " -- Running active modules..."
run_active_modules

####################################################################
# lets send whatever our modules have gathered
####################################################################

echo -e "\n -- Sending report..."
send_report
run_delayed_jobs

echo -e "\n$STRING_DONE"
rm -Rf $tmpdir

exit 0
