; Dictionary Headers for Tali Forth 2
; Scot W. Stevenson <scot.stevenson@gmail.com>
; First version: 05. Dec 2016 (Liara Forth)
; This version: 26. Aug 2018

; Dictionary headers are kept separately from the code, which allows various
; tricks in the code. We roughly follow the Gforth terminology: The Execution
; Token (xt) is the address of the first byte of a word's code that can be,
; uh, executed; the Name Token (nt) is a pointer to the beginning of the
; word's header in the Dictionary. There, the link to the next word in the
; Dictionary is always one cell down from the current word's own nt. In the 
; code ; itself, we use "nt_<WORD>" for the nt and "xt_<WORD>" for the xt. 
;
; This gives us the following header structure:
;
;              8 bit     8 bit
;               LSB       MSB
; nt_word ->  +--------+--------+
;          +0 | Length | Status |
;             +--------+--------+
;          +2 | Next Header     | -> nt_next_word
;             +-----------------+
;          +4 | Start of Code   | -> xt_word 
;             +-----------------+
;          +6 | End of Code     | -> z_word
;             +--------+--------+
;          +8 | Name   |        |
;             +--------+--------+
;             |        |        |
;             +--------+--------+
;             |        |  ...   | (name string does not end with a zero)
;          +n +--------+--------+
;
; The Status Byte is created by adding the flags defined in
; definitions.asm, which are:
;
;       CO - Compile Only
;       IM - Immediate Word
;       NN - Never Native Compile (must always be called by JSR)
;       AN - Always Native Compile (may not be called by JSR)
;       UF - Contains underflow check
;       HC - Has CFA (words created by CREATE and DOES> only)

; Note there are currently two bits unused.

; By default, all existing words can be natively compiled (compiled inline)
; or as a subroutine jump target; the system decides which variant to use
; based on a threshold the user can set.  By default, all user-created words
; are flagged never-native.  The user can override this by using the
; always-native word just after defining their new word.
; The NN flag forbids native compiling, the AN flag forces it.  

; The last word (top word in code) is always BYE. It is marked as the last word
; by its value of 0000 in its Next Header field. The words are sorted with the
; more common ones first (further down in code) so they are found earlier.
; Anything to do with output comes later (further up) because things will
; always be slow if there is a human involved.

; (The initial skeleton of this list was automatically generated by a script
; in the tools folder and then sorted by hand.)

nt_bye:
        .byte 3         ; length of word strings
        .byte 0         ; status byte
        .word 0000      ; next word in Dictionary, 0000 signals end
        .word xt_bye    ; start of code block (xt of this word)
        .word z_bye     ; end of code (RTS)
        .byte "bye"     ; word name, always lower case

nt_cold:
        .byte 4, 0
        .word nt_bye, xt_cold, z_cold
        .byte "cold"

nt_word:
        .byte 4, UF
        .word nt_cold, xt_word, z_word
        .byte "word"

nt_find:
        .byte 4, UF
        .word nt_word, xt_find, z_find
        .byte "find"

nt_environment_q:
        .byte 12, UF 
        .word nt_find, xt_environment_q, z_environment_q
        .byte "environment?"

nt_search:  
        .byte 6, UF+NN
        .word nt_environment_q, xt_search, z_search
        .byte "search"

nt_compare:
        .byte 7, UF
        .word nt_search, xt_compare, z_compare
        .byte "compare"

nt_disasm:
        .byte 6, UF
        .word nt_compare, xt_disasm, z_disasm
        .byte "disasm"

nt_dot_s:
        .byte 2, 0
        .word nt_disasm, xt_dot_s, z_dot_s
        .byte ".s"

nt_dump:
        .byte 4, UF
        .word nt_dot_s, xt_dump, z_dump
        .byte "dump"

nt_bell:
        .byte 4, 0
        .word nt_dump, xt_bell, z_bell
        .byte "bell"

nt_align:
        .byte 5, 0
        .word nt_bell, xt_align, z_align
        .byte "align"

nt_aligned:             ; same code as ALIGN
        .byte 7, 0
        .word nt_align, xt_align, z_align
        .byte "aligned"

