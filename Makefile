######################################################################
## To execute this file, type the following into terminal
## make
## ./main input
######################################################################
## Here specify the location of the IBAMR source and the location
## where IBAMR has been built.
IBAMR_SRC_DIR =   $(HOME)/sfw/ibamr/IBAMR
IBAMR_BUILD_DIR = $(HOME)/sfw/ibamr/ibamr-objs-opt

######################################################################
## Include variables specific to the particular IBAMR build.
include $(IBAMR_BUILD_DIR)/config/make.inc

CPPFLAGS += -I/opt/local/include
## LIBS     += -lnetcdf -lcurl

######################################################################
## Build the IB tester application.

## SOURCE FILES 

## OBJECT FILES
OBJS = main.o KnifeFishKinematics.o

## DIMENSIONALITY
PDIM = 3


#########################################################################
## Rules

default: check-opt main2d

main2d: $(IBAMR_LIB_2D) $(IBTK_LIB_2D) $(OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(OBJS) \
	$(IBAMR_LIB_2D) $(IBTK_LIB_2D) $(LIBS) -DNDIM=$(PDIM) -o $@
	
main3d: $(IBAMR_LIB_3D) $(IBTK_LIB_3D) $(OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(OBJS) \
	$(IBAMR_LIB_3D) $(IBTK_LIB_3D) $(LIBS) -DNDIM=$(PDIM) -o $@	
	
check-opt:
	if test "$(OPT)" == "1" ; then				\
	  if test -f stamp-debug ; then $(MAKE) clean ; fi ;	\
	  touch stamp-opt ;					\
	else							\
	  if test -f stamp-opt ; then $(MAKE) clean ; fi ;	\
	  touch stamp-debug ;					\
	fi ;

clean:
	$(RM) main*d 
	$(RM) stamp-{opt,debug}
	$(RM) *.o *.lo *.objs *.ii *.int.c
	$(RM) -r .libs
	$(RM) ./*.o

######################################################################
# THE FOLLOWING IS AUTOMATICALLY GENERATED BY MAKEDEPEND