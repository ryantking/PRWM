(* ****** ****** *)
//
// UnboxedWM
// Author: Ryan King <rtking@bu.edu>
//
(* ****** ****** *)

#define NULL
#define MAX_HIDDEN 32
#define DEF_SHELL "/bin/sh"

(* ****** ****** *)

#include "share/HATS/atspre_staload_libats_ML.hats"

staload "./../X11/SATS/X11.sats"

(* ****** ****** *)

typedef ScreenInfo = @{
  num = int,
  root = Window,
  menuwin = Window,
  def_cmap = Colormap,
  gc = ptr,
  black = ulint,
  white = ulint,
  min_cmaps = int,
  target = Cursor,
  sweep0 = Cursor,
  boxcurs = Cursor,
  arrow = Cursor,
  root_pixmap = Pixmap,
  display = string
}

typedef Client = @{
  window = Window,
  parent = Window,
  trans  = Window,
  next   = ptr,
  revert = ptr,

  x = int,
  y = int,
  dx = int,
  dy = int,
  border = int,

  size = XSizeHints,
  min_dx = int,
  min_dy = int,

  state = int,
  init = int,
  reparenting = int,
  is9term = int,
  hold = int,
  proto = int,

  label = string,
  instance = string,
  class = string,
  name = string,
  iconname = string,

  cmap = Colormap,
  ncmapwins = int,
  cmapwins = Window,
  wmcmaps = Colormap,
  screen = Screen
}

typedef Menu = '{
  item = arrszref(string),
  gen = (void) -> char,
  lasthit = int
}

(* ****** ****** *)

val curtime : int
val screens : list0(ScreenInfo)
val clients : Client

(* ****** ****** *)

fun getscreen(Window): ScreenInfo
fun client_nil(): Client
fun client_def(): Client
fun clients_eq(Client, Client):<!wrt> bool
fun getclient(Window, bool): Client