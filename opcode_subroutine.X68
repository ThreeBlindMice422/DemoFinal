OP       
            LEA     BUFFER,A2       * Loads buffer to A2
            CLR.W   BUFFER_COUNTER   * Clear buffer counter
while_loop  
            MOVE.L  END_ADDR, D7    * Loads ending address to D7
            CMP.L   START_ADDR, D7  * Compare ending adress to staring address
            BLT     OUTPUT_START    * branches to Output buffer if less or equal
            
            CLR.B   EA_SOURCE        * Clear source EA
            CLR.B   EA_DEST          * Clear destination EA
            CLR.B   bad_data_flag    * Clear bad data FLAG
            
            CLR.L   D7              * Clear     
            MOVEA.L START_ADDR,A1   * Loads the address to A1       
            
            
            ; for-loop to handle memory tag
            MOVE.L  START_ADDR,D3   * Loads the address to D3
            MOVEQ   #0, D1          ; Start counter
            MOVEQ   #4, D2          ; End counter      
loop_memory CMP.B   D1,D2           ; Compare D2 to D1
            BEQ     loop_memory_end ; if they are equal, then ends
            
            ROL.W   #4,D3           ; rotate to get the first char
            MOVE.W  D3,D4           ; Put into a temp storage
            AND     #$000F,D4       ; masks the first char 
            CMP.W   #$000A,D4       ; compare to check if it is a char or a number
            BGE     MEM_ALPHA       ; if it greater or equel means it is a alphabet
            BLS     MEM_NUM         ; if it less than means it is a number
loop_memory_back 
            MOVE.B  D4,(A2)+        ; Push char in label into buffer          
            ADDQ    #1,D1           ; increase the counter
            BRA     loop_memory     ; branch back
MEM_ALPHA
            ADD     #$37, D4        ; convert the hex to ASCII number          
            BRA     loop_memory_back ; back to loop    
MEM_NUM
            ADD     #$30, D4        ; convert the hex to ASCII number
            BRA     loop_memory_back ; back to loop
loop_memory_end     
            MOVE.B  #' ',(A2)+      ; Push SPACE into buffer  
            ADDQ.W  #5,BUFFER_COUNTER ; Increase the buffer counter      
            MOVE.W  (A1),D7         * Move the insturction into D7
            LEA     stack,SP        * Load the SP = A7 which is stack pointer                          
            LEA     op_jmp_table,A0 * Index into the table
            CLR.L   D0              * Clear
            CLR.L   D1              * Clear 
            MOVE.W  D7,D0           * Put instruction into D0
            MOVE.B  #shift,D1       * Put shift constant into D1
            LSR.W   D1,D0           * Logical shift right 12 bits
        
            MULU    #6,D0           * Multiply D0 by 6
                                    * Scale up 6 base on size of each jump entry
            JSR     0(A0,D0)        * Jump indirect with index
                                    * JSR stores the return location into the stack
                                    * so the 68k can return back to the JSR, and continue
            ADDI.L    #2, START_ADDR
            
            ; Trap tast 15 use for testing
            ; output Source and Destination EA
            ;----------------------------------------------------------
            ;CLR.L     D1                   ; Clear D1
            ;CLR.L     D2                   ; Clear D2
            ;MOVE.B    EA_SOURCE, D1        ; Put Carry into D1
            ;MOVEQ     #16,D2
            ;MOVE.B    #15,D0
            ;TRAP      #15                  ; Output as a hex number
            
            ;CLR.L     D1                   ; Clear D1
            ;CLR.L     D2                   ; Clear D2
            ;MOVE.B    EA_DEST, D1            ; Put Carry into D1
            ;MOVEQ     #16,D2
            ;MOVE.B    #15,D0
            ;TRAP      #15                  ; Output as a hex number
            ;----------------------------------------------------------
                         
            ;BRA while_loop
            BRA       EA
            
*-----------------------CLR & JSR & RTS & NOP & LEA & MOVEM TABLE---------
c0100_jum_tab JMP j_clr_b
            JMP j_rts_nop_clr_w
            JMP j_movem_w_jsr_clr_l
            JMP j_movem_l
            JMP j_0100_100
            JMP j_0100_101
            JMP j_0100_110
            JMP j_lea

j_clr_b
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP) 
            
            MOVE.B  #'C',(A2)+   ; Push C into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #'R',(A2)+   ; Push R into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
            ADDQ.W  #6,BUFFER_COUNTER ; Increase the buffer counter 
            ;CLR <ea>
            MOVE.B  #%11111111,EA_SOURCE ; Push Empty EA 11111111  into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into dest
                                                 
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_rts_nop_clr_w
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            LEA     nop_clr_w_rts_jmp_tab,A0   * Index into the table
            CLR.L   D0                * Clear
            MOVE.W  D7,D0             * Put instruction into D0
            AND.W   #$0600,D0         * Mask the condition bits
            MOVE.B  #9,D1             * Put shift constant into D1
            LSR.W   D1,D0             * Logical shift right 9 bits
                                      * get 0000 0000 0000 00[10bit][9bit]
            MULU    #6,D0
            
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue

            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6            
            RTS         
j_movem_w_jsr_clr_l 
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            LEA     movem_w_jsr_clr_L_tab,A0   * Index into the table
            CLR.L   D0                * Clear
            MOVE.W  D7,D0             * Put instruction into D0
            AND.W   #$0600,D0         * Mask the condition bits
            MOVE.B  #9,D1             * Put shift constant into D1
            LSR.W   D1,D0             * Logical shift right 9 bits
                                      * get 0000 0000 0000 00[10bit][9bit]
            MULU    #6,D0
            
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue

            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS    
j_movem_l   
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            MOVE.B  #'M',(A2)+   ; Push M into buffer
            MOVE.B  #'O',(A2)+   ; Push O into buffer
            MOVE.B  #'V',(A2)+   ; Push V into buffer
            MOVE.B  #'E',(A2)+   ; Push E into buffer
            MOVE.B  #'M',(A2)+   ; Push M into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W  #8,BUFFER_COUNTER ; Increase the buffer counter 
            
            LEA     movem_l_reg_mem_tab,A0   * Index into the table
            CLR.L   D0                * Clear
            MOVE.W  D7,D0             * Put instruction into D0
            AND.W   #$0400,D0         * Mask the condition bits
            MOVE.B  #10,D1             * Put shift constant into D1
            LSR.W   D1,D0             * Logical shift right 9 bits
                                      * get 0000 0000 0000 00[10bit][9bit]
            MULU    #6,D0
            
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue
             
                           
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_0100_100  JSR BAD_DATA    
            RTS
j_0100_101  JSR BAD_DATA    
            RTS
j_0100_110  JSR BAD_DATA    
            RTS
j_lea
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #'E',(A2)+   ; Push E Into buffer
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
            ADDQ.W  #4,BUFFER_COUNTER ; Increase the buffer counter 
            
            ;LEA <ea>,An           
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00001000,D0      ; Change mode to 001 An 
            MOVE.B  D0,EA_DEST        ; Push EA into destination
                                                
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
            
*-----------------------NOP & CLR.W & RTS TABLE------------------------------
nop_clr_w_rts_jmp_tab JMP j_nop_clr_rts_00
            JMP j_clr_w
            JMP j_nop_clr_rts_10
            JMP j_rts_nop

j_nop_clr_rts_00    JSR BAD_DATA    
                    RTS
j_clr_w
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)  
            
            MOVE.B  #'C',(A2)+   ; Push C into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #'R',(A2)+   ; Push R into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'W',(A2)+   ; Push W into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter 
            
            ;CLR <ea>
            MOVE.B  #%11111111,EA_SOURCE ; Push Empty EA 11111111  into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into dest
                           
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS     
j_nop_clr_rts_10    JSR BAD_DATA    
                    RTS
j_rts_nop
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            LEA     nop_rts_jmp_tab,A0   * Index into the table
            CLR.L   D0                * Clear
            MOVE.W  D7,D0             * Put instruction into D0
            AND.W   #$0004,D0         * Mask the condition bits
            MOVE.B  #2,D1             * Put shift constant into D1
            LSR.W   D1,D0             * Logical shift right 2 bits
                                      * get 0000 0000 0000 000[2bit]
            MULU    #6,D0
            
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue
                           
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS  

