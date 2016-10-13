# DTU HPC – Python 3.5

Install python and friends on DTUs shared user system. Included is:

* numpy
* scipy
* matplotlib (with Qt5 and basemap)
* scikit-learn
* pandas
* PyOpenCL (with mako)
* Theano (with pydot, libgpuarray, cuda 8.0 and cuDNN 5)

### Run setup script

Type or copy this after connecting with SSH:

```shell
wget https://raw.githubusercontent.com/AndreasMadsen/my-setup/master/dtu-hpc-python3/setup-python3.sh
qsub setup-python3.sh
while [ ! -f "setup-python3.log" ]; do sleep 1; done
less +F -r setup-python3.log
rm -f setup-python3.*
```

### After install and future login

For any future login and after the installation run one of these:

**If you need OpenCL or CUDA run:**

```shell
k40sh
module load python3
module load gcc/4.9.2
module load cuda/8.0
module load cudnn/v5.0-prod
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
MODULES=python3,gcc/6.2.0,qt,cuda/8.0,cudnn/v5.0-prod
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