nt_wordsize:
        .byte 8, UF
        .word nt_aligned, xt_wordsize, z_wordsize
        .byte "wordsize"

nt_words:
        .byte 5, 0
        .word nt_wordsize, xt_words, z_words
        .byte "words"

nt_marker:
        .byte 6, IM
        .word nt_words, xt_marker, z_marker
        .byte "marker"

nt_at_xy:
        .byte 5, UF
        .word nt_marker, xt_at_xy, z_at_xy
        .byte "at-xy"

nt_page:
        .byte 4, 0
        .word nt_at_xy, xt_page, z_page
        .byte "page"

nt_cr:
        .byte 2, 0
        .word nt_page, xt_cr, z_cr
        .byte "cr"

nt_input:
        .byte 5, 0
        .word nt_cr, xt_input, z_input
        .byte "input"

nt_output:
        .byte 6, 0
        .word nt_input, xt_output, z_output
        .byte "output"

nt_sign:
        .byte 4, UF
        .word nt_output, xt_sign, z_sign
        .byte "sign"

nt_hold:
        .byte 4, UF
        .word nt_sign, xt_hold, z_hold
        .byte "hold"

nt_number_sign_greater:
        .byte 2, UF
        .word nt_hold, xt_number_sign_greater, z_number_sign_greater
        .byte "#>"

nt_number_sign_s:
        .byte 2, UF
        .word nt_number_sign_greater, xt_number_sign_s, z_number_sign_s
        .byte "#s"

nt_number_sign:
        .byte 1, UF
        .word nt_number_sign_s, xt_number_sign, z_number_sign
        .byte "#"

nt_less_number_sign:
        .byte 2, 0
        .word nt_number_sign, xt_less_number_sign, z_less_number_sign
        .byte "<#"

nt_to_in:
        .byte 3, 0
        .word nt_less_number_sign, xt_to_in, z_to_in
        .byte ">in"

nt_within:
        .byte 6, UF
        .word nt_to_in, xt_within, z_within
        .byte "within"

nt_pad:
        .byte 3, 0
        .word nt_within, xt_pad, z_pad
        .byte "pad"

nt_cmove:
        .byte 5, UF
        .word nt_pad, xt_cmove, z_cmove
        .byte "cmove"

nt_cmove_up:
        .byte 6, UF
        .word nt_cmove, xt_cmove_up, z_cmove_up
        .byte "cmove>"

nt_move:
        .byte 4, NN+UF
        .word nt_cmove_up, xt_move, z_move
        .byte "move"

nt_backslash:
        .byte 1, IM
        .word nt_move, xt_backslash, z_backslash
        .byte $5c

nt_star_slash:
        .byte 2, UF
        .word nt_backslash, xt_star_slash, z_star_slash
        .byte "*/"

nt_star_slash_mod:
        .byte 5, UF
        .word nt_star_slash, xt_star_slash_mod, z_star_slash_mod
        .byte "*/mod"

nt_mod:
        .byte 3, UF
        .word nt_star_slash_mod, xt_mod, z_mod
        .byte "mod"

nt_slash_mod:
        .byte 4, UF
        .word nt_mod, xt_slash_mod, z_slash_mod
        .byte "/mod"

nt_slash:
        .byte 1, UF
        .word nt_slash_mod, xt_slash, z_slash
        .byte "/"

nt_fm_slash_mod:
        .byte 6, UF
        .word nt_slash, xt_fm_slash_mod, z_fm_slash_mod
        .byte "fm/mod"

nt_sm_slash_rem:
        .byte 6, UF
        .word nt_fm_slash_mod, xt_sm_slash_rem, z_sm_slash_rem
        .byte "sm/rem"

nt_um_slash_mod:
        .byte 6, UF
        .word nt_sm_slash_rem, xt_um_slash_mod, z_um_slash_mod
        .byte "um/mod"

nt_star:
        .byte 1, UF
        .word nt_um_slash_mod, xt_star, z_star
        .byte "*"

nt_um_star:
        .byte 3, UF
        .word nt_star, xt_um_star, z_um_star
        .byte "um*"

nt_m_star:
        .byte 2, UF
        .word nt_um_star, xt_m_star, z_m_star
        .byte "m*"

