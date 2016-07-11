module V = Sdlvideo

let setup width height =
  let _ = V.set_video_mode width height [`DOUBLEBUF] in
  let surface = V.get_video_surface () in
  surface
;;

let draw_ui surface ar =
  begin
    Array.iter
      (fun (rct,color) ->
        let rect = {V.r_x=rct.(0); r_y=rct.(1); r_w=rct.(2); r_h=rct.(3)} in
        V.fill_rect surface ~rect color)
      ar;
    V.flip surface
  end
;;


let main ?(width=800) ?(height=600) () =
  let rects = [|([|10; 10; 20; 10|], 0x00ff00l);
                ([|10; 10; 10; 20|], 0xff00ffl)|] in
  let surface = setup width height in
  draw_ui surface rects
;;
