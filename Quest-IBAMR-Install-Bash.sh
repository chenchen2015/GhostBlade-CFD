# Load Module
#module load valgrind
#module load hypre

# (Optional) Install Necessary Packages
sudo apt-get -q -y install m4

export CFD_HOME=$HOME/GhostBlade-CFD

cd $CFD_HOME
mkdir sfw

# Install HDF5
cd $CFD_HOME/sfw
mkdir hdf5
cd hdf5
wget http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.13/src/hdf5-1.8.13.tar.gz --no-check-certificate
tar xvfz hdf5-1.8.13.tar.gz
mv hdf5-1.8.13 1.8.13
cd 1.8.13
./configure \
  CC=gcc \
  CXX=g++ \
  FC=gfortran \
  F77=gfortran \
  --enable-production \
  --disable-debug \
  --prefix=$CFD_HOME/sfw/linux/hdf5/1.8.13
make
make check
make install

# Install Silo
cd $CFD_HOME/sfw
mkdir silo
cd silo
wget https://wci.llnl.gov/content/assets/docs/simulation/computer-codes/silo/silo-4.10/silo-4.10.tar.gz --no-check-certificate
tar xvfz silo-4.10.tar.gz
mv silo-4.10 4.10
cd 4.10
./configure \
  CC=gcc \
  CXX=g++ \
  FC=gfortran \
  F77=gfortran \
  --prefix=$CFD_HOME/sfw/linux/silo/4.10 \
  --disable-silex \
  --without-readline
make
make check
make install

# Install OpenMPI
cd $CFD_HOME/sfw
mkdir openmpi
cd openmpi
wget http://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-1.8.8.tar.gz --no-check-certificate
tar xvfz openmpi-1.8.8.tar.gz
mv openmpi-1.8.8 1.8.8
cd 1.8.8
./configure \
  CC=gcc \
  CXX=g++ \
  FC=gfortran \
  F77=gfortran \
  --prefix=$CFD_HOME/sfw/linux/openmpi/1.8.8 \
  --disable-mpi-cxx-seek \
  --disable-heterogeneous \
  --enable-orterun-prefix-by-default
make
make check
make install

# $HOME/.profile
# PETSc settings
export PETSC_DIR=$CFD_HOME/sfw/petsc/3.5.4
export PETSC_ARCH=linux-opt
# OpenMPI settings (add to ~/.profile)
#export PATH=$CFD_HOME/sfw/linux/openmpi/1.8.8/bin:$PATH
#export MANPATH=$CFD_HOME/sfw/linux/openmpi/1.8.8/share/man:$MANPATH</code>

# Install GSL
cd $CFD_HOME/sfw
mkdir gsl
cd gsl
wget http://gnu.mirror.iweb.com/gsl/gsl-1.16.tar.gz --no-check-certificate
tar xvfz gsl-1.16.tar.gz
mv gsl-1.16 1.16
cd 1.16
./configure \
  --prefix=$CFD_HOME/sfw/linux/gsl/1.16 \
  --disable-static \
  --disable-shared \
  CC=gcc \
  CXX=g++ \
  F77=gfortran \
  FC=gfortran
make 
make check
make install 


# Install PETSc
cd $CFD_HOME/sfw
mkdir petsc
cd petsc
wget http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.5.4.tar.gz --no-check-certificate
tar xvfz petsc-3.5.4.tar.gz
mv petsc-3.5.4 3.5.4
cd 3.5.4
# Build Optimized PETSc
export PETSC_DIR=$PWD
export PETSC_ARCH=linux-opt
./config/configure.py \
  --CC=$CFD_HOME/sfw/linux/openmpi/1.8.8/bin/mpicc \
  --CXX=$CFD_HOME/sfw/linux/openmpi/1.8.8/bin/mpicxx \
  --FC=$CFD_HOME/sfw/linux/openmpi/1.8.8/bin/mpif90 \
  --LDFLAGS="-L$CFD_HOME/sfw/linux/openmpi/1.8.8/lib -Wl,-rpath,$CFD_HOME/sfw/linux/openmpi/1.8.8/lib" \
  --PETSC_ARCH=$PETSC_ARCH \
  --with-shared-libraries \
  --with-debugging=0 \
  --with-x=0 \
  --download-hypre=1 \
  --download-fblaslapack=1
make
make test


