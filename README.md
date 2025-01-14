# Hardware Module - Digital Logic Design Project

## Project Overview

The goal of this project is to design a hardware module described in VHDL that interacts with memory to read and process a sequence of words. Each word is represented by a value between 0 and 255, with 0 being interpreted as "unspecified value." The module reads a sequence of words and processes them according to the rules outlined in the specification.

The specification for the project can be found in the file `Specification - ITA.pdf`, which provides a complete description of the system's behavior. 

## Project Description

In this project, we designed a hardware module that is capable of interacting with memory to process a sequence of words in the following manner:

1. The module reads the input sequence, which consists of `K` words, each with a value between 0 and 255.
2. Starting from the first address of the sequence (`ADD`), each word is stored every 2 bytes until the address `ADD + 2*(K-1)`.
3. Missing bytes, which contain the value `0`, are handled by copying the last valid value read at the respective address, unless the value is `0`.
4. A credibility value is added to the sequence. This value ranges from 0 to 31:
   - The credibility is set to 31 when a valid value is read.
   - If the previous value was `0`, the credibility is decremented by 1 from the previous valid credibility, but cannot go below 0.
5. If the sequence begins with a `0`, the credibility starts at 0.

## Solution Approach

The system was designed using Vivado and implemented on an Artix-7 FPGA (xc7a200tfbg484-1). The solution is based on the following components:

- **Finite State Machine (FSM):** The FSM manages the entire process of reading values from memory, handling missing values, and writing the processed values and credibility levels back to memory.
- **Memory Interfacing:** The FSM interacts with the memory by controlling the address bus and enabling read/write operations.
It is important to note that the **memory is not to be implemented** as part of this project, as it is already provided within the testbench in the file `project test bench`. The module interacts with this pre-existing memory during the simulation.

The FSM operates in several states, including reading memory, checking values, writing values, and adjusting the credibility. The process continues until all values are processed, and the final result is written back to memory.

## Hardware Platform

- **Development Environment:** Vivado
- **FPGA Model:** Artix-7 FPGA xc7a200tfbg484-1

## Detailed Solution

For a detailed explanation of the design and implementation of the solution, please refer to the file `Final Delivery - ITA.pdf`, which contains an in-depth discussion of the entire project, including VHDL code analysis, FSM design, memory interfacing, and the processing algorithm.

## Files

- **Specification - ITA.pdf:** This file contains the full project specification in Italian.
- **Final Delivery - ITA.pdf:** This file provides a comprehensive explanation of the solution in Italian.
- **project.vhd:** Contains the VHDL code used to implement the design, including the top-level module and FSM.

## How to Run

1. **Download the project files** and open them in Vivado.
2. **Load the project into Vivado** and configure the FPGA hardware (Artix-7 xc7a200tfbg484-1).
3. **Compile the VHDL code** and deploy it to the FPGA.
4. **Test the module** using the provided testbench or real-world memory interactions.

## License

This project is for educational purposes and follows the course requirements of the Digital Logic Design class. All rights to the original specification and VHDL code are owned by the author and are provided for academic use only.
