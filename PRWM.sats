(*
** Copyright (c) 2016 Ryan King
**
** Permission to use, copy, modify, and distribute this software for any
** purpose with or without fee is hereby granted, provided that the above
** copyright notice and this permission notice appear in all copies.
**
** THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
** WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
** MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
** ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
** WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
** ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
** OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*)

(* ****** ****** *)
//
// PRWM
// "A simle tiling window manager that unlocks the power of types!"
//
// Author: Ryan King (hello@ryanking.com)
//
(* ****** ****** *)

%{#
#include "PRWM.cats"
%}

#define ATS_PACKNAME "PRWM"
#define ATS_EXTERN_PREFIX "prwm_"

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"
#include "share/HATS/atspre_staload_libats_ML.hats"

staload FM = "libats/SATS/funmap_avltree.sats"
staload _ = "libats/DATS/funmap_avltree.dats"

staload "../ATS2-contrib/contrib/X11/SATS/X11.sats"

(*- CONSTANT DEFINITIONS -----------------------------------------------------*)

#define NUM_DESKTOPS 10

#define MOD     Mod1Mask

#define FOCUS   "rgb:bf/61/6a"
#define UNFOCUS "rgb:8f/a1/b3"

macdef MODE = $extval(int, "mode")
macdef SIZE = $extval(int, "size")

(* ****** ****** *)

// C Types

(* ****** ****** *)

absvtype Client_ptr (l:addr) = ptr(l)
vtypedef Client_ptr0 = [l:agez] Client_ptr(l)
vtypedef Client_ptr1 = [l:addr | l > null] Client_ptr(l)

fun sigchld(int): void = "mac#%"

fun make_desktops(): void = "mac#%"

fun open_windows(!Display_ptr1): void = "mac#%"

fun close_windows(!Display_ptr1): void = "mac#%"

fun save_desktop(int): void = "mac#%"

fun load_desktop(int): void = "mac#%"

(*- TYPE DEFS ----------------------------------------------------------------*)

absvt@ype Desktop = $extype_struct"Desktop" of {
  mode = int,
  size = int,
  head = Client_ptr0,
  current = Client_ptr0
}

datatype Event =
  | EVUnsupported of (int)
  | EVKeyPress of (uint, uint)
  | EVMapRequest of (Window)
  | EVDestroyNotify of (Window)
  | EVConfigureRequest of (Window, int, int, int, int, int, Window, int, ulint)

datatype Arg =
  | ARGnull of ()
  | ARGint of (int, Arg)
  | ARGstr of (string, Arg)

typedef Key = @{
  state = uint,
  keysym = KeySym,
  action = (Arg) -> void
}

typedef Cmd = ((Arg) -> void, Arg)

(*- FUNCTIONS ----------------------------------------------------------------*)

fun spawn : (!Display_ptr1, Arg) -> void

fun no_action : (Arg) -> void

fun fatal      : (string) -> void

fun set_mode : (int) -> void

fun set_size : (int) -> void

fun add_window : (Window) -> void

fun change_desktop : (!Display_ptr1, Arg) -> void

fun handle_event : (Event) -> void

fun get_color  : (!Display_ptr1, string) -> ulint

fun grab_keys : (!Display_ptr1, list0(Key)) -> void

(* End of [PRWM.sats] *)