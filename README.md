# Multi-Core RISC-V Bus Arbiter

## 📌 Project Overview
This project implements a Symmetric Dual-Core RTL architecture based on the **PicoRV32** (RISC-V RV32I) processor. It focuses on solving the **Shared Memory Contention** problem at the hardware level by designing a custom **Bus Arbiter** using a Round-Robin scheduling algorithm.

This is an academic project developed for the Computer Engineering curriculum at the University of Information Technology (UIT) - VNUHCM.

## 🏗️ System Architecture
The system follows a standard Master-Interconnect-Slave topology using Native Memory Interface handshake protocols (`valid` and `ready`).
* **Masters (Core 0 & Core 1):** Two independent PicoRV32 cores fetching and executing instructions parallelly.
* **Interconnect (Bus Arbiter):** A custom module (`picorv32_arbiter`) that manages memory access requests. It resolves bus contention by stalling one core (`ready = 0`) while granting access to the other based on the `last_served` state.
* **Slave (Shared Memory):** A customized RAM module with byte-masking write capabilities and combinational read logic for zero-latency responses.

## 📂 File Structure
* `dual_core.v`: The Top-level module that wires the two PicoRV32 cores, the Bus Arbiter, and the Shared Memory together.
* `picorv32.v`: The open-source RISC-V PicoRV32 core IP.
* `picorv32_arbiter.v`: The core logic of this project. Implements the Round-Robin arbitration and contention resolution.
* `singal_port_ram.v`: Single-port shared memory module.
* `dual_port_ram.v`: Alternative dual-port memory module for comparative analysis.
* `program.hex`: Compiled machine code (hexadecimal) loaded into the RAM at initialization.
* `tb_arbiter.v`: The automated testbench for behavioral simulation. Includes hierarchical probing and console logging for debugging.

## 🚀 Simulation & Testing
The system is verified using **ModelSim**. 
To run the simulation:
1. Create a new ModelSim project and add all `.v` files.
2. Compile the design.
3. Start simulation on the `tb_arbiter` module.
4. Run the simulation (e.g., `run 5 us`).
5. Observe the Transcript console for automated logs highlighting **Instruction Fetches**, **Data Writes**, and **Bus Contention/Stall events**.
6. View the Waveform to verify the `valid`/`ready` handshake and the +4 increment of the Program Counters.

## 👨‍💻 Authors
* **Nguyễn Đình Huy** - GitHub: [@huyng5131](https://github.com/huyng5131)
* **Nguyễn Gia Huy**

Computer Engineering Students @ University of Information Technology (UIT) - VNUHCM.