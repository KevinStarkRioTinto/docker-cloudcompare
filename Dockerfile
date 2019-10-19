# https://github.com/tyson-swetnam/cloudcompare-docker/blob/master/18.04/Dockerfile
# https://github.com/fcwu/docker-ubuntu-vnc-desktop
FROM dorowu/ubuntu-desktop-lxde-vnc as Base
RUN export DEBIAN_FRONTEND=noninteractive

# Install base requirements
RUN apt-get update && apt-get install -y qtdeclarative5-dev \
        build-essential g++ git cmake libqt5svg5-dev qttools5-dev unzip wget apt-utils \
        ffmpeg \
        libavcodec-dev \
        libavformat-dev \
        libavutil-dev \
        libeigen3-dev \
        libqt5opengl5-dev \
        libswscale-dev \
        libtbb-dev \
        libxerces-c-dev \
        # PDAL
        libssl-dev \
        python3-dev \
        # CGAL
        libcgal-dev \
        libcgal-qt5-dev

    # && apt-get -y autoremove \
    # && apt-get clean && \
	# && rm -rf /var/lib/apt/lists/*

# Install OpenGL Drivers
RUN apt-get update && \
    apt-get install -y libglu1-mesa-dev freeglut3-dev mesa-common-dev mesa-utils

# GDAL
# Add the UbuntuGIS PPA https://launchpad.net/~ubuntugis/+archive/ubuntu/ppa
# (can also use to install QGIS later)
RUN add-apt-repository --yes ppa:ubuntugis/ppa && \
    apt-get update && \
    apt-get install -y libproj-dev libgdal-dev && \
    apt-get upgrade -y && \
    apt-get install -y gdal-bin python-gdal python3-gdal libgeotiff-dev libjsoncpp-dev python-numpy

# LASZIP
# https://github.com/LASzip/LASzip.git
RUN mkdir -p /tmp/LASzip && \
    cd /tmp/LASzip && \
    git init && \
    git remote add origin https://github.com/LASzip/LASzip.git && \
    git fetch --tags && \
    latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
    cd /root && rm -rf /tmp/LASzip && \
    git clone --branch $latestTag --depth 1 https://github.com/LASzip/LASzip.git LASzip
RUN mkdir -p LASzip/build && \
    cd LASzip/build && \
    cmake -G "Unix Makefiles" -H/root/LASzip -B/root/LASzip/build \
    && make && \
    make install

# EIGEN
RUN wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/eigen3/3.3.4-2/eigen3_3.3.4.orig.tar.bz2 && \
    tar xvjf eigen* && \
    cd eigen-eigen* && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
    .. && \
    make && \
    make install

# PDAL
# https://pdal.io/development/compilation/unix.html
# https://github.com/CloudCompare/CloudCompare/blob/master/BUILD.md#optional-setup-for-las-using-pdal
RUN mkdir -p /tmp/PDAL && \
    cd /tmp/PDAL && \
    git init && \
    git remote add origin https://github.com/PDAL/PDAL.git && \
    git fetch --tags && \
    latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
    cd /root && rm -rf /tmp/PDAL && \
    git clone --branch $latestTag --depth 1 https://github.com/PDAL/PDAL.git PDAL
RUN mkdir PDAL/build && \
    cd PDAL/build && \
    cmake -G "Unix Makefiles" -H/root/PDAL -B/root/PDAL/build \
        -DCMAKE_BUILD_TYPE=Release \
        -DWITH_TESTS=OFF \
        -DWITH_LASZIP=ON \
        -DBUILD_PLUGIN_PYTHON=ON \
        -DBUILD_PLUGIN_PGPOINTCLOUD=ON \
    && make && \
    make install

# FBX
# https://github.com/CloudCompare/CloudCompare/blob/master/BUILD.md#optional-setup-for-fbx-sdk-support
# https://www.autodesk.com/developer-network/platform-technologies/fbx-sdk-2016-1-2
RUN wget -O "fbx.tar.gz" "http://download.autodesk.com/us/fbx_release_older/2016.1.2/fbx20161_2_fbxsdk_linux.tar.gz" && \
    mkdir -p fbx && \
    tar xf "fbx.tar.gz" --directory="fbx" && \
    chmod +x fbx/fbx20161_2_fbxsdk_linux && \
    mkdir -p /usr/fbxsdk && \
    echo "yes\nno\n" | fbx/fbx20161_2_fbxsdk_linux /usr/fbxsdk

