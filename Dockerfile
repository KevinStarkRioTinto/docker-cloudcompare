FROM ubuntu:bionic

ARG TZ=Etc/GMT
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install base requirements
RUN apt-get update                                                          && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends  \
        unzip wget git cmake g++                                               \
        software-properties-common apt-utils build-essential                   \
        qtdeclarative5-dev libqt5svg5-dev qttools5-dev                         \
        ffmpeg                                                                 \
        libavcodec-dev                                                         \
        libavformat-dev                                                        \
        libavutil-dev                                                          \
        libeigen3-dev                                                          \
        libqt5opengl5-dev                                                      \
        libswscale-dev                                                         \
        libtbb-dev                                                             \
        libxerces-c-dev                                                        \
        # PDAL
        libssl-dev                                                             \
        python3-dev                                                            \
        # CGAL
        libcgal-dev                                                            \
        libcgal-qt5-dev                                                        \
        # qPhotoscan
        zip                                                                    \
        zlib1g-dev                                                             \
        # OpenGL
        libglu1-mesa-dev                                                       \
        freeglut3-dev                                                          \
        mesa-common-dev                                                        \
        mesa-utils                                                             \
        # dlib
        # python3-setuptools                                                   \
        # CC
        libpng-dev                                                             \
        libusb-dev                                                             \
        libpcap-dev                                                            \
        python3-vtk7                                                           \
        # X virtual frame buffer
        xvfb

# GDAL
# Add the UbuntuGIS PPA https://launchpad.net/~ubuntugis/+archive/ubuntu/ppa
# (can also use to install QGIS later)
RUN add-apt-repository --yes ppa:ubuntugis/ppa                              && \
    apt-get update                                                          && \
    apt-get install -y --no-install-recommends                                 \
        libgdal-dev                                                            \
        libproj-dev                                                         && \
    apt-get upgrade -y                                                      && \
    apt-get install -y --no-install-recommends                                 \
        gdal-bin                                                               \
        python-gdal                                                            \
        python3-gdal                                                           \
        libgeotiff-dev                                                         \
        libjsoncpp-dev                                                         \
        python-numpy

# LASZIP
# https://github.com/LASzip/LASzip.git
RUN mkdir -p /tmp/LASzip                                                    && \
    cd /tmp/LASzip                                                          && \
    git init                                                                && \
    git remote add origin https://github.com/LASzip/LASzip.git              && \
    git fetch --tags                                                        && \
    latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)    && \
    cd ~ && rm -rf /tmp/LASzip                                              && \
    git clone --branch $latestTag --depth 1 https://github.com/LASzip/LASzip.git /tmp/LASzip
RUN mkdir -p /tmp/LASzip/build                                              && \
    cd /tmp/LASzip/build                                                    && \
    cmake -G "Unix Makefiles" -H/tmp/LASzip -B/tmp/LASzip/build             && \
    make                                                                    && \
    make install                                                            && \
    cd ~ && rm -rf /tmp/LASzip

# EIGEN
RUN cd /tmp                                                                 && \
    wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/eigen3/3.3.4-2/eigen3_3.3.4.orig.tar.bz2 && \
    tar xvjf eigen*                                                         && \
    cd eigen-eigen*                                                         && \
    # Configure
    mkdir build                                                             && \
    cd build                                                                && \
    cmake -DCMAKE_BUILD_TYPE=Release ..                                     && \
    # Build & install
    make                                                                    && \
    make install                                                            && \
    # Cleanup
    cd ~ && rm -rf /tmp/eigen-eigen*

# # FBX
# # https://github.com/CloudCompare/CloudCompare/blob/master/BUILD.md#optional-setup-for-fbx-sdk-support
# # https://www.autodesk.com/developer-network/platform-technologies/fbx-sdk-2016-1-2
# RUN wget -O "fbx.tar.gz" "http://download.autodesk.com/us/fbx_release_older/2016.1.2/fbx20161_2_fbxsdk_linux.tar.gz" && \
#     mkdir -p fbx && \
#     tar xf "fbx.tar.gz" --directory="fbx" && \
#     chmod +x fbx/fbx20161_2_fbxsdk_linux && \
#     mkdir -p /usr/fbxsdk && \
#     echo "yes\nn" | fbx/fbx20161_2_fbxsdk_linux /usr/fbxsdk

