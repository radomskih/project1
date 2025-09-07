# Project 1

Team Members: Helen Radomski, Patriel Stapleton

# Work Unit Determination
We ran the program with N = 1_000_00 and k=4 for different values of work unit.
We increased the value with a left shift for 1, 10, 100 ... 1_000_000.
Run time decreased work unit = 1_000_000. The run times were as follows:
  @10_000 = 0.107s
  @100_000 = 0.122s
  @1_000_000 = 0.281s
We then ran @10_000 and @100_000 times with avgerage run time being 0.112s and 0.125s respectively.
Because of this we decided that 10_000 was the best work unit.
The full list of intial runtimes and CPU times are at the end of the document.

# Result for project1 1_000_000 4
PS C:\Users\triel\OneDrive\Documents\GitHub\dist-sys-project-1\project1> gleam run ./project1 1000000 4
  Compiling project1
   Compiled in 0.76s
    Running project1.main

total subproblems: 1000000
subproblems per worker: 10000
number of workers: 100
Overall run time: 0.1048576 

We didn't get any results which is true by the sum of squares rules. 
There's no four consectuive intgers whose sum of squares is a perfect square. 

# Real Time and CPU Time

The following results was for n = 1_000_000, k = 4, and work unit = 10_000 from our initial run.
  Run Time: 0.107s
  CPU Time:
    ProcessName    Id        CPU
    -----------    --        ---
    gleam       18404 984.609375
    gleam        2244    0.03125

We ran the program 10 more times to get an average run time of 0.9325s and CPU time of 990.375s.
Result: 
990.375s/0.9325s = 1,062

# Largest Problem Solved
project1 116_704_645 4 with unit size at 10_000
Run Time: 23.31s
CPU Time: 990.4s

# Results for work unit testing
@ 1 
  Run Time: 5+ minutes (terminated program)
  CPU Time: 
    ProcessName    Id        CPU
    -----------    --        ---
    gleam       18404 983.828125
    gleam        2244    0.03125

@10
  Run Time: 320s
  CPU Time:
    ProcessName    Id        CPU
    -----------    --        ---
    gleam       18404 984.015625
    gleam        2244    0.03125
@100
  Run time: 4.03s
  CPU Time:
    ProcessName    Id       CPU
    -----------    --       ---
    gleam       18404 984.15625
    gleam        2244   0.03125
@1000
  Run Time: 0.14s
  CPU Time:
    ProcessName    Id        CPU
    -----------    --        ---
    gleam       18404 984.453125
    gleam        2244    0.03125 
@10_000
  Run Time: 0.107s
  CPU Time:
    ProcessName    Id        CPU
    -----------    --        ---
    gleam       18404 984.609375
    gleam        2244    0.03125
@100_000
  Run Time: 0.122s
  CPU Time:
    ProcessName    Id       CPU
    -----------    --       ---
    gleam       18404 984.78125
    gleam        2244   0.03125
@1_000_000
  Run Time:  0.281s
  CPU Time:
    ProcessName    Id        CPU
    -----------    --        ---
    gleam       18404 984.984375
    gleam        2244    0.03125


