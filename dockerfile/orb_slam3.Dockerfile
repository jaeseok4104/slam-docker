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

#install pangolin
RUN apt install -y libglew-dev &&\
    git clone https://github.com/stevenlovegrove/Pangolin.git /tmp/Pangolin && \
    cd /tmp/Pangolin && \
    git checkout 6e18d50c195357a69694bc3a86af858bcac59cc0 && \
    mkdir build && \
    cd /tmp/Pangolin/build && \
    cmake .. && \
    cmake --build .  -- -j `(nproc)` && \
    make install -j`(nproc)` && \
    ldconfig

#install cuda
RUN apt-get install -y nvidia-cuda-toolkit

#install opencv 4.4.0
RUN  git clone https://github.com/Itseez/opencv.git /tmp/opencv && \
    cd /tmp/opencv && \
    git checkout 4.4.0 && \
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

#install orb-slam3
RUN cd ~ &&\
    git clone https://github.com/UZ-SLAMLab/ORB_SLAM3.git &&\
    cd ORB_SLAM3 &&\
    git checkout v0.4-beta
RUN sed -i '33s/3.0/4.4.0/' /root/ORB_SLAM3/Examples/ROS/ORB_SLAM3/CMakeLists.txt

RUN cd ~/ORB_SLAM3 &&\
    chmod +x build.sh &&\
    /bin/bash -c './build.sh'

RUN cd ~/ORB_SLAM3 &&\
    chmod +x build_ros.sh &&\
    /bin/bash -c '. /opt/ros/melodic/setup.bash; export ROS_PACKAGE_PATH=${ROS_PACKAGE_PATH}:/root/ORB_SLAM3/Examples/ROS/ORB_SLAM3; ./build_ros.sh'

ENTRYPOINT ["/ros_entrypoint.sh"]