# PDAL
# https://pdal.io/development/compilation/unix.html
# https://github.com/CloudCompare/CloudCompare/blob/master/BUILD.md#optional-setup-for-las-using-pdal
RUN mkdir -p /tmp/PDAL                                                      && \
    cd /tmp/PDAL                                                            && \
    git init                                                                && \
    git remote add origin https://github.com/PDAL/PDAL.git                  && \
    git fetch --tags                                                        && \
    latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)    && \
    cd ~ && rm -rf /tmp/PDAL                                                && \
    git clone --branch $latestTag --depth 1 https://github.com/PDAL/PDAL.git /tmp/PDAL
RUN mkdir /tmp/PDAL/build                                                   && \
    cd /tmp/PDAL/build                                                      && \
    cmake -G "Unix Makefiles" -H/tmp/PDAL -B/tmp/PDAL/build                    \
        -DCMAKE_BUILD_TYPE=Release                                             \
        -DWITH_TESTS=OFF                                                       \
        -DWITH_LASZIP=ON                                                       \
        -DBUILD_PLUGIN_PYTHON=ON                                               \
        -DBUILD_PLUGIN_PGPOINTCLOUD=ON &&                                      \
    make                                                                    && \
    make install                                                            && \
    cd ~ && rm -rf /tmp/PDAL

# PCL
RUN apt-get install -y --no-install-recommends libpcl-dev

# # Dlib (required for qCanupo plugin)
# # https://github.com/davisking/dlib
# RUN mkdir -p /tmp/dlib && \
#     cd /tmp/dlib && \
#     git clone https://github.com/davisking/dlib /tmp/dlib && \
#     mkdir -p /tmp/dlib/build && \
#     cd /tmp/dlib/build && \
#     cmake -G "Unix Makefiles" -H/tmp/dlib -B/tmp/dlib/build && \
#     make && \
#     make install && \
#     cd .. && \
#     python3 setup.py install

RUN /sbin/ldconfig

RUN ln -s /usr/lib/x86_64-linux-gnu/libvtkCommonCore-6.2.so /usr/lib/libvtkproj4.so