*-----------------------NOP & RTS TABLE--------------------------------------
nop_rts_jmp_tab JMP j_nop
            JMP j_rts 
j_nop
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
                     
            MOVE.B  #'N',(A2)+   ; Push N into buffer
            MOVE.B  #'O',(A2)+   ; Push O into buffer
            MOVE.B  #'P',(A2)+   ; Push P into buffer
            ADDQ.W    #3,BUFFER_COUNTER ; Increase the buffer counter 
            
            ;NOP 
            MOVE.B  #%11111111,EA_SOURCE ; Push Empty EA into source
            MOVE.B  #%11111111,EA_DEST ; Push Empty EA into source 
                           
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS    
j_rts 
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'R',(A2)+   ; Push R into buffer
            MOVE.B  #'T',(A2)+   ; Push T into buffer
            MOVE.B  #'S',(A2)+   ; Push S into buffer
            ADDQ.W    #3,BUFFER_COUNTER ; Increase the buffer counter 
            
            ;RTS 
            MOVE.B  #%11111111,EA_SOURCE ; Push Empty EA into source
            MOVE.B  #%11111111,EA_DEST ; Push Empty EA into source  
            
            
                           
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS    

*-----------------------MOVEM.W & JSR & CLR.L TABLE---------------------------
movem_w_jsr_clr_L_tab JMP j_movem_w_reg_mem
            JMP j_clr_l
            JMP j_movem_w_mem_reg
            JMP j_jsr
j_movem_w_reg_mem  
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)

            MOVE.B  #'M',(A2)+   ; Push M into buffer
            MOVE.B  #'O',(A2)+   ; Push O into buffer
            MOVE.B  #'V',(A2)+   ; Push V into buffer
            MOVE.B  #'E',(A2)+   ; Push E into buffer
            MOVE.B  #'M',(A2)+   ; Push M into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'W',(A2)+   ; Push W into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #8,BUFFER_COUNTER ; Increase the buffer counter 
            
            ; MOVEM <list>,<ea>
            MOVE.B  #%00111101,EA_SOURCE ; Push mode 111 reg 101 into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into dest
            
                           
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_clr_l
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)

            MOVE.B  #'C',(A2)+   ; Push C into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #'R',(A2)+   ; Push R into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter 
            
            ;CLR <ea>
            MOVE.B  #%11111111,EA_SOURCE ; Push Empty EA 11111111  into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into dest
                           
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_movem_w_mem_reg   
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)

            MOVE.B  #'M',(A2)+   ; Push M into buffer
            MOVE.B  #'O',(A2)+   ; Push O into buffer
            MOVE.B  #'V',(A2)+   ; Push V into buffer
            MOVE.B  #'E',(A2)+   ; Push E into buffer
            MOVE.B  #'M',(A2)+   ; Push M into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'W',(A2)+   ; Push W into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #8,BUFFER_COUNTER ; Increase the buffer counter 
            
            ; MOVEM <ea>,<list>
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.B  #%00111110,EA_DEST ; Push mode 111 reg 110 into destination
                           
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS 
j_jsr
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
                       
            MOVE.B   #'J',(A2)+      ; Push JSR SAPCE into buffer   
            MOVE.B   #'S',(A2)+
            MOVE.B   #'R',(A2)+
            MOVE.B   #' ',(A2)+
            ADDQ.W     #4,BUFFER_COUNTER ; Increase the buffer counter 
            ; JSR
            MOVE.B  #%11111111,EA_SOURCE ; Push Empty EA into source           
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST       ; Push EA into destination
            
                    
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS

*-----------------------MOVEM.L_REG->MEM & MOVEM.L_MEM->REG TABLE----------------
movem_l_reg_mem_tab JMP j_movem_l_reg_mem
            JMP j_movem_l_mem_reg
j_movem_l_reg_mem 
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            ; MOVEM <list>,<ea>
            MOVE.B  #%00111101,EA_SOURCE ; Push mode 111 reg 101 into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into dest
                                    
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_movem_l_mem_reg 
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
                  
            ; MOVEM <ea>,<list>
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.B  #%00111110,EA_DEST ; Push mode 111 reg 110 into destination
                                    
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
*-----------------------ASR & LSL & ROL TABLE-----------------------------
reg_mem_jum_tab JMP j_reg_b
            JMP j_reg_w
            JMP j_reg_l
            JMP j_mem
            
j_reg_b
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            MOVE.W      D7,D0
            LEA     reg_b_jum_tab,A0  * Index into the table
            CLR.L   D0                * Zero it
            MOVE.W  D7,D0             * Put instruction into D0
            AND.L   #$0118,D0         * get 0000 0001 0001 1000 bits
            MOVE.B  #3,D1             * Put shift constant into D1
            LSL.B   D1,D0             * Logical shift left 3 bits
        
            MOVE.B  #6,D1             * Put shift constant into D1
            LSR.W   D1,D0             * Logical shift right 6 bits
                                      * get 0000 0000 0000 0[dr][3bit][4bit]
            
            MULU    #6,D0             * Multiply D0 by 6
                                      * Scale up 6 base on size of each jump entry
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue
            CMPI.B  #%0001,bad_data_flag * Check if bad flag is set
            BEQ     b_bit_test_end    * don't check data
            
            MOVE.W  D7,D0             * Put instruction into D0
            BTST    #5,D0             * bit test #5
            BEQ     b_immediate_c     * if z flag is set, means is a 0
                                      * i/r = 0 immediate shift count
            BNE     b_register_c      * if z flag is not set, means is a 1
                                      * i/r = 1 register shift count        
b_register_c
            ; LSL, ASR, ROL Dx,Dy 
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the EA bits
            LSR.W   #8,D0             ; Logical shift right 8 bits
            LSR.W   #1,D0             ; Logical shift right 1 bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0007,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into dest
            BRA     b_bit_test_end    * end i/r bit test
            
b_immediate_c   
            ; LSL, ASR, ROL #<data>,Dy
            MOVE.B  #%11111111,EA_SOURCE ; Push empty EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0007,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into dest
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the EA bits
            LSR.W   #8,D0             ; Logical shift right 8 bits
            LSR.W   #1,D0             ; Logical shift right 1 bits
            
            CMPI.W  #0,D0             ; Compare the register to 0 (000)
            BEQ     ASSIGN_EIGHT_JSR_b 
            BNE     ASSIGN_EIGHT_SKIP_b ; if the register is not 000, skip assign eight 
ASSIGN_EIGHT_JSR_b            
            JSR     ASSIGN_EIGHT      ; If equals then go to assign 111   
ASSIGN_EIGHT_SKIP_b                   
            ADD.B   #$30,D0           ; Change hex number to hex value for ASCII       
            MOVE.B  #'#',(A2)+        ; Push # sign into buffer
            MOVE.B  D0,(A2)+          ; Push immediate data into buffer
            MOVE.B  #',',(A2)+        ; Push , into buffer
            ADDQ.W    #3,BUFFER_COUNTER ; Increase the buffer counter 
            BRA     b_bit_test_end    * end i/r bit test
b_bit_test_end
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS

j_reg_w
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            MOVE.W      D7,D0
            LEA     reg_w_jum_tab,A0  * Index into the table
            CLR.L   D0                * Zero it
            MOVE.W  D7,D0             * Put instruction into D0
            AND.L   #$0118,D0         * get 0000 0001 0001 1000 bits
            MOVE.B  #3,D1             * Put shift constant into D1
            LSL.B   D1,D0             * Logical shift left 3 bits
        
            MOVE.B  #6,D1             * Put shift constant into D1
            LSR.W   D1,D0             * Logical shift right 6 bits
                                      * get 0000 0000 0000 0[dr][3bit][4bit]
            
            MULU    #6,D0             * Multiply D0 by 6
                                      * Scale up 6 base on size of each jump entry
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue
            CMPI.B  #%0001,bad_data_flag * Check if bad flag is set
            BEQ     w_bit_test_end    * don't check data            
     
            MOVE.W  D7,D0             * Put instruction into D0
            BTST    #5,D0             * bit test #5
            BEQ     w_immediate_c     * if z flag is set, means is a 0
                                      * i/r = 0 immediate shift count
            BNE     w_register_c      * if z flag is not set, means is a 1
                                      * i/r = 1 register shift count        
