ARG BASE_IMAGE=ubuntu:20.04

FROM ${BASE_IMAGE} as librs_builder

ENV DEBIAN_FRONTEND=noninteractive

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

RUN echo "Finish updates"

WORKDIR /bag2img

ARG RS_VERSION=2.53.1

RUN curl https://codeload.github.com/IntelRealSense/librealsense/tar.gz/v$RS_VERSION -o librealsense.tar.gz \
    && tar -xzf librealsense.tar.gz

RUN tar -zxf librealsense.tar.gz \
    && rm librealsense.tar.gz 

RUN ln -s /bag2img/librealsense-$RS_VERSION /bag2img/librealsense

RUN echo "Finish librealsense extraction"

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

FROM ${BASE_IMAGE} as librealsense

COPY --from=librs_builder /opt/librealsense /usr/local/
COPY --from=librs_builder /usr/lib/python3/dist-packages/pyrealsense2 /usr/lib/python3/dist-packages/pyrealsense2
COPY --from=librs_builder /bag2img/librealsense/config/99-realsense-libusb.rules /etc/udev/rules.d/
COPY --from=librs_builder /bag2img/librealsense/config/99-realsense-d4xx-mipi-dfu.rules /etc/udev/rules.d/
ENV PYTHONPATH=$PYTHONPATH:/usr/local/lib

# Install dep packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \	
    libusb-1.0-0 \
    udev \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

CMD [  "/bin/bash" ]