#!/bin/sh

#PBS -N setup-python3
#PBS -l walltime=01:30:00
#PBS -l nodes=1:ppn=4:gpus=1
#PBS -j oe
#PBS -o setup-python3.log
#PBS -q k40_interactive

# Stop on error
set -e

# Set $HOME if running as a qsub script
if [ -z "$PBS_O_WORKDIR" ]; then
    export HOME=$PBS_O_WORKDIR
fi

# Retry wget errors (20 times) (e.q. 504)
# sourceforge in particular is not very stable
function wgetretry {
    wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1 ||
    wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1
}

# Unload already installed software
module unload gcc
module unload cuda
module unload cudnn

# Setup to use gnu compiler and hide warnings
export CC='gcc -w'
export CXX='g++ -w'

# Setup cuda path for theano
export CUDA_VERSION='8.0'
export CUDNN_VERSION='5.1'
export CUDA_PATH="/appl/cuda/${CUDA_VERSION}"
export CUDNN_PATH="/appl/cudnn/v${CUDNN_VERSION}-prod"

# load modules
module load python3
module load gcc/4.9.2
module load cuda/$CUDA_VERSION
module load cudnn/v$CUDNN_VERSION-prod
module load qt
module load boost

# Expand path
export PATH="$HOME/bin:$PATH"
export LD_LIBRARY_PATH=$HOME/lib:$LD_LIBRARY_PATH

# Use HOME directory as base
cd $HOME

#
# Start time
#
start_time=`date +%s`

#
# Setup virtual env
#
export PYTHONPATH=
python3 -m venv ~/stdpy3 --copies
source ~/stdpy3/bin/activate

#
# Upgrade pip
#
pip3 install -U pip

#
# Install basic python math
#
pip3 install -U numpy
pip3 install -U scipy

#
# Install matplotlib with Qt5 and basemap enabled
#

# install sip and pyqt5
pip3 install -U pyqt5

# Install matplotlib
pip3 install -U matplotlib

# Install basemap (matplotlib extension)
wgetretry http://downloads.sourceforge.net/project/matplotlib/matplotlib-toolkits/basemap-1.0.7/basemap-1.0.7.tar.gz
tar -xf basemap-1.0.7.tar.gz
cd basemap-1.0.7
cd geos-3.3.3
./configure --prefix=$HOME
make -j4
make install
cd ..
python3 setup.py install
cd $HOME
rm -rf basemap-1.0.7*

#
# Install data science
#
pip3 install -U scikit-learn
pip3 install -U pandas

#
# Install pyOpenCL
#

# Install mako (optional dependency for pyopencl)
pip3 install -U mako

# Install ctags (dependency for pyopencl)
wgetretry http://prdownloads.sourceforge.net/ctags/ctags-5.8.tar.gz
tar -xf ctags-5.8.tar.gz
cd ctags-5.8
./configure --prefix=$HOME
make -j4 install
cd $HOME
rm -rf ctags-5.8*

# Install pyOpenCL
wgetretry https://pypi.io/packages/source/p/pyopencl/pyopencl-2016.2.tar.gz
tar -xf pyopencl-2016.2.tar.gz
cd pyopencl-2016.2
python3 configure.py \
    --cl-inc-dir=$CUDA_PATH/include \
    --cl-lib-dir=$CUDA_PATH/lib \
    --cl-libname=OpenCL
make -j4 install
cd $HOME
rm -rf pyopencl-2016.2*

#
# Install theano
#

# Instal pydot (optional theano dependencies)
pip3 install https://bitbucket.org/prologic/pydot/get/ac76697320d6.zip
pip3 uninstall -y pyparsing
pip3 install -U pyparsing==2.0.6
patch -f stdpy3/lib/python3.6/site-packages/dot_parser.py \
<<EOF
--- a/stdpy3/lib/python3.6/site-packages/dot_parser.py
+++ b/stdpy3/lib/python3.6/site-packages/dot_parser.py
@@ -25,8 +25,9 @@
 from pyparsing import ( nestedExpr, Literal, CaselessLiteral, Word, Upcase, OneOrMore, ZeroOrMore,
     Forward, NotAny, delimitedList, oneOf, Group, Optional, Combine, alphas, nums,
     restOfLine, cStyleComment, nums, alphanums, printables, empty, quotedString,
-    ParseException, ParseResults, CharsNotIn, _noncomma, dblQuotedString, QuotedString, ParserElement )
+    ParseException, ParseResults, CharsNotIn, dblQuotedString, QuotedString, ParserElement )

+_noncomma = "".join([c for c in printables if c != ","])

 class P_AttrList:
EOF

# Upgrade cmake (libgpuarray dependency)
wgetretry https://cmake.org/files/v3.5/cmake-3.5.1.tar.gz
tar -xf cmake-3.5.1.tar.gz
cd cmake-3.5.1
./bootstrap --prefix=$HOME
make -j4
make install
cd $HOME
rm -rf cmake-3.5.1*

# Install libgpuarray (optional theano dependency)
# Note the HPC version of check.h is old, so ck_assert_ptr_ne is not defined
# since it is just the test files. Just remove the test.
git clone https://github.com/Theano/libgpuarray.git
cd libgpuarray
git checkout 5f074850581fd06f72e39659781a0e3405c49187
mkdir Build && cd Build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=~/
make -j4
make install
cd $HOME
rm -rf libgpuarray

