(* ****** ****** *)
//
// UnboxedWM
// Author: Ryan King <rtking@bu.edu>
//
(* ****** ****** *)

// #include "share/atspre_define.hats"
// #include "share/atspre_staload.hats"
#include "share/HATS/atspre_staload_libats_ML.hats"

#include "../X11/SATS/X11.sats"

(* ****** ****** *)

typedef ScreenInfo = '{
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

typedef Client = '{
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
  screen = ptr
}

typedef Menu = '{
  item = arrszref(string)
}

(* ****** ****** *)

val dpy : ptr
val screens : array0(ScreenInfo)
val num_screens : int
val initting : int
val font : ptr
val nostalgia : int
val myargv : array0(string)
val shape : bool
val temprog : string
val shell : string
val version : array0(string)
val _border : int
val _inset : int
val curtime : int
val debug : int
val bordercolor : ulint

val exit_9wm : Atom
val restart_9wm : Atom
val wm_state : Atom
val wm_change_state : Atom
val _9wm_hold_mode : Atom
val wm_protocols : Atom
val wm_delete : Atom
val wm_take_focus : Atom
val wm_colormaps : Atom
val utf8_string : Atom
val wm_moveresize : Atom
val active_window : Atom

val clients : array0(Client)
val current : Client

val hiddenc : array0(Client)
val numhidden : int
val b3items : array0(string)
val b3menu : Menu

val ignore_badwindow : int