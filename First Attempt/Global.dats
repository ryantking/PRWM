(* ****** ****** *)
//
// UnboxedWM
// Author: Ryan King <rtking@bu.edu>
//
(* ****** ****** *)

#include "share/HATS/atspre_staload_libats_ML.hats"
staload UN = "prelude/SATS/unsafe.sats"

staload "./../X11/SATS/X11.sats"
staload "./Global.sats"

(* ****** ****** *)

#define NULL the_null_ptr

(* ****** ****** *)

val curtime = ref<int> (0)
val clients = ref<Client> ($UN.cast{Client}(0))

(* ****** ****** *)

implement getscreen(w) =
  let
    fun loop(scrs: list0(ScreenInfo)):<cloref1> ScreenInfo =
      case+ screens of
        | nil0() => $UN.cast{ScreenInfo}(0)
        | cons0(scr, scrs2) => if scr.root = w then scr else loop(scrs2)
  in
    loop(screens)
  end

implement client_nil() = $UN.cast{Client}(0)

implement client_def() =
  @{
    window = $UN.cast{Window}(0),
    parent = $UN.cast{Window}(0),
    trans = $UN.cast{Window}(0),
    next = $UN.cast{ptr}(clients),
    next = $UN.cast{ptr}(0),
    x = 0,
    y = 0,
    dx = 0,
    dy = 0,
    border = 0,
    size = $UN.cast{XSizeHints}(0),
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
    cmap = $UN.cast{Colormap}(0),
    ncmapwins = 0,
    cmapwins = $UN.cast{Window}(0),
    wmcmaps = $UN.cast{Colormap}(0),
    screen = $UN.cast{ptr}(0)
  } : Client

implement clients_eq(c1: Client, c2: Client): bool =
  c1.window = c2.window &&
  c1.parent = c2.parent

implement getclient(w, create) =
  let
    fun loop(cli: &Client):<cloref1> Client = (
      if cli = the_null_ptr then the_null_ptr
      else
        if cli->window = w || cli->parent = w then cli
        else loop(cli.next))
    val cli = if w = 0 || getscreen(w) then client_nil() else loop(clients)
    val cli = if cli != client_nil() then
                (cli.next := clients; clients := cli; cli)
              else
                if create then client_def()
                else client_nil()
  in
    cli
  end


(*
implement getclient(w, create) =
  let
    fun loop(cli: &Client):<cloref1> Client =

      case+ clis of
        | nil0() =>
          if create then
            let
              val cli2 = @{
              } : Client
              val () = !clients := cli2
            in cli2 end
          else $UN.cast{Client}(0)
        | cons0(cli, clis2) =>
          if cli.window = w || cli.parent = w then cli
          else loop(clis2)
  in
    if w = 0 || getscreen(0) then
  end
*)