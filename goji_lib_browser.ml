(* Published under the LGPL version 3
   Binding (c) 2013 Benjamin Canou *)

open Goji

let browser_package =
  register_package
    ~doc:"Basic JavaScript types and functions"
    ~version:"0.1"
    "browser"

let javascript_component =
  register_component
    ~license:Goji_license.lgpl_v3
    ~doc:"Basic JavaScript types and functions"
    browser_package "JavaScript"
    [ def_type
        ~doc:"Generic JavaScript values"
        "js_value" (abstract any) ;
      def_type
        ~doc:"Generic JavaScript objects"
        "js_object" (abstract any) ;
      def_type
        ~doc:"Native JavaScript (immutable, UTF-16) strings"
        "js_string" (abstract any) ;
      def_type
        ~doc:"Regular Expressions"
        "js_regexp" (abstract any) ;
      def_type
        ~doc:"Date objects"
        "js_date" (abstract any) ;

      structure "js_string"
        ~doc:"Operations on native JavaScript strings" [

        section "Construction" [

          def_function "to_string"
            ~doc:"Convert a native JavaScript UTF-16 string to an \
                  UTF-8 encoded OCaml string"
            [ curry_arg "str" (abbrv "js_string" @@ var "tmp") ]
            (get (var "tmp"))
            string ;
          def_function "of_string"
            ~doc:"Convert an OCaml string, expected to be UTF-8 encoded, \
                  to a native JavaScript UTF-16 string"
            [ curry_arg "str" (string @@ var "tmp") ]
            (get (var "tmp"))
            (abbrv "js_string") ;

          def_function "coerce_string"
            ~doc:"Use a JavaScript value as a JavaScript string (may raise Invalid_argument)"
            [ curry_arg "v" (abbrv "js_value" @@ var "tmp") ]
            (var_instanceof "tmp" "String")
            (abbrv "js_string") ;

          (* TODO: RangeError *)
          def_function "from_char_code"
            ~doc:"build a string from a single UTF-16 character code"
            [ curry_arg "code" (int @@ arg 0) ]
            (call (jsglobal "String.fromCharCode"))
            (abbrv "js_string") ;
          def_function "from_char_codes"
            ~doc:"build a string from a sequence of UTF-16 character codes"
            [ curry_arg "code" (list int @@ unroll ()) ]
            (call (jsglobal "String.fromCharCode"))
            (abbrv "js_string") ;

          def_function "from_code_point"
            ~doc:"build a string from a single UTF-32 code point"
            [ curry_arg "code" (int @@ arg 0) ]
            (call (jsglobal "String.fromCodePoint"))
            (abbrv "js_string") ;
          def_function "from_code_points"
            ~doc:"build a string from a sequence of UTF-32 code points"
            [ curry_arg "code" (list int @@ unroll ()) ]
            (call (jsglobal "String.fromCodePoint"))
            (abbrv "js_string") ;

          def_function "concat"
            ~doc:"Concatenates two native JavaScript strings"
            [ curry_arg "left" (abbrv "js_string" @@ this) ;
              curry_arg "right" (abbrv "js_string" @@ arg 0) ]
            (call_method "concat")
            (abbrv "js_string") ;

          def_function "repeat"
            ~doc:"Repeats a string a given number of times"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "count" (int @@ arg 0) ]
            (call_method "repeat")
            (abbrv "js_string") ;

          def_function "slice"
            ~doc:"Takes a slice of a string between two indexes. \
                  Indexes larger than the length of the string are truncated. \
                  Negative indexes are interpreted as backward offsets from the end of the string"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "start" (int @@ arg 0) ;
              curry_arg "stop" (int @@ arg 1) ]
            (call_method "slice")
            (abbrv "js_string") ;

          def_function "slice_from"
            ~doc:"Takes a slice of a string between an index and the end. \
                  Indexes larger than the length of the string are truncated. \
                  Negative indexes are interpreted as backward offsets from the end of the string"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "start" (int @@ arg 0) ]
            (call_method "slice")
            (abbrv "js_string") ;

          def_function "sub"
            ~doc:"Takes a slice of a string from an index and up to a given size. \
                  Indexes larger than the length of the string are truncated. \
                  Negative indexes are interpreted as backward offsets from the end of the string"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "start" (int @@ arg 0) ;
              curry_arg "len" (int @@ arg 1) ]
            (call_method "substr")
            (abbrv "js_string") ;

          def_function "trim"
            ~doc:"Removes whitespace at both ends of the string"
            [ curry_arg "str" (abbrv "js_string" @@ this) ]
            (call_method "trim")
            (abbrv "js_string") ;

          def_function "lowercase"
            ~doc:"Transforms a string to lowercase"
            [ opt_arg "use_locale" (bool @@ var "flag") ;
              curry_arg "str" (abbrv "js_string" @@ this) ]
            (test Guard.(var "flag" = bool true)
                (call_method "toLocaleLowerCase")
                (call_method "toLowerCase"))
            (abbrv "js_string") ;

          def_function "uppercase"
            ~doc:"Transforms a string to uppercase"
            [ opt_arg "use_locale" (bool @@ var "flag") ;
              curry_arg "str" (abbrv "js_string" @@ this) ]
            (test Guard.(var "flag" = bool true)
                (call_method "toLocaleUpperCase")
                (call_method "toUpperCase"))
            (abbrv "js_string") ;

        ] ;

        section "Access" [

          def_function "length"
            ~doc:"Number of UTF-16 characters in a native JavaScript string"
            [ curry_arg "str" ~doc:"The string" (abbrv "js_string" @@ var "obj") ]
            (get ((field (var "obj") "length")))
            int ;

          def_function "get_char_code"
            ~doc:"Access the UTF-16 characters of a native JavaScript string"
            [ curry_arg "str" ~doc:"The string" (abbrv "js_string" @@ this) ;
              curry_arg "nth" ~doc:"The position in the string starting from 0" (int @@ arg 0) ]
            (call_method "charCodeAt")
            int ;

          def_function "get_code_point"
            ~doc:"Access the UTF-32 characters of a native JavaScript string. \
                  Note that the index is still an UTF-16 index, this function \
                  just reads two UTF-16 chars to build a UTF-32 one when called \
                  on the first half of a surrogate pair"
            [ curry_arg "str" ~doc:"The string" (abbrv "js_string" @@ this) ;
              curry_arg "nth" ~doc:"The position in the string starting from 0" (int @@ arg 0) ]
            (call_method "codePointAt")
            int ;

        ] ;

        section "Escaping" [

          def_function "decode_URI"
            ~doc:"Decode escape sequences in an URI encoded string"
            [ curry_arg "str" (abbrv "js_string" @@ arg 0) ]
            (call (jsglobal "decodeURI"))
            (abbrv "js_string") ;

          def_function "encode_URI"
            ~doc:"Escape non alphanumeric or reserved characters in an URI. \
                 Only works on a valid URI, otherwise raises \
                  [Invalid_argument \"encode_URI\"]"
            [ curry_arg "str" (abbrv "js_string" @@ arg 0) ]
            (try_catch
               ~exns:[ Guard.(root = obj "URIError" && raise "Invalid_argument \"encode_URI\""), Const.undefined ]
               (call (jsglobal "encodeURI")))
            (abbrv "js_string") ;

          def_function "decode_URI_component"
            ~doc:"Decode escape sequences in an URI encoded string"
            [ curry_arg "str" (abbrv "js_string" @@ arg 0) ]
            (call (jsglobal "decodeURIComponent"))
            (abbrv "js_string") ;

          def_function "encode_URI_component"
            ~doc:"URI escape non alphanumeric or reserved characters in an string"
            [ curry_arg "str" (abbrv "js_string" @@ arg 0) ]
            (call (jsglobal "encodeURIComponent"))
            (abbrv "js_string") ;
          
        ] ;

        section "Parsing" [

          def_function "parse_int"
            ~doc:"Parses an integer in JavaScript format and in the given radix. \
                  Be default, the radix is infered from the prefix: 10 if none, 16 if [0x], \
                  implementation dependent if [0]"
            [ opt_arg "radix" (int @@ rest ()) ;
              curry_arg "str" (abbrv "js_string" @@ arg 0) ]
            (call (jsglobal "parseInt"))
            (option_nan int) ;

          def_function "parse_float"
            ~doc:"Parses an float in JavaScript format. \
                  Warning, [parse_float \"NaN\"] will return [None]"
            [ curry_arg "str" (abbrv "js_string" @@ arg 0) ]
            (call (jsglobal "parseFloat"))
            (option_nan float)
        ] ;

        section "Search and Replace" [

          def_function "contains_from"
            ~doc:"Search for a substring starting at a given offset \
                  (0 if not specified)"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              opt_arg "offset" (int @@ arg 1) ;
              curry_arg "sub" (abbrv "js_string" @@ arg 0) ]
            (call_method "contains")
            bool ;

          def_function "ends_with"
            ~doc:"Determines if a substring is present and ends at \
                  a given position (or at the end if not specified)"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              opt_arg "offset" (int @@ arg 1) ;
              curry_arg "sub" (abbrv "js_string" @@ arg 0) ]
            (call_method "endsWith")
            bool ;

          def_function "starts_with"
            ~doc:"Determines if a substring is present and starts at \
                  a given position (or at 0 if not specified)"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              opt_arg "offset" (int @@ arg 1) ;
              curry_arg "sub" (abbrv "js_string" @@ arg 0) ]
            (call_method "startsWith")
            bool ;

          def_function "index_of"
            ~doc:"Search for a substring and return its position \
                  starting at a given offset (0 if not specified)"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              opt_arg "offset" (int @@ arg 1) ;
              curry_arg "sub" (abbrv "js_string" @@ arg 0) ]
            (call_method "indexOf")
            (Option (Guard.(var "root" = Const.int (-1)), int)) ;

          def_function "index_of_regexp"
            ~doc:"Returns the matching position when successful"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "pattern" (abbrv "js_regexp" @@ arg 0) ]
            (call_method "search")
            (Option (Guard.(var "root" = Const.int (-1)), int)) ;

          def_function "last_index_of"
            ~doc:"Search for a substring and return the position \
                  of its last occurence starting at a given offset \
                  (0 if not specified)"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              opt_arg "offset" (int @@ arg 1) ;
              curry_arg "sub" (abbrv "js_string" @@ arg 0) ]
            (call_method "lastIndexOf")
            (Option (Guard.(var "root" = Const.int (-1)), int)) ;

          def_function "match_regexp"
            ~doc:"Returns the array on matched groups when successful \
                  (index 0 contains the whole match)"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "pattern" (abbrv "js_regexp" @@ arg 0) ]
            (call_method "match")
            (nonempty_array_or_null (abbrv "js_string")) ;

          def_function "replace"
            ~doc:"Returns the matching position when successful"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg ~doc:"the substring to find and replace"
                "pattern" (abbrv "js_string" @@ arg 0)  ;
              curry_arg ~doc:"the replacement, in which \
                              [$&] is the matched substring, \
                              [$$] is a dollar sign, \
                              [$^] is the part of the original string before the match and \
                              [$'] the part after"
                "replacement" (abbrv "js_string" @@ arg 1) ]
            (call_method "replace")
            (abbrv "js_string") ;

          def_function "replace_regexp"
            ~doc:"Returns the matching position when successful"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg ~doc:"the pattern to find and replace"
                "pattern" (abbrv "js_regexp" @@ arg 0)  ;
              curry_arg ~doc:"the replacement, in which \
                              [$&] is the matched substring, \
                              [$$] is a dollar sign, \
                              [$^] is the part of the original string before the match, \
                              [$'] the part after and \
                              [$n] the [n]th matched group"
                "replacement" (abbrv "js_string" @@ arg 1) ]
            (call_method "replace")
            (abbrv "js_string") ;

          def_function "split"
            ~doc:"Splits a string using a separator"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "sep" (abbrv "js_string" @@ arg 0) ]
            (call_method "split")
            (array (abbrv "js_string")) ;

          def_function "split_regexp"
            ~doc:"Splits a string using a regexp separator"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "sep" (abbrv "js_regexp" @@ arg 0) ]
            (call_method "split")
            (array (abbrv "js_string")) ;

        ] ;

        let locale_compare ~doc name usage =
          def_function name
            ~doc:"Search for a substring and return the position \
                  of its last occurence starting at a given offset \
                  (0 if not specified)"
            [ curry_arg "left" (abbrv "js_string" @@ this) ;
              opt_arg
                ~doc:"A list of BCP-47 language tags"
                "locales" (list string @@ rest ()) ;
              opt_arg "matcher" (abbrv "locale_matcher" @@ field (var "options") "usage") ;
              opt_arg "sensitivity" (abbrv "locale_compare_sensitivity" @@ field (var "options") "sensitivity") ;
              opt_arg "ignore_punctuation" (bool @@ field (var "options") "ignorePunctuation") ;
              opt_arg "detect_numbers" (bool @@ field (var "options") "numeric") ;
              opt_arg "case_order" (abbrv "locale_compare_case_order" @@ field (var "options") "caseFirst") ;
              curry_arg "right" (abbrv "js_string" @@ arg 0) ]
            (abs "_"
               (set_const (field (var "options") "usage") Const.(string usage))
               (abs "_"
                  (set (rest ()) (var "options"))
                  (call_method "localeCompare")))
            int
        in
        section "Comparison" [

          def_type "locale_matcher"
            (public (simple_string_enum [ "lookup" ; "best fit" ])) ;

          def_type "locale_compare_sensitivity"
            (public (simple_string_enum [ "base" ; "accent" ; "case" ; "variant" ])) ;

          def_type "locale_compare_case_order"
            (public (string_enum [ "Uppercase_first", "upper" ; "Lowercase_first", "lower" ; "Locale_default", "false" ])) ;

          locale_compare
            ~doc:"Compare two JavScript strings using the specified locale, \
                  considering similar strings as equivalent" 
            "locale_compare_for_searching" "search" ;

          locale_compare
            ~doc:"Compare two JavScript strings using the specified locale, \
                  ordering similar strings" 
            "locale_compare_for_sorting" "sort" ;
        ]
      ] ;
      structure "js_obj"
        ~doc:"Not for the casual user" [
        section "Generic operations" [
          def_function "js_value"
            ~doc:"Use any value as its generic JavaScript representation"
            [ curry_arg "v" (param "'a" @@ var "tmp") ]
            (get (var "tmp"))
            (abbrv "js_value") ;
          def_function "coerce"
            ~doc:"Use any JavaScript value with any OCaml type (UNSAFE)"
            [ curry_arg "v" (abbrv "js_value" @@ var "tmp") ]
            (get (var "tmp"))
            (param "'a") ;
          def_function "eval"
            ~doc:"Eval a piece of JavaScript code and obtain its result"
            [ curry_arg "code" (string @@ arg 0) ]
            (call (jsglobal "eval"))
            (abbrv "js_value") ;
          def_value "undefined"
            ~doc:"This one is not very well defined"
            (get (jsglobal "undefined"))
            (abbrv "js_value") ;
          def_function "is"
            ~doc:"Physical equality on objects, strict equality on primitive values ([is undefined undefined], but not [is undefined null])"
            [ curry_arg "obj_l" (abbrv "js_value" @@ arg 0) ;
              curry_arg "obj_r" (abbrv "js_value" @@ arg 1) ]
            (call (jsglobal "Object.is"))
            bool ;
        ] ;
        section "Operations on objects" [
          def_function "coerce_object"
            ~doc:"Use a JavaScript value as a JavaScript object (may raise Invalid_argument)"
            [ curry_arg "v" (abbrv "js_value" @@ var "tmp") ]
            (var_instanceof "tmp" "Object")
            (abbrv "js_object") ;
          def_value "root"
            ~doc:"The fathermother of all objects who goes by the name [Object]"
            (get (jsglobal "Object"))
            (abbrv "js_object") ;
          def_value "null"
            ~doc:"At last, we have it !"
            (get (jsglobal "null"))
            (abbrv "js_object") ;
          def_type "property_descriptor"
            (public (record [
                 row "configurable" (bool @@ field root "configurable") ;
                 row "enumerable" (bool @@ field root "enumerable") ;
                 row "writable" (bool @@ field root "writable") ;
                 row "getter" (option_undefined (callback [] (abbrv "js_value")) @@ field root "get") ;
                 row "setter" (option_undefined (callback [ curry_arg "new_value" (abbrv "js_value" @@ arg 0) ] void) @@ field root "set") ;
                 row "value" (option_undefined (abbrv "js_value") @@ field root "value") ;
               ])) ;
          def_function "create"
            ~doc:"Build a new object given its prototype and an object to duplicates properties from"
            [ opt_arg "prototype" (abbrv "js_object" @@ arg 0) ;
              opt_arg "properties" (assoc (abbrv "property_descriptor") @@ rest ()) ]
            (call (jsglobal "Object.create"))
            (abbrv "js_object") ;
          def_function "define_property"
            ~doc:"Define a property from a name and its descriptor fields"
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ;
              curry_arg "prop" (string @@ arg 1) ;
              opt_arg "configurable" (bool @@ field (arg 2) "configurable") ;
              opt_arg "enumerable" (bool @@ field (arg 2) "enumerable") ;
              opt_arg "writable" (bool @@ field (arg 2) "writable") ;
              opt_arg "getter" (callback [] (abbrv "js_value") @@ field (arg 2) "get") ;
              opt_arg "setter" (callback [ curry_arg "new_value" (abbrv "js_value" @@ arg 0) ] void @@ field (arg 2) "set") ;              
              curry_arg "value" (abbrv "js_value" @@ field (arg 2) "value") ]
            (call (jsglobal "Object.defineProperty"))
            void ;
          def_function "define_property_from_descriptor"
            ~doc:"Define a property from a name and a specific descriptor"
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ;
              curry_arg "prop" (string @@ arg 1) ;
              curry_arg "descriptor" (abbrv "property_descriptor" @@ arg 2) ]
            (call (jsglobal "Object.defineProperty"))
            void ;
          def_function "define_properties_from_descriptors"
            ~doc:"Define properties from their names and specific descriptors"
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ;
              opt_arg "properties" (assoc (abbrv "property_descriptor") @@ rest ()) ]
            (call (jsglobal "Object.defineProperty"))
            void ;
          def_function "get_own_property_descriptor"
            ~doc:"Get the descriptor of a property defined by this object (and not one of its prototypes)"
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ;
              curry_arg "prop" (string @@ arg 1) ]
            (call (jsglobal "Object.getOwnPropertyDescriptor"))
            (option_undefined (abbrv "property_descriptor")) ;
          def_function "get_own_property_names"
            ~doc:"Get the names of all the properties that are defined by this object (and not one of its prototypes)"
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ]
            (call (jsglobal "Object.getOwnPropertyNames"))
            (list string) ;
          def_function "keys"
            ~doc:"Get the names of all the properties that are defined by this object (and not inherited) and enumerable"
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ]
            (call (jsglobal "Object.keys"))
            (list string) ;
          def_function "get_prototype"
            ~doc:"Get the prototype of an object"
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ]
            (call (jsglobal "Object.getPrototypeOf"))
            (abbrv "js_object") ;
          def_function "set_prototype"
            ~doc:"Set the prototype of an object (N.B. it's a bad idea and it's slow)"
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ;
              curry_arg "proto" (abbrv "js_object" @@ arg 1)]
            (call (jsglobal "Object.setPrototypeOf"))
            void ;
          def_function "prevent_extensions"
            ~doc:"Makes an object non extensible"
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ]
            (call (jsglobal "Object.preventExtensioms"))
            void ;
          def_function "seal"
            ~doc:"Makes an object non extensible, and its properties non configurable"
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ]
            (call (jsglobal "Object.seal"))
            void ;
          def_function "freeze"
            ~doc:"Makes an object non extensible, and its properties non configurable and immutable"
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ]
            (call (jsglobal "Object.freeze"))
            void ;
          def_function "is_extensible"
            ~doc:"Tell if an object is extensible (see {!prevent_extensions})"
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ]
            (call (jsglobal "Object.isExtensible"))
            bool ;
          def_function "is_sealed"
            ~doc:"Tell if an object is frozen (see {!seal})"
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ]
            (call (jsglobal "Object.isSealed"))
            bool ;
          def_function "is_frozen"
            ~doc:"Tell if an object is frozen (see {!freeze})"
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ]
            (call (jsglobal "Object.isFrozen"))
            bool ;
        ]
      ] ;
      structure "js_date"
        ~doc:"Operations on JavaScript date objects" [
        
        section "Construction" [
          def_function "now"
            ~doc:"Create a date object with the current time"
            []
            (call_constructor (jsglobal "Date"))
            (abbrv "js_date") ;
          
          def_function "create"
            ~doc:"Create a Date from components"
            [ labeled_arg "ymd" ~doc:"(year, month, day)"
                (tuple [ int @@ arg 0 ; int @@ arg 1 ; int @@ arg 2 ]) ;
              opt_arg "hmss" ~doc:"(hour, minute, second, millisecond)"
                (tuple [ int @@ arg 3 ; int @@ arg 4 ; int @@ arg 5 ; int @@ arg 6 ]) ]
            (call_constructor (jsglobal "Date"))
            (abbrv "js_date") ;

        ] ;

        section "Conversions" [

          def_function "from_time_value"
            ~doc:"Create a Date from the number of milliseconds since 1 January 1970 00:00:00 UTC"
            [ curry_arg "stamp" (float @@ arg 0) ]
            (call_constructor (jsglobal "Date"))
            (abbrv "js_date") ;

          def_function "to_time_value"
            ~doc:"Extract the number of milliseconds since 1 January 1970 00:00:00 UTC"
            [ curry_arg "date" (abbrv "js_date" @@ this) ]
            (call_method "getTime")
            float ;

          def_function "from_string"
            ~doc:"Create a Date from an RFC 2822 of ISO 8601 timestamp"
            [ curry_arg "stamp" (string @@ arg 0) ]
            (call_constructor (jsglobal "Date"))
            (abbrv "js_date") ;

          def_function "to_string"
            ~doc:"Builds the ISO 8601 string version of the date"
            [ curry_arg "date" (abbrv "js_date" @@ this) ]
            (call_method "toISOString")
            string ;

          def_function "to_human_string"
            ~doc:"Builds a human string version of the date"
            [ opt_arg "use_locale" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
                (call_method "toLocaleString")
                (call_method "toString"))
            string ;

          def_function "to_date_string"
            ~doc:"Builds a human readable string version of the date part (y,m,d)"
            [ opt_arg "use_locale" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
                (call_method "toLocaleDateString")
                (call_method "toDateString"))
            string ;

          def_function "to_time_string"
            ~doc:"Builds a human readable string version of the date part (h,m,s,ms)"
            [ opt_arg "use_locale" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
                (call_method "toLocaleTimeString")
                (call_method "toTimeString"))
            string ;

        ] ;

        section "Access" [

          def_function "time_zone_offset"
            ~doc:"Extract the time zone offset in minutes for the current locale"
            [ curry_arg "date" (abbrv "js_date" @@ this) ]
            (call_method "getTimezoneOffset")
            int ;
          
          def_function "year"
            ~doc:"Extract the full year from a Date object"
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "getUTCFullYear")
               (call_method "getFullYear"))
            int ;

          def_function "month"
            ~doc:"Extract the month (0-11) from a Date object"
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "getUTCMonth")
               (call_method "getMonth"))
            int ;

          def_function "day"
            ~doc:"Extract the day of the month (1-31) from a Date object"
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "getUTCDate")
               (call_method "getDate"))
            int ;

          def_function "day_of_the_week"
            ~doc:"Extract the day of the week (0-6) from a Date object"
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "getUTCDay")
               (call_method "getDay"))
            int ;

          def_function "hour"
            ~doc:"Extract the hour (0-23) from a Date object"
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "getUTCHours")
               (call_method "getHours"))
            int ;

          def_function "minute"
            ~doc:"Extract the minute (0-59) from a Date object"
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "getUTCMinutes")
               (call_method "getMinutes"))
            int ;

          def_function "second"
            ~doc:"Extract the second (0-59) from a Date object"
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "getUTCSeconds")
               (call_method "getSeconds"))
            int ;

          def_function "millisecond"
            ~doc:"Extract the millisecond (0-999) from a Date object"
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "getUTCMilliseconds")
               (call_method "getMilliseconds"))
            int ;

        ] ;
        
        section "Modification" [
          
          def_function "set_year"
            ~doc:"Set the full year of a Date object"
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ;
              curry_arg "v" (int @@ arg 1) ]
            (test Guard.(var "flag" = bool true)
               (call_method "setUTCFullYear")
               (call_method "setFullYear"))
            void ;

          def_function "set_month"
            ~doc:"Set the month (0-11) of a Date object"
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ;
              curry_arg "v" (int @@ arg 1) ]
            (test Guard.(var "flag" = bool true)
               (call_method "setUTCMonth")
               (call_method "setMonth"))
            void ;

          def_function "set_day"
            ~doc:"Set the day of the month (1-31) of a Date object"
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ;
              curry_arg "v" (int @@ arg 1) ]
            (test Guard.(var "flag" = bool true)
               (call_method "setUTCDate")
               (call_method "setDate"))
            void ;

          def_function "set_hour"
            ~doc:"Set the hour (0-23) of a Date object"
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ;
              curry_arg "v" (int @@ arg 1) ]
            (test Guard.(var "flag" = bool true)
               (call_method "setUTCHours")
               (call_method "setHours"))
            void ;

          def_function "set_minute"
            ~doc:"Set the minute (0-59) of a Date object"
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ;
              curry_arg "v" (int @@ arg 1) ]
            (test Guard.(var "flag" = bool true)
               (call_method "setUTCMinutes")
               (call_method "setMinutes"))
            void ;

          def_function "set_second"
            ~doc:"Set the second (0-59) of a Date object"
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ;
              curry_arg "v" (int @@ arg 1) ]
            (test Guard.(var "flag" = bool true)
               (call_method "setUTCSeconds")
               (call_method "setSeconds"))
            void ;

          def_function "set_millisecond"
            ~doc:"Set the millisecond (0-999) of a Date object"
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ;
              curry_arg "v" (int @@ arg 1) ]
            (test Guard.(var "flag" = bool true)
               (call_method "setUTCMilliseconds")
               (call_method "setMilliseconds"))
            void ;

          ];
      ]
    ]

