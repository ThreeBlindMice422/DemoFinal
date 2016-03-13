* System equates
stack       EQU     $A000
shift       EQU     12                * Shift 12 bits
CR          EQU     $0D
LF          EQU     $0A
WELCOME     DC.B    'Welcome to the disassembler!',CR,LF,0
PROMPTST    DC.B    'Enter starting address in hex:',CR,LF,0
PROMPTEND   DC.B    'Enter ending address in hex:',CR,LF,0
INVALID_MSG DC.B    'Invalid input!',CR,LF,0
HINT        DC.B    'Hint: Addresses must be between 0 to FFFFFF inclusive, an even number,',CR,LF,'and the starting address must be less than the ending address.',CR,LF,CR,LF,0
LOAD_MORE     DC.B    CR,LF,'Press enter to load more...',0
START_OVER    DC.B    CR,LF,'That was exciting! Try again?',CR,LF,'(Enter 1 for yes, any other keys for no)',CR,LF,0
END_PROCESS   DC.B    CR,LF,':( See you again soon!',0

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
