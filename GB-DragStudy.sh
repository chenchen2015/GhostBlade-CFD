#!/bin/bash
#MSUB -A p20751
#MSUB -l nodes=6:ppn=8
#MSUB -l walltime=04:00:00
#MSUB -N GB_Drag_Study
#MSUB -o outlog
#MSUB -e errlog
#MSUB -V
#MSUB -M chen.bme@u.northwestern.edu
#MSUB -m abe

ulimit -s unlimited
cd $PBS_O_WORKDIR

##restart_number = 
##mpiexec ./main3d input3d.Knifefish restart_IB3d $restart_number -stokes_ksp_monitor_true_residual -stokes_ksp_converged_reason -stokes_ksp_rtol 1.0e-5 > KSP.log

mpiexec ./main3d input3d.Knifefish -stokes_ksp_monitor_true_residual -stokes_ksp_converged_reason -stokes_ksp_rtol 1.0e-5 > KSP.log
