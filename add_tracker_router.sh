#!/bin/sh
# Get transmission credentials and ip or dns address
# 定时任务
# * */1 * * * sh /mnt/mydisk/add_tracker.sh>>/mnt/mydisk/tracker.log
tips="No active torrent"
# transmission-remote下载放到这里（上传的只有mt7621，其他cpu自己找）
app=/usr/bin/transmission-remote
# 账号密码
auth=transmission_user:password
# 地址，端口
host=192.168.2.1:9091
# tracker文件，每行一条
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
