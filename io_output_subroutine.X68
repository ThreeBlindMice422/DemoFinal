OUTPUT_START:                  ; first instruction of program
    LEA     BUFFER,A2
    MOVEA.L A2,A3
    CLR.L   D2 
    MOVE.B  #25,D2 ; output x lines at a time
    MOVE.B  D2,D3 ; store x for reloading
    MOVE.B  #1,D1 ; 1 byte long
    BRA OUTLOOP
OUTLOOP:
    MOVEA.W A2,A1 ; load (next) data at data buffer to A1
    ADDA.W  #1,A2
    MOVE.B  #1,D0 ; output string at A1 without CRLF
    TRAP    #15
    SUBI.W  #1,BUFFER_COUNTER ; decrement counter
    CMPI.W  #0,BUFFER_COUNTER ; if all data is read, go to end
    BEQ     END
    CMPI.B  #$0A,(A1) ; compare LF to byte that just got displayed (end of line)
    BEQ     END_LINE
    *SUBI.B  #1,D2 ; decrement D2 (x~0)
    *CMPI.B  #0,D2 ; if the x lines are displayed, goto branch
    *BEQ     END_BATCH
    BRA     OUTLOOP
    
END_LINE:
    SUBI.B  #1,D2 ; subtract 1 from line counter
    CMPI.B  #0,D2 ; check if end of line batch is reached (25)
    BEQ     END_BATCH ; if reached, go to END_BATCH to load the next 25 lines
    BRA     OUTLOOP ; branch back for next line
    
END_BATCH:
    LEA     LOAD_MORE,A1 ; load "load more..." message to A1
    MOVE.B  #13,D0 ; display the message
    TRAP    #15
    MOVE.B  #5,D0 ; wait for user to press a key (note: D1 stores the input)
    TRAP    #15
    MOVE.B  #1,D1 ; reload byte size
    MOVE.B  D3,D2 ; reload x, then go back to outloop
    BRA     OUTLOOP
    

    
END:
    LEA     START_OVER,A1
    MOVE.B  #18,D0
    TRAP    #15
    CMPI.B  #1,D1
    BEQ     START
    LEA     END_PROCESS,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #9,D0
    TRAP    #15

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
