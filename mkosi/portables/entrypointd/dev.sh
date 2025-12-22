#!/usr/bin/env bash

local_script_path=./mkosi.extra/usr/lib/entrypointd/entrypointd
machine_script_path=/usr/lib/entrypointd/entrypointd

watcher(){
	inotifywait -e close_write,modify ${local_script_path}
}

update(){
	echo "file changed"
	sudo machinectl copy-to entrypointd ${local_script_path} ${machine_script_path} --force
	sudo machinectl shell entrypointd /usr/bin/systemctl restart entrypointd
}

while true; do watcher; update; done
