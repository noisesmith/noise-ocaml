module V = Vidstuff
module M = Midistuff

let sliders =
  [|([|10; 10; 10; 140|], 0xffffffl);
    ([|10; 137; 10; 12|], 0x000000l)|]

let update_array arr n f =
  Array.set arr n (f arr.(n))

let main () =
   let midi_info = M.select_device true ~regex:"nano" () in
   let midi_index = match midi_info with
   | Some (i, _) -> i
   | None -> failwith "no nano found" in
   let midi = M.get_stream midi_index in
   let run_midi = M.map_midi midi in
   let surface = V.setup 800 600 in
   let midi_handler ((estatus, data1, data2) as status) =
     begin
       M.print_event status;
       match sliders.(1) with
       | (el, _) -> Array.set el 1 (137 - data2)
       | _ -> failwith "cannot find widget to update"
     end in
   let rec go () =
     begin
       run_midi midi_handler;
       V.draw_ui surface sliders;
       go ()
     end in
   go ()
