type metadata =
  { name : string
  ; description : string
  ; image : string option
  ; site : string
  ; locations : string list
  ; consortium : bool
  }
[@@deriving yaml]

let path = Fpath.v "data/industrial_users/en"

let parse content =
  let metadata, _ = Utils.extract_metadata_body content in
  metadata_of_yaml metadata

type t =
  { name : string
  ; slug : string
  ; description : string
  ; image : string option
  ; site : string
  ; locations : string list
  ; consortium : bool
  ; body_md : string
  ; body_html : string
  }

let all =
  Utils.map_files (fun content ->
      let metadata, body = Utils.extract_metadata_body content in
      let metadata = Utils.decode_or_raise metadata_of_yaml metadata in
      { name = metadata.name
      ; slug = Utils.slugify metadata.name
      ; description = metadata.description
      ; image = metadata.image
      ; site = metadata.site
      ; consortium = metadata.consortium
      ; locations = metadata.locations
      ; body_md = body
      ; body_html = Omd.of_string body |> Omd.to_html
      })

let all_en () = all "industrial_users/en"

let all_fr () = all "industrial_users/fr"

let pp ppf v =
  Fmt.pf
    ppf
    {|
  { name = %a
  ; slug = %a
  ; description = %a
  ; image = %a
  ; site = %a
  ; locations = %a
  ; consortium = %b
  ; body_md = %a
  ; body_html = %a
  }|}
    Pp.string
    v.name
    Pp.string
    v.slug
    Pp.string
    v.description
    (Pp.option Pp.string)
    v.image
    Pp.string
    v.site
    (Pp.list Pp.string)
    v.locations
    v.consortium
    Pp.string
    v.body_md
    Pp.string
    v.body_html

let pp_list = Pp.list pp

let template () =
  Format.asprintf
    {|
type t =
  { name : string
  ; slug : string
  ; description : string
  ; image : string option
  ; site : string
  ; locations : string list
  ; consortium : bool
  ; body_md : string
  ; body_html : string
  }
  
let all_en = %a

let all_fr = %a
|}
    pp_list
    (all_en ())
    pp_list
    (all_fr ())
