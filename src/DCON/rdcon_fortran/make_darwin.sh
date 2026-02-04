#!/bin/sh

export NETCDF=/opt/homebrew
export LAPACKHOME=/System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/
export FC=/opt/homebrew/bin/gfortran-15
export CC=/opt/homebrew/bin/gcc-15
export FFLAGS='-fallow-argument-mismatch -O0'

cd ./install; make