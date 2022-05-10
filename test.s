  .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb

  .global Main
  .global Init_Test
  .global origArray
  .global newArray


  .section  .text

Main:
  STMFD   SP!, {LR}

  BL      InitRam

  @
  @ Test each of the subroutines
  @

  @ Test get9x9 by getting array[7][6]
  LDR     R0, =origArray
  LDR     R1, =7
  LDR     R2, =6
  BL      get9x9
  @ R0 should be 20

  @ Test set9x9 by setting array[7][6] to 10 ...
  LDR     R0, =origArray
  LDR     R1, =7
  LDR     R2, =6
  LDR     R3, =10
  BL      set9x9
  @ array[7][6] should be 10

  @ Test average9x9 by getting the average
  @ around array[4][3] at a radius of 2
  LDR     R0, =origArray
  LDR     R1, =4
  LDR     R2, =3
  LDR     R3, =2
  BL      average9x9
  @ R0 should be 11

  @ Test blur9x9
  LDR     R0, =origArray
  LDR     R1, =newArray
  LDR     R2, =2
  BL      blur9x9

End_Main:
  LDMFD   SP!, {PC}


  .type     Init_Test, %function
Init_Test:
  BX      LR


@ InitRam subroutine
@ Utility subroutine to initialise RAM from ROM
InitRam:

  STMFD   SP!, {R4-R7,LR}
  
  LDR   R4, =init_start    @ start address of initialisation data
  LDR   R5, =init_end      @ end address of initialisation data
  LDR   R6, =data_start    @ start oddress of RAM data

whInit:
  CMP   R4, R5            @ copy word-by-word from init_start
  BHS   ewhInit           @   to init_end in ROM, storing in RAM
  LDR   R7, [R4], #4      @   starting at data_start
  STR   R7, [R6], #4      @
  B     whInit            @
ewhInit:                  @

  LDMFD   SP!, {R4-R7,PC}


  .section  .rodata

init_start:

init_origArray:
  .word  10, 10, 10, 10, 10, 10, 10, 10, 10
  .word  10, 10, 10, 10, 10, 10, 10, 10, 10
  .word  10, 12, 12, 12, 12, 12, 10, 10, 10
  .word  10, 12, 10, 10, 10, 12, 10, 10, 10
  .word  10, 12, 10,  3, 10, 12, 10, 10, 10
  .word  10, 12, 10, 10, 10, 12, 10, 10, 10
  .word  10, 12, 12, 12, 12, 12, 10, 10, 10
  .word  10, 10, 10, 10, 10, 10, 20, 10, 10
  .word  10, 10, 10, 10, 10, 10, 10, 10, 10
  .equ   size_origArray, .-init_origArray

init_end:


  .section  .data

data_start:

origArray:
  .space  size_origArray  @ enough space for a copy of origArray above

newArray:
  .space  size_origArray  @ enough space for another copy of origArray above


.end
