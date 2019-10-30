# CloudCompare
A dockerised installation of the [CloudCompare](http://www.cloudcompare.org) application, designed for headless running. Inspired by previous work from [tyson-swetnam](https://github.com/tyson-swetnam/cloudcompare-docker/blob/master/18.04/Dockerfile) and [dorowu](https://github.com/fcwu/docker-ubuntu-vnc-desktop).

This container runs with a vnc remote desktop and contains the following CloudCompare plugins (pretty much everything I could find a `dflag` for that would compile on unix):

### GL
* `EDL`: Eye-dome Lighting OpenGL shader
* `SSAO`: Screen Space Ambient Occlusion OpenGL shader
### Standard
* `Animation`: Animation rendering plugin
* `Broom`: Clean a point cloud with a virtual broom
* `CSF`: A pointclouds filtering algorithm utilize cloth simulation process(Wuming Zhang; Jianbo Qi; Peng Wan,2015)
* ~~`Canupo`: Train or apply a classifier on a point cloud~~ # TODO: Unable to compile on Linux
* `Compass`: A virtual 'compass' for measuring outcrop orientations
* `Facets`: BRGM Fracture detection plugin
* `HPR`: Uses the Hidden Point Removal algorithm for approximating point visibility in an N dimensional point cloud, as seen from a given viewpoint
* `HoughNormals`: Uses the Hough transform to estimate normals in unstructured point clouds
* `M3C2`: Multiscale Model to Model Cloud Comparison (M3C2)
* `PCL`: Point Cloud Library wrapper
* `PCV`: Ambient Occlusion for mesh or point cloud
* `PoissonRecon`: Surface Mesh Reconstruction (for closed surfaces)
* `RANSAC_SD`: Automatic RANSAC Shape Detection
* SRA: Comparison between a point cloud and a surface of revolution
### IO
* `AdditionalIO`: This plugin adds some less frequently used I/O formats to CloudCompare
* `CSVMatrixIO`: 2.5D CSV matrix I/O filter
* `CoreIO`: Allows reading & writing of many file formats
* `E57IO`: Add E57 read/write capability using the libE57Format library
* `FBXIO`: Add FBX read/write capability using AutoDesk's FBX SDK
* `PDALIO`: Add LAS read/write capability using the PDAL library
* `PhotoscanIO`: Photoscan (PSZ) I/O filter

## Usage
Run the container with `docker run -p 5079:80 saracen9/cloudcompare` and the connect with `http://hostnameOrIPaddress:5079`.

For additional options such as vnc, http authentication and ssl certificate usage see the original base image [here](https://hub.docker.com/r/dorowu/ubuntu-desktop-lxde-vnc/).