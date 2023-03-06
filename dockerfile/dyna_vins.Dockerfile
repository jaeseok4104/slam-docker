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
ros-melodic-tf

#install ceres-solver
RUN cd /tmp &&\
git clone https://ceres-solver.googlesource.com/ceres-solver &&\
cd ./ceres-solver &&\
git checkout aeebc66bd8ff5db65b852dac0cbac28f618ac5d8 &&\
cd .. &&\
mkdir ceres-bin &&\
# SuiteSparse (optional)
apt-get install -y libsuitesparse-dev &&\
cd ceres-bin &&\
cmake ../ceres-solver &&\
make -j3 &&\
make test &&\
make -j`(nproc)` && \
make install && \
cd .. && \
rm -rf ceres-bin && \
rm -rf ceres-solver

#install opencv 3.4.1
RUN  git clone https://github.com/Itseez/opencv.git /tmp/opencv && \
    cd /tmp/opencv && \
    git checkout 3.4.1 && \
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
    && make -j`(nproc)` \
    && make install \
    && echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf && \
    ldconfig

#install cuda
RUN apt-get install -y nvidia-cuda-toolkit

#install dynavins
RUN mkdir -p ~/catkin_ws/src &&\
cd ~/catkin_ws/src &&\
git clone https://github.com/url-kaist/dynaVINS &&\
cd dynaVINS &&\
#setup dyanvins using vins-fusion
git clone https://github.com/HKUST-Aerial-Robotics/VINS-Fusion /tmp/VINS-Fusion &&\
cp -rf /tmp/VINS-Fusion/camera_models ../ &&\
cp /tmp/VINS-Fusion/support_files/brief_k10L6.bin ./support_files/ &&\
cp /tmp/VINS-Fusion/support_files/brief_pattern.yml ./support_files/ &&\
#delete VINS-Fusion
rm -rf /tmp/VINS-Fusion

#build
RUN cd ~/catkin_ws &&\
/bin/bash -c '. /opt/ros/melodic/setup.bash; catkin_make -DCMAKE_BUILD_TYPE=Release'

#rviz install
RUN apt install -y ros-melodic-rviz

#entrypoint setup
RUN sed -i "6i source \"/root/catkin_ws/devel/setup.bash\"" /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]