nt_count:
        .byte 5, UF
        .word nt_m_star, xt_count, z_count
        .byte "count"

nt_decimal:
        .byte 7, 0
        .word nt_count, xt_decimal, z_decimal
        .byte "decimal"

nt_hex:
        .byte 3, 0
        .word nt_decimal, xt_hex, z_hex
        .byte "hex"

nt_to_number:
        .byte 7, UF
        .word nt_hex, xt_to_number, z_to_number
        .byte ">number"

nt_number:
        .byte 6, UF
        .word nt_to_number, xt_number, z_number
        .byte "number"

nt_digit_question:
        .byte 6, UF
        .word nt_number, xt_digit_question, z_digit_question
        .byte "digit?"

nt_base:
        .byte 4, 0
        .word nt_digit_question, xt_base, z_base
        .byte "base"

nt_evaluate:
        .byte 8, UF
        .word nt_base, xt_evaluate, z_evaluate
        .byte "evaluate"

nt_state:
        .byte 5, 0
        .word nt_evaluate, xt_state, z_state
        .byte "state"

nt_again:
        .byte 5, AN+CO+IM+UF
        .word nt_state, xt_again, z_again
        .byte "again"

nt_begin:
        .byte 5, AN+CO+IM
        .word nt_again, xt_begin, z_begin
        .byte "begin"

nt_quit:
        .byte 4, 0
        .word nt_begin, xt_quit, z_quit
        .byte "quit"

nt_recurse:
        .byte 7, CO+IM+NN
        .word nt_quit, xt_recurse, z_recurse
        .byte "recurse"

nt_leave:
        .byte 5, AN+CO
        .word nt_recurse, xt_leave, z_leave
        .byte "leave"

nt_unloop:
        .byte 6, AN+CO
        .word nt_leave, xt_unloop, z_unloop
        .byte "unloop"

nt_exit:
        .byte 4, AN+CO
        .word nt_unloop, xt_exit, z_exit
        .byte "exit"

nt_plus_loop:
        .byte 5, CO+IM
        .word nt_exit, xt_plus_loop, z_plus_loop
        .byte "+loop"

nt_loop:
        .byte 4, CO+IM
        .word nt_plus_loop, xt_loop, z_loop
        .byte "loop"

nt_j:
        .byte 1, AN+CO
        .word nt_loop, xt_j, z_j
        .byte "j"

nt_i:
        .byte 1, AN+CO
        .word nt_j, xt_i, z_i
        .byte "i"

nt_question_do:
        .byte 3, CO+IM+NN
        .word nt_i, xt_question_do, z_question_do
        .byte "?do"

nt_do:
        .byte 2, CO+IM+NN
        .word nt_question_do, xt_do, z_do
        .byte "do"

nt_abort_quote:
        .byte 6, CO+IM+NN
        .word nt_do, xt_abort_quote, z_abort_quote
        .byte "abort", $22

nt_abort:
        .byte 5, 0
        .word nt_abort_quote, xt_abort, z_abort
        .byte "abort"

nt_uf_strip:
        .byte 8, 0
        .word nt_abort, xt_uf_strip, z_uf_strip
        .byte "uf-strip"

nt_nc_limit:
        .byte 8, 0
        .word nt_uf_strip, xt_nc_limit, z_nc_limit
        .byte "nc-limit"

nt_always_native:
        .byte 13, 0
        .word nt_nc_limit, xt_always_native, z_always_native
        .byte "always-native"

nt_never_native:
        .byte 12, 0
        .word nt_always_native, xt_never_native, z_never_native
        .byte "never-native"

nt_compile_only:
        .byte 12, 0
        .word nt_never_native, xt_compile_only, z_compile_only
        .byte "compile-only"

nt_immediate:
        .byte 9, 0
        .word nt_compile_only, xt_immediate, z_immediate
        .byte "immediate"

nt_postpone:
        .byte 8, IM+CO
        .word nt_immediate, xt_postpone, z_postpone
        .byte "postpone"

nt_s_quote:
        .byte 2, IM
        .word nt_postpone, xt_s_quote, z_s_quote
        .byte "s", $22