# Install SAMRAI
cd $CFD_HOME/sfw
mkdir samrai
cd samrai
mkdir 2.4.4
cd 2.4.4
wget https://computation.llnl.gov/project/SAMRAI/download/SAMRAI-v2.4.4.tar.gz --no-check-certificate
tar xvfz SAMRAI-v2.4.4.tar.gz
cd SAMRAI
./source/scripts/includes --link
# Patch SAMRAI
cd $CFD_HOME/sfw/samrai/2.4.4/SAMRAI
wget https://github.com/IBAMR/IBAMR/releases/download/v0.1-rc1/SAMRAI-v2.4.4-patch-121212.gz --no-check-certificate
./source/scripts/includes --link
gunzip -c $CFD_HOME/sfw/samrai/2.4.4/SAMRAI/SAMRAI-v2.4.4-patch-121212.gz | patch -p2
# Build
cd $CFD_HOME/sfw/samrai/2.4.4
mkdir objs-dbg
cd objs-dbg
../SAMRAI/configure \
  --prefix=$CFD_HOME/sfw/samrai/2.4.4/linux-dbg \
  --with-CC=gcc \
  --with-CXX=g++ \
  --with-F77=gfortran \
  --with-MPICC=$CFD_HOME/sfw/linux/openmpi/1.8.8/bin/mpicc \
  --with-hdf5=$CFD_HOME/sfw/linux/hdf5/1.8.13 \
  --without-hypre \
  --with-silo=$CFD_HOME/sfw/linux/silo/4.10 \
  --without-blaslapack \
  --without-cubes \
  --without-eleven \
  --without-kinsol \
  --without-petsc \
  --without-sundials \
  --without-x \
  --with-doxygen \
  --with-dot \
  --enable-debug \
  --disable-opt \
  --enable-implicit-template-instantiation \
  --disable-deprecated
make
make install
# Build Optimized SAMRAI
cd $CFD_HOME/sfw/samrai/2.4.4
mkdir objs-opt
cd objs-opt
../SAMRAI/configure \
  CFLAGS="-O3" \
  CXXFLAGS="-O3" \
  FFLAGS="-O3" \
  --prefix=$CFD_HOME/sfw/samrai/2.4.4/linux-opt \
  --with-CC=gcc \
  --with-CXX=g++ \
  --with-F77=gfortran \
  --with-MPICC=$CFD_HOME/sfw/linux/openmpi/1.8.8/bin/mpicc \
  --with-hdf5=$CFD_HOME/sfw/linux/hdf5/1.8.13 \
  --without-hypre \
  --with-silo=$CFD_HOME/sfw/linux/silo/4.10 \
  --without-blaslapack \
  --without-cubes \
  --without-eleven \
  --without-kinsol \
  --without-petsc \
  --without-sundials \
  --without-x \
  --with-doxygen \
  --with-dot \
  --disable-debug \
  --enable-opt \
  --enable-implicit-template-instantiation \
  --disable-deprecated
make
make install


# Build IBAMR
cd $CFD_HOME/sfw
mkdir ibamr
cd ibamr
git clone https://github.com/IBAMR/IBAMR.git
cd $CFD_HOME/sfw/ibamr
mkdir ibamr-objs-opt
cd ibamr-objs-opt
export PETSC_ARCH=linux-opt
export PETSC_DIR=$CFD_HOME/sfw/petsc/3.5.4
../IBAMR/configure \
  CC=$CFD_HOME/sfw/linux/openmpi/1.8.8/bin/mpicc \
  CXX=$CFD_HOME/sfw/linux/openmpi/1.8.8/bin/mpicxx \
  FC=$CFD_HOME/sfw/linux/openmpi/1.8.8/bin/mpif90 \
  CFLAGS="-O3 -Wall" \
  CXXFLAGS="-O3 -Wall" \
  FCFLAGS="-O3 -Wall" \
  CPPFLAGS="-DOMPI_SKIP_MPICXX" \
  --with-samrai=$CFD_HOME/sfw/samrai/2.4.4/linux-opt \
  --with-hdf5=$CFD_HOME/sfw/linux/hdf5/1.8.13 \
  --with-silo=$CFD_HOME/sfw/linux/silo/4.10
make
make check

# Test IBAMR
cd $CFD_HOME/sfw/ibamr/ibamr-objs-opt/examples/IB/explicit/ex1
make examples
./main2d input2d
