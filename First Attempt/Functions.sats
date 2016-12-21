(* ****** ****** *)
//
// UnboxedWM
// Author: Ryan King <rtking@bu.edu>
//
(* ****** ****** *)

#include "./../X11/SATS/X11.sats"

staload "./Data.sats"

fun usage : () -> void
fun initscreen : () -> void
fun getscreen : () -> ScreenInfo
fun timestamp : () -> Time
fun sendcmessage : () -> void
fun sendconfig : () -> void
fun sighandler : () -> void
fun getevent : () -> void
fun cleanup : () -> void


fun	mainloop : () -> void
fun	configurerep : () -> void
fun	maprep : () -> void
fun	circulaterep : () -> void
fun	unmap : () -> void
fun	newwindop : () -> void
fun	destrop : () -> void
fun	clientmesp : () -> void
fun	cmap : () -> void
fun	propertp : () -> void
fun	shapenotifp : () -> void
fun	entep : () -> void
fun	focusip : () -> void
fun	reparenp : () -> void

fun	mainloop : () -> void
fun	configurereq : () -> void
fun	mapreq : () -> void
fun	circulatereq : () -> void
fun	unmap : () -> void
fun	newwindow : () -> void
fun	destroy : () -> void
fun	clientmesg : () -> void
fun	cmap : () -> void
fun	property : () -> void
fun	shapenotify : () -> void
fun	enter : () -> void
fun	focusin : () -> void
fun	reparent : () -> void

fun manage : () -> int
fun	scanwins : () -> void
fun	setshape : () -> void
fun	withdraw : () -> void
fun	gravitate : () -> void
fun	cmapfocus : () -> void
fun	cmapnofocus : () -> void
fun	getcmaps : () -> void
fun _getprop : () -> int
fun	getprop : () -> string
fun	getwprop : () -> Window
fun getiprop : () -> int
fun getwstate : () -> int
fun	setwstate : () -> void
fun	setlabel : () -> void
fun	getproto : () -> void
fun	gettrans : () -> void

fun	button : (XButtonEvent) -> void
fun	spawn : () -> void
fun	reshape : () -> void
fun	move : () -> void
fun	delete : () -> void
fun	hide : () -> void
fun	unhide : () -> void
fun	unhidec : () -> void
fun	renamec : () -> void

fun	setactive : () -> void
fun	draw_border : () -> void
fun	active : () -> void
fun	nofocus : () -> void
fun	top : () -> void
fun	getclient : () -> Client
fun	rmclient : () -> void
fun	dump_revert : () -> void
fun	dump_clients : () -> void

/* grab.c */
fun menuhit : () -> int
fun	selectwin : () -> Client
fun sweep : () -> int
fun drag : () -> int
fun	getmouse : () -> void
fun	setmouse : () -> void

/* error.c */
fun handler : () -> int
fun	fatal : () -> void
fun	graberror : () -> void
fun	showhints : () -> void


/* cursor.c */
fun	initcurs : (ScreenInfo) -> void