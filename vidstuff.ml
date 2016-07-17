module V = Sdlvideo

module IntMap = Map.Make(struct type t = int let compare = compare end)

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

class vslider name x y w h ?min ?max ?init ?fg ?bg ?thumb () =
  let foreground = default fg 0x00ff00l in
  let background = default bg 0xff00ffl in
  let mn = default min 0 in
  let mx = default max 127 in
  let thumb_size = default thumb 5 in
  let ini = default init mn in
  let calc = adjustor (fi mn) (fi mx)
                      (fi (h - thumb_size)) 0. in
  let put n = int_of_float (calc (fi n)) in
  object (self)
    inherit widget
    val name = name
    val mutable position = put ini
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
    method update n = position <- int_of_float (calc (fi n))
  end


let setup width height =
  let _ = V.set_video_mode width height [`DOUBLEBUF] in
  let surface = V.get_video_surface () in
  surface

let draw_ui surface im =
  begin
    IntMap.iter (fun _ widget -> ignore (widget#draw surface)) im;
    V.flip surface
  end

let widgets =
  let open IntMap in
  empty
  |> add 1 (new vslider "a" 10 10 10 100 ~init:20 ())
  |> add 2 (new vslider "b" 30 10 10 100 ~init:10 ())
  |> add 3 (new vslider "c" 50 10 10 100 ~init:0 ())
  |> add 4 (new vslider "d" 70 10 10 100 ~init:70 ())

let main ?(width=800) ?(height=600) () =
  let surface = setup width height in
  begin
    draw_ui surface widgets;
    surface
  end
