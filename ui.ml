module V = Vidstuff
module M = Midistuff

let sliders = [| new V.vslider 10 10 10 100 ~max:127 ();
                 new V.vslider 20 10 10 100 ~max:127 ~thumb:10 ();
                 new V.vslider 30 10 10 100 ~max:127 ~thumb:20 ();
                 new V.vslider 40 10 10 100 ~max:127 ~thumb:40 ();
                 new V.vslider 10 210 10 100 ~max:127 ();
                 new V.vslider 20 210 10 100 ~max:127 ~thumb:10 ();
                 new V.vslider 30 210 10 100 ~max:127 ~thumb:20 ();
                 new V.vslider 40 210 10 100 ~max:127 ~thumb:40 () |]

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
       Array.iter (fun x -> x#update data2) sliders
     end in
   let rec go () =
     begin
       run_midi midi_handler;
       V.draw_ui surface sliders;
       Unix.select [] [] [] 0.05;
       go ()
     end in
   go ()
