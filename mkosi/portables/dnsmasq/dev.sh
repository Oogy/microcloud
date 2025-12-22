#!/usr/bin/env bash

local_script_path=./mkosi.extra/usr/lib/dnsmasq/dnsmasq
machine_script_path=/usr/lib/dnsmasq/dnsmasq

watcher(){
	inotifywait -e close_write,modify ${local_script_path}
}

update(){
	echo "file changed"
	sudo machinectl copy-to dnsmasq ${local_script_path} ${machine_script_path} --force
	sudo machinectl shell dnsmasq /usr/bin/systemctl restart dnsmasq
}

while true; do watcher; update; done