w_register_c
            ; LSL, ASR, ROL Dx,Dy 
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the EA bits
            LSR.W   #8,D0             ; Logical shift right 8 bits
            LSR.W   #1,D0             ; Logical shift right 1 bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0007,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into dest
            BRA     w_bit_test_end    * end i/r bit test
            
w_immediate_c   
            ; LSL, ASR, ROL #<data>,Dy
            MOVE.B  #%11111111,EA_SOURCE ; Push empty EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0007,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into dest
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the EA bits
            LSR.W   #8,D0             ; Logical shift right 8 bits
            LSR.W   #1,D0             ; Logical shift right 1 bits
            
            CMPI.W  #0,D0             ; Compare the register to 0 (000)
            BEQ     ASSIGN_EIGHT_JSR_w 
            BNE     ASSIGN_EIGHT_SKIP_w ; if the register is not 000, skip assign eight 
ASSIGN_EIGHT_JSR_w            
            JSR     ASSIGN_EIGHT      ; If equals then go to assign 111   
ASSIGN_EIGHT_SKIP_w                   
            ADD.B   #$30,D0           ; Change hex number to hex value for ASCII  
            
            MOVE.B  #'#',(A2)+        ; Push # sign into buffer
            MOVE.B  D0,(A2)+          ; Push immediate data into buffer
            MOVE.B  #',',(A2)+        ; Push , into buffer
            ADDQ.W    #3,BUFFER_COUNTER ; Increase the buffer counter 
            BRA     w_bit_test_end    * end i/r bit test
w_bit_test_end           
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_reg_l
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            MOVE.W      D7,D0
            LEA     reg_l_jum_tab,A0  * Index into the table
            CLR.L   D0                * Zero it
            MOVE.W  D7,D0             * Put instruction into D0
            AND.L   #$0118,D0         * get 0000 0001 0001 1000 bits
            MOVE.B  #3,D1             * Put shift constant into D1
            LSL.B   D1,D0             * Logical shift left 3 bits
        
            MOVE.B  #6,D1             * Put shift constant into D1
            LSR.W   D1,D0             * Logical shift right 6 bits
                                      * get 0000 0000 0000 0[dr][3bit][4bit]
            
            MULU    #6,D0             * Multiply D0 by 6
                                      * Scale up 6 base on size of each jump entry
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue            
            CMPI.B  #%0001,bad_data_flag * Check if bad flag is set
            BEQ     l_bit_test_end    * don't check data
            
            MOVE.W  D7,D0             * Put instruction into D0
            BTST    #5,D0             * bit test #5
            BEQ     l_immediate_c     * if z flag is set, means is a 0
                                      * i/r = 0 immediate shift count
            BNE     l_register_c      * if z flag is not set, means is a 1
                                      * i/r = 1 register shift count        
l_register_c
            ; LSL, ASR, ROL Dx,Dy 
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the EA bits
            LSR.W   #8,D0             ; Logical shift right 8 bits
            LSR.W   #1,D0             ; Logical shift right 1 bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0007,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into dest
            BRA     l_bit_test_end    * end i/r bit test
            
l_immediate_c   
            ; LSL, ASR, ROL #<data>,Dy
            MOVE.B  #%11111111,EA_SOURCE ; Push empty EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0007,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into dest
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the EA bits
            LSR.W   #8,D0             ; Logical shift right 8 bits
            LSR.W   #1,D0             ; Logical shift right 1 bits
            
            CMPI.W  #0,D0             ; Compare the register to 0 (000)
            BEQ     ASSIGN_EIGHT_JSR_l 
            BNE     ASSIGN_EIGHT_SKIP_l ; if the register is not 000, skip assign eight 
ASSIGN_EIGHT_JSR_l            
            JSR     ASSIGN_EIGHT      ; If equals then go to assign 111   
ASSIGN_EIGHT_SKIP_l                   
            ADD.B   #$30,D0           ; Change hex number to hex value for ASCII  
            
            MOVE.B  #'#',(A2)+        ; Push # sign into buffer
            MOVE.B  D0,(A2)+          ; Push immediate data into buffer
            MOVE.B  #',',(A2)+        ; Push , into buffer
            ADDQ.W    #3,BUFFER_COUNTER ; Increase the buffer counter 
            BRA     l_bit_test_end    * end i/r bit test
l_bit_test_end
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_mem
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            MOVE.W      D7,D0
            LEA     mem_jum_tab,A0  * Index into the table
            CLR.L   D0                * Zero it
            MOVE.W  D7,D0             * Put instruction into D0
            AND.L   #$0700,D0         * get 0000 0001 0001 1000 bits
        
            MOVE.B  #8,D1             * Put shift constant into D1
            LSR.W   D1,D0             * Logical shift right 8 bits
                                      * get 0000 0000 0000 0[10bit][9bit][dr]
            
            MULU    #6,D0             * Multiply D0 by 6
                                      * Scale up 6 base on size of each jump entry
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue            
            
            ; LSL, ASR, ROL <ea>
            MOVE.B  #%11111111,EA_SOURCE ; Push Empty EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into dest

            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS

*-----------------------ASR & LSL & ROL Register Byte size shift TABLE-------------------
reg_b_jum_tab   JMP j_asr_b
                JMP j_reg_b_001
                JMP j_reg_b_010
                JMP j_reg_b_011
                JMP j_reg_b_100
                JMP j_lsl_b
                JMP j_reg_b_110
                JMP j_rol_b

j_asr_b 
                MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
   
                MOVE.B  #'A',(A2)+   ; Push A into buffer
                MOVE.B  #'S',(A2)+   ; Push S into buffer
                MOVE.B  #'R',(A2)+   ; Push R into buffer
                MOVE.B  #'.',(A2)+   ; Push . into buffer
                MOVE.B  #'B',(A2)+   ; Push B into buffer
                MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
                ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter 
                
                           
                MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
                RTS
j_reg_b_001     JSR BAD_DATA    
                RTS
j_reg_b_010     JSR BAD_DATA    
                RTS
j_reg_b_011     JSR BAD_DATA    
                RTS
j_reg_b_100     JSR BAD_DATA    
                RTS
j_lsl_b
                MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP) 
                
                MOVE.B  #'L',(A2)+   ; Push L into buffer
                MOVE.B  #'S',(A2)+   ; Push S into buffer
                MOVE.B  #'L',(A2)+   ; Push L into buffer
                MOVE.B  #'.',(A2)+   ; Push . into buffer
                MOVE.B  #'B',(A2)+   ; Push B into buffer
                MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
                ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter 
                
                           
                MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
                RTS
j_reg_b_110     JSR BAD_DATA    
                RTS
j_rol_b
                MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)  

                MOVE.B  #'R',(A2)+   ; Push R into buffer
                MOVE.B  #'O',(A2)+   ; Push O into buffer
                MOVE.B  #'L',(A2)+   ; Push L into buffer
                MOVE.B  #'.',(A2)+   ; Push . into buffer
                MOVE.B  #'B',(A2)+   ; Push B into buffer
                MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
                ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter 
                           
                MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
                RTS

*-----------------------ASR & LSL & ROL Register Word size shift TABLE--------------------              
reg_w_jum_tab   JMP j_asr_w
                JMP j_reg_w_001
                JMP j_reg_w_010
                JMP j_reg_w_011
                JMP j_reg_w_100
                JMP j_lsl_w
                JMP j_reg_w_110
                JMP j_rol_w

j_asr_w
                MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP) 
                
                MOVE.B  #'A',(A2)+   ; Push A into buffer
                MOVE.B  #'S',(A2)+   ; Push S into buffer
                MOVE.B  #'R',(A2)+   ; Push R into buffer
                MOVE.B  #'.',(A2)+   ; Push . into buffer
                MOVE.B  #'W',(A2)+   ; Push W into buffer
                MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
                ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter   
                           
                MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
                RTS
