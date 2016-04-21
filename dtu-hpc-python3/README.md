# DTU HPC – Python 3.4

Install python and friends on DTUs shared user system. Included is:

* numpy
* scipy
* matplotlib (with Qt5 and basemap)
* scikit-learn
* pandas
* PyOpenCL (with mako)
* Theano (with pydot and libgpuarray)
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

### CuDNN v5 support

DTU HPC currently don't have a cuDNN v5 module. v3 is the latest available and
Theano requires v5. You can manually registre at
https://developer.nvidia.com/cudnn and download "cuDNN v5 Library for Linux".

when you have done so, transfer the file (`cudnn-7.5-linux-x64-v5.0-rc.tgz`) to
your home directory and execute:

```shell
tar -xf cudnn-7.5-linux-x64-v5.0-rc.tgz
cat >> ~/.theanorc <<EOF

[dnn]
enabled = True
include_path = $HOME/cuda/include
library_path = $HOME/cuda/lib64
EOF
rm -f cudnn-7.5-linux-x64-v5.0-rc.tgz
```

### After install and future login

For any future login and after the installation run one of these:

**If you need OpenCL or CUDA run:**

```shell
k40sh
module load python3
module load gcc/4.9.2
module load cuda/7.5
module load qt
export PYTHONPATH=
source ~/stdpy3/bin/activate
```

**Otherwise use:**

```shell
qrsh
module load python3
module load gcc/4.9.2
module load qt
export PYTHONPATH=
source ~/stdpy3/bin/activate
```

You can make this happen automatically for all shell-login, just run:

```shell
cat >> .gbarrc <<EOF
MODULES=python3,gcc/4.9.2,qt,cuda/7.5
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
