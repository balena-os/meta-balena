#!/bin/sh

. /usr/libexec/os-helpers-logging

if [ "${EXIT_STATUS}" != "0" ]; then
	info "NTP time lost synchonization - forcing synchronization"

	if ! /usr/bin/chronyc 'burst 4/4' > /dev/null ||
		 ! /usr/bin/chronyc makestep > /dev/null; then
		error "Failed to trigger NTP sync"
	fi
fi