j_reg_w_001     JSR BAD_DATA    
                RTS
j_reg_w_010     JSR BAD_DATA    
                RTS
j_reg_w_011     JSR BAD_DATA    
                RTS
j_reg_w_100     JSR BAD_DATA    
                RTS
j_lsl_w
                MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)

                MOVE.B  #'L',(A2)+   ; Push L into buffer
                MOVE.B  #'S',(A2)+   ; Push S into buffer
                MOVE.B  #'L',(A2)+   ; Push L into buffer
                MOVE.B  #'.',(A2)+   ; Push . into buffer
                MOVE.B  #'W',(A2)+   ; Push W into buffer
                MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
                ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter   
                           
                MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
                RTS
j_reg_w_110     JSR BAD_DATA    
                RTS
j_rol_w
                MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)

                MOVE.B  #'R',(A2)+   ; Push R into buffer
                MOVE.B  #'O',(A2)+   ; Push O into buffer
                MOVE.B  #'L',(A2)+   ; Push L into buffer
                MOVE.B  #'.',(A2)+   ; Push . into buffer
                MOVE.B  #'W',(A2)+   ; Push W into buffer
                MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
                ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter  
                           
                MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
                RTS
*-----------------------ASR & LSL & ROL Regsiter Long size shift TABLE----------------------   
reg_l_jum_tab   JMP j_asr_l
                JMP j_reg_l_001
                JMP j_reg_l_010
                JMP j_reg_l_011
                JMP j_reg_l_100
                JMP j_lsl_l
                JMP j_reg_l_110
                JMP j_rol_l

j_asr_l
                MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
                
                MOVE.B  #'A',(A2)+   ; Push A into buffer
                MOVE.B  #'S',(A2)+   ; Push S into buffer
                MOVE.B  #'R',(A2)+   ; Push R into buffer
                MOVE.B  #'.',(A2)+   ; Push . into buffer
                MOVE.B  #'L',(A2)+   ; Push L into buffer
                MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
                ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter 
                           
                MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
                RTS
j_reg_l_001     JSR BAD_DATA    
                RTS
j_reg_l_010     JSR BAD_DATA    
                RTS
j_reg_l_011     JSR BAD_DATA    
                RTS
j_reg_l_100     JSR BAD_DATA    
                RTS
j_lsl_l
                MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)

                MOVE.B  #'L',(A2)+   ; Push L into buffer
                MOVE.B  #'S',(A2)+   ; Push S into buffer
                MOVE.B  #'L',(A2)+   ; Push L into buffer
                MOVE.B  #'.',(A2)+   ; Push . into buffer
                MOVE.B  #'L',(A2)+   ; Push L into buffer
                MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
                ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter   
                           
                MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
                RTS
j_reg_l_110     JSR BAD_DATA    
                RTS
j_rol_l
                MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)

                MOVE.B  #'R',(A2)+   ; Push R into buffer
                MOVE.B  #'O',(A2)+   ; Push O into buffer
                MOVE.B  #'L',(A2)+   ; Push L into buffer
                MOVE.B  #'.',(A2)+   ; Push . into buffer
                MOVE.B  #'L',(A2)+   ; Push L into buffer
                MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
                ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter      
                           
                MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
                RTS
*-----------------------ASR & LSL & ROL memory shift TABLE-----------------------------                
mem_jum_tab     JMP j_asr
                JMP j_mem_001
                JMP j_mem_010
                JMP j_lsl
                JMP j_mem_100
                JMP j_mem_101
                JMP j_mem_110
                JMP j_rol

j_asr   
                MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)  
                
                MOVE.B  #'A',(A2)+   ; Push A into buffer
                MOVE.B  #'S',(A2)+   ; Push S into buffer
                MOVE.B  #'R',(A2)+   ; Push R into buffer
                MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
                ADDQ.W    #4,BUFFER_COUNTER ; Increase the buffer counter 
                           
                MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
                RTS
j_mem_001       JSR BAD_DATA    
                RTS
j_mem_010       JSR BAD_DATA    
                RTS
j_lsl   
                MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
        
                MOVE.B  #'L',(A2)+   ; Push L into buffer
                MOVE.B  #'S',(A2)+   ; Push S into buffer
                MOVE.B  #'L',(A2)+   ; Push L into buffer
                MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
                ADDQ.W    #4,BUFFER_COUNTER ; Increase the buffer counter   
                           
                MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
                RTS
j_mem_100       JSR BAD_DATA    
                RTS
j_mem_101       JSR BAD_DATA    
                RTS
j_mem_110       JSR BAD_DATA    
                RTS
j_rol
                MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)  
                
                MOVE.B  #'R',(A2)+   ; Push R into buffer
                MOVE.B  #'O',(A2)+   ; Push O into buffer
                MOVE.B  #'L',(A2)+   ; Push L Into buffer
                MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
                ADDQ.W    #4,BUFFER_COUNTER ; Increase the buffer counter   
                           
                MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
                RTS
*-----------------------AND & MULS.W JUMP TABLE-----------------------------
and_jmp_tab JMP     j_and_b             * AND & MULS.W jump table
            JMP     j_and_w
            JMP     j_and_l
            JMP     c0011
            JMP     j_and_b_d_ea
            JMP     j_and_w_d_ea
            JMP     j_and_l_d_ea
            JMP     j_muls_w
j_and_b
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'N',(A2)+   ; Push N into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter    
            
            MOVE.B  #%0000,Immediate_s ; Push Size of immediate data
            
            * AND <ea>, Dn
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_and_w
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'N',(A2)+   ; Push N into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'W',(A2)+   ; Push W into buffer
            MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter  
            
            MOVE.B  #%0001,Immediate_s ; Push Size of immediate data
            
            * AND <ea>, Dn
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_and_l
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'N',(A2)+   ; Push N into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter 

            MOVE.B  #%0010,Immediate_s ; Push Size of immediate data  
            
            * AND <ea>, Dn
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
c0011       JSR BAD_DATA    
            RTS
j_and_b_d_ea
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'N',(A2)+   ; Push N into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter   
            
            * AND Dn, <ea>
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_and_w_d_ea
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'N',(A2)+   ; Push N into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'W',(A2)+   ; Push W into buffer
            MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter   
            
            * AND Dn, <ea>
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_and_l_d_ea
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'N',(A2)+   ; Push N into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #' ',(A2)+   ; Push SPACE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter   
            
            * AND Dn, <ea>
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_muls_w      
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)

            MOVE.B  #'M',(A2)+   ; Push M into buffer
            MOVE.B  #'U',(A2)+   ; Push U into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #'S',(A2)+   ; Push S into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W  #5,BUFFER_COUNTER ; Increase the buffer counter 
            
            MOVE.B  #%0001,Immediate_s ; Push Size of immediate data
            
            * MULS <ea>, Dn
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
*-----------------------ADDI, SUBI JUMP TABLE-----------------------
addi_subi_jum_tab JMP   j_addi_subi_000
            JMP     j_andi
            JMP     j_subi
            JMP     j_addi
            JMP     j_addi_subi_100
            JMP     j_addi_subi_101
            JMP     j_addi_subi_110
            JMP     j_addi_subi_111
            
j_addi_subi_000
            JSR     BAD_DATA
            RTS
