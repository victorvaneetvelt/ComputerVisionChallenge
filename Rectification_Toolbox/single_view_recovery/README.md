# single_view_rectification

MATLAB GUI which lets the users load an image and drag 4 points to mark the corners of a (world coordinate) square and perform a recovery. Each image is displayed side by side for visual comparison. 

The underlying classes consists of an abstract parent with the shared functionality (like loading, setting corners, etc.) and 2 subclasses where each one implements the different recovery methods specified in the vision note and applied with imwarp (which performs the transformation as well as interpolation). The only check implemented is a bounding box to abort recovery if the transformed image is too large for comfort.

Note: This works best for images with a moderate perspective, extreme projections leaves unsatisfactory results. 