# Install CloudCompare
# use Dflags for enabled plugins
RUN cd /tmp                                                                 && \
    git clone --recursive https://github.com/cloudcompare/CloudCompare.git  && \
    mkdir -p CloudCompare/build                                             && \
    cd /tmp/CloudCompare/build                                              && \
    git submodule init                                                      && \
    git submodule update                                                    && \
    cmake -G "Unix Makefiles" -H/tmp/CloudCompare -B/tmp/CloudCompare/build    \
        -DCMAKE_BUILD_TYPE=Release                                             \
        -DCMAKE_INSTALL_PREFIX=/opt/CloudCompare                               \
        ############################
        # PLUGINS
        ############################
        # -- GL
        # https://github.com/CloudCompare/CloudCompare/tree/master/plugins/core/GL
        ############################
        # qEDL | Eye-dome Lighting OpenGL shader
        -DPLUGIN_GL_QEDL=ON                                                    \
        # qSSAO | Screen Space Ambient Occlusion OpenGL shader
        -DPLUGIN_GL_QSSAO=ON                                                   \
        ############################
        # -- Standard
        # https://github.com/CloudCompare/CloudCompare/tree/master/plugins/core/Standard
        ############################
        # qAnimation | Animation rendering plugin
        -DPLUGIN_STANDARD_QANIMATION=ON                                        \
        -DWITH_FFMPEG_SUPPORT=ON                                               \
        -DFFMPEG_INCLUDE_DIR=/usr/include/x86_64-linux-gnu                     \
        -DFFMPEG_LIBRARY_DIR=/usr/lib/x86_64-linux-gnu                         \
        # qBroom | Clean a point cloud with a virtual broom.
        -DPLUGIN_STANDARD_QBROOM=ON                                            \
        # qCSF | A pointclouds filtering algorithm utilize cloth simulation process(Wuming Zhang; Jianbo Qi; Peng Wan,2015)
        -DPLUGIN_STANDARD_QCSF=ON                                              \
        # qCanupo | Train or apply a classifier on a point cloud.
        # -DPLUGIN_STANDARD_QCANUPO=ON \
        # -DDLIB_ROOT=/usr/local/include/dlib \
        # qCompass | A virtual 'compass' for measuring outcrop orientations.
        -DPLUGIN_STANDARD_QCOMPASS=ON                                          \
        # qFacets | BRGM Fracture detection plugin
        -DPLUGIN_STANDARD_QFACETS=ON                                           \
        -DOPTION_USE_SHAPE_LIB=ON                                              \
        # qHPR | Uses the Hidden Point Removal algorithm for approximating point visibility in an N dimensional point cloud, as seen from a given viewpoint.
        -DPLUGIN_STANDARD_QHPR=ON                                              \
        # qHoughNormals | Uses the Hough transform to estimate normals in unstructured point clouds
        -DPLUGIN_STANDARD_QHOUGH_NORMALS=ON                                    \
        -DEIGEN_ROOT_DIR=/usr/include/eigen3                                   \
        # qM3C2 | Multiscale Model to Model Cloud Comparison (M3C2)
        -DPLUGIN_STANDARD_QM3C2=ON                                             \
        # qPCL | Point Cloud Library wrapper
        -DPLUGIN_STANDARD_QPCL=ON                                              \
        # qPCV | Ambient Occlusion for mesh or point cloud
        -DPLUGIN_STANDARD_QPCV=ON                                              \
        # qPoissonRecon | Surface Mesh Reconstruction (for closed surfaces)
        -DPLUGIN_STANDARD_QPOISSON_RECON=ON                                    \
        -DPOISSON_RECON_WITH_OPEN_MP=ON                                        \
        # qRANSAC_SD | Automatic RANSAC Shape Detection
        -DPLUGIN_STANDARD_QRANSAC_SD=ON                                        \
        # qSRA | Comparison between a point cloud and a surface of revolution
        -DPLUGIN_STANDARD_QSRA=ON                                              \
        -DOPTION_USE_DXF_LIB=ON                                                \
        ############################
        # -- IO
        # https://github.com/CloudCompare/CloudCompare/tree/master/plugins/core/IO
        ############################
        # qAdditionalIO | This plugin adds some less frequently used I/O formats to CloudCompare
        -DPLUGIN_IO_QADDITIONAL=ON                                             \
        # qCSVMatrixIO | 2.5D CSV matrix I/O filter
        -DPLUGIN_IO_QCSV_MATRIX=ON                                             \
        # qCoreIO | Allows reading & writing of many file formats.
        -DPLUGIN_IO_QCORE=ON                                                   \
        # qE57IO | Add E57 read/write capability using the libE57Format library
        -DPLUGIN_IO_QE57=ON                                                    \
        ## qFBXIO | Add FBX read/write capability using AutoDesk's FBX SDK
        #-DPLUGIN_IO_QFBX=ON \
        #-DFBX_SDK_INCLUDE_DIR=/usr/fbxsdk/include \
        #-DFBX_SDK_LIBRARY_FILE=/usr/fbxsdk/lib/gcc4/x64/release/libfbxsdk.so \
        # qPDALIO | Add LAS read/write capability using the PDAL library. | https://github.com/cloudcompare/cloudcompare/blob/master/BUILD.md#optional-setup-for-las-using-pdal
        -DPLUGIN_IO_QPDAL=TRUE                                                 \
        # qPhotoscanIO | Photoscan (PSZ) I/O filter
        -DPLUGIN_IO_QPHOTOSCAN=ON                                              \
        ############################
        # Misc other flags
        ############################
        # GDAL | raster files support | https://github.com/cloudcompare/cloudcompare/blob/master/BUILD.md#optional-setup-for-gdal-support
        -DOPTION_USE_GDAL=ON                                                   \
        # Others
        -DCOMPILE_CC_CORE_LIB_WITH_TBB=ON                                      \
        -DCOMPILE_CC_CORE_LIB_WITH_CGAL=ON                                     \
        -DJSON_ROOT_DIR=/usr/include/jsoncpp                                && \
    make                                                                    && \
    make install                                                            && \
    cd ~ && rm -rf /tmp/CloudCompare

RUN /sbin/ldconfig -v
ENV LD_LIBRARY_PATH="/opt/CloudCompare/lib/cloudcompare:$LD_LIBRARY_PATH"
ENV PATH="/opt/CloudCompare/bin:$PATH"

# build info and cleanup
RUN apt-get -y autoremove && \
    apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
    echo "Timestamp:" `date --utc` | tee /image-build-info.txt