################################################################################
# Common runtime packages
FROM ubuntu:bionic AS common

ARG TZ=Etc/GMT
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install base requirements
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bc \
        ca-certificates \
        ffmpeg \
        gdal-bin \
        libpcl-dev \
        libqt5concurrent5 \
        locale \
        python3 \
        python3-gdal \
        python3-vtk7 \
        unzip \
        wget \
        xvfb \
        zip \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


################################################################################
# Build CloudCompare
FROM common AS cc_builder

# Build tools
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        software-properties-common \
        cmake \
        g++ \
        git \
        libssl-dev

# GIS repository
RUN add-apt-repository --yes ppa:ubuntugis/ppa && apt-get update

# Development packages
RUN apt-get install -y --no-install-recommends \
        # GDAL
        libgdal-dev \
        libproj-dev \
        # CloudCompare
        qttools5-dev \
        # libpcap-dev \
        # libpng-dev \
        libqt5opengl5-dev \
        libqt5svg5-dev \
        # python3-vtk7 \
        qtdeclarative5-dev \
        # # CGAL
        # libcgal-dev \
        libcgal-qt5-dev \
        # # qPhotoscan
        # zlib1g-dev \
        # # OpenGL
        # libglu1-mesa-dev \
        # freeglut3-dev \
        # mesa-common-dev \
        # mesa-utils
        # PCL
        libpcl-dev

#===============================================================================
# CloudCompare
WORKDIR /tmp/CloudCompare
# Clone
RUN git clone --recursive https://github.com/cloudcompare/CloudCompare.git .
RUN git submodule init && git submodule update

# Configure CMake
WORKDIR build
RUN cmake -G "Unix Makefiles" -H.. -B. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/opt/CloudCompare \
        -DJSON_ROOT_DIR=/usr/include/jsoncpp \
        #-----------------------------------------------------------------------
        # https://github.com/CloudCompare/CloudCompare/tree/master/plugins/core/GL
        # qEDL | Eye-dome Lighting OpenGL shader
        -DPLUGIN_GL_QEDL=ON \
        # qSSAO | Screen Space Ambient Occlusion OpenGL shader
        -DPLUGIN_GL_QSSAO=ON \
        #-----------------------------------------------------------------------
        # https://github.com/CloudCompare/CloudCompare/tree/master/plugins/core/Standard
        # qAnimation | Animation rendering plugin
        -DPLUGIN_STANDARD_QANIMATION=ON \
        -DWITH_FFMPEG_SUPPORT=ON \
        -DFFMPEG_INCLUDE_DIR=/usr/include/x86_64-linux-gnu \
        -DFFMPEG_LIBRARY_DIR=/usr/lib/x86_64-linux-gnu \
        # qBroom | Clean a point cloud with a virtual broom.
        -DPLUGIN_STANDARD_QBROOM=ON \
        # qCSF | A pointclouds filtering algorithm utilize cloth simulation process(Wuming Zhang; Jianbo Qi; Peng Wan,2015)
        -DPLUGIN_STANDARD_QCSF=ON \
        # qCompass | A virtual 'compass' for measuring outcrop orientations.
        -DPLUGIN_STANDARD_QCOMPASS=ON \
        # qFacets | BRGM Fracture detection plugin
        -DPLUGIN_STANDARD_QFACETS=ON \
        -DOPTION_USE_SHAPE_LIB=ON \
        # qHPR | Uses the Hidden Point Removal algorithm for approximating point visibility in an N dimensional point cloud, as seen from a given viewpoint.
        -DPLUGIN_STANDARD_QHPR=ON \
        # qHoughNormals | Uses the Hough transform to estimate normals in unstructured point clouds
        -DPLUGIN_STANDARD_QHOUGH_NORMALS=ON \
        -DEIGEN_ROOT_DIR=/usr/include/eigen3 \
        # qM3C2 | Multiscale Model to Model Cloud Comparison (M3C2)
        -DPLUGIN_STANDARD_QM3C2=ON \
        # qPCL | Point Cloud Library wrapper
        -DPLUGIN_STANDARD_QPCL=ON \
        # qPCV | Ambient Occlusion for mesh or point cloud
        -DPLUGIN_STANDARD_QPCV=ON \
        # qPoissonRecon | Surface Mesh Reconstruction (for closed surfaces)
        -DPLUGIN_STANDARD_QPOISSON_RECON=ON \
        -DPOISSON_RECON_WITH_OPEN_MP=ON \
        # qRANSAC_SD | Automatic RANSAC Shape Detection
        -DPLUGIN_STANDARD_QRANSAC_SD=ON \
        # qSRA | Comparison between a point cloud and a surface of revolution
        -DPLUGIN_STANDARD_QSRA=ON \
        -DOPTION_USE_DXF_LIB=ON \
        #-----------------------------------------------------------------------
        # https://github.com/CloudCompare/CloudCompare/tree/master/plugins/core/IO
        # qAdditionalIO | This plugin adds some less frequently used I/O formats to CloudCompare
        -DPLUGIN_IO_QADDITIONAL=ON \
        # qCSVMatrixIO | 2.5D CSV matrix I/O filter
        -DPLUGIN_IO_QCSV_MATRIX=ON \
        # qCoreIO | Allows reading & writing of many file formats.
        -DPLUGIN_IO_QCORE=ON \
        #-----------------------------------------------------------------------
        # GDAL | raster files support | https://github.com/cloudcompare/cloudcompare/blob/master/BUILD.md#optional-setup-for-gdal-support
        -DOPTION_USE_GDAL=ON \
        # Others
        -DCOMPILE_CC_CORE_LIB_WITH_TBB=ON \
        -DCOMPILE_CC_CORE_LIB_WITH_CGAL=ON

# Build & Install
RUN make
RUN make install


################################################################################
# Final Runtime
FROM common

COPY --from=cc_builder /opt/CloudCompare /opt/CloudCompare

ENV LD_LIBRARY_PATH="/opt/CloudCompare/lib:/opt/CloudCompare/lib/cloudcompare/plugins:$LD_LIBRARY_PATH"
ENV PATH="/opt/CloudCompare/bin:$PATH"

# Mount points for data and scripts
VOLUME [ "/data", "/work" ]

CMD /bin/sh -c 'xvfb-run CloudCompare -SILENT -CLEAR'
