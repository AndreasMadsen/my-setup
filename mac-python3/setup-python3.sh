#!/bin/sh

# Always
brew update
export HOMEBREW_MAKE_JOBS=4
cd $HOME

#
# Install build tools
#

# Install wget
brew install wget
# Install gfortran
brew install gcc
brew link --overwrite gcc
# Install buildtools
brew install cmake

#
# Install Python 3 with openssl
#
brew install openssl
brew install python3
brew linkapps python3
pip3 install --upgrade pip setuptools wheel

#
# Install math tools
#
brew install homebrew/python/numpy --with-python3 --without-python
brew install homebrew/python/scipy --with-python3 --without-python --default-fortran-flags

#
# Install matplotlib (with Qt5, cario and basemap)
#
brew install pyqt5 --with-python3 --without-python
brew install homebrew/python/matplotlib --with-python3 --without-python --with-cairo --with-pyqt5
brew install homebrew/python/matplotlib-basemap --with-python3 --without-python

#
# Install pyOpenCL
#
pip3 install -U mako
pip3 install -U pyopencl

#
# Install theano
#

# Install pydot
pip3 instal pydot

# Install clBLAS
git clone https://github.com/clMathLibraries/clBLAS.git
cd clBLAS
git checkout develop
mkdir build && cd build
cmake ../src -DCMAKE_BUILD_TYPE=Release
make && make install
cd ../..
rm -rf clBLAS

# Install libgpuarray
pip3 install cython
pip3 install tools
git clone https://github.com/Theano/libgpuarray.git
cd libgpuarray
mkdir Build && cd Build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=x86_64
make
make install
cd ..
python3 setup.py install
cd ..
rm -rf libgpuarray

# Install theano
pip3 install theano

# Configure theano
cat > .theanorc <<EOF
[global]
device = gpu
floatX = float32
EOF

# Install lasagne
pip3 install lasagne
