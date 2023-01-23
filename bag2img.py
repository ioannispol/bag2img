import os
import pyrealsense2 as rs
import numpy as np
import cv2

# Create directories to save the images
if not os.path.exists("color_images"):
    os.mkdir("color_images")
if not os.path.exists("depth_images"):
    os.mkdir("depth_images")
if not os.path.exists("infrared_images"):
    os.mkdir("infrared_images")

# Configure depth and color streams
pipeline = rs.pipeline()
config = rs.config()
config.enable_stream(rs.stream.depth, 640, 480, rs.format.z16, 30)
config.enable_stream(rs.stream.color, 640, 480, rs.format.bgr8, 30)
config.enable_stream(rs.stream.infrared, 1, 640, 480, rs.format.y8, 30)
config.enable_stream(rs.stream.infrared, 2, 640, 480, rs.format.y8, 30)

# Start streaming from file
config.enable_device_from_file("./20221115_172244.bag")

pipeline.start(config)

frame_count = 0
while True:
    # Wait for a coherent pair of frames: depth and color
    frames = pipeline.wait_for_frames()
    depth_frame = frames.get_depth_frame()
    color_frame = frames.get_color_frame()
    infrared_frame_1 = frames.get_infrared_frame(1)
    infrared_frame_2 = frames.get_infrared_frame(2)

    # Convert images to numpy arrays
    depth_image = np.asanyarray(depth_frame.get_data())
    color_image = np.asanyarray(color_frame.get_data())
    infrared_image_1 = np.asanyarray(infrared_frame_1.get_data())
    infrared_image_2 = np.asanyarray(infrared_frame_2.get_data())

    # Apply colormap on depth image (image must be converted to 8-bit per pixel first)
    depth_colormap = cv2.applyColorMap(cv2.convertScaleAbs(depth_image, alpha=0.03), cv2.COLORMAP_JET)

    # Save the images
    cv2.imwrite("color_images/color_image_{}.jpg".format(frame_count), color_image)
    cv2.imwrite("depth_images/depth_image_{}.jpg".format(frame_count), depth_colormap)
    cv2.imwrite("infrared_images/infrared_image_1_{}.jpg".format(frame_count), infrared_image_1)
    cv2.imwrite("infrared_images/infrared_image_2_{}.jpg".format(frame_count), infrared_image_2)
    frame_count += 1

    # Stack all images horizontally
    images = np.hstack((color_image, depth_colormap, infrared_image_1, infrared_image_2))

    # Show images
    cv2.imshow("Images", images)
    key = cv2.waitKey(1)

    # Exit program if 'q' is pressed
    if key & 0xFF == ord('q'):
        cv2.destroyAllWindows()
        pipeline.stop()
        break
