#!/bin/sh

# Always
brew update
export HOMEBREW_MAKE_JOBS=4
cd $HOME

#
# Install wget
#
brew install wget

#
# Install gfortran
#
brew install gcc
brew link --overwrite gcc

#
# Install Python 3 with openssl
#
brew install openssl
brew link openssl --overwrite
brew install python3 --with-brewed-openssl
brew linkapps python3
pip3 install --upgrade pip

#
# Install math tools
#
brew install numpy --with-python3
brew link --overwrite numpy
brew install scipy --with-python3 --default-fortran-flags

#
# Install matplotlib (with Qt4, cario and basemap)
#
brew install sip --with-python3
brew install pyqt --with-python3
brew linkapps qt
brew install py3cairo
brew install matplotlib --with-python3
brew install matplotlib-basemap --with-python3

#
# Install pyOpenCL
#
pip3 install -U mako
pip3 install -U pyopencl

#
# Install theano
#

# Install pydot
pip3 install https://bitbucket.org/prologic/pydot/get/ac76697320d6.zip
patch -f /usr/local/lib/python3.4/site-packages/dot_parser.py \
<<EOF
--- a/usr/local/lib/python3.4/site-packages/dot_parser.py
+++ b/usr/local/lib/python3.4/site-packages/dot_parser.py
@@ -25,8 +25,9 @@
 from pyparsing import ( nestedExpr, Literal, CaselessLiteral, Word, Upcase, OneOrMore, ZeroOrMore,
     Forward, NotAny, delimitedList, oneOf, Group, Optional, Combine, alphas, nums,
     restOfLine, cStyleComment, nums, alphanums, printables, empty, quotedString,
-    ParseException, ParseResults, CharsNotIn, _noncomma, dblQuotedString, QuotedString, ParserElement )
+    ParseException, ParseResults, CharsNotIn, dblQuotedString, QuotedString, ParserElement )

+_nocomma = "".join([c for c in printables if c != ","])

 class P_AttrList:

EOF

# Install clBLAS
git clone https://github.com/clMathLibraries/clBLAS.git
cd clBLAS
mkdir build && cd build
cmake ../src -DCMAKE_BUILD_TYPE=Release
make && make install
cp -r package/* /usr/local/
cp -r package/lib64/* /usr/local/lib/
cd ../..
rm -rf clBLAS

# Install libgpuarray
pip3 install cython
pip3 install tools
git clone https://github.com/Theano/libgpuarray.git
cd libgpuarray
patch -f CMakeLists.txt <<EOF
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -11,7 +11,7 @@
 execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_SOURCE_DIR}/lib)
 set(LIBRARY_OUTPUT_PATH ${CMAKE_SOURCE_DIR}/lib)

-set(CMAKE_OSX_ARCHITECTURES i386 x86_64)
+set(CMAKE_OSX_ARCHITECTURES x86_64)

 add_subdirectory(src)
 add_subdirectory(tests)
EOF
mkdir Build && cd Build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=x86_64
make
make install
cd ..
python3 setup.py install
cd ..
rm -rf libgpuarray

# Install theano
pip3 install theano=dev

# Configure theano
cat > .theanorc <<EOF
[global]
device = gpu
floatX = float32
EOF

# Install lasagne (craffel fork)
git clone https://github.com/craffel/nntools.git
cd nntools
python3 setup.py install
cd ..
rm -rf nntools

#
# Install netCDF4
#
wget http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.14.tar
tar -xf hdf5-1.8.14.tar
cd hdf5-1.8.14
./configure --enable-shared --enable-hl
make
make install
cd $HOME
rm -rf hdf5-1.8.14*

wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.3.3.tar.gz
tar -xzf netcdf-4.3.3.tar.gz
cd netcdf-4.3.3
./configure --enable-netcdf-4 --enable-dap --enable-shared
make
make install
cd $HOME
rm -rf netcdf-4.3.3*

wget https://pypi.python.org/packages/source/n/netCDF4/netCDF4-1.1.5.tar.gz
tar -xzf netCDF4-1.1.5.tar.gz
cd netCDF4-1.1.5
python3 setup.py install
cd $HOME
rm -rf netCDF4-1.1.5*
