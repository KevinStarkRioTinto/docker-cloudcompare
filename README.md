# CloudCompare

A dockerised installation of the [CloudCompare](http://www.cloudcompare.org) application, designed for headless running of scripts only. Derived from [darth-veitcher/docker-cloudcompare](https://github.com/darth-veitcher/docker-cloudcompare) and adapted for multistage build and removal of VNC features.

The list of available CloudCompare commands is detailed here: <https://www.cloudcompare.org/doc/wiki/index.php?title=Command_line_mode>

This container runs only as a headless script execution runtime and contains the following CloudCompare plugins (pretty much everything I could find a `dflag` for that would compile on unix):

### GL

- `EDL`: Eye-dome Lighting OpenGL shader
- `SSAO`: Screen Space Ambient Occlusion OpenGL shader

### Standard

- `Animation`: Animation rendering plugin
- `Broom`: Clean a point cloud with a virtual broom
- `CSF`: A pointclouds filtering algorithm utilize cloth simulation process(Wuming Zhang; Jianbo Qi; Peng Wan,2015)
- ~~`Canupo`: Train or apply a classifier on a point cloud~~ # TODO: Unable to compile on Linux
- `Compass`: A virtual 'compass' for measuring outcrop orientations
- `Facets`: BRGM Fracture detection plugin
- `HPR`: Uses the Hidden Point Removal algorithm for approximating point visibility in an N dimensional point cloud, as seen from a given viewpoint
- `HoughNormals`: Uses the Hough transform to estimate normals in unstructured point clouds
- `M3C2`: Multiscale Model to Model Cloud Comparison (M3C2)
- `PCL`: Point Cloud Library wrapper
- `PCV`: Ambient Occlusion for mesh or point cloud
- `PoissonRecon`: Surface Mesh Reconstruction (for closed surfaces)
- `RANSAC_SD`: Automatic RANSAC Shape Detection
- SRA: Comparison between a point cloud and a surface of revolution

### IO

- `AdditionalIO`: This plugin adds some less frequently used I/O formats to CloudCompare
- `CSVMatrixIO`: 2.5D CSV matrix I/O filter
- `CoreIO`: Allows reading & writing of many file formats
- `E57IO`: Add E57 read/write capability using the libE57Format library
- ~~`FBXIO`: Add FBX read/write capability using AutoDesk's FBX SDK~~
- `PDALIO`: Add LAS read/write capability using the PDAL library
- `PhotoscanIO`: Photoscan (PSZ) I/O filter

## Usage

CloudCompare is usually called multiple times as part of a more complex workflow, wrapped in a python or shell script.

```sh
docker run -v {local data}:/data -v {local scripts}:/work kevinstarkriotinto/cloudcompare:latest {script to run}
```

**Examples**

```sh
# Minimal
$ docker run kevinstarkriotinto/cloudcompare:latest /bin/sh -c 'xvfb-run CloudCompare -SILENT -CLEAR'
# QSocketNotifier: Can only be used with threads started with QThread
# QStandardPaths: XDG_RUNTIME_DIR not set, defaulting to '/tmp/runtime-root'
# [Global Shift] Max abs. coord = 1e+4 / max abs. diag = 1e+6
# [ccColorScalesManager] Found 0 custom scale(s) in persistent settings
# [Plugin] Searching: /opt/CloudCompare/lib/cloudcompare/plugins
#         Plugin found: Additional I/O (libQADDITIONAL_IO_PLUGIN.so)
#         Plugin found: Animation (libQANIMATION_PLUGIN.so)
#         Plugin found: CEA Virtual Broom (libQBROOM_PLUGIN.so)
#         Plugin found: Compass (libQCOMPASS_PLUGIN.so)
#         Plugin found: Core I/O (libQCORE_IO_PLUGIN.so)
#         Plugin found: CSF Filter (libQCSF_PLUGIN.so)
#         Plugin found: CSV Matrix I/O (libQCSV_MATRIX_IO_PLUGIN.so)
#         Plugin found: EDL Shader (libQEDL_GL_PLUGIN.so)
#         Plugin found: Facet/fracture detection (libQFACETS_PLUGIN.so)
#         Plugin found: Hough Normals Computation (libQHOUGH_NORMALS_PLUGIN.so)
#         Plugin found: Hidden Point Removal (libQHPR_PLUGIN.so)
#         Plugin found: M3C2 Distance (libQM3C2_PLUGIN.so)
#         Plugin found: PCD file I/O (libQPCL_IO_PLUGIN.so)
#         Plugin found: PCL wrapper (libQPCL_PLUGIN.so)
#         Plugin found: PCV / ShadeVis (libQPCV_PLUGIN.so)
#         Plugin found: PoissonRecon (libQPOISSON_RECON_PLUGIN.so)
#         Plugin found: RANSAC Shape Detection (libQRANSAC_SD_PLUGIN.so)
#         Plugin found: Surface of Revolution Analysis (libQSRA_PLUGIN.so)
#         Plugin found: SSAO Shader (libQSSAO_GL_PLUGIN.so)
# [Plugin] Searching: /root/.local/share/CCCorp/CloudCompare/plugins
# [Plugin] Searching: /usr/local/share/CCCorp/CloudCompare/plugins
# [Plugin] Searching: /usr/share/CCCorp/CloudCompare/plugins
# [Plugin][Additional I/O] New file extensions registered: ICM OUT PN POLY POV PV SOI SX
# [Plugin][Core I/O] New file extensions registered:  GEOREF MA OBJ OFF PDMS PTX SBF STL VTK
# [Plugin][CSV Matrix I/O] New file extensions registered: CSV
# [Plugin][PCD file I/O] New file extensions registered: PCD
# Processed finished in 0.00 s.
```
