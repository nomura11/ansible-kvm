#!/bin/bash

export LANG=C

variable1=
variable2=false
. $1

logfile=/tmp/ansible_module.log

######################################################################
# For ansible
#

# redirect anything to logfile but ansible response
exec 3>/dev/stdout >> $logfile 2>&1

changed=false
failed=false
rc=0
exit_ansible() {
	local x
	if [ "$1" != "" ]; then
		rc=$1
	fi
	if [ "$rc" != "0" ]; then
		failed=true
	fi
	if [ ! -z "$msg" ]; then
		x=", \"msg\": \"$msg\""
	fi
	echo "{ \"rc\": $rc, \"changed\": $changed, \"failed\": $failed $x }" >&3
	exit $rc
}

is_true() {
	local var=$1

	if [ -z "$var" ]; then
		return 1
	fi
	if [ "$var" = "0" ]; then
		return 1
	fi
	if (echo "$var" | grep -qi "^\(false\|no\)$"); then
		return 1
	fi

	return 0
}

######################################################################
# 
#

if change_config; then
	changed=true
fi

do_something
if [ $? -ne 0 ]; then
	failed=true
fi

do_otherthing

exit_ansible $?

