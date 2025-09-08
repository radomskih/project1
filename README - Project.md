# Project 1

Team Members: Helen Radomski, Patriel Stapleton

# Work Unit Determination
We ran the program with N = 1_000_00 and k=4 for different values of work unit.
We increased the value with a left shift for 1, 10, 100 ... 1_000_000.
Run time decreased work unit = 1_000_000. The run times were as follows:
  @ 1 - Run Time: 5+ minutes (terminated program)
  @10 - Run Time: 320s
  @100 - Run time: 4.03s
  @1000 - Run Time: 0.14s
  @10_000 - Run Time: 0.107s
  @100_000 - Run Time: 0.122s
  @1_000_000 - Run Time:  0.281s

We then ran @10_000 and @100_000 times with avgerage run time being 0.112s and 0.125s respectively.
Because of this we decided that 10_000 was the best work unit.
The full list of intial runtimes are at the end of the document.

# Result for project1 1_000_000 4
PS C:\Users\triel\OneDrive\Documents\GitHub\dist-sys-project-1\project1> gleam run ./project1 1000000 4
  Compiling project1
   Compiled in 0.76s
    Running project1.main

Overall run time: 0.1048576 

We didn't get any results which is true by the sum of squares rules. 
There's no four consectuive intgers whose sum of squares is a perfect square. 

# Real Time and CPU Time

The following results was for n = 1_000_000, k = 4, and work unit = 10_000. 
We did so 10 more times to get an average run time of 0.1232 and 1s CPU time of 1s.
Result: 1s/0.1232 = 8.117
The computer we tested on had 8 virtual cores which means the program leveraged all 8 cores.

# Largest Problem Solved
project1 116_704_645 4 with unit size at 10_000
Run Time: 23.06s
CPU Time: 89s
Ratio: 4.25 
Which means all 4 physical cores were being utlized