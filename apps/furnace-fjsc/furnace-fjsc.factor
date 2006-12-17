! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
IN: furnace:fjsc
USING: kernel html furnace xml io httpd sequences 
       namespaces file-responder parser-combinators lazy-lists
       fjsc  ;

: script ( path -- )
  #! given a path to a javascript file, output the 
  #! script tag that references it.
  <script "text/javascript" =type =src script> </script> ;

: fjsc-page ( scripts title quot -- )
  #! Display a web page importing the given script
  #! tags and using the title. The body of the page
  #! is generated by calling the quotation.
  -rot xhtml-preamble
  chars>entities
  <html " xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\"" write-html html>
    <head>
      <title> write </title>
      [ script ] each
    </head>
    <body>
     call
    </body>
  </html> ;
  
: fjsc-render ( template title -- )
  #! Render the fjsc page importing the required
  #! scripts.
  serving-html {
    "/responder/fjsc-resources/jquery.js"
    "/responder/fjsc-resources/bootstrap.js"
  } swap [
    [
      f swap render-template
    ] fjsc-page
  ] with-html-stream ;

: compile ( code -- )
  #! Compile the facor code as a string, outputting the http
  #! response containing the javascript.
  serving-text
  'expression' parse car parse-result-parsed fjsc-compile 
   write flush ;

! The 'compile' action results in an URL that looks like
! 'responder/fjsc/compile'. It takes one query or post 
! parameter called 'code'. It calls the 'compile' word
! passing the parameter to it on the stack.
\ compile { 
  { "code" v-required } 
} define-action

: repl ( -- )
  #! The main 'repl' page.
  f "repl" "Factor to Javascript REPL" fjsc-render ;

! An action called 'repl' 
\ repl { } define-action

! Create the web app, providing access 
! under '/responder/fjsc' which calls the
! 'repl' action.
"fjsc" "repl" "apps/furnace-fjsc" web-app

! An URL to the javascript resource files used by
! the 'fjsc' responder.
"fjsc-resources" [
 [
   "libs/fjsc/resources/" resource-path "doc-root" set
   file-responder
 ] with-scope
] add-simple-responder
