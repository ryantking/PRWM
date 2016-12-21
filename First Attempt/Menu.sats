(* ****** ****** *)
//
// UnboxedWM
// Author: Ryan King <rtking@bu.edu>
//
(* ****** ****** *)

staload "./../X11/SATS/X11.sats"
staload "./Global.sats"

(* ****** ****** *)

val hidden_clients : arrszref(Client)

val num_hidden : int

val b3items : arrszref(string)

val b3menu : Menu

fun	button : (XButtonEvent) -> void
fun	spawn : () -> void
fun	reshape : () -> void
fun	move : () -> void
fun	delete : () -> void
fun	hide : () -> void
fun	unhide : () -> void
fun	unhidec : () -> void
fun	renamec : () -> void