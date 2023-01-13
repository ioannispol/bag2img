FROM ros:noetic-ros-base
SHELL ["/bin/bash", "-c"]
WORKDIR /bag2img

COPY requirements.txt requirements.txt
COPY bag_2_image.py bag_2_image.py
#CMD apt update
RUN apt-get update && apt-get install -y \
  python3-pip \
  git \
  ros-$ROS_DISTRO-rosbag ros-$ROS_DISTRO-roslz4 \
  ros-$(rosversion -d)-cv-bridge \
  && rm -rf /var/lib/apt/lists/*
RUN pip install -r requirements.txt
#RUN [echo "$SHELL"]

# To use rosbag
#RUN apt install ros-$ROS_DISTRO-rosbag ros-$ROS_DISTRO-roslz4
RUN source /opt/ros/$ROS_DISTRO/setup.bash

#RUN apt-get install ros-$(rosversion -d)-cv-bridge

EXPOSE 8888

#ENTRYPOINT ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--no_browser"]
CMD [ "/bin/bash" ]
