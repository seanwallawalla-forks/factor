! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: strings USING: generic kernel kernel-internals lists math ;

BUILTIN: string 12 [ 1 "str-length" f ] [ 2 hashcode f ] ;
M: string = str= ;

BUILTIN: sbuf 13 ;
M: sbuf = sbuf= ;

UNION: text string integer ;

: f-or-"" ( obj -- ? )
    dup not swap "" = or ;

: str-length< ( str str -- boolean )
    #! Compare string lengths.
    swap str-length swap str-length < ;

: cat ( [ "a" "b" "c" ] -- "abc" )
    ! If f appears in the list, it is not appended to the
    ! string.
    80 <sbuf> swap [ [ over sbuf-append ] when* ] each sbuf>str ;

: cat2 ( "a" "b" -- "ab" )
    swap
    80 <sbuf>
    dup >r sbuf-append r>
    dup >r sbuf-append r>
    sbuf>str ;

: cat3 ( "a" "b" "c" -- "abc" )
    [ ] cons cons cons cat ;

: index-of ( string substring -- index )
    0 -rot index-of* ;

: str-lexi> ( str1 str2 -- ? )
    ! Returns if the first string lexicographically follows str2
    str-compare 0 > ;

: str-head ( index str -- str )
    #! Returns a new string, from the beginning of the string
    #! until the given index.
    0 -rot substring ;

: str-contains? ( substr str -- ? )
    swap index-of -1 = not ;

: str-tail ( index str -- str )
    #! Returns a new string, from the given index until the end
    #! of the string.
    [ str-length ] keep substring ;

: str/ ( str index -- str str )
    #! Returns 2 strings, that when concatenated yield the
    #! original string.
    [ swap str-head ] 2keep swap str-tail ;

: str// ( str index -- str str )
    #! Returns 2 strings, that when concatenated yield the
    #! original string, without the character at the given
    #! index.
    [ swap str-head ] 2keep 1 + swap str-tail ;

: str-head? ( str begin -- ? )
    2dup str-length< [
        2drop f
    ] [
        dup str-length rot str-head =
    ] ifte ;

: ?str-head ( str begin -- str ? )
    2dup str-head? [
        str-length swap str-tail t
    ] [
        drop f
    ] ifte ;

: str-tail? ( str end -- ? )
    2dup str-length< [
        2drop f
    ] [
        dup str-length pick str-length swap - rot str-tail =
    ] ifte ;

: ?str-tail ( str end -- ? )
    2dup str-tail? [
        str-length swap [ str-length swap - ] keep str-head t
    ] [
        drop f
    ] ifte ;

: split1 ( string split -- before after )
    2dup index-of dup -1 = [
        2drop f
    ] [
        [ swap str-length + over str-tail ] keep
        rot str-head swap
    ] ifte ;

: (str>list) ( i str -- list )
    2dup str-length >= [
        2drop [ ]
    ] [
        2dup str-nth >r >r 1 + r> (str>list) r> swons
    ] ifte ;

: str>list ( str -- list )
    0 swap (str>list) ;

: str-each ( str quot -- )
    #! Execute the quotation with each character of the string
    #! pushed onto the stack.
    >r str>list r> each ; inline

PREDICATE: integer blank     " \t\n\r" str-contains? ;
PREDICATE: integer letter    CHAR: a CHAR: z between? ;
PREDICATE: integer LETTER    CHAR: A CHAR: Z between? ;
PREDICATE: integer digit     CHAR: 0 CHAR: 9 between? ;
PREDICATE: integer printable CHAR: \s CHAR: ~ between? ;

: quotable? ( ch -- ? )
    #! In a string literal, can this character be used without
    #! escaping?
    dup printable? swap "\"\\" str-contains? not and ;

: url-quotable? ( ch -- ? )
    #! In a URL, can this character be used without
    #! URL-encoding?
    dup letter?
    over LETTER? or
    over digit? or
    swap "/_?." str-contains? or ;
