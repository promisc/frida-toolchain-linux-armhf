#!/bin/bash -ux

get_logs () {
    echo -en '\n\n\n\n================== Logs below ====================\n\n\n\n'
    find build -type f -name "*.log" -printf "%T@:%p\n" | sort -n | cut -d ":" -f 2 | xargs -rL 1 -- tail -vn 100
    exit 1
}

find build -type f -name "*.log" -exec rm {} +

$@ || get_logs
