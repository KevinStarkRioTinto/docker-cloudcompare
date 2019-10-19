# CloudCompare
A dockerised installation of the [CloudCompare](http://www.cloudcompare.org) application, designed for headless running. Inspired by previous work from [tyson-swetnam](https://github.com/tyson-swetnam/cloudcompare-docker/blob/master/18.04/Dockerfile) and [dorowu](https://github.com/fcwu/docker-ubuntu-vnc-desktop).

This container runs with a vnc remote desktop and contains the following CloudCompare plugins (pretty much everything I could find a `dflag` for that would compile on unix):

* E57 file format support [x]
* qPoissonRecon [x]
* LAS/LAZ using PDAL [x]
* PCL [x]
* Autodesk FBX [x]
* GDAL [x]

## Usage
Run the container with `docker run -p 5079:80 saracen9/cloudcompare` and the connect with `http://hostnameOrIPaddress:5079`.

For additional options such as vnc, http authentication and ssl certificate usage see the original base image [here](https://hub.docker.com/r/dorowu/ubuntu-desktop-lxde-vnc/).