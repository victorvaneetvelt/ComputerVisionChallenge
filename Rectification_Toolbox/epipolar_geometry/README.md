
# Epipolar lines, rectification and disparity (rectificationGUI)
GUI to show the effects of camera positions on epipolar geometry as well as point to line correspondance. The fundamental matrix is estimated and some corresponding points are shown along with their epipolar lines.

Furthermore the epipoles is moved to the plane at infinity so the epipolar lines become parallel and the y-coordinates are aligned, this lets us do a 1D search for correspondanse as well as estimate disparity (difference in x-direction between corresponding points which gives depth information). The resulting rectified images are shown with the same corresponding points and epipoles.

After rectification there is also the option to look at disparity between the corresponding points (in the form of "Visualize") and perform dense stereomatching to obtain a disparity map.

Note that rectification may not work but the use of RANSAC leaves the execution non-deterministic so another run might work. Rectification results are determined by the epipoles placement relative to the image where farther away is better (at infinity is offcourse ideal). Also images have to be rich in structure and have as little rotational difference as possible for dense stereomatching to be effective.

# Projective depth
GUI to show binary space partitioning. Picking 3 points defines a plane (virtual or real), the plane induced homography can be checked against known point correspondances and the sign of the difference indicates a side of the plane. This way the points can be segmented on each side of the plane.

The GUI lets 3 points be picked continously to partition the rest on each side of the plane, displayed by difference in color.

Note that to make the point correspondances compatible with the epipolar geometry some point fitting to the epipolar lines are used, this is computationally expensive and may take a while when first executing the program. 