j_andi
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            LEA     andi_jmp_tab,A0    * Index into the table
            CLR.L   D0                * Zero it
            MOVE.W  D7,D0             * Put instruction into D0
            MOVE.B  #8,D1             * Put shift constant into D1
            LSL.W   D1,D0             * Logical shift left 7 bits
        
            MOVE.B  #14,D1            * Put shift constant into D1
            LSR.W   D1,D0             * Logical shift left 13 bits
            
            MULU    #6,D0             * Multiply D0 by 6
                                      * Scale up 6 base on size of each jump entry
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_subi
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            LEA     subi_jmp_tab,A0    * Index into the table
            CLR.L   D0                * Zero it
            MOVE.W  D7,D0             * Put instruction into D0
            MOVE.B  #8,D1             * Put shift constant into D1
            LSL.W   D1,D0             * Logical shift left 7 bits
        
            MOVE.B  #14,D1            * Put shift constant into D1
            LSR.W   D1,D0             * Logical shift left 13 bits
            
            MULU    #6,D0             * Multiply D0 by 6
                                      * Scale up 6 base on size of each jump entry
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_addi
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            LEA     addi_jmp_tab,A0    * Index into the table
            CLR.L   D0                * Zero it
            MOVE.W  D7,D0             * Put instruction into D0
            MOVE.B  #8,D1             * Put shift constant into D1
            LSL.W   D1,D0             * Logical shift left 7 bits
        
            MOVE.B  #14,D1            * Put shift constant into D1
            LSR.W   D1,D0             * Logical shift left 13 bits
            
            MULU    #6,D0             * Multiply D0 by 6
                                      * Scale up 6 base on size of each jump entry
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_addi_subi_100
            JSR     BAD_DATA
            RTS
j_addi_subi_101
            JSR     BAD_DATA
            RTS
j_addi_subi_110
            JSR     BAD_DATA
            RTS
j_addi_subi_111
            JSR     BAD_DATA
            RTS
*-----------------------ANDI JUMP TABLE-----------------------------
andi_jmp_tab JMP     j_andi_b             * ADDI jump table
            JMP     j_andi_w
            JMP     j_andi_l
            
j_andi_b    
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'N',(A2)+   ; Push D into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'I',(A2)+   ; Push I into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #7,BUFFER_COUNTER ; Increase the buffer counter
            
            * ANDI #<data>, <ea>
            MOVE.B  #%00111100,EA_SOURCE ; Push Immediate mode 111 reg 100 into source     
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVE.B  #%0000,Immediate_s ; Push Size of immediate data
                             
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
   
j_andi_w
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'N',(A2)+   ; Push N into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'I',(A2)+   ; Push I into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'W',(A2)+   ; Push W into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #7,BUFFER_COUNTER ; Increase the buffer counter
            
            * ANDI #<data>, <ea>
            MOVE.B  #%00111100,EA_SOURCE ; Push Immediate mode 111 reg 100 into source     
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVE.B  #%0001,Immediate_s ; Push Size of immediate data
                             
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_andi_l
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'N',(A2)+   ; Push D into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'I',(A2)+   ; Push I into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #7,BUFFER_COUNTER ; Increase the buffer counter
            
            * ANDI #<data>, <ea>
            MOVE.B  #%00111100,EA_SOURCE ; Push Immediate mode 111 reg 100 into source     
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVE.B  #%0010,Immediate_s ; Push Size of immediate data
                             
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS 
*-----------------------SUBI JUMP TABLE-----------------------------
subi_jmp_tab JMP     j_subi_b             * ADDI jump table
            JMP     j_subi_w
            JMP     j_subi_l
j_subi_b     
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'S',(A2)+   ; Push S into buffer
            MOVE.B  #'U',(A2)+   ; Push U into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #'I',(A2)+   ; Push I into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #7,BUFFER_COUNTER ; Increase the buffer counter
            
            * SUBI #<data>, <ea>
            MOVE.B  #%00111100,EA_SOURCE ; Push Immediate mode 111 reg 100 into source     
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVE.B  #%0000,Immediate_s ; Push Size of immediate data
                             
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS        
j_subi_w
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'S',(A2)+   ; Push S into buffer
            MOVE.B  #'U',(A2)+   ; Push U into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #'I',(A2)+   ; Push I into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'W',(A2)+   ; Push W into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #7,BUFFER_COUNTER ; Increase the buffer counter
            
            * SUBI #<data>, <ea>
            MOVE.B  #%00111100,EA_SOURCE ; Push Immediate mode 111 reg 100 into source     
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVE.B  #%0001,Immediate_s ; Push Size of immediate data
                             
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS   
j_subi_l
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'S',(A2)+   ; Push S into buffer
            MOVE.B  #'U',(A2)+   ; Push U into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #'I',(A2)+   ; Push I into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #7,BUFFER_COUNTER ; Increase the buffer counter
            
            * SUBI #<data>, <ea>
            MOVE.B  #%00111100,EA_SOURCE ; Push Immediate mode 111 reg 100 into source     
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVE.B  #%0010,Immediate_s ; Push Size of immediate data
                             
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS   
*-----------------------ADDI JUMP TABLE-----------------------------        
addi_jmp_tab JMP     j_addi_b             * ADDI jump table
            JMP     j_addi_w
            JMP     j_addi_l
j_addi_b
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'I',(A2)+   ; Push I into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #7,BUFFER_COUNTER ; Increase the buffer counter
            
            * ADDI #<data>, <ea>
            MOVE.B  #%00111100,EA_SOURCE ; Push Immediate mode 111 reg 100 into source     
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVE.B  #%0000,Immediate_s ; Push Size of immediate data
                             
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_addi_w
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'I',(A2)+   ; Push I into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'W',(A2)+   ; Push W into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #7,BUFFER_COUNTER ; Increase the buffer counter
            
             * ADDI #<data>, <ea>
            MOVE.B  #%00111100,EA_SOURCE ; Push Immediate mode 111 reg 100 into source     
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVE.B  #%0001,Immediate_s ; Push Size of immediate data
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_addi_l
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'I',(A2)+   ; Push I into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #7,BUFFER_COUNTER ; Increase the buffer counter
            
             * ADDI #<data>, <ea>
             MOVE.B  #%00111100,EA_SOURCE ; Push Immediate mode 111 reg 100 into source     
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVE.B  #%0010,Immediate_s ; Push Size of immediate data
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
        
*-----------------------CMP JUMP TABLE-----------------------------
cmp_jmp_tab 
            JMP     j_cmp_b             * CMP jump table
            JMP     j_cmp_w
            JMP     j_cmp_l
            JMP     j_cmp_11
j_cmp_b
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'C',(A2)+   ; Push C into buffer
            MOVE.B  #'M',(A2)+   ; Push M into buffer
            MOVE.B  #'P',(A2)+   ; Push P into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter  
            
            MOVE.B  #%0000,Immediate_s ; Push Size of immediate data
            
            * CMP <ea>, Dn
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_cmp_w
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'C',(A2)+   ; Push C into buffer
            MOVE.B  #'M',(A2)+   ; Push M into buffer
            MOVE.B  #'P',(A2)+   ; Push P into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'W',(A2)+   ; Push W into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter 
            
            MOVE.B  #%0001,Immediate_s ; Push Size of immediate data
            
            * CMP <ea>, Dn
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_cmp_l
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #%0010,Immediate_s ; Push Size of immediate data
            
            MOVE.B  #'C',(A2)+   ; Push C into buffer
            MOVE.B  #'M',(A2)+   ; Push M into buffer
            MOVE.B  #'P',(A2)+   ; Push P into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter  
            
            * CMP <ea>, Dn
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_cmp_11    JSR     BAD_DATA
            RTS
*-----------------------SUB JUMP TABLE-----------------------------
sub_jmp_tab JMP     j_sub_b             * SUB jump table
            JMP     j_sub_w
            JMP     j_sub_l
            JMP     code011
            JMP     j_sub_b_d_ea
            JMP     j_sub_w_d_ea
            JMP     j_sub_l_d_ea

j_sub_b
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'S',(A2)+   ; Push S into buffer
            MOVE.B  #'U',(A2)+   ; Push U into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter 
            
            MOVE.B  #%0000,Immediate_s ; Push Size of immediate data
            
            ; SUB <ea>, Dn         
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
            
j_sub_w       
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'S',(A2)+   ; Push S into buffer
            MOVE.B  #'U',(A2)+   ; Push U into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'W',(A2)+   ; Push W into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter  
            
            MOVE.B  #%0001,Immediate_s ; Push Size of immediate data
            
            ; SUB <ea>, Dn         
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_sub_l         
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'S',(A2)+   ; Push S into buffer
            MOVE.B  #'U',(A2)+   ; Push U into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter

            MOVE.B  #%0010,Immediate_s ; Push Size of immediate data   
            
            ; SUB <ea>, Dn         
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
code011     JSR BAD_DATA    
            RTS
