open Unix

let index = Bytes.index_from
let get = Bytes.get

let get_bits v pos len pos' =
  let () = assert ((pos - len) = pos') in
  let left_pad = 8 - pos in
  let left_trimmed = (v lsl left_pad) land 0xff in
  let right_pad = 8 - len in
  let result = left_trimmed lsr right_pad in
  result

type header = {
  bit_rate : int;
  frequency : int;
  pad : int;
  private_ : int;
  mode : int;
  mode_ext : int;
  copy : int;
  orig : int;
  emphasis : int
}

let mp3_header a b = {
  bit_rate = get_bits a 8 4 4;
  frequency = get_bits a 4 2 2;
  pad = get_bits a 2 1 1;
  private_ = get_bits a 1 1 0;
  mode = get_bits b 8 2 6;
  mode_ext = get_bits b 6 2 4;
  copy = get_bits b 4 1 3;
  orig = get_bits b 3 1 2;
  emphasis = get_bits b 2 2 0
}

let is_header bytes idx =
  (get bytes idx) = '\xff' && (get bytes (idx + 1)) = '\xff'

let rec find_header bytes idx =
  if is_header bytes idx
  then let a = get bytes (idx + 2) in
       let b = get bytes (idx + 3) in
       let byte_a = int_of_char a in
       let byte_b = int_of_char b in
       let header = mp3_header byte_a byte_b in
       (idx, header)
  else let new_idx = index bytes (idx + 1) '\xff' in
       find_header bytes new_idx

let file_bytes buf ?(i=0) ?(j=0) ?(len=0) name =
  let handle = openfile name [O_RDONLY] 0o640 in
  let n = match len with
          | 0 -> Bytes.length buf
          | _ -> len in
  let _ = lseek handle j SEEK_SET in
  let res = read handle buf i n in
  begin
    close handle;
    res
  end

let fold f init src =
  let acc = ref init in
  let step el =
    let next = f !acc el in
    acc := next in
  begin
    Bytes.iter step src;
    !acc
  end

let val_from b n len =
  let from = n / 8 in
  (* let from_mask = n mod 8 in *)
  let size = n+len in
  let _to = size / 8 in
  (* let shift = size mod 8 in *)
  let buffer = Bytes.sub b from _to in
  let folder (pos,t) b = (pos+8, t + ((int_of_char b) lsl pos)) in
  fst (fold folder (0,0) buffer)

let self_test () =
  let buf = Bytes.create 65536 in
  let _ = file_bytes buf ~j:65536 "res/441.mp3" in
  buf
