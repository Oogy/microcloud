#!/bin/sh
set -e

setup_exports() {
    echo "/data *(rw,fsid=0,no_subtree_check,no_root_squash)" > /etc/exports
    exportfs -a
}

start_rpcbind() {
    rpcbind -w
}

start_mountd() {
    rpc.mountd --no-nfs-version 3
}

start_nfsd() {
    rpc.nfsd --no-nfs-version 3
}

main() {
    setup_exports
    start_rpcbind
    start_mountd
    start_nfsd
    while true; do sleep 3600; done
}

main
