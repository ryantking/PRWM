#
# Makefile for PRWM
#

PATSCC=$(PATSHOME)/bin/patscc
PATSOPT=$(PATSHOME)/bin/patsopt

PATSHOMEQ="$(PATSHOME)"
PATSHOMELIBQ="$(PATSHOMERELOC)"

all :: \
PRWM.dats; \
$(PATSCC) -o prwm -lX11 -DATS_MEMALLOC_LIBC PRWM.dats
