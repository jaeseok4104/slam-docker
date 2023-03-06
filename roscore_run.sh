#!/bin/bash
to_abs_path() {
    local RELATIVE_PATH=$(echo "`dirname $0`"/$@)
    echo $(realpath $RELATIVE_PATH)
}

ABS_PATH=$(to_abs_path ./)
docker-compose --file ${ABS_PATH}/docker-compose/roscore_run_compose.yml run roscore