# Install theano (development version)
pip3 install git+https://github.com/Theano/Theano.git

# Configure theano
cat > .theanorc <<EOF
[global]
device = gpu
floatX = float32

[cuda]
root = $CUDA_PATH

[lib]
cnmem = 1

[dnn]
enabled = True
include_path = $CUDNN_PATH/include
library_path = $CUDNN_PATH/lib64
EOF

# Install lasagne (development version)
pip3 install git+https://github.com/Lasagne/Lasagne.git

#
# Install TensorFlow
#

# install bazel (tensorflow dependency)
wgetretry https://github.com/bazelbuild/bazel/releases/download/0.4.3/bazel-0.4.3-dist.zip
unzip bazel-0.4.3-dist.zip -d bazel-0.4.3-dist
cd bazel-0.4.3-dist
CC=gcc CXX=g++ ./compile.sh
mkdir -p $HOME/bin
cp -f ./output/bazel $HOME/bin/bazel
cd $HOME
rm -rf bazel-0.4.3*

# configure bazel
cat > $HOME/.bazelrc <<EOF
# --batch: always run in batch mode, since there are some firewall issues.
# --output_user_root: HOME is NFS (filesystem), this will not work with bazel.
startup --batch --output_user_root=/tmp/$USER/.bazel
EOF

# create bazed output root directory
mkdir -p /tmp/$USER

# install wheel (used for building tensorflow pip package)
pip3 install -U wheel

# install tensorflow
git clone https://github.com/tensorflow/tensorflow
cd tensorflow
git checkout tags/v1.0.1

# apply patch for "could not find as"
curl -L https://raw.githubusercontent.com/AndreasMadsen/my-setup/master/dtu-hpc-python3/tensorflow.patch | git am -

# fix an issue with ldconfig not being in the $PATH
ln -fs /sbin/ldconfig $HOME/bin/ldconfig

# set configuration parameters

# GPUs appear to be on E5-26xx CPU machines, so optimize for sandybridge
# http://stackoverflow.com/questions/943755/gcc-optimization-flags-for-xeon
# Some nodes also has AVX2 and FMA support but these aren't avaliable on the
# login node, which is useful for running `tensorboard`
# https://en.wikipedia.org/wiki/List_of_Intel_Xeon_microprocessors#Xeon_E5-26xx_.28dual-processor.29

# The GPUs and cuda capability are 4x Tesla K40c (3.5), 8x Tesla K80c (3.7)
# and 8x TITAN X (6.1). Note that the k40sh also has a 1x Tesla K40c (3.5),
# 2x Tesla K20c (3.5), 1x GTX TITAN X (5.2). But we choose to not compile with
# cuda capability 5.2, since it takes longer to compile and it will still work.

# JEMALLOC is a better malloc and is by default enabled, however it depends
# on the MADV_NOHUGEPAGE linux feature, which is not avaliable here.

# XLA is a linear algebra optimizer, in v1 it is experimental and by default
# disabled. Confirm the default for now, but check back on it later, when it
# becomes stable.
export PYTHON_BIN_PATH=`which python3`
export CC_OPT_FLAGS='-march=sandybridge -w'
export TF_NEED_GCP=0
export TF_NEED_HDFS=0
export TF_NEED_CUDA=1
export TF_NEED_JEMALLOC=0
export TF_ENABLE_XLA=0
export TF_NEED_OPENCL=0
export GCC_HOST_COMPILER_PATH=`which gcc`
export TF_CUDA_VERSION=$CUDA_VERSION
export CUDA_TOOLKIT_PATH=$CUDA_PATH
export TF_CUDNN_VERSION=`echo $CUDNN_VERSION | head -c 1`
export CUDNN_INSTALL_PATH=$CUDNN_PATH
export TF_CUDA_COMPUTE_CAPABILITIES="3.5,3.7,6.1"

# configure tensorflow
yes "" 2>/dev/null | CC=gcc CXX=g++ ./configure

# build tensorflow
# use --verbose_failures -s for more verboseness
CC=gcc CXX=g++ bazel build \
  --ignore_unsupported_sandboxing --spawn_strategy=standalone \
  --config=opt --config=cuda \
  //tensorflow/tools/pip_package:build_pip_package

# build pip package
./bazel-bin/tensorflow/tools/pip_package/build_pip_package $HOME/tensorflow_pkg

# install tensorflow
# note that the path will change depending on the version
pip3 install -U $HOME/tensorflow_pkg/tensorflow-1.0.1-cp36-cp36m-linux_x86_64.whl

# cleanup bazel build files
bazel clean --expunge

# cleanup tensorflow
cd $HOME
rm -rf tensorflow tensorflow_pkg tensorflow.patch

# DONE
end_time=`date +%s`
run_time=$((end_time-start_time))

printf '\nInstall script finished. Took: %dh:%dm:%ds\n' \
  $(($run_time/3600)) $(($run_time%3600/60)) $(($run_time%60))

cat <<EOF
####################################
##                                ##
##       python3 installed        ##
##                                ##
####################################
EOF
