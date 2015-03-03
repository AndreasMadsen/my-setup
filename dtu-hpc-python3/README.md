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

### Note on login

**Note the install part only works when using `hpc-fe.gbar.dtu.dk` as the `ssh` host!** ThinLinc and `login.gbar.dtu.dk` won’t work. This is because `k40sh` is needed to compile the OpenCL and CUDA parts. The SSH guide can be found here: http://gbar.dtu.dk/faq/53-ssh (just be sure to replace `login.gbar.dtu.dk` with `hpc-fe.gbar.dtu.dk`).

### Run setup script

Type or copy this after connecting with SSH:

```shell
k40sh
wget https://raw.githubusercontent.com/AndreasMadsen/my-setup/master/dtu-hpc-python3/setup-python3.sh
sh setup_python3.sh
rm -f setup_python3.sh
exit
```

### After install and future login

For any future login and after the installation run one of these:

**If you need OpenCL or CUDA run:**

```shell
k40sh
module load python
module load gcc
module load qt
module load cuda
export PYTHONPATH=
source ~/stdpy/bin/activate
```

**Otherwise use:**

```shell
qrsh
module load python
module load gcc
module load qt
export PYTHONPATH=
source ~/stdpy/bin/activate
```

Personally I have all the `module`, `export` and `source` stuff in my `.profile.sh` file.
