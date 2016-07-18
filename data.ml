open Unix

let mp3_structure =
  object
   val sync_word = (0, 12, 0xfff);
   val version = (13, 13, 0x1);
   val layer = (14, 15, 0x1);
   val error = (16, 16, 0x1);
   val bit_rate = (17, 20, 0xa);
   val frequency = (21, 22, 0x0);
   val pad = (23, 23, 0x0);
   val private_ = (24, 24, 0x0);
   val mode = (25, 26, 0x1);
   val mode_ext = (27, 28, 0x0);
   val copy = (29, 29, 0x0);
   val orig = (30, 30, 0x0);
   val emphasis = (31, 32, 0x0)
  end

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
  let _ = file_bytes buf ~j:65536 "res/knabble.mp3" in
  buf
