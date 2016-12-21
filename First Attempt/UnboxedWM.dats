(* ****** ****** *)
//
// UnboxedWM
// Author: Ryan King <rtking@bu.edu>
//
(* ****** ****** *)

(* ****** ****** *)
#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"
#include "share/HATS/atslib_staload_libats_libc.hats"
#include "share/HATS/atspre_staload_libats_ML.hats"
(*
#include "UnboxedWM_main.dats"

implement parse_args{n}(argc, argv) =
  let
    var res = ref<Args>(@{
      exit = false,
      restart = false,
      font = "",
      term = ""
    })
    fun loop{i: int | i >= 1; i <= n}
    (i: int i, argv: !argv(n), res: ref(Args)): ref(Args) =
      if i = argc then res
      else let val cmd = argv[i] in
        case+ 0 of
          | _ when cmd = "exit" =>
        (res->exit := true; loop(succ(i), argv, res))
          | _ when cmd = "restart" =>
        (res->restart := true; loop(succ(i), argv, res))
          | _ when cmd = "-h" || cmd = "--help" => (usage(false); res)
          | _ when cmd = "-f" || cmd = "--font" =>
            let val i = succ(i) in
              if i < argc then (res->font := argv[i]; loop(succ(i), argv, res))
              else (usage(true); res)
            end
          | _ when cmd = "-t" || cmd = "--term" =>
            let val i = succ(i) in
              if i < argc then (res->term := argv[i]; loop(succ(i), argv, res))
              else (usage(true); res)
            end
          | _ =>> (usage(true); res)
      end
    val args = loop(1, argv, res)
  in
    if args->exit && args->restart then (usage(true); args) else args
  end

implement init_display() = dpy where {
    val dpy = XOpenDisplay("")
    val () = if dpy = 0 then fatal("Failed to open the display")
    val () = assertloc(dpy > 0)
  }

implement init_signals(handler) = (
  if sigterm_res = sig_ign_int then (signal(SIGTERM, SIG_IGN))(0);
  if sigint_res = sig_ign_int then (signal(SIGINT, SIG_IGN))(0);
  if sighup_res = sig_ign_int then (signal(SIGHUP, SIG_IGN))(0);
  ())
  where {
    val sig_ign_int = $UN.cast{int}(SIG_IGN)
    val sigterm_res = $UN.cast{int}(signal(SIGTERM, handler))
    val sigint_res = $UN.cast{int}(signal(SIGINT, handler))
    val sighup_res = $UN.cast{int}(signal(SIGHUP, handler))
  }

implement init_font(dpy, fonts, user_fname) =
  let
    val user_font = XLoadQueryFont(dpy, user_fname)
    fun loop(dpy: cPtr1(Display), fonts: list0(string)): cPtr0(XFontStruct) =
      case+ fonts of
        | nil0() => (fatal("UnboxedWM: Could not load a font."); cptr_null())
        | cons0(fname, fonts2) =>
          let val font = XLoadQueryFont(dpy, fname) in
            if font = 0 then loop(dpy, fonts2) else font
          end
  in
    if user_font != 0 then user_font
    else (
      if user_fname = "" then ()
      else fprintln!(stderr_ref, "UnboxedWM: User font failed to load.");
      loop(dpy, def_fonts))
  end

implement init_screen(dpy, font) = scr where {
    var scr : ScreenInfo
    val () = scr.root_pixmap := 0
    val () = scr.root := DefaultRootWindow(dpy)
    val () = scr.def_cmap := DefaultColormap(dpy, 0)
    val () = scr.min_cmaps :=
      ($UN.cptr_get<Screen>(ScreenOfDisplay(dpy, 0))).min_maps
    val () = scr.black := BlackPixel(dpy, 0)
    val () = scr.white := WhitePixel(dpy, 0)
    val () = scr.target := XCreateFontCursor(dpy, XC_left_ptr)
    val () = scr.sweep0 := XCreateFontCursor(dpy, XC_crosshair)
    val () = scr.boxcurs := XCreateFontCursor(dpy, XC_sizing)
    val () = scr.arrow := XCreateFontCursor(dpy, XC_dotbox)
    val () = scr.menu_win := XCreateSimpleWindow(
      dpy, scr.root, 0, 0, g0i2u(1), g0i2u(1), g0i2u(1), scr.black, scr.white
    )
    var gv : XGCValues?
    val () = gv.function := GXxor
    val () = gv.foreground := scr.black lxor scr.white
    val () = gv.background := scr.white
    val () = gv.line_width := 0
    val () = gv.subwindow_mode := IncludeInferiors
    val () = gv.font := (if font > 0 then ($UN.cptr_get(font)).fid else 0)
    val mask = GCForeground lor GCBackground lor GCFunction lor GCLineWidth lor
               GCSubwindowMode
    val mask = if font > 0 then mask lor GCFont else mask
    val () = scr.gc := XCreateGC(dpy, scr.root, mask, cptr_rvar(gv))

    var attr : XSetWindowAttributes?
    val () = attr.cursor := scr.arrow
    val () = attr.event_mask := SubstructureRedirectMask lor
      SubstructureNotifyMask lor ColormapChangeMask lor ButtonPressMask lor
      ButtonReleaseMask lor PropertyChangeMask
    val cw_mask = CWCursor lor CWEventMask
    val _ = XChangeWindowAttributes(dpy, scr.root, cw_mask, cptr_rvar(attr))
    val _ = XSync(dpy, false)
  }

implement init_state(dpy, scr, font, term_prog) =
  @{
    time = CurrentTime,
    dpy = dpy,
    scr = ref(scr),
    clients = Client_none(),
    current = cptr_null(),
    shell = let
        val env_shell = getenv_opt("SHELL") in
        if option0_is_some(env_shell) then option0_unsome_exn<string>(env_shell)
        else "/bin/sh" end,
    term_prog = term_prog,
    font = ref<cPtr0(XFontStruct)>(font),
    rc_menu = Menu_opt("New",
              Menu_opt("Resize",
              Menu_opt("Move",
              Menu_opt("Hide",
              Menu_opt("Exit",
              Menu_empty()))))),

    exit_uwm = XInternAtom(dpy, "UWM_EXIT", false),
    restart_uwm = XInternAtom(dpy, "UWM_RESTART", false),
    wm_state = XInternAtom(dpy, "WM_STATE", false),
    wm_change_state = XInternAtom(dpy, "WM_CHANGE_STATE", false),
    wm_protocols = XInternAtom(dpy, "WM_PROTOCOLS", false),
    wm_delete = XInternAtom(dpy, "WM_DELTE_WINDOW", false),
    wm_take_focus = XInternAtom(dpy, "WM_TAKE_FOCUS", false),
    wm_colormaps = XInternAtom(dpy, "WM_COLORMAP_WINDOWS", false),
    wm_moveresize = XInternAtom(dpy, "WM_MOVERESIZE", false),
    active_window = XInternAtom(dpy, "ACTIVE_WINDOW", false),
    utf8_string = XInternAtom(dpy, "UTF8_STRING", false),
    _uwm_running = XInternAtom(dpy, "_UWM_RUNNING", false),
    _uwm_hold_mode = XInternAtom(dpy, "_UWM_HOLD_MODE", false)
  }: UWMState

implement main0(argc, argv) =
  let
    val args= parse_args(argc, argv)
    val _ = init_signals(lam (signal :int): void => !signaled := true)
    val dpy = init_display()
    val _ = XSetErrorHandler(handler)
    val font = init_font(dpy, def_fonts, args->font)
    val scr = init_screen(dpy, font)
    val state = ref<UWMState>(init_state(dpy, scr, font, args->term))
    val () = if args-> exit then send_message(
          state, DefaultRootWindow(state->dpy), state->exit_uwm, 0, true
        )
    val () = if args-> restart then send_message(
          state, DefaultRootWindow(state->dpy), state->restart_uwm, 0, true
        )
    val _ = XSync(state->dpy, false)
    val () = !starting := false
    val _ = XCloseDisplay(state->dpy)
  in () end
*)

implement main0(argc, argv) = let val foo = g0i2u(4) in () end