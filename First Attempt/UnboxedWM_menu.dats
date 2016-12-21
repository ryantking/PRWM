(* ****** ****** *)
//
// UnboxedWM
// Author: Ryan King <rtking@bu.edu>
//
// UnboxedWM_menu.dats: Implementation of the WM menus
//
(* ****** ****** *)

(*- INCLUSIONS ---------------------------------------------------------------*)

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"
#include "share/HATS/atspre_staload_libats_ML.hats"

staload UN = "prelude/SATS/unsafe.sats"

#include "./UnboxedWM_main.dats"

(*- VARIABLE DEFINITIONS -----------------------------------------------------*)

(*- FUNCTION DEFINITIONS _----------------------------------------------------*)

implement button(e) =
  let
    val () = !curtime := e.time
  in
    ()
  end

(* ****** ****** *)

(*
val num_hidden = 0

val b3items = (arrszref)$arrpsz{string}
  ("New", "Reshape", "Move", "Delete", "Hide", "")

implement button(e) =
  let
    val () = curtime := e.time
    val s = getscreen(e.root)
  in
    if s = 0 then ()
    else
      let
        val c = getclient(e.window)
      in
        ()
      end
  end




val def_sizehints = @{
  flags = $UN.cast{lint}0,
  x = 0,
  y = 0,
  width = 0,
  height = 0,
  min_width = 0,
  min_height = 0,
  max_width = 0,
  max_height = 0,
  min_aspect = @{x = 0, y = 0},
  max_aspect = @{x = 0, y = 0}
} : XSizeHints

val def_client = '{
  window = $UN.cast{XID}(0),
  parent = $UN.cast{XID}(0),
  trans = $UN.cast{XID}(0),
  next = NULL,
  revert = NULL,

  x = 0,
  y = 0,
  dx = 0,
  dy = 0,
  border = 0,

 size = def_sizehints,
 min_dx = 0,
 min_dy = 0,

 state = 0,
 init = 0,
 reparenting = 0,
 is9term = 0,
 hold = 0,
 proto = 0,

 label = "",
 instance = "",
 class = "",
 name = "",
 iconname = "",

  cmap = $UN.cast{XID}0,
  ncmapwins = 0,
  cmapwins = $UN.cast{XID}0,
  wmcmaps = $UN.cast{XID}0,
  screen = NULL
} : Client

val hidden_clients = arrayref_make_elt<Client>(
  i2sz(MAX_HIDDEN),
  def_client
)

val b3items = (arrszref)$arrpsz{string}("New", "Reshape", "Move", "Delete", "Hide", "")

val b3menu = '{
  item = b3items
} : Menu
*)

implement menuhit() = 4