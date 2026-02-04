
include ../DEFAULTS.inc

# extend these variables to sub-makes (?= sets a default if user doesn't specify options)
FFLAGS ?= -g
CFLAGS ?= -g

export FFLAGS
export CFLAGS
export OMPFLAG
export LDFLAGS

# compile package

all: v equil lsode vacuum rdcon pentrc dcon

# executables:

lsode:
	cd ../lsode;  $(MAKE)

equil:
	cd ../equil;  $(MAKE)

vacuum:
	cd ../vacuum; $(MAKE)

rdcon:
	cd ../rdcon;   $(MAKE)

pentrc:
	cd ../pentrc;  $(MAKE)

dcon:
	cd ../dcon;    $(MAKE)

# print verbose info

v:
	@echo "------------------------------------------------------------"
	@echo "Defaults tailored for $(PLATFORM)"
	@echo "Compiling with FC = $(FC)"
	@echo "   using math libraries $(MATHLIBS)"
	@echo "   from $(MATHDIR)"
	@echo "   including $(MATHINC)"
	@echo "   and netcdf libraries $(NETCDFLIBS) $(NETCDF_C_LIBS)"
	@echo "   from $(NETCDFDIR) $(NETCDF_C_DIR)"
	@echo "   including $(NETCDFINC)"
	@echo "   and compiler libraries $(FCLIBS)"
	@echo "   from $(FCDIR)"
	@echo "   including $(FCINC)"
	@echo "   and using OMPFLAG $(OMPFLAG)"
	@echo
	@echo "Set environment FC,LAPACKHOME,NETCDFHOME to change these"
ifeq ("$(PLATFORM)","portal")
	@echo "   example: module load gcc4 lapack netcdf"
endif
	@echo "------------------------------------------------------------"

# cleaning

clean:
	cd ../lsode;  make clean
	cd ../equil;  make clean
	cd ../vacuum; make clean
	cd ../rdcon;  make clean
	cd ../harvest;  make clean
	cd ../pentrc;  make clean
	cd ../dcon;  make clean

realclean: clean
	clear
	rm -rf ../lib ../bin

print-% : ; $(info $* is a $(flavor $*) variable set to [$($*)]) @true
