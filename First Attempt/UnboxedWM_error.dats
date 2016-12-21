(* ****** ****** *)
//
// UnboxedWM
// Author: Ryan King <rtking@bu.edu>
//
// UnboxedWM_error.dats: Error handling
//
(* ****** ****** *)


(*- INCLUSIONS ---------------------------------------------------------------*)

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"
#include "share/HATS/atspre_staload_libats_ML.hats"

staload UN = "prelude/SATS/unsafe.sats"
staload "./../X11/SATS/X11.sats"
staload "./UnboxedWM.sats"

(*- VARIABLE INITIALIZATION --------------------------------------------------*)

val starting = ref<bool>(true)

(*- FUNCTION DEFINITIONS _----------------------------------------------------*)

implement fatal(msg) = (
  fprintln!(stderr_ref, "UnboxedWM: ", msg);
  exit(1)
)

implement handler(d, e_ptr) =
  let
    val (pf, fpf | e) = $UN.cptr_vtake(e_ptr)
  in
    if (!starting && $UN.cast{uchar}(!e.error_code) = BadAccess) &&
       ($UN.cast{uchar}(!e.request_code) = X_ChangeWindowAttributes) then (
        fprintln!(
          stderr_ref,
          "UnboxedWM: Another window manager is already running.",
          "UnboxedWM is not starting."
        );
        let prval () = fpf (pf) in exit(1) end
    ) else
        let
          var buff = @[char][1024]()
          val _ = XGetErrorText(
            d, $UN.cast{int}(!e.error_code),
            addr@buff, 1024
          )
          val err_text = $UN.cast{string}(buff)
          var buff = @[char][1024]()
          val _ = XGetErrorDatabaseText(
            d, "XRequest", tostring_int($UN.cast{int}(!e.request_code)),
            "", addr@buff, 1024
          )
          val req_text = $UN.cast{string}(buff)
          val _ = $extfcall(
            int, "fprintf", stderr_ref,
            "UnboxedWM: %s(0x%x): %s\n",
            req_text, !e.resourceid, err_text)
          prval () = fpf (pf)
        in
          0
        end
  end