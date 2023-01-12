FROM ros:noetic-ros-base
WORKDIR /bag2img

COPY requirements.txt requirements.txt
COPY bag_2_image.py bag_2_image.py

RUN apt-get update && apt-get install -y \
  python3-pip \
  git \
  ros-$ROS_DISTRO-rosbag ros-$ROS_DISTRO-roslz4 \
  ros-$(rosversion -d)-cv-bridge \
  pip3 install -r requirements.txt

SHELL ["/bin/bash", "-c"]

RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc

CMD [ "/bin/bash" ]