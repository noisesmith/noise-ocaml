let desc = Unix.descr_of_in_channel
let noblock = Unix.set_nonblock

let out on stuff =
  begin
    output_string on stuff;
    output_string on "\n";
    flush on
  end

let rec copy_buf ?(read_index=0) buffer input =
  let buf_len = Bytes.length buffer in
  match read_index with
  | x when x >= buf_len -> x
  | _ -> try
           let space = (buf_len - read_index) in
           let count = Unix.read input buffer read_index space in
           match count with
           | 0 -> read_index
           | _ -> copy_buf ~read_index:(count + read_index) buffer input
         with
         | Unix.Unix_error (n, s, e) when n = Unix.EAGAIN -> read_index
         | err -> begin
                    print_string (Printf.sprintf "exception %s in process"
                                                 (Printexc.to_string err));
                    read_index
                  end

let rec copy_all buf fd =
  let buf_len = Bytes.length buf in
  let consumed = copy_buf ~read_index:0 buf fd in
  let to_process = Bytes.sub_string buf 0 consumed in
  if consumed = buf_len
  then String.concat "" [to_process; copy_all buf fd]
  else to_process

let split_lines s =
  let rec lines acc idx =
    let found = try String.rindex_from s (idx-1) '\n'
                with
                | Not_found -> -1 in
    let region_start = found + 1 in
    let region_size = idx - region_start in
    let next_string = String.sub s region_start region_size in
    let new_acc = next_string :: acc in
    if region_start = 0
    then new_acc
    else lines (next_string :: acc) found in
  lines [] (String.length s)

class proc per_line args =
  let buf_len = 4096 in
  let buf = Bytes.create buf_len in
  object (self)
    val mutable process = None;
    val mutable _in = None;
    val mutable _out = None;
    val mutable _err = None;
    val mutable outfd = None;
    val mutable errfd = None;
    method start () =
      let env = Unix.environment () in
      let (o,i,e) = Unix.open_process_full args env in
      let out_desc = desc o in
      let err_desc = desc e in
      begin
        noblock out_desc;
        noblock err_desc;
        _in <- Some i;
        _out <- Some o;
        _err <- Some e;
        outfd <- Some out_desc;
        errfd <- Some err_desc;
      end
    method process ?(fd=outfd) () =
      let fdesc = match fd with
      | None -> failwith "no fd to process"
      | Some f -> f in
      let result = copy_all buf fdesc in
      let lines = split_lines result in
      List.iter per_line lines
  end
