(* ****** ****** *)
//
// UnboxedWM
// Author: Ryan King <rtking@bu.edu>
//
// UnboxedWM_main.dats: Main variable declarations and function definitions
//
(* ****** ****** *)


(*- INCLUSIONS ---------------------------------------------------------------*)

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"
#include "share/HATS/atspre_staload_libats_ML.hats"

#include "UnboxedWM_client.dats"

(*- VARIABLE DEFINITIONS -----------------------------------------------------*)

val signaled = ref<bool>(false)
val starting = ref<bool>(true)

val WNOHANG = $extval(int, "WNOHANG")

val def_fonts = cons0("poopy butthole",
  cons0("-*-dejavu sans-bold-r-*-*-14-*-*-*-p-*-*-*",
	cons0("-adobe-helvetica-bold-r-*-*-14-*-*-*-p-*-*-*",
	cons0("lucm.latin1.9",
	cons0("blit",
	cons0("9x15bold",
	cons0("lucidasanstypewriter-12",
	cons0("fixed",
	cons0("*", nil0())))))))))

val cur_time = ref<Time>(~1)

(*- FUNCTION DEFINITIONS _----------------------------------------------------*)

implement usage(err) =
  let
    val out = if err then stderr_ref else stdout_ref
  in (
    if err then fprintln!(out, "Invald command line arguments.") else ();
    fprintln!(
      out,
      "Usage: UnboxedWM [Options] [Command]\n\n",
      "Options:\n",
      "  -h --help                         Show this information\n",
      "  -f --font   [font name]           Specify the font to use\n",
      "  -t --term   [terminal program]    Specify the terminal to use\n",
      "  -b --border [border color]        Specify the border color\n\n",
      "Commands:\n",
      "  exit        exit the window manager\n",
      "  restart     restart the window manager\n"
    );
    exit(1))
  end

fun sigchild(signum: int): void =
  if waitpid(~1, NULL, WNOHANG) > 0 then sigchild(signum) else ()

implement timestamp(state) =
  if state->time = CurrentTime then
    let
      var xp : XPropertyEvent?
      val () = xp.time := 0
      var ev : XEvent?
      val () = ev.type := 0
      val () = ev.xproperty := xp
      val _ = XChangeProperty(
        state->dpy, state->scr->root, state->_uwm_running, state->_uwm_running,
        8, PropModeAppend, "", 0
      )
      val _ = XMaskEvent(state->dpy, PropertyChangeMask, cptr_rvar(ev))
    in
      ev.xproperty.time
    end
  else state->time

implement send_message(state, win, msg_type, msg, is_root) =
  let
    var ev : XEvent?
    val () = ev.type := 0
    var xc : XClientMessageEvent?
    val () = xc.type := ClientMessage
    val () = xc.window := win
    val () = xc.message_type := msg_type
    val () = xc.format := 32
    val () = xc := set_l(msg, 0, xc)
    val () = xc := set_l(timestamp(state), 1, xc)
    val () = ev.xclient := xc
    val mask = if is_root then g0u2i(SubstructureRedirectMask) else 0
    val status = XSendEvent(state->dpy, win, false, mask, cptr_rvar(ev))
  in
    if status = 0 then fprintln!(
      stderr_ref, "UnboxedWM: Messaeg failed to send\n"
    )
   end