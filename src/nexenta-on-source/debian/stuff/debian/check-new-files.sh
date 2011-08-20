#!/bin/bash

revs=$(cd $GATEROOT; hg qseries | awk -F- '/^bkport\-/ {print $2}' | awk -F\. '{print $1}' | grep -v reworked)
revs_reworked=$(cd $GATEROOT; hg qseries | awk -F- '/^bkport\-reworked\-/ {print $3}' | awk -F\. '{print $1}')
revs="$revs $revs_reworked"

for r in $revs; do
	cd $GATEROOT
	if hg log -p -r $r | grep "\-\-\- /dev/null" >/dev/null; then
		echo "$r: HAS NEW FILES"
	else
		echo "$r: OK"
	fi
done
