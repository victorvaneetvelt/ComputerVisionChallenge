# stitching

To stitch two overlapping images together one needs to find (at least) 4 shared points between them and calculate the homography. Applying the homography aligns the image in such a way that it can be overlayed the reference image. 

To have educational value the user is free to find these 4 points in each image. If not one could also use the automatic stitching feature which will find matching points through feature extraction and do a homography fitting with RANSAC.

Note that for alignment to be proper the two image sceneries must be considered planar since the homography maps between planes. Scenery with a great distance to the camera may be approximated as a plane, otherwise the images must be taken with pure rotation around the camera center.

For more information: Corke p.431, Hartley/Zisserman p.206

When doing automatic stitching the corresponding points have to be found through feature extraction and comparison. Due to likely miss matches outlier detection have to be applied when fitting a homography to the data. If a linear transform is used to estimate the homography it is also important to normalize the data (with a centroid at (0,0) and a mean distance of $\sqrt{2}$ to it) to get proper results. This can be done with a similarity transform.

# usage

The stitching is performed through a GUI which uses a stitching class. The user may specify 4 correlating points in the two specified images and perform a stitch. More tile images can be added to the (right of the) reference if the user so pleases. If the automatic option is used SURF features are found and matched and a homography is fitted to the normalized data with RANSAC.

Options:
- 'High res' will switch out (all non-zero) pixels of the warped tile image with the reference instead of adding them on top of each other. 
- 'Show match' Lets the user see the SURF features which was found to be a match. Note that there can be many mismatches which RANSAC will sift out.
