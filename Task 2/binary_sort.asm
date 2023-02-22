###############################################################################
# Startup code
#
# Initializes the stack pointer, calls main, and stops simulation.
#
# Memory layout:
#   0 ... ~0x300  program
#   0x7EC       Top of stack, growing down
#   0x7FC       stdin/stdout
#
###############################################################################

.org 0x00
_start:
  ADDI sp, zero, 0x7EC
  ADDI fp, sp, 0

  # set saved registers to unique default values
  # to make checking for correct preservation easier
  LUI  s1, 0x11111
  ADDI s1, s1, 0x111
  ADD  s2, s1, s1
  ADD  s3, s2, s1
  ADD  s4, s3, s1
  ADD  s5, s4, s1
  ADD  s6, s5, s1
  ADD  s7, s6, s1
  ADD  s8, s7, s1
  ADD  s9, s8, s1
  ADD  s10, s9, s1
  ADD  s11, s10, s1

  JAL  ra, main
  EBREAK

###############################################################################
# Function: int binary_search(int* A, int low, int high, int x)
#
binary_search:
# prologue
  ADDI sp, sp, -28 
  SW   ra, 24(sp) # ra
  SW   fp, 20(sp) # s0
  ADDI fp, sp, 28 # 

  SW s11, -12(fp)
  SW s1, -16(fp)
  SW s2, -20(fp)
  SW s3, -24(fp)
  SW s4, -28(fp)

  ADDI s11, a0, 0                  # Save a0 A
  ADDI s4, a2, 0                 # low
  ADDI s3, a3, 0                 # high 
  ADDI s2, a4, 0                 # x
  ADDI s1, zero, 0                 # m

start_if_search:

  BLT s3, s4, start_else_search # if((int)s4 > (int)s3) goto start_else_search; // low <= high
  ADDI t0, zero, 1 # t0 = 1;
  ADD t1, s4, s3 # t1 = s3 + s4;
  SRL t1, t1, t0 # t1 = t1 >> t0;

  ADDI s1, t1, 0 # m = (low +high )/2

  ADDI t0, zero, 2 # t0 = 2;
  SLL t1, s1, t0 # t1 = s1 << t0;
  ADD t2, s11, t1 # t2 = s11 + t1;
  LW t3, 0(t2) # t3 = *(int*)t2; // A[m]
  BNE s2, t3, more_binary_search # if((int)s2 != (int)t3) goto more_binary_search; // x == A[m]
  ADDI a7, s1, 0 # a7 = s1;
  JAL zero, end_return 
start_else_search:
  ADDI t0, zero, 2 # t0 = 2;
  SLL t1, s4, t0 # t1 = s4 << t0;
  ADD t2, s11, t1 # t2 = s11 + t1;
  LW t2, 0(t2) # t2 = *(int*)t2; // A[low]
  BGE t2, s2, else_else_search # if((int)s2 <= (int)t2) goto else_else_search; // x > A[low]
  ADDI a7, s4, 1 # a7 = s4 + 1;
  JAL zero, end_return 
else_else_search:
  ADDI a7, s4, 0 # a7 = s4;
  JAL zero, end_return
more_binary_search:
  BGE s2, t3, binary_search_m_pus_one # if((int)s2 >= (int)t3) goto binary_search_m_pus_one; // x < A[m]
  ADDI a0, s11, 0 # a0 = s11;
  ADDI a2, s4, 0 # a2 = s4;
  ADDI t0, s1, -1 # t0 = s1 - 1;
  ADDI a3, t0, 0 # a3 = t0;
  ADDI a4, s2, 0 # a4 = s2;
  JAL ra, binary_search
  JAL zero, end_return
binary_search_m_pus_one:
  ADDI a0, s11, 0 # a0 = s11;
  ADDI t0, s1, 1 # t0 = s1 + 1;
  ADDI a2, t0, 0 # a2 = t0;
  ADDI a3, s3, 0 # a3 = s3;
  ADDI a4, s2, 0 # a4 = s2;
  JAL ra, binary_search
  JAL zero, end_return

end_return:
  # restore s registers to start values
  LW s4, -28(fp)
  LW s3, -24(fp)
  LW s2, -20(fp)
  LW s1, -16(fp)
  LW s11, -12(fp)

  # epilogue
  LW   fp, 20(sp) 
  LW   ra, 24(sp) 
  ADDI sp, sp, 28 
  JALR zero, 0(ra)                    # return;

###############################################################################
# Function: void insertion_sort(int* A, int size)
#
insertion_sort:
  # prologue
  ADDI sp, sp, -32 
  SW   ra, 28(sp) # ra
  SW   fp, 24(sp) # s0
  ADDI fp, sp, 32 # 

  SW s11, -12(fp)
  SW s1, -16(fp)
  SW s2, -20(fp)
  SW s3, -24(fp)
  SW s4, -28(fp)
  SW s5, -32(fp)
  ADDI s11, a0, 0                  # Save a0 A
  ADDI s3, zero, 0                 # i
  ADDI s2, zero, 0                 # x 
  ADDI s4, zero, 0                 # idx
  ADDI s1, zero, 1                 # j

