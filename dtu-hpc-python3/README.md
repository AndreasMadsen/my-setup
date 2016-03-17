# DTU HPC – Python 3.4

Install python and friends on DTUs shared user system. Included is:

* numpy
* scipy
* matplotlib (with Qt4 and basemap)
* scikit-learn
* pandas
* PyOpenCL (with mako)
* Theano (with pydot, clBLAS, libgpuarray)
* netCDF4

### Run setup script

Type or copy this after connecting with SSH:

```shell
wget https://raw.githubusercontent.com/AndreasMadsen/my-setup/master/dtu-hpc-python3/setup-python3.sh
qsub setup-python3.sh
while [ ! -f "setup-python3.log" ]; do sleep 1; done
less +F -r setup-python3.log
rm -f setup-python3.*
```

(
Since some of the HPC's root packages can be out of date you may need install updated/new packages locally. For instance, if you get a "your CMAKE version is too old..." error you can take the following steps to resolve it:
```
wget https://cmake.org/files/v3.5/cmake-3.5.0.tar.gz
tar -zxvf cmake-3.5.0.tar.gz
cd cmake-3.5.0
./configure --prefix=[your local install directory]
make
make install

PATH=[your local install directory]:$PATH
```
Now check that you are indeed running the local cmake:
```
cmake --version
```
If the output is as expected you can proceed using the qsub above

)



### After install and future login

For any future login and after the installation run one of these:

**If you need OpenCL or CUDA run:**

```shell
k40sh
module load python3
module load gcc
module load qt
module load cuda
export PYTHONPATH=
source ~/stdpy3/bin/activate
```

**Otherwise use:**

```shell
qrsh
module load python3
module load gcc
module load qt
export PYTHONPATH=
source ~/stdpy3/bin/activate
```

You can make this happen automatically for all shell-login, just run:

```shell
cat >> .gbarrc <<EOF
MODULES=python3,gcc,qt,cuda
EOF
cat >> .profile <<EOF
# Setup local python3
if tty -s ; then
export PYTHONPATH=
source ~/stdpy3/bin/activate
fi

EOF
```

However you should still do the `module`, `export` and `source` dance when makeing a script for `qsub`.
