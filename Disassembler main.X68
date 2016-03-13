*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Kei Chibazakura, Bonnie Yip, Hao-Han Chao 
* Date       : 03/11/2016
* Description: Disassembler for DEMO
*-----------------------------------------------------------
       
*****************************************
*
* Disassembler code starts here
*
*****************************************
    ORG $1000
MAIN:
    INCLUDE 'io_input_subroutine.x68'
    INCLUDE 'opcode_subroutine.x68'
    INCLUDE 'ea_subroutine.x68' 
    INCLUDE 'io_output_subroutine.x68'
    INCLUDE 'variables.x68'
    INCLUDE 'strings.x68'
    SIMHALT             ; halt simulator

STOP:
    END    MAIN




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
