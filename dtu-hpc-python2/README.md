Install python and friends on DTUs shared user system. In particually with OpenCL and CUDA support.

**Note the install part only works when using `hpc-fe.gbar.dtu.dk` as the `ssh` host!** ThinLinc and `login.gbar.dtu.dk` won’t work. This is because `k40sh` is needed to compile the OpenCL and CUDA parts. The SSH guide can be found here: http://gbar.dtu.dk/faq/53-ssh (just be sure to replace `login.gbar.dtu.dk` with `hpc-fe.gbar.dtu.dk`).

Type or copy this after connecting with SSH, using `time` this have been messured to take 37 minutes:

```shell
k40sh
wget https://gist.githubusercontent.com/AndreasMadsen/45050d426e411e985703/raw/setup_python.sh
sh setup_python.sh
exit
```

For any future login and after the installation run one of these:

If you need OpenCL or CUDA run:

```shell
k40sh
module load python
module load gcc
module load cuda/6.0
source ~/stdpy/bin/activate
```

Otherwise use:

```shell
qrsh
module load python
module load gcc
source ~/stdpy/bin/activate
```

Personally I have all the `module` and `source` stuff in my `.profile.sh` file.