j_sub_b_d_ea
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'S',(A2)+   ; Push S into buffer
            MOVE.B  #'U',(A2)+   ; Push U into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter   
            
            ; SUB Dn, <ea>   
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_SOURCE      ; Push EA into source 
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into destination
                                                      
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
            
j_sub_w_d_ea       
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'S',(A2)+   ; Push S into buffer
            MOVE.B  #'U',(A2)+   ; Push U into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'W',(A2)+   ; Push W into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter   
            
            ; SUB Dn, <ea>   
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_SOURCE      ; Push EA into source 
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into destination                           
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_sub_l_d_ea         
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'S',(A2)+   ; Push S into buffer
            MOVE.B  #'U',(A2)+   ; Push U into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter   
            
            ; SUB Dn, <ea>   
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_SOURCE      ; Push EA into source 
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into destination                           
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS


*-----------------------ADD & ADDA JUMP TABLE-----------------------------
add_jmp_tab JMP     j_add_b             * ADD & ADDA jump table
            JMP     j_add_w
            JMP     j_add_l
            JMP     j_adda_w
            JMP     j_add_b_d_ea
            JMP     j_add_w_d_ea
            JMP     j_add_l_d_ea
            JMP     j_adda_l
                              
j_add_b
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter

            MOVE.B  #%0000,Immediate_s ; Push Size of immediate data   
            
            ; ADD <ea>, Dn
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
            
j_add_w       
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'W',(A2)+   ; Push W into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter 
            
            MOVE.B  #%0001,Immediate_s ; Push Size of immediate data
            
            ; ADD <ea>, Dn
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_add_l         
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter 
            
            MOVE.B  #%0010,Immediate_s ; Push Size of immediate data
            
            ; ADD <ea>, Dn
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_adda_w         
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'W',(A2)+   ; Push W into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #7,BUFFER_COUNTER ; Increase the buffer counter
            
            MOVE.B  #%0001,Immediate_s ; Push Size of immediate data
            
            
            ; ADDA <ea>, An   
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00001000,D0     ; Change mode to 001 An 
            MOVE.B  D0,EA_DEST        ; Push EA into destination        
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS   
j_add_b_d_ea
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter
            
            ; ADD Dn, <ea>
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_SOURCE      ; Push EA into source 
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into destination                            
            
                                       
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
            
j_add_w_d_ea       
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'W',(A2)+   ; Push W into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter
            
            ; ADD Dn, <ea>
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_SOURCE      ; Push EA into source 
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into destination                           
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_add_l_d_ea         
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter 
            
            ; ADD Dn, <ea>
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_SOURCE      ; Push EA into source 
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_DEST        ; Push EA into destination                           
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_adda_l
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'A',(A2)+   ; Push A into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #7,BUFFER_COUNTER ; Increase the buffer counter
            
            MOVE.B  #%0010,Immediate_s ; Push Size of immediate data
            
            ; ADDA <ea>, An   
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00001000,D0     ; Change mode to 001 An 
            MOVE.B  D0,EA_DEST        ; Push EA into destination 
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS

*-----------------------BCC JUMP TABLE-----------------------------
bcc_jmp_tab JMP   j_bcc
           JMP   code01
           JMP   j_bgt
           JMP   j_ble

j_bcc   
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #'C',(A2)+   ; Push C into buffer
            MOVE.B  #'C',(A2)+   ; Push C into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #4,BUFFER_COUNTER ; Increase the buffer counter
            
            ; BCC <label>
            MOVE.B  #%11111111,EA_SOURCE      ; Push Empty EA into source  
            MOVE.B  #%11111111,EA_DEST      ; Push Empty EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
code01      JSR BAD_DATA    
            RTS
j_bgt
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #'G',(A2)+   ; Push G into buffer
            MOVE.B  #'T',(A2)+   ; Push T into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #4,BUFFER_COUNTER ; Increase the buffer counter
            
            ; BGT <label>
            MOVE.B  #%11111111,EA_SOURCE      ; Push Empty EA into source  
            MOVE.B  #%11111111,EA_DEST      ; Push Empty EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
j_ble
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #'E',(A2)+   ; Push E into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #4,BUFFER_COUNTER ; Increase the buffer counter
            
            ; BLE <label>
            MOVE.B  #%11111111,EA_SOURCE      ; Push Empty EA into source  
            MOVE.B  #%11111111,EA_DEST      ; Push Empty EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
 
*-----------------------OPCODE JUMP TABLE-----------------------------
op_jmp_table JMP     code0000
            JMP     code0001
            JMP     code0010
            JMP     code0011
            JMP     code0100
            JMP     code0101
            JMP     code0110
            JMP     code0111
            JMP     code1000
            JMP     code1001
            JMP     code1010
            JMP     code1011
            JMP     code1100
            JMP     code1101
            JMP     code1110
            JMP     code1111
            
code0000    
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)   
            LEA     addi_subi_jum_tab,A0    * Index into the table
            CLR.L   D0                * Zero it
            MOVE.W  D7,D0             * Put instruction into D0
            MOVE.B  #4,D1             * Put shift constant into D1
            LSL.W   D1,D0             * Logical shift left 7 bits
        
            MOVE.B  #13,D1            * Put shift constant into D1
            LSR.W   D1,D0             * Logical shift left 13 bits
            
            MULU    #6,D0             * Multiply D0 by 6
                                      * Scale up 6 base on size of each jump entry
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue  
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
code0001
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP) 
            
            MOVE.B  #'M',(A2)+   ; Push M into buffer
            MOVE.B  #'O',(A2)+   ; Push O into buffer
            MOVE.B  #'V',(A2)+   ; Push V into buffer
            MOVE.B  #'E',(A2)+   ; Push E into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'B',(A2)+   ; Push B into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W  #7,BUFFER_COUNTER ; Increase the buffer counter
            
            MOVE.B  #%0000,Immediate_s ; Push Size of immediate data       
            
            * MOVE <ea>,<ea>
            MOVE.W  D7,D0             ; Put instruction into D0           
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source            
              
            MOVE.W  D7,D0             ; Put instruction into D0
            MOVE.W  D7,D1             ; Put instruction into D1
            AND.W   #$0E00,D0         ; ANDing the EA bits for register
            LSR.W   #8,D0             ; Logical shift right 8 bits
            LSR.W   #1,D0             ; Logical shift right 1 bits
            AND.W   #$01C0,D1         ; ANDing the EA bits for mode
            LSR.W   #3,D1             ; Logical shift right 8 bits
            OR.W    D1,D0             ; Swap register and mode
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVE.B  #%0000,Immediate_s ; Push Size of immediate data
                           
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
            
code0010    
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.W  D7,D0               * Put instruction into D0
            AND.W   #$01C0,D0           * Mask the mode bits
            LSR.W   #6,D0               * Logical shift right 6 bits
            
            CMPI.B  #%0001,D0           * check if the dest is a Address register
            BEQ     movea_l_bad         * If it is a MOVEA, bad data
            BNE     move_l_cont         * if it isn't a MOVEA, then it is a MOVE
movea_l_bad
            JSR     BAD_DATA
            BRA     movea_l_bad_skip        
            
move_l_cont          
                      
            MOVE.B  #'M',(A2)+   ; Push M into buffer
            MOVE.B  #'O',(A2)+   ; Push O into buffer
            MOVE.B  #'V',(A2)+   ; Push V into buffer
            MOVE.B  #'E',(A2)+   ; Push E into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'L',(A2)+   ; Push L into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #7,BUFFER_COUNTER ; Increase the buffer counter
            
            MOVE.B  #%0010,Immediate_s ; Push Size of immediate data
            
            * MOVE <ea>,<ea>        
            MOVE.W  D7,D0             ; Put instruction into D0           
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source            
              
            MOVE.W  D7,D0             ; Put instruction into D0
            MOVE.W  D7,D1             ; Put instruction into D1
            AND.W   #$0E00,D0         ; ANDing the EA bits for register
            LSR.W   #8,D0             ; Logical shift right 8 bits
            LSR.W   #1,D0             ; Logical shift right 1 bits
            AND.W   #$01C0,D1         ; ANDing the EA bits for mode
            LSR.W   #3,D1             ; Logical shift right 8 bits
            OR.W    D1,D0             ; Swap register and mode
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVE.B  #%0010,Immediate_s ; Push Size of immediate data
movea_l_bad_skip            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS

