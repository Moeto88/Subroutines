  .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb
  
  .global  get9x9
  .global  set9x9
  .global  average9x9
  .global  blur9x9


@ get9x9 subroutine
@ Retrieve the element at row r, column c of a 9x9 2D array
@   of word-size values stored using row-major ordering.
@
@ Parameters:
@   R0: address - array start address
@   R1: r - row number
@   R2: c - column number
@
@ Return:
@   R0: element at row r, column c
get9x9:
  PUSH    {R4-R5,LR}                      @ save registers

  @
  @ your implementation goes here
  @
  LDR     R4, =9                          @ constant = 9
  MUL     R5, R1, R4                      @ index = r * constant
  ADD     R5, R5, R2                      @ index = index + c
  LDR     R0, [R0, R5, LSL #2]            @ result = word[address + (index * 4)]

  POP     {R4-R5,PC}                      @ restore registers



@ set9x9 subroutine
@ Set the value of the element at row r, column c of a 9x9
@   2D array of word-size values stored using row-major
@   ordering.
@
@ Parameters:
@   R0: address - array start address
@   R1: r - row number
@   R2: c - column number
@   R3: value - new word-size value for array[r][c]
@
@ Return:
@   none
set9x9:
  PUSH    {R4-R5,LR}                      @ save registers

  @
  @ your implementation goes here
  @
  LDR     R4, =9                          @ constant = 9
  MUL     R5, R1, R4                      @ index = r * constant
  ADD     R5, R5, R2                      @ index = index + c
  STR     R3, [R0, R5, LSL #2]            @ word[address + (index * 4)] = value;

  POP     {R4-R5,PC}                      @ restore registers



@ average9x9 subroutine
@ Calculate the average value of the elements up to a distance of
@   n rows and n columns from the element at row r, column c in
@   a 9x9 2D array of word-size values. The average should include
@   the element at row r, column c.
@
@ Parameters:
@   R0: address - array start address
@   R1: r - row number
@   R2: c - column number
@   R3: n - element radius
@
@ Return:
@   R0: average value of elements
average9x9:
  PUSH    {R4-R9,LR}                      @ save registers

  @
  @ your implementation goes here
  @
  SUB     R1, R1, R3        @ r = r - n
  SUB     R2, R2, R3        @ c = c - n
  MOV     R9, #2            @ const = 2
  MUL     R3, R3, R9        @ n = n * temp
  ADD     R3, R3, #1        @ n++
  MOV     R6, R3            @ temp1 = n
  MOV     R4, R3            @ temp2 = n
  MOV     R8, #0            @ total = 0

while:
  CMP     R4, #0            @ while(temp2 != 0)
  BEQ     endWhile          @ {
  CMP     R6, #0            @   if(temp1 != 0)
  BEQ     nextRow           @   {
  BL      get9x9            @    invoke get9x9;
  ADD     R8, R8, R0        @    total = total + result
  LDR     R0, =origArray    @    address = origArray
  ADD     R2, R2, #1        @    c++
  SUB     R6, R6, #1        @    temp--
  B       while             @   }
nextRow:                    @   else {
  MOV     R6, R3            @          temp1 = n
  ADD     R1, R1, #1        @          r++
  SUB     R4, R4, #1        @          temp2--
  SUB     R2, R2, R3        @          c = c - n }
  B       while             @ }

endWhile:  
  MUL     R3, R3, R3        @ n = n * n
  UDIV    R0, R8, R3        @ result = total / n


  POP     {R4-R9,PC}                      @ restore registers


@ blur9x9 subroutine
@ Create a new 9x9 2D array in memory where each element of the new
@ array is the average value the elements, up to a distance of n
@ rows and n columns, surrounding the corresponding element in an
@ original array, also stored in memory.
@
@ Parameters:
@   R0: addressA - start address of original array
@   R1: addressB - start address of new array
@   R2: n - radius
@
@ Return:
@   none
blur9x9:
  PUSH    {R4-R8,LR}                      @ save registers

  @
  @ your implementation goes here
  @
  LDR     R4, =0            @ row = 0
  LDR     R5, =0            @ column = 0
  MOV     R8, R2            @ temp1 = n
  MOV     R3, R2            @ temp2 = n
  MOV     R1, R4            @ r = row
  MOV     R2, R5            @ c = column
  LDR     R6, =9            @ const = 9

while2:
  CMP     R1, R6            @ while(r != const)
  BEQ     endWhile2         @ {
  CMP     R2, R6            @   if(c != const)
  BEQ     nextRow2          @   {
  BL      average9x9        @    invoke average9x9
  MOV     R3, R0            @    value = result
  LDR     R0, =newArray     @    address = newArray
  MOV     R1, R4            @    r = row   
  MOV     R2, R5            @    c = column
  BL      set9x9            @    invoke set9x9
  LDR     R0, =origArray    @    address = origArray
  MOV     R3, R8            @    temp2 = temp1
  MOV     R1, R4            @    r = row    
  ADD     R5, R5, #1        @    column++
  MOV     R2, R5            @    c = column
  B       while2            @   }

nextRow2:                   @   else {
  MOV     R2, #0            @         c = 0
  MOV     R5, #0            @         column = 0
  ADD     R4, R4, #1        @         row++
  MOV     R1, R4            @         r = row
  B       while2            @ }


endWhile2:


  POP     {R4-R8,PC}                      @ restore registers

.end