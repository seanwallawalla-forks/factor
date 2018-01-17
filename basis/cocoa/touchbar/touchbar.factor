! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types cocoa cocoa.classes cocoa.messages
cocoa.runtime combinators core-foundation.strings kernel locals
;
IN: cocoa.touchbar

: make-touchbar ( seq self -- touchbar )
    [ NSTouchBar -> alloc -> init dup ] dip -> setDelegate: {
        [ swap <CFStringArray> { void { id SEL id } } ?-> setDefaultItemIdentifiers: ]
        [ swap <CFStringArray> { void { id SEL id } } ?-> setCustomizationAllowedItemIdentifiers: ]
        [ nip ]
    } 2cleave ;

:: make-NSTouchBar-button ( self identifier label-string action-string -- button )
    NSCustomTouchBarItem send: alloc
        identifier <CFString> { id { id SEL id } } ?send: \initWithIdentifier: :> item
        NSButton
            label-string <CFString>
            self
            action-string lookup-selector { id { id SEL id id SEL } } ?send: \buttonWithTitle:target:action: :> button
        item button send: \setView:
        item ;