nt_dot_quote:
        .byte 2, CO+IM
        .word nt_s_quote, xt_dot_quote, z_dot_quote
        .byte ".", $22

nt_sliteral:
        .byte 8, CO+IM+UF
        .word nt_dot_quote, xt_sliteral, z_sliteral
        .byte "sliteral"

nt_literal:
        .byte 7, IM+CO+UF
        .word nt_sliteral, xt_literal, z_literal
        .byte "literal"

nt_branch:
        .byte 6, CO+IM+NN
        .word nt_literal, xt_branch, z_branch
        .byte "branch"

nt_zero_branch:                 ; do not check for underflow
        .byte 7, CO+IM+NN
        .word nt_branch, xt_zero_branch, z_zero_branch
        .byte "0branch"

nt_right_bracket:
        .byte 1, IM
        .word nt_zero_branch, xt_right_bracket, z_right_bracket
        .byte "]"

nt_left_bracket:
        .byte 1, IM+CO
        .word nt_right_bracket, xt_left_bracket, z_left_bracket
        .byte "["

nt_compile_comma:
        .byte 8, UF+NN
        .word nt_left_bracket, xt_compile_comma, z_compile_comma
        .byte "compile,"

nt_colon_noname:
        .byte 7, 0
        .word nt_compile_comma, xt_colon_noname, z_colon_noname
        .byte ":noname"

nt_semicolon:
        .byte 1, CO+IM
        .word nt_colon_noname, xt_semicolon, z_semicolon
        .byte ";"

nt_colon:
        .byte 1, 0
        .word nt_semicolon, xt_colon, z_colon
        .byte ":"

nt_source_id:
        .byte 9, 0
        .word nt_colon, xt_source_id, z_source_id
        .byte "source-id"

nt_source:
        .byte 6, 0
        .word nt_source_id, xt_source, z_source
        .byte "source"

nt_parse:
        .byte 5, UF
        .word nt_source, xt_parse, z_parse
        .byte "parse"

nt_parse_name:
        .byte 10, NN
        .word nt_parse, xt_parse_name, z_parse_name
        .byte "parse-name"

nt_latestnt:
        .byte 8, 0
        .word nt_parse_name, xt_latestnt, z_latestnt
        .byte "latestnt"

nt_latestxt:
        .byte 8, 0
        .word nt_latestnt, xt_latestxt, z_latestxt
        .byte "latestxt"

nt_defer:
        .byte 5, 0
        .word nt_latestxt, xt_defer, z_defer
        .byte "defer"

nt_to_body:
        .byte 5, UF
        .word nt_defer, xt_to_body, z_to_body
        .byte ">body"

nt_name_to_string:
        .byte 11, UF
        .word nt_to_body, xt_name_to_string, z_name_to_string
        .byte "name>string"

nt_int_to_name:
        .byte 8, UF
        .word nt_name_to_string, xt_int_to_name, z_int_to_name
        .byte "int>name"

nt_name_to_int:
        .byte 8, UF
        .word nt_int_to_name, xt_name_to_int, z_name_to_int
        .byte "name>int"

nt_bracket_tick:
        .byte 3, CO+IM
        .word nt_name_to_int, xt_bracket_tick, z_bracket_tick
        .byte "[']"

nt_tick:
        .byte 1, 0
        .word nt_bracket_tick, xt_tick, z_tick
        .byte "'"

nt_find_name:
        .byte 9, UF
        .word nt_tick, xt_find_name, z_find_name
        .byte "find-name"

nt_fill:
        .byte 4, UF
        .word nt_find_name, xt_fill, z_fill
        .byte "fill"

nt_blank:
        .byte 5, 0     ; underflow checked by FILL
        .word nt_fill, xt_blank, z_blank
        .byte "blank"

nt_erase:
        .byte 5, 0      ; underflow checked by FILL
        .word nt_blank, xt_erase, z_erase
        .byte "erase"

nt_d_plus:
        .byte 2, UF
        .word nt_erase, xt_d_plus, z_d_plus
        .byte "d+"

nt_d_minus:
        .byte 2, UF
        .word nt_d_plus, xt_d_minus, z_d_minus
        .byte "d-"

