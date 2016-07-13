module V = Vidstuff
module M = Midistuff

let controls = V.IntMap.(
  empty
  |> add 1 (new V.vslider "pitch" 10 10 10 100 ~max:127 ())
  |> add 2 (new V.vslider "modulation" 20 10 10 100 ~max:127 ()))

let usleep n =
  ignore (Unix.select [] [] [] n)

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
       if V.IntMap.mem data1 controls
       then let slider = V.IntMap.find data1 controls in
           slider#update data2
       else ()
     end in
   let rec go () =
     begin
       run_midi midi_handler;
       V.draw_ui surface controls;
       usleep 0.05;
       go ()
     end in
   go ()
