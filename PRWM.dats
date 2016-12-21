(* ****** ****** *)
//
// PRWM
// "A simle tiling window manager that unlocks the power of types!"
//
// Author: Ryan King (hello@ryanking.com)
//
(* ****** ****** *)

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"
#include "share/HATS/atslib_staload_libats_libc.hats"
#include "share/HATS/atspre_staload_libats_ML.hats"
staload "libats/libc/SATS/sys/types.sats"
staload "libats/libc/SATS/unistd.sats"

staload UN = "prelude/SATS/unsafe.sats"

staload "../ATS2-contrib/contrib/X11/SATS/X11.sats"
staload "./PRWM.sats"

(*- GLOBAL VARIABLES ---------------------------------------------------------*)

implement no_action(a) = ()

  val foo = ref<bool>(true)
val screen          = ref<int>(0)
val scr_width       = ref<int>(0)
val scr_height      = ref<int>(0)
val root            = ref<Window>(Window(0))
val current_desktop = ref<int>(0)
val quit            = ref<bool>(false)
val color_focus     = ref<ulint>(g0i2u(0))
val color_unfocus   = ref<ulint>(g0i2u(0))
val mode_p          = $extval(ptr, "&mode")
val size_p          = $extval(ptr, "&size")

val keys : list0(Key) = cons0(@{state = MOD, keysym = XK_h, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_l, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_x, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_j, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_Tab, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_k, action = no_action}: Key,
           cons0(@{state = MOD lor ShiftMask, keysym = XK_j, action = no_action}: Key,
           cons0(@{state = MOD lor ShiftMask, keysym = XK_k, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_Return, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_space, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_c, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_F7, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_F5, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_F6, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_F9, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_F10, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_F11, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_p, action = no_action}: Key,
           cons0(@{state = MOD lor ShiftMask, keysym = XK_Return, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_Right, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_Left, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_0, action = no_action}: Key,
           cons0(@{state = MOD lor ShiftMask, keysym = XK_0, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_1, action = no_action}: Key,
           cons0(@{state = MOD lor ShiftMask, keysym = XK_1, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_2, action = no_action}: Key,
           cons0(@{state = MOD lor ShiftMask, keysym = XK_2, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_3, action = no_action}: Key,
           cons0(@{state = MOD lor ShiftMask, keysym = XK_3, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_4, action = no_action}: Key,
           cons0(@{state = MOD lor ShiftMask, keysym = XK_4, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_5, action = no_action}: Key,
           cons0(@{state = MOD lor ShiftMask, keysym = XK_5, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_6, action = no_action}: Key,
           cons0(@{state = MOD lor ShiftMask, keysym = XK_6, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_7, action = no_action}: Key,
           cons0(@{state = MOD lor ShiftMask, keysym = XK_7, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_8, action = no_action}: Key,
           cons0(@{state = MOD lor ShiftMask, keysym = XK_8, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_9, action = no_action}: Key,
           cons0(@{state = MOD lor ShiftMask, keysym = XK_9, action = no_action}: Key,
           cons0(@{state = MOD, keysym = XK_q, action = no_action}: Key,
            nil0()))))))))))))))))))))))))))))))))))))))))))

(*- ERROR FUNCTIONS ----------------------------------------------------------*)

implement fatal(msg) = (
  fprintln!(stderr_ref, "PRWM: ", msg);
  exit(1)
)

(*- WINDOW FUNCTIONS ---------------------------------------------------------*)

implement spawn(display, arg) =
  case+ arg of
    | ARGstr(prog, _) =>
      if pid2int(fork()) = 0 then (
        println!("Made it here!");
        if pid2int(fork()) = 0 then () where {
           val () = println!("Connection Number ", XConnectionNumber(display))
          val _ = execv_unsafe(prog, the_null_ptr)
          //if XConnectionNumber(display) > 0 then let val _ = close(XConnectionNumber(display)) in () end
          // else println!("Did not close the shit")
        } else exit(0)
      ) else ()
    | _ =>> ()

implement set_mode(mode) = $UN.ptr0_set<int>(mode_p, mode)

implement set_size(mode) = $UN.ptr0_set<int>(size_p, mode)