code0011    
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.W  D7,D0               * Put instruction into D0
            AND.W   #$01C0,D0           * Mask the mode bits
            LSR.W   #6,D0               * Logical shift right 6 bits
            
            CMPI.B  #%0001,D0           * check if the dest is a Address register
            BEQ     movea_w_bad         * If it is a MOVEA, bad data
            BNE     move_w_cont         * if it isn't a MOVEA, then it is a MOVE
movea_w_bad
            JSR     BAD_DATA
            BRA     movea_w_bad_skip                   
move_w_cont             
            
            MOVE.B  #'M',(A2)+   ; Push M into buffer
            MOVE.B  #'O',(A2)+   ; Push O into buffer
            MOVE.B  #'V',(A2)+   ; Push V into buffer
            MOVE.B  #'E',(A2)+   ; Push E into buffer
            MOVE.B  #'.',(A2)+   ; Push . into buffer
            MOVE.B  #'W',(A2)+   ; Push W into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #7,BUFFER_COUNTER ; Increase the buffer counter
            
            MOVE.B  #%0001,Immediate_s ; Push Size of immediate data
            
            * MOVE <ea>,<ea>
            MOVE.W  D7,D0             ; Put instruction into D0           
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source            
              
            MOVE.W  D7,D0             ; Put instruction into D0
            MOVE.W  D7,D1             ; Put instruction into D1
            AND.W   #$0E00,D0         ; ANDing the EA bits for register
            LSR.W   #8,D0             ; Logical shift right 8 bits
            LSR.W   #1,D0             ; Logical shift right 1 bits
            AND.W   #$01C0,D1         ; ANDing the EA bits for mode
            LSR.W   #3,D1             ; Logical shift right 8 bits
            OR.W    D1,D0             ; Swap register and mode
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVE.B  #%0001,Immediate_s ; Push Size of immediate data          
movea_w_bad_skip            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
            
code0100     
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            LEA     c0100_jum_tab,A0    * Index into the table
            CLR.L   D0                  * Clear
            MOVE.W  D7,D0               * Put instruction into D0
            AND.W   #$01C0,D0           * Mask the condition bits
            LSR.W   #6,D0               * Logical shift right 6 bits
            
            MULU    #6,D0
            
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue

            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS          
code0101       
            JSR BAD_DATA    
            RTS
code0110   
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            LEA     bcc_jmp_tab,A0      * Index into the table
            CLR.L   D0                  * Clear
            MOVE.W  D7,D0               * Put instruction into D0
            AND.W   #$0300,D0           * Mask the condition bits
            LSR.W   #8,D0               * Logical shift right 8 bits
            
            MULU    #6,D0
            
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue
            
            CMPI.B  #%0001,bad_data_flag * Check if bad flag is set
            BEQ     displacement_00_end    * don't check data
            
            CLR.L   D0                     
            MOVE.W  D7,D0             * Put instruction into D0
            AND.W   #$00FF,D0         * Masks the 0-8 bits DISPLACEMENT
            CMPI.B  #$00,D0           * Check if dispalcement is #$00
            BEQ     displacement_00   * branch to 16-bit displacement  

            MOVE.W  D7,D6             * Put instruction into D6
            AND.W   #$00FF,D6         * Get the 8-bit displacement
            ADDI.B  #2,D6             * From next program counter displacement 
            ADD.L   START_ADDR,D6     * Get the label address                  
            ************** (0)000 ************** 
            CLR.L   D0                          
            MOVE.W  D6,D0             * Put instruction into D0
            AND.W   #$F000,D0         * Masks to get the 4-7 bits first byte
            LSR.W   #8,D0             * Move to the right  
            LSR.W   #4,D0             * Move to the right            
               
            MULU.W  #6,D0       
            LEA     hex_table,A6 
            JSR     0(A6,D0)
                
            ************** 0(0)00 **************   
            CLR.L   D0                     
            MOVE.W  D6,D0             * Put instruction into D0
            AND.W   #$0F00,D0         * Masks to get the 0-3 bits first byte
            LSR.W   #8,D0             * Move to the right     
                            
            MULU.W  #6,D0       
            LEA     hex_table,A6 
            JSR     0(A6,D0)
            
            ************** 00(0)0 ************** 
            CLR.L   D0                          
            MOVE.W  D6,D0             * Put instruction into D0
            AND.W   #$00F0,D0         * Masks to get the 4-7 bits first byte
            LSR.W   #4,D0             * Move to the right            
               
            MULU.W  #6,D0       
            LEA     hex_table,A6 
            JSR     0(A6,D0)
                
            ************** 000(0) **************   
            CLR.L   D0                     
            MOVE.W  D6,D0             * Put instruction into D0
            AND.W   #$000F,D0         * Masks to get the 0-3 bits first byte   
                            
            MULU.W  #6,D0       
            LEA     hex_table,A6 
            JSR     0(A6,D0)
            
            ADDQ.W    #4,BUFFER_COUNTER ; Increase the buffer counter
            BRA       displacement_00_end ; skip the assignment for dispalcement = $00
          
displacement_00           
            ADDQ.L   #2,START_ADDR  ; MOVE pointer to next byte
            MOVEA.L START_ADDR, A3  ; Loads the start address to A3        
            
            ; for-loop to handle label after BCC
            MOVEQ   #0, D1          ; Start counter
            MOVEQ   #4, D2          ; End counter
            MOVE.W  (A3),D3         ; Move bcc branch tag to D3
            ADD.L   START_ADDR,D3   ; Get the Label address
            
loop_bcc    CMP.B   D1,D2           ; Compare D2 to D1
            BEQ     loop_bcc_end    ; if they are equal, then ends
            
            ROL.W   #4,D3           ; rotate to get the first char
            MOVE.W  D3,D4           ; Put into a temp storage
            AND     #$000F,D4       ; masks the first char 
            CMP.W   #$000A,D4       ; compare to check if it is a char or a number
            BGE     bcc_ALPHA       ; if it greater or equel means it is a alphabet
            BLS     bcc_NUM         ; if it less than means it is a number
loop_bcc_back 
            MOVE.B  D4,(A2)+        ; Push char in label into buffer          
            ADDQ    #1,D1           ; increase the counter
            BRA     loop_bcc        ; branch back
bcc_ALPHA
            ADD     #$37, D4        ; convert the hex to ASCII number          
            BRA     loop_bcc_back   ; back to loop    
bcc_NUM
            ADD     #$30, D4        ; convert the hex to ASCII number
            BRA     loop_bcc_back   ; back to loop
loop_bcc_end                          
            ADDQ.W    #4,BUFFER_COUNTER ; Increase the buffer counter
displacement_00_end            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS       
code0111    
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'M',(A2)+   ; Push M into buffer
            MOVE.B  #'O',(A2)+   ; Push O into buffer
            MOVE.B  #'V',(A2)+   ; Push V into buffer
            MOVE.B  #'E',(A2)+   ; Push E into buffer
            MOVE.B  #'Q',(A2)+   ; Push Q into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter
            
            * MOVEQ #<data>, Dn
            MOVE.B  #%11111111,EA_SOURCE ; Push Empty EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the EA bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 8 bit
            MOVE.B  D0,EA_DEST        ; Push EA into dest
            
            MOVEA.L START_ADDR, A3  ; Loads the start address to A3
            ADDQ    #1,A3           ; MOVE pointer to next byte
            MOVE.B  #'#',(A2)+      ; Push # into buffer
            MOVE.B  #'$',(A2)+      ; Push $ into buffer
            ; for-loop to handle data in the MOVEQ instruction
            MOVEQ   #0, D1          ; Start counter
            MOVEQ   #2, D2          ; End counter
            MOVE.B  (A3),D3         ; Move Data in instruction to D3  
            ROL.W   #8,D3           ; rotate to get the first char          
