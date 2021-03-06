\ ------------------------------------------------------------------------
testing block words: BLK SCR LOAD THRU BUFFER BLOCK UPDATE FLUSH

marker block_tests

\ Bring in a 4-block ram drive
T{ 4 block-ramdrive-init -> }T

\ Put a string into the first block.
T{ : teststring s" Testing Blocks!" ; -> }T
T{ : teststringlength teststring swap drop ; -> }T
T{ teststring 0 block swap move update flush -> }T

\ See if it's in the ramdrive.
T{ ramdrive teststringlength teststring compare -> 0 }T

\ We don't have an official editor yet, so bring in just
\ enough to create some basic screens.
decimal
( List the current screen)
: L  ( - ) 
    scr @ block                  ( Load the screen )
    cr ." Screen #" scr @ 4 u.r  ( Print the screen number )
    16 0 do
        cr i 2 u.r space       ( Print the line number )
        dup i 64 * + 64 type     ( Print the line )
    loop cr drop ;

( List a given screen )
: list  ( scr# - )
    scr ! ( Save the screen number)
    L ;   ( Print the screen )

( Editor, continued )
( line provides the address, in the buffer, of the given line )
: line  ( line# - c-addr)
    64 *        ( Convert line number to # characters offset )
    scr @ block ( Get the buffer address for that block )
    + ;         ( Add the offset )

: E ( line# - ) ( Erase the given line number with spaces )
    line 64 blank update ;

: O     ( line# - ) ( Overwrite line with new text )
    dup E                    ( Erase existing text on line )
    cr dup 2 u.r ."  * " line 64 accept drop update ;

( Editor, continued )
: enter-screen ( scr# - )
  dup scr ! buffer drop
  16 0 do i o loop ;
: erase-screen ( scr# - )
  dup scr ! buffer 1024 blank update ;


T{ 0 erase-screen flush -> }T

\ Make sure the test string from before is gone by looking for space
\ at the beginning of the ramdrive.
T{ s"           " ramdrive 10 compare -> 0 }T

\ Enter screens for testing LOAD and THRU
1 enter-screen
( Test screen 1 )
( 1 ) variable testvalue
( 2 ) testvalue 5 !
( 3 ) variable blkinscreen
( 4 ) blk @ blkinscreen !
( 5 ) variable blkinstring
( 6 ) s" blk @ blkinstring !" evaluate
( 7 ) variable blkinscreenA
( 8 ) blk @ blkinscreenA !
( 9 )
( 10 )
( 11 )
( 12 )
( 13 )
( 14 )
( 15 )

\ Load screen 1 and then check for the expected side effects.
T{ 1 load -> }T

\ BLK should be 0 while in the string and 1 while in the rest of the block.
T{ blkinscreen @  -> 1 }T
T{ blkinstring @  -> 0 }T
T{ blkinscreenA @ -> 1 }T

2 enter-screen
( Test screen 2 )
( 1 ) ( Test loading another screen )
( 2 ) variable shouldbe19 ( when "2 3 thru" is run)
( 3 ) 5 shouldbe19 !
( 4 ) variable blkinscreenB
( 5 ) blk @ blkinscreenB ! ( should be 2 )
( 6 ) 3 load
( 7 ) blk @ constant blkinscreenD ( try a different method )
( 8 )
( 9 )
( 10 )
( 11 )
( 12 )
( 13 )
( 14 )
( 15 ) 

3 enter-screen
( Test screen 2 )
( 1 ) 
( 2 ) 
( 3 ) shouldbe19 @ 7 + shouldbe19 !
( 4 ) 
( 5 ) 
( 6 ) 
( 7 ) 
( 8 )
( 9 )
( 10 )
( 11 )
( 12 )
( 13 )
( 14 ) ( blkinscreen4 should be 3 because we are on screen 3 )
( 15 ) ( testing the last line )     blk @ constant blkinscreenC

T{ 2 list -> }T
T{ scr @ -> 2 }T \ Screen 2 is the last one we listed.

\ Load screens 2 and 3 with THRU and check for side effects.
\ shouldbe19 should be 5 + 7 + 7 because screen 2 loads screen 3.
T{ 2 3 thru -> }T

T{ blkinscreenB @ -> 2  }T \ Note: blkinscreen3 is a variable.
T{ blkinscreenC   -> 3  }T \ Note: blkinscreen4 is a constant.
T{ blkinscreenD   -> 2  }T \ Note: blkinscreen5 is a constant.
T{ shouldbe19 @   -> 19 }T

\ Release all of the memory used.
block_tests
