#!/bin/sh

# Retry wget errors (20 times) (e.q. 504)
# sourceforge in particular is not very stable
function wgetretry {
    wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1 ||
    wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1 || wget $1
}

# Load python 2
deactivate
module unload python3
module load python

# Setup to use gnu compiler and hide warnings
export CC='gcc -w'
export CXX='g++ -w'

# Use HOME directory as base
cd $HOME

# install asciidoc
wget http://sourceforge.net/projects/asciidoc/files/asciidoc/8.6.9/asciidoc-8.6.9.tar.gz
tar -zxf asciidoc-8.6.9.tar.gz
cd asciidoc-8.6.9
./configure --prefix=$HOME
make && make install
cd ..
rm -rf asciidoc-8.6.9*

# install xmlto
wget https://fedorahosted.org/releases/x/m/xmlto/xmlto-0.0.26.tar.gz
tar -zxf xmlto-0.0.26.tar.gz
cd xmlto-0.0.26
./configure --prefix=$HOME
make && make install
cd ..
rm -rf xmlto-0.0.26*

# install libxslt
wget ftp://xmlsoft.org/libxml2/libxslt-git-snapshot.tar.gz
tar -zxf libxslt-git-snapshot.tar.gz
cd libxslt*
./configure --prefix=$HOME
make && make install
cd ..
rm -rf libxslt*

# install docbook2x-texi
wget http://sourceforge.net/projects/docbook2x/files/docbook2x/0.8.3/docbook2X-0.8.3.tar.gz
tar -zxf docbook2X-0.8.3.tar.gz
cd docbook2X-0.8.3
./configure --prefix=$HOME
make && make install
cd ..
rm -rf docbook2X-0.8.3*
\cp -f ~/bin/docbook2texi ~/bin/docbook2x-texi

# install git
git clone git://git.kernel.org/pub/scm/git/git.git
cd git
make configure
./configure --prefix=$HOME
make -j4 all doc
make install install-doc
cd ..
rm -rf git

# DONE
cat <<EOF
####################################
##                                ##
##         util installed         ##
##                                ##
####################################
EOF