nt_d_to_s:
        .byte 3, UF
        .word nt_d_minus, xt_d_to_s, z_d_to_s
        .byte "d>s"

nt_s_to_d:
        .byte 3, UF
        .word nt_d_to_s, xt_s_to_d, z_s_to_d
        .byte "s>d"

nt_to:
        .byte 2, NN+IM
        .word nt_s_to_d, xt_to, z_to
        .byte "to"

nt_value:               ; same code as CONSTANT
        .byte 5, UF
        .word nt_to, xt_constant, z_constant
        .byte "value"

nt_constant:
        .byte 8, UF
        .word nt_value, xt_constant, z_constant
        .byte "constant"

nt_variable:
        .byte 8, 0
        .word nt_constant, xt_variable, z_variable
        .byte "variable"

nt_does:
        .byte 5, CO+IM
        .word nt_variable, xt_does, z_does
        .byte "does>"

nt_create:
        .byte 6, 0
        .word nt_does, xt_create, z_create
        .byte "create"

nt_allot:
        .byte 5, UF
        .word nt_create, xt_allot, z_allot
        .byte "allot"

nt_key:
        .byte 3, 0
        .word nt_allot, xt_key, z_key
        .byte "key"

nt_depth:
        .byte 5, 0
        .word nt_key, xt_depth, z_depth
        .byte "depth"

nt_unused:
        .byte 6, 0
        .word nt_depth, xt_unused, z_unused
        .byte "unused"

nt_accept:
        .byte 6, UF+NN
        .word nt_unused, xt_accept, z_accept
        .byte "accept"

nt_refill:
        .byte 6, 0
        .word nt_accept, xt_refill, z_refill
        .byte "refill"

nt_slash_string:
        .byte 7, UF
        .word nt_refill, xt_slash_string, z_slash_string
        .byte "/string"

nt_minus_trailing:
        .byte 9, UF
        .word nt_slash_string, xt_minus_trailing, z_minus_trailing
        .byte "-trailing"

nt_bl:
        .byte 2, 0
        .word nt_minus_trailing, xt_bl, z_bl
        .byte "bl"

nt_spaces:
        .byte 6, UF
        .word nt_bl, xt_spaces, z_spaces
        .byte "spaces"

nt_bounds:
        .byte 6, UF
        .word nt_spaces, xt_bounds, z_bounds
        .byte "bounds"

nt_c_comma:
        .byte 2, UF
        .word nt_bounds, xt_c_comma, z_c_comma
        .byte "c,"

nt_dnegate:
        .byte 7, UF
        .word nt_c_comma, xt_dnegate, z_dnegate
        .byte "dnegate"

nt_negate:
        .byte 6, UF
        .word nt_dnegate, xt_negate, z_negate
        .byte "negate"

nt_invert:
        .byte 6, UF
        .word nt_negate, xt_invert, z_invert
        .byte "invert"

nt_two_to_r:
        .byte 3, CO+UF          ; native is special case
        .word nt_invert, xt_two_to_r, z_two_to_r
        .byte "2>r"

nt_two_r_from:
        .byte 3, CO             ; native is special case
        .word nt_two_to_r, xt_two_r_from, z_two_r_from
        .byte "2r>"

nt_two_r_fetch:
        .byte 3, CO+NN          ; native is special case, leave NN for now
        .word nt_two_r_from, xt_two_r_fetch, z_two_r_fetch
        .byte "2r@"

nt_two_variable:
        .byte 9, 0
        .word nt_two_r_fetch, xt_two_variable, z_two_variable
        .byte "2variable"

nt_two_fetch:
        .byte 2, UF
        .word nt_two_variable, xt_two_fetch, z_two_fetch
        .byte "2@"

nt_two_store:
        .byte 2, UF
        .word nt_two_fetch, xt_two_store, z_two_store
        .byte "2!"

nt_two_over:
        .byte 5, UF
        .word nt_two_store, xt_two_over, z_two_over
        .byte "2over"

nt_two_swap:
        .byte 5, UF
        .word nt_two_over, xt_two_swap, z_two_swap
        .byte "2swap"

