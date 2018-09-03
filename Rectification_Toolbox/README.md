# image_processing_summer_17

A collection of MATLAB software using the image processing and computer vision toolbox to demonstrate single- and multiview geometry in uncalibrated computer vision.

The theory used can be found in [this](Applications_of_single__and_multiple_view_geometry_in_computer_vision.pdf) note and the lecture notes of TPK4170.

# usage
Run main.m and pick an application:
- Single view recovery: Recover affine ( parallel lines of a rectangle ) and/or metric properties ( perpendicular lines of a square ) by specifying a rectangle or square in the world scene.
- Stitching: Piece together (planar or purely rotated) images by specifying 4 corresponding points (or pressing auto) that define a homography.
- 3D recovery: Example of projective recovery (3D points) by triangulation with the canonical camera matrices and affine recovery by triangulation with the infinity homography from predetermined vanishing points.
- Rectification: Rectify two images taken with close to pure translation such that the epipolar lines are parallel and aligned. Also do a dense stereo-match and get the resulting binocular disparity map (dependent of the rectification result) recovering (affine) depth.
- Segmentation: Example using the results of rectification and disparity to segment out an object and make a 3D pointcloud.  
- Projective depth: Specify 3 points to make a virtual plane and partition the image points on either side of it.  