sort_loop_begin:
  BGE s1, a1, after_sort_loop # if((int)s1 >= (int)a1) goto after_sort_loop;

  ADDI t0, zero, 2 # t0 = 2;
  SLL t0, s1, t0 # t0 = s1 << t0;
  ADD t0, s11, t0 # t0 = s11 + t0;
  LW s2, 0(t0) # s2 = *(int *)(t0);

  ADDI a0, s11, 0               # a0 = s11;     // A
  ADDI a2, x0, 0                 # a2 = 0;          // low
  ADDI a3, s1, 0                # a3 = s2;       // j high
  ADDI a4, s2, 0                # a4 = s2;       // x
  JAL ra, binary_search         # binary_search();
  ADDI s4, a7, 0                  # Save a7 idx
  ADDI s3, s1, 0                  # Save s1  // i = j
  
while_sort_loop:
  BGE s4, s3, continue_read # if((int)s3 <= (int)s4) goto continue_read; // i > idx
  
  ADDI t0, s3, 0 # t0 = s3;
  ADDI t1, zero, 2 # t1 = 2;
  SLL t2, t0, t1 # t2 = t0 << t1;
  ADD t2, s11, t2 # t2 = s11 + t2;

  ADDI t0, s3, -1       # t0 = s3 - 1;
  ADDI t1, zero, 2        # t1 = 2;
  SLL t3, t0, t1        # t3 = t0 << t1;
  ADD t3, s11, t3       # t = s11 + t0;
  LW t3 , 0(t3)         # t3 = *(int)t3
  SW t3, 0(t2)          # *(int*)t2 = t3; // could be wrong !!!!
  ADDI s3, s3, -1 # s3 = s3 - 1;

  JAL zero, while_sort_loop

continue_read:
  ADDI t0, s4, 0 # t0 = s4;
  ADDI t1, zero, 2 # t1 = 2;
  SLL t1, t0, t1 # t1 = t0 << t1;
  ADD t1, s11, t1 # t1 = s11 + t1;
  ADDI t2, s2, 0 # t2 = s2;
  SW t2, 0(t1) # *(int*)t1 = t2; // could be wrong !!!!
  ADDI s1, s1, 1 # s1 = s1 + 1;
  JAL zero, sort_loop_begin

after_sort_loop:
  # restore s registers to start values
  LW s5, -32(fp)
  LW s4, -28(fp)
  LW s3, -24(fp)
  LW s2, -20(fp)
  LW s1, -16(fp)
  LW s11, -12(fp)

  # epilogue
  LW   fp, 24(sp) 
  LW   ra, 28(sp) 
  ADDI sp, sp, 32 
  JALR zero, 0(ra)                # return;


###############################################################################
# Function: int input(int *A)
#
# Reads at most 10 values from stdin to the input array.
#
# Input args:
# a0: address for array A
# Return value:
# a0: Number of read elements
#
###############################################################################
input:
  ADDI t0, a0, 0                  # Save a0
  LW   a0, 0x7fc(zero)            # Load size
  ADDI t1, zero, 10               # Maximum
  ADDI t2, zero, 0                # Loop counter
.before_input_loop:
  BGE  t2, t1, .after_input_loop  # Maximum values reached
  BGE  t2, a0, .after_input_loop  # All values read

  # Read from stdin in store in array A
  LW   t3, 0x7fc(zero)
  SW   t3, 0(t0)
  # Pointer increments
  ADDI t0, t0, 4

  ADDI t2, t2, 1                  # Increment loop counter
  JAL  zero, .before_input_loop   # Jump to loop begin

.after_input_loop:
  JALR zero, 0(ra)

###############################################################################
# Function: void output(int size, int* A)
#
# Prints input and output values to stdout
#
# Input args:
# a0: Number of elements
# a1: address for array A
#
###############################################################################
output:
.before_output_loop:
  BEQ  a0, zero, .after_output_loop
  # Load values
  LW   t0, 0(a1)
  # Output Values to stdout
  SW   t0, 0x7fc(zero)
  # Pointer increments
  ADDI a1, a1, 4
  # Decrement loop counter
  ADDI a0, a0, -1
  # jump to beginning
  JAL  zero, .before_output_loop

.after_output_loop:
  JALR zero, 0(ra)

###############################################################################
# Function: main
#
# Calls input, insertion_sort, and output
#
###############################################################################
main:
  ADDI sp, sp, -64
  SW   ra, 60(sp)
  SW   s0, 56(sp)
  ADDI s0, sp, 64

  ADDI a0, s0, -52                # a0 = (size_t) A;
  JAL  ra, input                  # input();
  SW   a0, -56(s0)                # size = a0;

  ADDI a1, a0, 0                  # a1 = size;
  ADDI a0, s0, -52                # a0 = (size_t) A;
  JAL  ra, insertion_sort         # insertion_sort();

  LW   a0, -56(s0)                # a0 = size;
  ADDI a1, s0, -52                # a1 = (size_t) A;
  JAL  ra, output                 # output();

  ADDI a0, zero, 0                # return 0;

  LW   s0, 56(sp)
  LW   ra, 60(sp)
  ADDI sp, sp, 64
  JALR zero, 0(ra)
