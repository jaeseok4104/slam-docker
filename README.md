# SLAM Docker

## How to use

if you want run docker, you can run docker using `run_docker.sh`

## Example
-------------------
### Running Docker(with roslaunch)

```
#when use nvidia graphic for xhost, you should use 
./run_docker.sh dyna_vins run cuda
#when use intel graphic for xhost, you should use 
./run_docker.sh dyna_vins run normal

roslaunch dynaVINS viode_stereo.launch
```
### Running Docker(without roslaunch (ex. rosrun))

```
#when use nvidia graphic for xhost, you should use 
./run_docker.sh orb_slam3 run cuda
#when use intel graphic for xhost, you should use 
./run_docker.sh orb_slam3 run normal

#other terminal
./roscore_run.sh

#slam_docker terminal
rosrun ORB_SLAM3 Stereo_Inertial Vocabulary/ORBvoc.txt Examples/Stereo-Inertial/TUM_512.yaml false
```

### Running rosbag

```
./dataset_runner.sh ${DATASET_PATH} ${DATSET_FILE_NAME} ${COMMAND(ex. /imu0:=/imu)}
```