implement change_desktop(display, arg) =
  case+ arg of
    | ARGint(num, ARGnull()) when num = !current_desktop => ()
    | ARGint(num, ARGnull()) => begin
        close_windows(display);
        save_desktop(!current_desktop);
        load_desktop(!current_desktop);
        open_windows(display);
      end
    | _ =>> fatal("Invalid desktop change attempt")

implement handle_event(ev) =
  case+ ev of
    | EVUnsupported(type) => println!("No idea what this is! ", type)
    | EVKeyPress(state, key) => println!("Key Press: ", state, " + ", key)
    | EVMapRequest(w) => println!("Window")
    | EVDestroyNotify(w) => println!("Destroy!")
    | EVConfigureRequest(w, x, y, width, height, border_width, above, detail, value_mask) => println!("Configure request!")

(* ****** ****** *)

// Runner Functions

(* ****** ****** *)

implement get_color(display, color) = c_scr.pixel where {
  var c_scr : XColor
  var c_ex :XColor
  val map = XDefaultColormap(display, 0)
  val status = XAllocNamedColor(display, map, color, c_scr, c_ex)
  val () = assertloc(status <> 0)
  prval () = opt_unsome{XColor}(c_scr)
  prval () = opt_unsome{XColor}(c_ex)
}

implement grab_keys(display, keys) = loop(display, keys) where {
  fun loop(display: !Display_ptr1, keys: list0(Key)): void =
    case+ keys of
      | cons0(key, keys2) =>
        let
          val code = XKeysymToKeycode(display, key.keysym)
          val state : uint = key.state
          val root : Window = ref_get_elt(root)
          val res = XGrabKey(display, g0int_of_uchar(code), state, root, true, GrabModeAsync, GrabModeAsync)
        in loop(display, keys2) end
      | _ =>> ()
}

implement main0() = let
  fun init_display(display_name: stropt): Display_ptr1 = display where {
    val display = XOpenDisplay(display_name)
    val () = if iseqz(display) then fatal("Failed to open the display")
    val () = assertloc(isneqz(display))
  }

  val () = sigchld(0)
  val display = init_display(stropt_none())
  val () = !screen := XDefaultScreen(display)
  val () = !root := XRootWindow(display, !screen)
  val () = !scr_width := XDisplayWidth(display, !screen)
  val () = !scr_height := XDisplayHeight(display, !screen)
  val () = !color_focus := get_color(display, FOCUS)
  val () = !color_unfocus := get_color(display, UNFOCUS)
  val () = grab_keys(display, keys)
  val () = set_mode(0)
  val () = let val size = g0f2i(0.6 * !scr_width) in set_size(size) end
  val () = make_desktops()
  val () = change_desktop(display, ARGint(1, ARGnull()))
  val () = XSelectInput(display, !root, SubstructureNotifyMask lor SubstructureRedirectMask);

  val urxvt = ARGstr("urxvt", ARGnull())

  var xev : XEvent?
  val () = while (true) let
      val () = XNextEvent(display, xev)
      val type = xev.type
      val () = if !foo then (spawn(display, urxvt); !foo := false)
    in
      case+ 0 of
        | _ when (type = KeyPress) =>
          let
            val xkey = xev.xkey : XKeyEvent
            val state = xkey.state
            val keycode = xkey.keycode
          in handle_event(EVKeyPress(state, keycode)) end
        | _ when (type = MapRequest) =>
          let
            val xmaprequest = xev.xmaprequest
            val window = xmaprequest.window
          in handle_event(EVMapRequest(window)) end
        | _ when (type = DestroyNotify) =>
          let
            val xdestroy = xev.xconfigurerequest
            val window = xdestroy.window
          in handle_event(EVDestroyNotify(window)) end
        | _ when (type = ConfigureRequest) =>
          let
            val xconfigurerequest = xev.xconfigurerequest
            val window = xconfigurerequest.window
            val x = xconfigurerequest.x
            val y = xconfigurerequest.y
            val width = xconfigurerequest.width
            val height = xconfigurerequest.height
            val border_width = xconfigurerequest.border_width
            val above = xconfigurerequest.above
            val detail = xconfigurerequest.detail
            val value_mask = xconfigurerequest.value_mask
          in
            handle_event(
              EVConfigureRequest(
                window, x, y, width, height, border_width,
                above, detail, value_mask
              )
            )
          end
        | _ =>> handle_event(EVUnsupported(type))
    end

  val () = XCloseDisplay(display)
  in () end


(* End of [PRWM.dats] *)
