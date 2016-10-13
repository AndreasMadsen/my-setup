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

# Load already installed software
module unload gcc
module unload cuda
module unload cudnn

module load python3
module load gcc/6.2.0
module load cuda/8.0
module load cudnn/v5.0-prod
module load qt
module load boost

# Setup to use gnu compiler and hide warnings
export CC='gcc -w'
export CXX='g++ -w'

# Setup cuda path for theano
export CUDA_PATH='/appl/cuda/8.0'
export CUDNN_PATH='/appl/cudnn/v5.0-prod'

# Expand path
export PATH="$HOME/bin:$PATH"

# Use HOME directory as base
cd $HOME

# Setup virtual env
export PYTHONPATH=
pyvenv ~/stdpy3 --copies
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
patch -f stdpy3/lib/python3.5/site-packages/dot_parser.py \
<<EOF
--- a/stdpy3/lib/python3.5/site-packages/dot_parser.py
+++ b/stdpy3/lib/python3.5/site-packages/dot_parser.py
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

# DONE
cat <<EOF
####################################
##                                ##
##       python3 installed        ##
##                                ##
####################################
EOF
