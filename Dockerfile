FROM ros:noetic-ros-base AS build_env
WORKDIR /bag2img

COPY requirements.txt requirements.txt
COPY bag_2_image.py bag_2_image.py

RUN apt-get update && apt-get install -y \
  python3-pip \
  git \
  curl \
  ros-$ROS_DISTRO-rosbag ros-$ROS_DISTRO-roslz4 \
  ros-$(rosversion -d)-cv-bridge

RUN pip3 install -r requirements.txt

SHELL ["/bin/bash", "-c"]

RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc

######################
# Build librealsense #
######################
FROM build_env as librealsense_build

ENV RS_VERSION=2.53.1

RUN curl https://codeload.github.com/IntelRealSense/librealsense/tar.gz/v$RS_VERSION -o librealsense.tar.gz \
    && tar -xzf librealsense.tar.gz \
    && true

# build deps
RUN apt-get update \
    && apt-get install -qq -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libssl-dev \
    libusb-1.0-0-dev \
    pkg-config \
    libgtk-3-dev \
    libglfw3-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \    
    curl \
    python3 \
    python3-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://codeload.github.com/IntelRealSense/librealsense/tar.gz/refs/tags/v$LIBRS_VERSION -o librealsense.tar.gz 
RUN tar -zxf librealsense.tar.gz \
    && rm librealsense.tar.gz 
RUN ln -s /bag2img/librealsense-$LIBRS_VERSION /bag2img/librealsense

RUN cd /bag2img/librealsense \
    && mkdir build && cd build \
    && cmake \
    -DCMAKE_C_FLAGS_RELEASE="${CMAKE_C_FLAGS_RELEASE} -s" \
    -DCMAKE_CXX_FLAGS_RELEASE="${CMAKE_CXX_FLAGS_RELEASE} -s" \
    -DCMAKE_INSTALL_PREFIX=/opt/librealsense \    
    -DBUILD_GRAPHICAL_EXAMPLES=OFF \
    -DBUILD_PYTHON_BINDINGS:bool=true \
    -DCMAKE_BUILD_TYPE=Release ../ \
    && make -j$(($(nproc)-1)) all \
    && make install 

CMD [ "/bin/bash" ]