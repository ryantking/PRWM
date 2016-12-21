#
# Makefile for UnboxedWM
#

PATSCC=$(PATSHOME)/bin/patscc
PATSOPT=$(PATSHOME)/bin/patsopt

all :: \
UnboxedWM.dats; \
$(PATSCC) -o UnboxedWM -lX11 -DATS_MEMALLOC_LIBC UnboxedWM.dats
