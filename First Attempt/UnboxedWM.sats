(* ****** ****** *)
//
// UnboxedWM
// Author: Ryan King <rtking@bu.edu>
//
// UnboxedWM.sats: Static definitions
//
(* ****** ****** *)

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"
#include "share/HATS/atspre_staload_libats_ML.hats"

staload "./../X11/SATS/X11.sats"

(*- C INTERFACE --------------------------------------------------------------*)

%{#
#include "./UnboxedWM.cats"
%}

#define ATS_PACKNAME "UnboxedWM"  // ATS2 packaname
#define ATS_EXTERN_PREFIX "UnboxedWM_"

fun waitpid(int, ptr, int): int = "mac#%"
fun signal(int, (int) -> void): (int) -> void = "mac#%"

macdef SIGHUP  = $extval(int, "SIGHUP")
macdef SIGINT  = $extval(int, "SIGINT")
macdef SIGQUIT = $extval(int, "SIGQUIT")
macdef SIGFPE  = $extval(int, "SIGFPE")
macdef SIGKILL = $extval(int, "SIGKILL")
macdef SIGTERM = $extval(int, "SIGTERM")
macdef SIG_DFL = $extval((int) -> void, "SIG_DFL")
macdef SIG_IGN = $extval((int) -> void, "SIG_IGN")


(*- DEFINITIONS --------------------------------------------------------------*)

#define NULL         the_null_ptr // Null value
#define MAX_HIDDEN   32           // Max number of hidden windows
#define SHELL        "/usr/sh"    // Default shell
#define Pdelete 	   1
#define Ptakefocus	 2
#define ButtonMask ButtonPressMask lxor ButtonReleaseMask
#define BORDER       4
#define INSET        1

#define WithdrawnState 0
#define NormalState 1
#define IconicState 3

(*- TYPE DEFINITIONS ---------------------------------------------------------*)

typedef Args = @{
  exit = bool,
  restart = bool,
  font = string,
  term = string
}

// ScreenInfo: A single screen
typedef ScreenInfo = @{
  root = Window,
  menu_win = Window,
  def_cmap = Colormap,
  gc = GC,
  black = uint,
  white = uint,
  min_cmaps = int,
  target = Cursor,
  sweep0 = Cursor,
  boxcurs = Cursor,
  arrow = Cursor,
  root_pixmap = Pixmap
}

typedef ClientProps = @{
  window = Window,
  parent = Window,
  trans  = Window,
  hidden = Bool,

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
  hold = bool,
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
  screen = ScreenInfo
}

datatype Client =
  | Client_none of ()
  | Client_some of (cPtr0(Client), ClientProps, Client)

datatype Menu =
  | Menu_empty of ()
  | Menu_opt of (string, Menu)

typedef UWMState = @{
  time = Time,
  dpy = cPtr1(Display),
  scr = ref(ScreenInfo),
  clients = Client,
  current = cPtr0(Client),

  shell = string,
  term_prog = string,
  font = ref(cPtr0(XFontStruct)),
  rc_menu = Menu,

  exit_uwm = Atom,
  restart_uwm = Atom,
  wm_state = Atom,
  wm_change_state = Atom,
  _uwm_hold_mode = Atom,
  _uwm_running = Atom,
  wm_protocols = Atom,
  wm_delete = Atom,
  wm_take_focus = Atom,
  wm_colormaps = Atom,
  utf8_string = Atom,
  wm_moveresize = Atom,
  active_window = Atom
}

(* GLOBAL VARIABLES ----------------------------------------------------------*)
val starting        : ref(bool)
val signaled        : ref(bool)

(* FUNCTION DECLARATIONS -----------------------------------------------------*)

// Error Functions
fun	fatal : (string) -> void

// Main Functions
fun usage        : (bool) -> void
fun timestamp    : (ref(UWMState)) -> Time
fun send_message : (ref(UWMState), Window, Atom, int, bool) -> void
fun send_config  : () -> void
fun get_event    : () -> void

// Init Functions
fun parse_args{n:int | n >= 1}(int(n), !argv(n)) : ref(Args)
fun init_display : () -> cPtr1(Display)
fun init_signals : ((int) -> void) -> void
fun init_font    : (cPtr1(Display), list0(string), string) -> cPtr0(XFontStruct)
fun init_screen  : (cPtr1(Display), cPtr0(XFontStruct)) -> ScreenInfo
fun init_state   : (cPtr1(Display), ScreenInfo, cPtr0(XFontStruct), string) -> UWMState
fun cleanup      : () -> void

//Client Functions
fun client_is_null    : (Client) -> bool
fun client_isnot_null : (Client) -> bool
fun eq_client_client  : (Client, Client) -> bool
fun neq_client_client : (Client, Client) -> bool
fun client_get_rev    : (Client) -> cPtr0(Client)
fun client_get_next   : (Client) -> Client
fun client_get_props  : (Client) -> ClientProps
fun eq_cptrcl_cptrcl  : (cPtr0(Client), cPtr0(Client)) -> bool
fun cptrcl_get_rev    : (cPtr0(Client)) -> cPtr0(Client)
fun cptrcl_get_next   : (cPtr0(Client)) -> Client
fun cptrcl_get_props  : (cPtr0(Client)) -> ClientProps

symintr .props .next .rev
overload iseqz with client_is_null
overload isneqz with client_isnot_null
overload = with eq_client_client
overload != with neq_client_client
overload .rev with client_get_rev
overload .next with client_get_next
overload .props with client_get_props
overload = with eq_cptrcl_cptrcl
overload .rev with cptrcl_get_rev
overload .next with cptrcl_get_next
overload .props with cptrcl_get_props

fun	set_active        : (ref(UWMState), ClientProps, bool) -> ref(UWMState)
fun	draw_border       : (cPtr1(Display), ClientProps, bool) -> cPtr1(Display)
fun active            : (ref(UWMState), cPtr0(Client)) -> ref(UWMState)
fun focus_primary     : (ClientProps) -> void
fun	no_focus          : (ref(UWMState)) -> ref(UWMState)
fun top               : (ref(UWMState), Client) -> ref(UWMState)
fun get_client        : (ref(UWMState), Window, bool) -> void
fun rm_client         : (ref(UWMState), Client) -> void

fun	cmap_no_focus : (ScreenInfo) -> void

// Events
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

// Manager functions
fun manage : () -> int
fun	scanwins : () -> void
fun	setshape : () -> void
fun	withdraw : () -> void
fun	gravitate : () -> void
fun	cmapfocus : () -> void
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

// Menu functions
fun	button : (XButtonEvent) -> void
fun	spawn : () -> void
fun	reshape : () -> void
fun	move : () -> void
fun	delete : () -> void
fun	hide : () -> void
fun	unhide : () -> void
fun	unhidec : () -> void
fun	renamec : () -> void

// Mouse Functions
fun menuhit : () -> int
fun	selectwin : () -> Client
fun sweep : () -> int
fun drag : () -> int
fun	getmouse : () -> void
fun	setmouse : () -> void

// Error Functions
fun handler : (cPtr1(Display), cPtr1(XErrorEvent)) -> int
fun	graberror : () -> void
fun	showhints : () -> void