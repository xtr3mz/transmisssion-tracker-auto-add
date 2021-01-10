#!/bin/sh
# Get transmission credentials and ip or dns address
# transmision-remote 放到 /usr/bin/，添加下行到/etc/crontab/root
# * */1 * * * /bin/sh /mnt/mydisk/add_tracker.sh>>/mnt/mydisk/tracker.log
# tracker.txt 放到同目录，每行一个地址
# 文件保存编码 utf8
tips="No active torrent"
app=/usr/bin/transmission-remote
auth=transmissionuser:transmissionpassword
host=192.168.2.1:9091
trackerslist=$(pwd)/trackers.txt

add_trackers() {
	torrent_hash=$1
	id=$2
	if [ -f $trackerslist ]; then
	for tracker in $(cat $trackerslist) ; do
		if $app "$host"  --auth="$auth" --torrent "${torrent_hash}" -td "${tracker}" | grep -q 'success'; then
		    echo ' skiped.'
		else
		    echo ' added .'
		fi
		echo "...${tracker}"
	done
	else
	    echo "trackers.txt lost"
	fi
}


ids="$($app "$host"  --auth="$auth" --list | grep -vE 'Seeding|Stopped|Finished|[[:space:]]100%[[:space:]]' | grep '^ ' | awk '{ print $1 }')"
for id in $ids ; do
	    hash="$($app "$host"  --auth="$auth" --torrent "$id" --info | grep '^  Hash: ' | awk '{ print $2 }')"
	    torrent_name="$($app "$host"  --auth="$auth" --torrent "$id" --info | grep '^  Name: ' |cut -c 9-)"
	    echo $(date "+%Y-%m-%d %H:%M:%S")" - Adding trackers for $torrent_name..."

	    add_trackers "$hash" "$id"
	    tips="done"
done
echo $tips