# PCL
RUN apt-get install -y libpcl-dev

# RUN /sbin/ldconfig

# Install CloudCompare
# use Dflags for enabled plugins
RUN git clone --recursive https://github.com/cloudcompare/CloudCompare.git && \
    mkdir -p CloudCompare/build && \
    cd /root/CloudCompare/build && \
    git submodule init && \
    git submodule update && \
    cmake -G "Unix Makefiles" -H/root/CloudCompare -B/root/CloudCompare/build \
        -DCMAKE_BUILD_TYPE=Release \
        ############################
        # PLUGINS
        ############################
        # -- Standard
        # https://github.com/CloudCompare/CloudCompare/tree/master/plugins/core/Standard
        ############################
        # qPoissonRecon | Surface Mesh Reconstruction (for closed surfaces)
        -DPLUGIN_STANDARD_QPOISSON_RECON=ON \
        -DPOISSON_RECON_WITH_OPEN_MP=ON \
        # qAnimation | Animation rendering plugin
        -DPLUGIN_STANDARD_QANIMATION=ON \
        -DWITH_FFMPEG_SUPPORT=ON \
        -DFFMPEG_INCLUDE_DIR=/usr/include/x86_64-linux-gnu \
        -DFFMPEG_LIBRARY_DIR=/usr/lib/x86_64-linux-gnu \
        # qHoughNormals | Uses the Hough transform to estimate normals in unstructured point clouds
        -DPLUGIN_STANDARD_QHOUGH_NORMALS=ON \
        -DEIGEN_ROOT_DIR=/usr/include/eigen3 \
        ############################
        # -- IO
        # https://github.com/CloudCompare/CloudCompare/tree/master/plugins/core/IO
        ############################
        # qE57IO | Add E57 read/write capability using the libE57Format library
        -DPLUGIN_IO_QE57=ON \
        # qFBXIO | Add FBX read/write capability using AutoDesk's FBX SDK
        -DPLUGIN_IO_QFBX=ON \
        -DFBX_SDK_INCLUDE_DIR=/usr/fbxsdk/include \
        -DFBX_SDK_LIBRARY_FILE=/usr/fbxsdk/lib/gcc4/x64/release/libfbxsdk.so \
        # qPDALIO | Add LAS read/write capability using the PDAL library. | https://github.com/cloudcompare/cloudcompare/blob/master/BUILD.md#optional-setup-for-las-using-pdal
        -DPLUGIN_IO_QPDAL=TRUE \
        ############################
        # Misc other flags
        ############################
        # GDAL | raster files support | https://github.com/cloudcompare/cloudcompare/blob/master/BUILD.md#optional-setup-for-gdal-support
        -DOPTION_USE_GDAL=ON \
        # Others
        -DCOMPILE_CC_CORE_LIB_WITH_TBB=ON \
        -DCOMPILE_CC_CORE_LIB_WITH_CGAL=ON \
        -DOPTION_USE_SHAPE_LIB=ON \
        -DOPTION_USE_DXF_LIB=ON \
        -DJSON_ROOT_DIR=/usr/include/jsoncpp \
        # -DINSTALL_QADDITIONAL_IO_PLUGIN=ON \
        # -DINSTALL_QBROOM_PLUGIN=ON \
        # -DINSTALL_QCOMPASS_PLUGIN=ON \
        # -DINSTALL_QCSF_PLUGIN=ON \
        # -DINSTALL_QEDL_PLUGIN=ON \
        # -DINSTALL_QFACETS_PLUGIN=ON \
        # -DINSTALL_QHPR_PLUGIN=ON \
        # -DINSTALL_QM3C2_PLUGIN=ON \
        # -DINSTALL_QPCV_PLUGIN=ON \
        # -DINSTALL_QPHOTOSCAN_IO_PLUGIN=ON \
        # -DINSTALL_QSRA_PLUGIN=ON \
        # -DINSTALL_QSSAO_PLUGIN=ON \
        && \
    make && \
    make install

# build info
RUN echo "Timestamp:" `date --utc` | tee /image-build-info.txt