let document_component =
  register_component
    ~license:Goji_license.lgpl_v3
    ~doc:"DOM (Document Object Model) types and functions"
    browser_package "Document"
    [ def_type
        ~doc:"The type of generic Dom nodes"
        "node" (abstract any) ;
      def_function "body"
        ~doc:"Retrives the body of the main document"
        []
        (get (jsglobal "document.body"))
        (abbrv "node") ;
      def_function "get_element_by_id"
        ~doc:"Retrieve a DOM node from its ID in the main document"
        [ curry_arg "n" (abbrv "node" @@ arg 0) ]
        (call (jsglobal "document.getElementById"))
        (option_null (abbrv "node")) ;
      def_function "get_elements_by_name"
        ~doc:"Retrieve the list of nodes with a given tag"
        [ curry_arg "n" (abbrv "node" @@ arg 0) ]
        (call (jsglobal "document.getElementsByTagName"))
        (list (abbrv "node")) ;
      def_function "get_elements_by_name"
        ~doc:"Retrieve the list of nodes with a given name attribute"
        [ curry_arg "n" (abbrv "node" @@ arg 0) ]
        (call (jsglobal "document.getElementsByName"))
        (list (abbrv "node")) ;
      def_function "get_elements_by_class"
        ~doc:"Retrieve the list of nodes with a given CSS class attribute"
        [ curry_arg "n" (abbrv "node" @@ arg 0) ]
        (call (jsglobal "document.getElementsByClassName"))
        (list (abbrv "node")) ;
      map_method "node" "appendChild" ~rename:"append"
        ~doc:"Adds a new child to a node after its existing ones"
        [ curry_arg "child" (abbrv "node" @@ arg 0) ]
        void ;
      def_function "create"
        ~doc:"Build a new node from its tag (in the main document)"
        [ curry_arg "tag" (string @@ arg 0) ]
        (call_method ~sto:(jsglobal "document") "createElement")
        (abbrv "node")
    ]
