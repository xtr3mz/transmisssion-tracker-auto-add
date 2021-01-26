#!/bin/sh
# transmission 自动添加tracker 保存为utf8编码 权限0777
# * */1 * * * /mnt/mydisk/addtracker.sh>/mnt/mydisk/tracker.log

tips="No active torrent"
app=/usr/bin/transmission-remote
#下载自己路由器能用的transmission-remote到/mnt/mydisk/
apx=/mnt/mydisk/transmission-remote
#账号:密码
auth=transmission:transmission
#hostip 和 端口 不要写127.0.0.1
host=192.168.2.1:9091
#存放trakcer的文件 每行一条地址
trackerslist=/mnt/mydisk/trackers.txt

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
	    echo "trackers.txt lost" $trackerslist
	fi
}

if [ ! -f "$app" ]; then
	cp $apx $app
	chmod 777 $app
fi

ids="$($app "$host"  --auth="$auth" --list | grep -vE 'Seeding|Stopped|Finished|[[:space:]]100%[[:space:]]' | grep '^ ' | awk '{ print $1 }')"
for id in $ids ; do
	    hash="$($app "$host"  --auth="$auth" --torrent "$id" --info | grep '^  Hash: ' | awk '{ print $2 }')"
	    torrent_name="$($app "$host"  --auth="$auth" --torrent "$id" --info | grep '^  Name: ' |cut -c 9-)"
	    echo $(date "+%Y-%m-%d %H:%M:%S")" - Adding trackers for $torrent_name..."
		    add_trackers "$hash" "$id"
	    tips="done"
done

echo $tips
