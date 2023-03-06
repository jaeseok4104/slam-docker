#!/bin/bash
to_abs_path() {
    local RELATIVE_PATH=$(echo "`dirname $0`"/$@)
    echo $(realpath $RELATIVE_PATH)
}

if [ $# -lt 2 ]
    then 
        echo "Wrong Arguments."
        echo "run_docker.sh takes all docker-compose arguments"
        echo "example) ./dataset_runner (your_dataset_abs_folder) (your_dataset_name)"
        exit
fi 
ABS_PATH=$(to_abs_path ./)
export DATASET=$1
export DATASET_NAME=$2
FULL_COMMAND=("$@")
unset FULL_COMMAND[0]
unset FULL_COMMAND[1]
export ROSBAG_COMMAND=$( IFS=' '; printf '%s' "${FULL_COMMAND[*]}" )
echo "${FULL_COMMAND[*]}"
echo "${ROSBAG_COMMAND}"


docker-compose --file ${ABS_PATH}/docker-compose/ros_dataset_runner_compose.yml run dataset