#include <stdio.h>
#include <stdint.h>

//-----------------------------------------------------------------------------
// RISC-V Register set
const size_t zero = 0;
size_t a0, a1;                      // fn args or return args
size_t a2, a3, a4, a5, a6, a7;      // fn args
size_t t0, t1, t2, t3, t4, t5, t6;  // temporaries
// Callee saved registers, must be stacked befor using it in a function!
size_t s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11;
//-----------------------------------------------------------------------------


// int binary_search(int* A, int low, int high, int x)
void binary_search()
{
  size_t stacekd_s0 = s11;
  size_t stacked_s1 = s1;
  size_t stacekd_s2 = s2;
  size_t stacked_s3 = s3;
  size_t stacked_s4 = s4;
  s11 = a0; // A
  s4 = a2; // low
  s3 = a3; // high
  s2 = a4; // x
  s1 = 0; // m

start_if_search:
  if((int)s4 > (int)s3) goto start_else_search; // low <= high
  t0 = 1;
  t1 = s4 + s3;
  t1 = t1 >> t0;
  
  s1 = t1; // m = (low +high )/2

  t0 = 2;
  t1 = s1 << t0;
  t2 = s11 + t1;
  t3 = *(int*)t2; // A[m]
  if((int)s2 != (int)t3) goto more_binary_search; // x == A[m]
  a7 = s1;
  goto end_return;
start_else_search:
  t0 = 2;
  t1 = s4 << t0;
  t2 = s11 + t1;
  t2 = *(int*)t2; // A[low]
  if((int)s2 <= (int)t2) goto else_else_search; // x > A[low]
  a7 = s4 + 1;
  goto end_return;
else_else_search:
  a7 = s4;
  goto end_return;
more_binary_search:
  if((int)s2 >= (int)t3) goto binary_search_m_pus_one; // x < A[m]
  a0 = s11; // A
  a2 = s4; // low
  t0 = s1 - 1;
  a3 = t0; // high
  a4 = s2; // x

  binary_search();
  goto end_return;
binary_search_m_pus_one:
  a0 = s11; // A
  t0 = s1 + 1;
  a2 = t0; // low
  a3 = s3; // high
  a4 = s2; // x
  binary_search();
  goto end_return;
end_return:
  s11 = stacekd_s0;
  s1 = stacked_s1;
  s2 = stacekd_s2;
  s3 = stacked_s3;
  s4 = stacked_s4;
  return;
}


// void insertion_sort(int* A, int size)
void insertion_sort()
{
  size_t stacked_s0 = s11;
  size_t stacked_s1 = s1;
  size_t stacked_s2 = s2;
  size_t stacked_s3 = s3;
  size_t stacked_s4 = s4;
  size_t stacked_s5 = s5;

  s11 = a0; // A
  a1; // size
  s3 = 0; // i
  s2 = 0; //x
  s4 = 0; // idx
  s1 = 1; // j
sort_loop_begin:
  if((int)s1 >= (int)a1) goto after_sort_loop; // j < size
  t0 = 2;
  t0 = s1 << t0;
  t0 = s11 + t0;
  s2 = *(int*)t0; // x = A[j]

  a0 = s11; // A
  a2 = 0; // low
  a3 = s1; // j high
  a4 = s2;  // x
  binary_search();
  s4 = a7; // idx return from binary_sort()
  s3 = s1; // i
while_sort_loop:
  if((int)s3 <= (int)s4) goto continue_read; // i > idx
  t0 = s3 ;
  t1 = 2;
  t2 = t0 << t1;
  t2 = s11 + t2; // A[i]

  t0 = s3 - 1;
  t1 = 2;
  t3 = t0 << t1;
  t3 = s11 + t3; // A[i-1]

  *(int*)t2 = *(int*)t3;
  s3 = s3 -1;
  goto while_sort_loop;
continue_read:
  t0 = s4;
  t1 = 2;
  t1 = t0 << t1;
  t1 = s11 + t1;

  t2 = s2;

  *(int*)t1 = t2;
  s1 = s1 +1; // j++
  goto sort_loop_begin;
after_sort_loop:
  s11 = stacked_s0;
  s1 = stacked_s1;
  s2 = stacked_s2;
  s3 = stacked_s3;
  s4 = stacked_s4;
  s5 = stacked_s5;
  return;

}


void input(void)
{
    // Read size
    t0 = a0; // Save a0
    a0 = fscanf(stdin, "%08x\n", (int*)&t1);
    t4 = 1;
    if (a0 == t4) goto input_continue;
    // Early exit
    a0 = 0;
    return;

input_continue:
    t4 = 1;
    t5 = 10;
input_loop_begin:
    if(t5 == 0) goto after_input_loop;
    a0 = fscanf(stdin, "%08x\n", (int*)&t2);
    if(a0 == t4) goto continue_read;
    // Exit, because read was not successful
    a0 = t1;
    return;
continue_read:
    *(int*)t0 = t2;
    // Pointer increment for next iteration
    t0 = t0 + 4;
    // Loop counter decrement
    t5 = t5 - 1;
    goto input_loop_begin;

after_input_loop:
    a0 = t1;
    return;
}


void output(void)
{
before_output_loop:
    if (a0 == 0) goto after_output_loop;

    fprintf(stdout, "%08x\n", (unsigned int)*(int*)a1);

    // Pointer increment for next iteration
    a1 = a1 + 4;
    // Decrement loop counter
    a0 = a0 - 1;
    goto before_output_loop;

after_output_loop:
    return;
}


int main(void)
{
  int A[10];
  int size;

  a0 = (size_t) A;
  input();
  size = a0;

  a0 = (size_t) A;
  a1 = size;
  // void insertion_sort(int* A, int size)
  insertion_sort();

  a0 = size;
  a1 = (size_t) A;
  output();

  return 0;
}

