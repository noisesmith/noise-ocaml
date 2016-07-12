module V = Sdlvideo

(* TODO - let's also use async?
 * #thread
 * #require "async"*)

class virtual widget =
  object (self)
    method virtual draw : V.surface -> bool
    method virtual update : int -> unit
  end

let default opt other =
  match opt with
  Some v -> v
  | None -> other

let adjustor a b a' b' =
  let domain = b -. a in
  let stretch = (b' -. a') /. domain in
  fun v -> (v -. a) *. stretch +. a'

let fi = float_of_int

class vslider x y w h ?min ?max ?init ?fg ?bg ?thumb () =
  let foreground = default fg 0x00ff00l in
  let background = default bg 0xff00ffl in
  let mn = default min 0 in
  let mx = default max 1 in
  let thumb_size = default thumb 5 in
  let ini = default init mn in
  let calc = adjustor (fi mn) (fi mx)
                      (fi (h - thumb_size)) 0. in
  object (self)
    inherit widget
    val mutable position = ini
    method draw surface =
      let base = {V.r_x = x;
                    r_y = y;
                    r_w = w;
                    r_h = h} in
      let thumb = {V.r_x = x;
                     r_y = position + y;
                     r_w = w;
                     r_h = thumb_size} in
      begin
        V.fill_rect ~rect:base surface background;
        V.fill_rect ~rect:thumb surface foreground;
        true
      end
    method update n = position <- int_of_float (calc (fi n)); ()
  end


let setup width height =
  let _ = V.set_video_mode width height [`DOUBLEBUF] in
  let surface = V.get_video_surface () in
  surface

let draw_ui surface ar =
  begin
    Array.iter (fun widget -> ignore (widget#draw surface)) ar;
    V.flip surface
  end


let main ?(width=800) ?(height=600) () =
  let widgets = [| new vslider 10 10 10 100 ~init:20 ();
                   new vslider 30 10 10 100 ~init:100 ();
                   new vslider 50 10 10 100 ~init:0 ();
                   new vslider 70 10 10 100 ~init:70 () |] in
  let surface = setup width height in
  begin
    draw_ui surface widgets;
    surface
  end
