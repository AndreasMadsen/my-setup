# Mac – Python 3.5

Install python and friends on Mac OS X. This is similar to the `DTU_HPC_python3`
install scripts, but is not as well tested. Included is:

* numpy
* scipy
* matplotlib (with Qt4, cairo and basemap)
* scikit-learn
* pandas
* PyOpenCL (with mako)
* Theano (with pydot, clBLAS, libgpuarray)
* netCDF4

### Run setup script

This assumes that you have `brew` installed.

```shell
wget https://raw.githubusercontent.com/AndreasMadsen/my-setup/master/mac-python3/setup-python3.sh
sh setup_python3.sh
rm -f setup_python3.sh
exit
```
