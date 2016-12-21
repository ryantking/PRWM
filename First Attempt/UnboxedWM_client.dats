(* ****** ****** *)
//
// UnboxedWM
// Author: Ryan King <rtking@bu.edu>
//
// UnboxedWM_error.dats: Error handling
//
(* ****** ****** *)

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"
#include "share/HATS/atspre_staload_libats_ML.hats"

#include "UnboxedWM_error.dats"

(*- FUNCTION DEFINITIONS _----------------------------------------------------*)

implement client_is_null(cl) =
  case+ cl of | Client_none() => true | _ =>> false

implement client_isnot_null(cl) =
  case+ cl of | Client_some _ => true | _ =>> false

implement eq_client_client(cl1, cl2) =
  if iseqz(cl1) && iseqz(cl2) then true
  else if iseqz(cl1) || iseqz(cl2) then false
  else let
      val Client_some(_, props1, _) = cl1
      val Client_some(_, props2, _) = cl2
    in
      props1.window = props2.window && props1.label = props2.label &&
      props1.instance = props2.instance && props1.class = props2.class &&
      props1.name = props2.name
    end

implement neq_client_client(cl1, cl2) = ~(cl1 = cl2)

implement client_get_rev(cl) =
  case+ cl of
    | Client_none() => cptr_null()
    | Client_some(rev, _, _) => rev

implement client_get_next(cl) =
  case+ cl of
    | Client_none() => Client_none()
    | Client_some(_, _, next) => next

implement client_get_props(cl) =
  let
    exception PropertiesOfNullClient of ()
  in
    case+ cl of
      | Client_none() => $raise PropertiesOfNullClient()
      | Client_some(_, props, _) => props
  end

implement eq_cptrcl_cptrcl(clp1, clp2) =
  $UN.cptr_get<Client>(clp1) = $UN.cptr_get<Client>(clp2)

implement cptrcl_get_rev(clp) =
  if cptr_is_null(clp) then cptr_null()
  else
    let
      val cl = $UN.cptr_get<Client>(clp)
    in
      case+ cl of
        | Client_none() => cptr_null()
        | Client_some(rev, _, _) => rev
    end

implement cptrcl_get_next(clp) =
  if cptr_is_null(clp) then Client_none()
  else
    let
      val cl = $UN.cptr_get<Client>(clp)
    in
      case+ cl of
        | Client_none() => Client_none()
        | Client_some(_, _, next) => next
    end

implement cptrcl_get_props(clp) =
  let
    exception PropertiesOfNullClient of ()
    exception PropertiesOfNullClientPtr of ()
    val () = if cptr_is_null(clp) then $raise PropertiesOfNullClientPtr()
    val cl = $UN.cptr_get<Client>(clp)
  in
    case+ cl of
      | Client_none() => $raise PropertiesOfNullClient()
      | Client_some(_, props, _) => props
  end

implement set_active(state, cprops, on) =
  if cprops.parent = cprops.screen.root then state where {
    val _ = if on then XSetInputFocus(
                state->dpy, cprops.window, RevertToPointerRoot,
                timestamp(state)
              ) else XGrabButton(
                state->dpy, AnyButton, AnyModifier, cprops.parent, false,
                ButtonPressMask lxor ButtonReleaseMask, GrabModeAsync,
                GrabModeSync, 0, 0
              )
    val () = state->dpy := draw_border(state->dpy, cprops, on)
  } else state

implement draw_border(dpy, cprops, on) = dpy where {
  val bg = if on then cprops.screen.black else cprops.screen.white
  val _ = XSetWindowBackground(dpy, cprops.parent, bg)
  val _ = XClearWindow(dpy, cprops.parent)
  val _ = if cprops.hold && on then XDrawRectangle(
            dpy, cprops.parent, cprops.screen.gc, INSET, INSET,
            g0i2u(cprops.dx + BORDER - INSET),
            g0i2u(cprops.dx + BORDER - INSET)
          ) else 0
}
implement active(state, target) =
  if cptr_is_null(target) then
    (fprintln!(stderr_ref, "UnboxedWM: active(Client_none())"); state)
  else if target = state->current then state
  else state where {
    fun set_reverts(cl: Client):<cloref1> Client =
      case+ cl of
        | Client_none() => Client_none()
        | Client_some(rev, props, next) =>
            if rev = target
            then Client_some(target.rev(), props, set_reverts(next))
            else Client_some(rev, props, set_reverts(next))

    fun norm_reverts(cl: Client): Client =
      case+ cl of
        | Client_none() => Client_none()
        | Client_some(rev, props, next) =>
          if cptr_is_null(rev) || props.state = NormalState then cl
          else norm_reverts(Client_some(rev.rev(), props, next))

    val state = set_active(state, target.props(), false)
    val state = if cptr_is_null(state->current) then state
                else set_active(state, state->current.props(), false)
    val () = if cptr_isnot_null(state->current)
             then (state->clients) := set_reverts(state->clients)
    // val () = norm_reverts(clients)
    // val @Client_some(rev, props, next) = $UN.ptr0_get<Client>(target)
    // val () = $UN.ptr0_set<Client>(target, Client_some(current, props, next))
    // val c = $UN.ptr0_get<Client>(target)
    // val () = norm_reverts(c)
    // val () = $UN.ptr0_set<Client>(target, c)
    // val () = $UN.ptr0_set<Client>(current, c)
  }

(*
implement focus_primary(current) = ()

implement cmap_no_focus(scr) = ()

implement no_focus(state) =
  let
    fun loop(cl: ref(Client)):<cloref1> ref(Client) = (
      case+ !cl of
        | Client_none() => ref(Client_none())
        | Client_some(rev, props, next) =>
          if props.state = NormalState then
             ref(Client_some((loop(rev)), props, next)) where {
               val () = !state := !(active(state, !cl))
             }
          else cl)
    val () = if isneqz(!(state->cur_client)) then (
               !state := !(set_active(state, !(state->cur_client).props(), false));
               state->cur_client := loop(state->cur_client);
               cmap_no_focus((!(state->cur_client).props()).screen))
    val () = state->cur_client := ref(Client_none())
    var attr : XSetWindowAttributes?
    val () = attr.override_redirect := true
    val mask = CWOverrideRedirect
    val w = XCreateWindow(
        state->dpy, state->scr->root, 0, 0, g0i2u(1), g0i2u(1), g0i2u(0),
        g0u2i(CopyFromParent), InputOnly, cptr_null(), mask, cptr_rvar(attr)
      )
    val _ = XSetInputFocus(state->dpy, w, RevertToPointerRoot, timestamp(state))
  in
    state
  end

implement top(state, client) =
  let
    fun loop(cl: Client):<cloref1> Client =
      case+ cl of
        | Client_none() => Client_none()
        | Client_some(rev, props, _) =>
          if cl = client then Client_some(rev, props, state->clients)
          else loop(cl.next())
  in
    c
  end
  *)