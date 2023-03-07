#ros melodic
FROM ros:melodic-perception


RUN apt-get update && apt-get install -y libgoogle-glog-dev libgflags-dev \
    libatlas-base-dev \
    libeigen3-dev \
    cmake \
    python-catkin-tools \
    ros-melodic-cv-bridge \
    ros-melodic-image-transport \
    ros-melodic-message-filters \
    ros-melodic-tf \
    libpython2.7-dev

#install cuda
RUN apt-get install -y nvidia-cuda-toolkit

#install opencv 3.2.0
RUN  git clone https://github.com/Itseez/opencv.git /tmp/opencv && \
    cd /tmp/opencv && \
    git checkout 3.2.0 && \
    mkdir -p ./build && \
    cd ./build && \
    cmake \
    -D CMAKE_BUILD_TYPE=Release \
    -D BUILD_OPENEXR=OFF \
    -D BUILD_PROTOBUF=OFF \
    -D BUILD_opencv_apps=OFF \
    -D BUILD_opencv_calib3d=ON \
    -D BUILD_opencv_dnn=OFF \
    -D BUILD_opencv_ml=OFF \
    -D BUILD_opencv_objdetect=OFF \
    -D BUILD_opencv_photo=OFF \
    -D BUILD_opencv_python2=OFF \
    -D BUILD_opencv_python_bindings-generator=OFF \
    -D BUILD_opencv_shape=OFF \
    -D BUILD_opencv_stitching=OFF \
    -D BUILD_opencv_superres=OFF \
    -D BUILD_opencv_ts=OFF \
    -D BUILD_opencv_video=ON \
    -D BUILD_opencv_videoio=ON \
    -D BUILD_opencv_videostab=OFF \
    -D BUILD_opencv_world=OFF \
    -D BUILD_TIFF=ON \
    -D WITH_CUDA=OFF \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D BUILD_NEW_PYTHON_SUPPORT=OFF \
    -D WITH_V4L=ON \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D ENABLE_CXX11=ON .. \
    -D ENABLE_PRECOMPILED_HEADERS=OFF .. \
    && make -j`(nproc)` \
    && make install \
    && echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf && \
    ldconfig

#install gtsam
RUN apt-get update \
    && apt install -y software-properties-common \
    && add-apt-repository -y ppa:borglab/gtsam-release-4.0 \
    && apt-get update \
    && apt install -y libgtsam-dev libgtsam-unstable-dev \
    && rm -rf /var/lib/apt/lists/*

#install libnabo
RUN cd /tmp &&\
    git clone https://github.com/ethz-asl/libnabo.git &&\
    cd libnabo &&\
    git checkout 1.0.7&&\
    SRC_DIR=`pwd` &&\
    BUILD_DIR=${SRC_DIR}/build &&\
    mkdir -p ${BUILD_DIR} && cd ${BUILD_DIR} &&\
    cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo ${SRC_DIR} &&\
    make -j&&\
    sudo make install

#instlal libboost
RUN apt install -y libboost-dev

#install disco-slam
RUN mkdir -p ~/catkin_ws/src &&\
    cd ~/catkin_ws/src &&\
    git clone https://github.com/yeweihuang/LIO-SAM.git &&\
    cd LIO-SAM/src &&\
    git clone https://github.com/RobustFieldAutonomyLab/DiSCo-SLAM
RUN sed -i '125s/libnabo::nabo/${libnabo_LIBRARIES}/' /root/catkin_ws/src/LIO-SAM/CMakeLists.txt
RUN sed -i '32i find_package(Boost REQUIRED COMPONENTS timer)' /root/catkin_ws/src/LIO-SAM/CMakeLists.txt
#build
RUN cd ~/catkin_ws &&\
/bin/bash -c '. /opt/ros/melodic/setup.bash; catkin_make -DCMAKE_BUILD_TYPE=Release'

#rviz install
RUN apt update && apt install -y ros-melodic-rviz

#entrypoint setup
RUN sed -i "6i source \"/root/catkin_ws/devel/setup.bash\"" /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]