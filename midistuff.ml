open Portmidi;;
open Printf;;
open Str;;

type devices =
  {inputs : (int * Portmidi.device_info) list;
   outputs : (int * Portmidi.device_info) list;
   default : (int * Portmidi.device_info) option}

let device_query () =
  let device_count = count_devices () in
  let default_index = get_default_input_device_id () in
  let rec devices n found =
    let {inputs; outputs; default} = found in
    if n >= device_count
    then found
    else let next_device = get_device_info n in
         let next = (n, next_device) in
         let default = if n = default_index
                       then (Some next)
                       else default in
         let found =
           match next_device with
           | {input = true} -> {default; inputs = next :: inputs; outputs}
           | {input = false} -> {default; inputs; outputs = next :: outputs} in
         devices (n + 1) found in
         devices 0 {inputs=[]; outputs=[]; default=None}
;;

let select_device input ?(regex=".*") ?devices () =
  let {inputs; outputs} = match devices with
                          | (Some d) -> d
                          | None -> device_query () in
  let dev_list = if input
                 then inputs
                 else outputs in
  let matched (_, {name}) = string_match (regexp regex) name 0 in
  let rec find_dev devices =
    match devices with
    | [] -> None
    | (d :: _) when matched d -> (Some d)
    | (_ :: ds) -> find_dev ds in
  find_dev dev_list
;;

let nanocontrol () = select_device true ~regex:"nanoKONTROL MIDI" ()

let nanostream () =
  let res = nanocontrol () in
  match res with
  | Some (device_index, device) -> (Some (open_input device_index 64))
  | None -> None

let map_midi stream =
  let events = Array.make 128 {message = Int32.zero; timestamp=Int32.zero} in
  let rec map_stream f =
    let read_count = read_stream stream events 0 128 in
    let rec process n =
      if read_count <= n
      then ()
      else begin
        f (message_contents events.(n).message);
        process (n + 1)
      end in
    (* printf "processing %d events\n" read_count; *)
    process 0 in
  map_stream

let print_event (status, data1, data2) =
  begin
    printf "%d\t%d\t%d" status data1 data2;
    print_newline ()
  end
;;

let main ?(dev = "nanoKONTROL MIDI") () =
  let info = select_device true ~regex:dev () in
  let index = match info with
  | Some (i, _) -> i
  | None -> failwith (sprintf "No \"%s\" device found." dev) in
  let stream = open_input index 64 in
  let mm = map_midi stream in
    let rec go () =
      begin
        mm print_event;
        go ();
      end in
    go ()
;;