nt_two_drop:
        .byte 5, UF
        .word nt_two_swap, xt_two_drop, z_two_drop
        .byte "2drop"

nt_max:
        .byte 3, UF
        .word nt_two_drop, xt_max, z_max
        .byte "max"

nt_min:
        .byte 3, UF
        .word nt_max, xt_min, z_min
        .byte "min"

nt_zero_less:
        .byte 2, UF
        .word nt_min, xt_zero_less, z_zero_less
        .byte "0<"

nt_zero_greater:
        .byte 2, UF
        .word nt_zero_less, xt_zero_greater, z_zero_greater
        .byte "0>"

nt_zero_unequal:
        .byte 3, UF
        .word nt_zero_greater, xt_zero_unequal, z_zero_unequal
        .byte "0<>"

nt_zero_equal:
        .byte 2, UF
        .word nt_zero_unequal, xt_zero_equal, z_zero_equal
        .byte "0="

nt_greater_than:
        .byte 1, UF
        .word nt_zero_equal, xt_greater_than, z_greater_than
        .byte ">"

nt_u_greater_than:
        .byte 2, UF
        .word nt_greater_than, xt_u_greater_than, z_u_greater_than
        .byte "u>"

nt_u_less_than:
        .byte 2, UF
        .word nt_u_greater_than, xt_u_less_than, z_u_less_than
        .byte "u<"

nt_less_than:
        .byte 1, UF
        .word nt_u_less_than, xt_less_than, z_less_than
        .byte "<"

nt_not_equals:
        .byte 2, UF
        .word nt_less_than, xt_not_equals, z_not_equals
        .byte "<>"

nt_equal:
        .byte 1, UF
        .word nt_not_equals, xt_equal, z_equal
        .byte "="

nt_two_slash:
        .byte 2, UF
        .word nt_equal, xt_two_slash, z_two_slash
        .byte "2/"

nt_two_star:
        .byte 2, UF
        .word nt_two_slash, xt_two_star, z_two_star
        .byte "2*"

nt_one_plus:
        .byte 2, UF
        .word nt_two_star, xt_one_plus, z_one_plus
        .byte "1+"

nt_one_minus:
        .byte 2, UF
        .word nt_one_plus, xt_one_minus, z_one_minus
        .byte "1-"

nt_here:
        .byte 4, 0
        .word nt_one_minus, xt_here, z_here
        .byte "here"

nt_cell_plus:
        .byte 5, UF
        .word nt_here, xt_cell_plus, z_cell_plus
        .byte "cell+"

nt_cells:
        .byte 5, 0
        .word nt_cell_plus, xt_two_star, z_two_star  ; same as 2*
        .byte "cells"

nt_chars:
        .byte 5, AN+UF                          ; deleted during compile
        .word nt_cells, xt_chars, z_chars
        .byte "chars"

nt_char_plus:
        .byte 5, 0
        .word nt_chars, xt_one_plus, z_one_plus ; same as 1+
        .byte "char+"

nt_bracket_char:
        .byte 6, CO+IM
        .word nt_char_plus, xt_bracket_char, z_bracket_char
        .byte "[char]"

nt_char:
        .byte 4, 0
        .word nt_bracket_char, xt_char, z_char
        .byte "char"

nt_pick:
        .byte 4, 0              ; underflow check is complicated, leave off here
        .word nt_char, xt_pick, z_pick
        .byte "pick"

nt_lshift:
        .byte 6, UF
        .word nt_pick, xt_lshift, z_lshift
        .byte "lshift"

nt_rshift:
        .byte 6, UF
        .word nt_lshift, xt_rshift, z_rshift
        .byte "rshift"

nt_xor:
        .byte 3, UF
        .word nt_rshift, xt_xor, z_xor
        .byte "xor"

nt_or:
        .byte 2, UF
        .word nt_xor, xt_or, z_or
        .byte "or"

nt_and:
        .byte 3, UF
        .word nt_or, xt_and, z_and
        .byte "and"

nt_dabs:
        .byte 4, UF
        .word nt_and, xt_dabs, z_dabs
        .byte "dabs"