loop_moveq_data  
            CMP.B   D1,D2           ; Compare D2 to D1
            BEQ     loop_moveq_data_end  ; if they are equal, then ends
            
            ROL.W   #4,D3           ; rotate to get the first char
            MOVE.W  D3,D4           ; Put into a temp storage
            AND     #$000F,D4       ; masks the first char 
            CMP.W   #$000A,D4       ; compare to check if it is a char or a number
            BGE     moveq_ALPHA     ; if it greater or equel means it is a alphabet
            BLS     moveq_NUM       ; if it less than means it is a number
loop_moveq_data_back 
            MOVE.B  D4,(A2)+        ; Push char in label into buffer          
            ADDQ    #1,D1           ; increase the counter
            BRA     loop_moveq_data ; branch back
moveq_ALPHA
            ADD     #$37, D4        ; convert the hex to ASCII number          
            BRA     loop_moveq_data_back ; back to loop    
moveq_NUM
            ADD     #$30, D4        ; convert the hex to ASCII number
            BRA     loop_moveq_data_back ; back to loop
loop_moveq_data_end    
            MOVE.B  #',',(A2)+      ; Push , into buffer                      
            ADDQ.W    #4,BUFFER_COUNTER ; Increase the buffer counter
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS            
            
code1000    
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #'D',(A2)+   ; Push D into buffer
            MOVE.B  #'I',(A2)+   ; Push I into buffer
            MOVE.B  #'V',(A2)+   ; Push V into buffer
            MOVE.B  #'U',(A2)+   ; Push U into buffer
            MOVE.B  #' ',(A2)+   ; Push SAPCE into buffer
            ADDQ.W    #5,BUFFER_COUNTER ; Increase the buffer counter
            
            MOVE.B  #%0001,Immediate_s ; Push Size of immediate data
            
            * DIVU.W < ea > ,Dn             
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$003F,D0         ; ANDing the EA bits
            MOVE.B  D0,EA_SOURCE      ; Push EA into source
            
            MOVE.W  D7,D0             ; Put instruction into D0
            AND.W   #$0E00,D0         ; ANDing the register bits
            LSR.W   #8,D0             ; Logical shift right 8 bit
            LSR.W   #1,D0             ; Logical shift right 1 bit
            OR.B    #%00000000,D0     ; Change mode to 000 Dn 
            MOVE.B  D0,EA_DEST        ; Push EA into destination
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS

code1001    
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)     
            LEA     sub_jmp_tab,A0    * Index into the table
            CLR.L   D0                * Zero it
            MOVE.W  D7,D0             * Put instruction into D0
            MOVE.B  #7,D1             * Put shift constant into D1
            LSL.W   D1,D0             * Logical shift left 7 bits
        
            MOVE.B  #13,D1            * Put shift constant into D1
            LSR.W   D1,D0             * Logical shift right 13 bits
            
            MULU    #6,D0             * Multiply D0 by 6
                                      * Scale up 6 base on size of each jump entry
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
            
            
code1010    JSR BAD_DATA    
            RTS
code1011    
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)     
            LEA     cmp_jmp_tab,A0    * Index into the table
            CLR.L   D0                * Zero it
            MOVE.W  D7,D0             * Put instruction into D0
            MOVE.B  #7,D1             * Put shift constant into D1
            LSL.W   D1,D0             * Logical shift left 7 bits
        
            MOVE.B  #13,D1            * Put shift constant into D1
            LSR.W   D1,D0             * Logical shift left 13 bits
            
            MULU    #6,D0             * Multiply D0 by 6
                                      * Scale up 6 base on size of each jump entry
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS

code1100    
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)     
            LEA     and_jmp_tab,A0    * Index into the table
            CLR.L   D0                * Zero it
            MOVE.W  D7,D0             * Put instruction into D0
            MOVE.B  #7,D1             * Put shift constant into D1
            LSL.W   D1,D0             * Logical shift left 7 bits
        
            MOVE.B  #13,D1            * Put shift constant into D1
            LSR.W   D1,D0             * Logical shift right 13 bits
            
            MULU    #6,D0             * Multiply D0 by 6
                                      * Scale up 6 base on size of each jump entry
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
code1101    
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)     
            LEA     add_jmp_tab,A0    * Index into the table
            CLR.L   D0                * Zero it
            MOVE.W  D7,D0             * Put instruction into D0
            MOVE.B  #7,D1             * Put shift constant into D1
            LSL.W   D1,D0             * Logical shift left 7 bits
        
            MOVE.B  #13,D1            * Put shift constant into D1
            LSR.W   D1,D0             * Logical shift right 13 bits
            
            MULU    #6,D0             * Multiply D0 by 6
                                      * Scale up 6 base on size of each jump entry
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
code1110    
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)     
            LEA     reg_mem_jum_tab,A0 * Index into the table
            CLR.L   D0                * Zero it
            MOVE.W  D7,D0             * Put instruction into D0
            MOVE.B  #8,D1             * Put shift constant into D1
            LSL.W   D1,D0             * Logical shift left 7 bits
        
            MOVE.B  #14,D1            * Put shift constant into D1
            LSR.W   D1,D0             * Logical shift left 13 bits
            
            MULU    #6,D0             * Multiply D0 by 6
                                      * Scale up 6 base on size of each jump entry
            JSR     0(A0,D0)          * Jump indirect with index
                                      * JSR stores the return location into the stack
                                      * so the 68k can return back to the JSR, and continue
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS
            
code1111    JSR BAD_DATA    
            RTS

ASSIGN_EIGHT 
            MOVE.B  #%1000,D0          ; if it is, assign to 111
            RTS

BAD_DATA
            MOVEM.L     D0-D7/A0-A1/A3-A6, -(SP)
            
            MOVE.B  #%0001, bad_data_flag  ; Set bad_data_flag to 1
            MOVE.B  #'D',(A2)+   ; Push C into buffer
            MOVE.B  #'A',(A2)+   ; Push L into buffer
            MOVE.B  #'T',(A2)+   ; Push R into buffer
            MOVE.B  #'A',(A2)+   ; Push . into buffer
            MOVE.B  #' ',(A2)+   ; Push L into buffer
            MOVE.B  #'$',(A2)+   ; Push SPACE into buffer
            ADDQ.W    #6,BUFFER_COUNTER ; Increase the buffer counter
            
            MOVE.B  #%11111111,EA_SOURCE ; Push Empty EA 11111111  into source
            MOVE.B  #%11111111,EA_DEST ; Push Empty EA 11111111  into destination
            ; for-loop to handle bad data
            MOVEQ   #0, D1          ; Start counter
            MOVEQ   #4, D2          ; End counter
            MOVEA.L START_ADDR, A3  ; Loads the start address to A3
            MOVE.W  (A3),D3         ; Move Data in instruction to D3        
loop_bad_data  
            CMP.B   D1,D2           ; Compare D2 to D1
            BEQ     loop_bad_data_end  ; if they are equal, then ends
            
            ROL.W   #4,D3           ; rotate to get the first char
            MOVE.W  D3,D4           ; Put into a temp storage
            AND     #$000F,D4       ; masks the first char 
            CMP.W   #$000A,D4       ; compare to check if it is a char or a number
            BGE     bad_ALPHA     ; if it greater or equel means it is a alphabet
            BLS     bad_NUM       ; if it less than means it is a number
loop_bad_data_back 
            MOVE.B  D4,(A2)+        ; Push char in label into buffer          
            ADDQ    #1,D1           ; increase the counter
            BRA     loop_bad_data ; branch back
bad_ALPHA
            ADD     #$37, D4        ; convert the hex to ASCII number          
            BRA     loop_bad_data_back ; back to loop    
bad_NUM
            ADD     #$30, D4        ; convert the hex to ASCII number
            BRA     loop_bad_data_back ; back to loop
loop_bad_data_end                         
            ADDQ.W  #4,BUFFER_COUNTER ; Increase the buffer counter
            
            MOVEM.L     (SP)+, D0-D7/A0-A1/A3-A6
            RTS


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
