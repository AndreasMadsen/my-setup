#!/bin/sh

module load python
module load gcc
module load cuda/6.0

# Setup to use gnu compiler
export CC=gcc
export CXX=g++

# Setup virtual env
virtualenv stdpy
source ./stdpy/bin/activate

pip install numpy
pip install scipy
pip install matplotlib
pip install scikit-learn
pip install pandas
pip install mako
pip install pil
pip install nose

# Install pydot
pip uninstall pyparsing -y
pip install -Iv https://pypi.python.org/packages/source/p/pyparsing/pyparsing-1.5.7.tar.gz#md5=9be0fcdcc595199c646ab317c1d9a709
pip install pydot

# Install pyOpenCL
wget --no-check-certificate https://pypi.python.org/packages/source/p/pyopencl/pyopencl-2013.2.tar.gz
tar xfz pyopencl-2013.2.tar.gz
cd pyopencl-2013.2
python configure.py \
    --cl-inc-dir=/opt/cuda/6.0/include \
    --cl-lib-dir=/opt/cuda/6.0/lib \
    --cl-libname=OpenCL
make install
cd ..
rm -rf pyopencl-2013.2
rm -f pyopencl-2013.2.tar.gz

# Install theano
pip install theano
cat > .theanorc <<EOF
[global]
device = gpu
floatX = float32
root = /opt/cuda/6.0
EOF

# Install basemap extension to matplotlib
wget http://downloads.sourceforge.net/project/matplotlib/matplotlib-toolkits/basemap-1.0.7/basemap-1.0.7.tar.gz
tar -xzf basemap-1.0.7.tar.gz 
cd basemap-1.0.7
cd geos-3.3.3
export GEOS_DIR=$HOME
./configure --prefix=$GEOS_DIR
make; make install
cd ..
python setup.py install
cd ..
rm -rf basemap-1.0.7
rm -f basemap-1.0.7.tar.gz 

# Install netCDF4
wget http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.13.tar
tar -xf hdf5-1.8.13.tar
cd hdf5-1.8.13
./configure --prefix=$HOME --enable-shared --enable-hl
make
make install
cd ..
wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.3.2.tar.gz
tar -xzf netcdf-4.3.2.tar.gz
cd netcdf-4.3.2
./configure --enable-netcdf-4 --enable-dap --enable-shared --prefix=$HOME
make
make install
cd ..
wget --no-check-certificat https://pypi.python.org/packages/source/n/netCDF4/netCDF4-1.1.0.tar.gz#md5=8e2958160c8cccfc80f61ae0427e067f
tar -xzf netCDF4-1.1.0.tar.gz
cd netCDF4-1.1.0
python setup.py install
cd ..

rm -rf hdf5-1.8.13
rm -f hdf5-1.8.13.tar
rm -rf netcdf-4.3.2
rm -f netcdf-4.3.2.tar.gz
rm -rf netCDF4-1.1.0
rm -f netCDF4-1.1.0.tar.gz