nt_abs:
        .byte 3, UF
        .word nt_dabs, xt_abs, z_abs
        .byte "abs"

nt_minus:
        .byte 1, UF
        .word nt_abs, xt_minus, z_minus
        .byte "-"

nt_plus:
        .byte 1, UF
        .word nt_minus, xt_plus, z_plus
        .byte "+"

nt_question_dup:
        .byte 4, UF
        .word nt_plus, xt_question_dup, z_question_dup
        .byte "?dup"

nt_two_dup:
        .byte 4, UF
        .word nt_question_dup, xt_two_dup, z_two_dup
        .byte "2dup"

nt_two:
        .byte 1, 0
        .word nt_two_dup, xt_two, z_two
        .byte "2"

nt_one:
        .byte 1, 0
        .word nt_two, xt_one, z_one
        .byte "1"

nt_zero:
        .byte 1, 0
        .word nt_one, xt_zero, z_zero
        .byte "0"

nt_space:
        .byte 5, 0
        .word nt_zero, xt_space, z_space
        .byte "space"

nt_true:
        .byte 4, 0
        .word nt_space, xt_true, z_true
        .byte "true"

nt_false:
        .byte 5, 0
        .word nt_true, xt_false, z_false
        .byte "false"

nt_question:
        .byte 1, 0
        .word nt_false, xt_question, z_question
        .byte "?"

nt_u_dot:
        .byte 2, UF
        .word nt_question, xt_u_dot, z_u_dot
        .byte "u."

nt_dot:
        .byte 1, UF
        .word nt_u_dot, xt_dot, z_dot
        .byte "."

nt_type:
        .byte 4, UF
        .word nt_dot, xt_type, z_type
        .byte "type"

nt_emit:
        .byte 4, NN+UF
        .word nt_type, xt_emit, z_emit
        .byte "emit"

nt_execute:
        .byte 7, UF
        .word nt_emit, xt_execute, z_execute
        .byte "execute"

nt_plus_store:
        .byte 2, UF
        .word nt_execute, xt_plus_store, z_plus_store
        .byte "+!"

nt_c_store:
        .byte 2, UF
        .word nt_plus_store, xt_c_store, z_c_store
        .byte "c!"

nt_c_fetch:
        .byte 2, UF
        .word nt_c_store, xt_c_fetch, z_c_fetch
        .byte "c@"

nt_comma:
        .byte 1, UF
        .word nt_c_fetch, xt_comma, z_comma
        .byte ","

nt_tuck:
        .byte 4, UF
        .word nt_comma, xt_tuck, z_tuck
        .byte "tuck"

nt_not_rote:
        .byte 4, UF
        .word nt_tuck, xt_not_rote, z_not_rote
        .byte "-rot"

nt_rot:
        .byte 3, UF
        .word nt_not_rote, xt_rot, z_rot
        .byte "rot"

nt_nip:
        .byte 3, UF
        .word nt_rot, xt_nip, z_nip
        .byte "nip"

nt_r_fetch:
        .byte 2, CO        ; native is special case
        .word nt_nip, xt_r_fetch, z_r_fetch
        .byte "r@"

nt_r_from:
        .byte 2, CO        ; native is special case
        .word nt_r_fetch, xt_r_from, z_r_from
        .byte "r>"

nt_to_r:
        .byte 2, CO+UF     ; native is special case
        .word nt_r_from, xt_to_r, z_to_r
        .byte ">r"

nt_over:
        .byte 4, UF
        .word nt_to_r, xt_over, z_over
        .byte "over"

nt_fetch:
        .byte 1, UF
        .word nt_over, xt_fetch, z_fetch
        .byte "@"

nt_store:
        .byte 1, UF
        .word nt_fetch, xt_store, z_store
        .byte "!"

nt_swap:
        .byte 4, UF
        .word nt_store, xt_swap, z_swap
        .byte "swap"

nt_dup:
        .byte 3, UF
        .word nt_swap, xt_dup, z_dup
        .byte "dup"

; DROP is always the first native word in the Dictionary
dictionary_start:
nt_drop:
        .byte 4, UF
        .word nt_dup, xt_drop, z_drop
        .byte "drop"

; END
