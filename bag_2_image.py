#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright 2016 Massachusetts Institute of Technology
# Tutorial : http://wiki.ros.org/rosbag/Code%20API#Python_API
"""
    Extract images from a rosbag.
    How to use: In terminal, cd DIRECTORY_OF_THIS_FILE and then type following
                python bag_to_images.py --bag_file camera_odom_compressed.bag --output_dir output/ --image_topic '/camera/image_raw'
                python bag_to_images.py --bag_file my_rosbag_file.bag --output_dir output/ --image_topic '/eGolf/front_cam/image_raw'
"""

import os
import argparse
import cv2
import rosbag
#from pyrosenv.sensor_msgs.msg import Image
from sensor_msgs.msg import Image
from cv_bridge import CvBridge
import numpy as np
#from progressbar import printProgressBar

def main():
    """Extract a folder of images from a rosbag.
    """
    parser = argparse.ArgumentParser(description="Extract images from a ROS bag.")
    parser.add_argument("--bag_file", help="Input ROS bag.")
    parser.add_argument("--output_dir", help="Output directory.")
    parser.add_argument("--image_topic", help="single image topic or list of topics")

    args = parser.parse_args()

    print ("Extract images from %s on topic %s into %s" % (args.bag_file,
                                                          args.image_topic, args.output_dir))
    # Create output directory if doesnt exist
    if not os.path.exists(args.output_dir):
            os.makedirs(args.output_dir)

    bag = rosbag.Bag(args.bag_file, "r")
    bridge = CvBridge()
    print("Duration:", bag.get_end_time()-bag.get_start_time(),"sec")
    topics= bag.get_type_and_topic_info()[1].keys() #all the topics info
    print("\nAvailable topics in bag file are:{}".format(topics))
    total_frames = bag.get_message_count(args.image_topic) #Total frames in topic
    print("\nTotal frames in bag file are:{}".format(total_frames))
    types=[] #infor about each topic types
    for i in range(0,len(bag.get_type_and_topic_info()[1].values())):
        types.append(bag.get_type_and_topic_info()[1].values())
    # print("\nTypes are: {}".format(types))
    for topic, msg, t in bag.read_messages(topics=[args.image_topic]):
        print("Size of the image: W {} x H {}".format(msg.width, msg.height))
        print("Encoding of the frames: {}".format(msg.encoding))
        break

    basename = os.path.splitext(os.path.basename(args.bag_file))[0]
    count = 0
    #printProgressBar(0, total_frames, prefix='writing frames:'.ljust(15), suffix='Complete')
    for topic, msg, t in bag.read_messages(topics=[args.image_topic]):
        #cv_img = bridge.imgmsg_to_cv2(msg, desired_encoding="passthrough")  # gray image ouput

        # # CONVERT MESSAGE TO A NUMPY ARRAY
        # img = np.fromstring(msg.data, dtype=np.uint8)
        # img = img.reshape(msg.height, msg.width)
        #
        # # CONVERT TO RGB
        # cv_img = cv2.cvtColor(img, cv2.COLOR_GRAY2RGB)

        cv_img = bridge.imgmsg_to_cv2(msg, "mono8")         # RGB output
        
        p = os.path.join(args.output_dir, basename)
        p = p + "_{:05}".format(count)+".png"
        cv2.imwrite(p, cv_img)
        #cv2.imwrite(os.path.join(args.output_dir, "frame%06i.png" % count), cv_img)
        # print ("Wrote image %i" % count)
        count += 1
        #printProgressBar(count, total_frames, prefix='writing frames:'.ljust(15), suffix='Complete')


    bag.close()
    print("extracted images")
    return

if __name__ == '__main__':
    main()