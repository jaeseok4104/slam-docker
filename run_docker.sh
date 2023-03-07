#!/bin/bash
to_abs_path() {
    local RELATIVE_PATH=$(echo "`dirname $0`"/$@)
    echo $(realpath $RELATIVE_PATH)
}
if [ "$#" -eq "0" ]
    then 
        echo "example) $0 slam name"
        echo "example) $1 run/build/up service name"
        exit
fi 
ABS_PATH=$(to_abs_path ./)
FULL_COMMAND=("$@")
unset FULL_COMMAND[0]
docker-compose --file ${ABS_PATH}/docker-compose/"$1"_compose.yml ${FULL_COMMAND[@]}