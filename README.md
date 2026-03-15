# Digital Design & Verification Projects

This repository showcases specialized Verilog designs, focusing on hierarchical structural implementation and modular verification methodologies.

---

## 1. Smart FIFO8 (64-bit x 8-entry)
A high-performance synchronous FIFO memory system. This project demonstrates the design and validation of a complex storage element by cross-verifying a gate-level structural model against a behavioral golden reference.

### Interface Signals:
* **Inputs:** `clk`, `neg_reset` (Active Low), `wr_en`, `re_en`, `data_in [63:0]`.
* **Outputs:** `data_out [63:0]`, `full` flag, `empty` flag.

### Architectural Breakdown:
* **Structural Hierarchy:** * **Memory Fabric:** 8x64-bit register bank (`reg64b_en`).
    * **Addressing Logic:** 3-to-8 Decoder (`decoder3to8`) for write steering.
    * **Data Retrieval:** 64-bit 8-to-1 Multiplexer (`mux8to3_64b`).
    * **Pointer Management:** Dual 3-bit **Synchronous Counters** handling wrap-around logic.
* **Equivalence Verification:** A real-time **Scoreboard** monitors both models every clock cycle, ensuring 100% bit-accurate equivalence in data and flags.

### Robust Verification & Edge-Case Coverage:
The system was validated using an optimized, high-stress testbench designed to cover the entire operational space through four critical scenarios:

1. **Underflow Protection:** Verified by challenging the `empty` state with simultaneous Read/Write (Ping-Pong) operations. The test confirmed that the system blocks invalid reads and prevents garbage data propagation.
2. **Overfill Protection (The 9th Write):** Attempted 9 consecutive writes into the 8-entry FIFO. Verified that the internal pointers remained locked and the 9th entry was ignored, preserving data integrity.
3. **Full-State Throughput:** Executed multiple simultaneous Read/Write cycles while the FIFO was at maximum capacity (`full=1`). This confirmed the system's ability to maintain peak throughput without dropping flags or corrupting pointers.
4. **Reset Recovery:** Applied an asynchronous reset during active high-load operations, verifying immediate synchronization and correct data retrieval from the first address post-reset.

![FIFO8 Verification Waveform](https://raw.githubusercontent.com/EyalSchiff/Self-verilog-projects/main/FIFO8/fifo8_structural/fifo8_struct_waveform.png)

---

## 2. Hierarchical Locker16 System
A 16-bit priority-based resource management system emphasizing modularity, pre-planned component reuse, and structural hardware constraints.

### Component-Based Hierarchy:
1. **Primitive Layer:** Custom-designed **SR Flip-Flops (SRFF)** with gate-level logic.
2. **Locker4 Module:** A 4-bit unit integrating **Decoder/Encoder** logic with state storage.
3. **Locker16 (Top Level):** A 16-bit architecture realized by interconnecting four Locker4 modules via a priority-bus.

### Design Philosophy & Structural Arbitration:
Unlike behavioral models, this structural design exhibits **State-Dependent Arbitration** during concurrent operations, a direct result of the underlying SRFF architecture.

### Critical Edge-Case Validation (Testbench Results):
The Locker16 testbench was designed to challenge the structural logic and ensure robustness in critical scenarios:

1. **State-Dependent Arbitration (Simultaneous Pop & Push):**
    * **The Scenario:** A simultaneous request to occupy (`pop_valid`) and release (`push_valid`) the same locker address.
    * **Observation:** The outcome depends on the current state of the cell.
    * **Initial Empty State:** If the locker is empty, the `Pop` operation (Set) prevails as per system definition, allowing the locker to be caught.
    * **Initial Full State:** If the locker is already full, the structural **Reset-Priority** takes over. The `Push` signal (Reset) overrides the `Pop`, resulting in the locker being released.
    * **Result:** This dual-logic ensures the system gracefully handles hand-offs based on resource availability.

2. **Saturation & Overflow Protection:**
    * **Scenario:** Filling the system to 100% capacity (16/16 lockers) and attempting an additional `Pop` allocation.
    * **Result:** The `pop_ready` signal transitions to `0` asynchronously, blocking further requests and protecting existing occupied lockers from being overwritten.

3. **Parallel Independence (Multi-Address Concurrency):**
    * **Scenario:** Executing different operations on different addresses simultaneously (e.g., Releasing Locker 10 while Popping Locker 13).
    * **Result:** Confirmed that the Push-Decoder and Pop-Encoder operate on independent data paths, proving structural isolation across the hierarchy.

4. **Dynamic Priority Integrity:**
    * **Scenario:** Releasing lockers in a non-sequential order (e.g., addresses 5, 9, 13).
    * **Result:** The Priority Encoder immediately updated `pop_address` to point to the highest available index (13) without requiring additional clock cycles.

![Locker16 Waveform](https://raw.githubusercontent.com/EyalSchiff/Self-verilog-projects/main/Lockers_16/Locker16_waveform.png)

---

## Technical Summary
* **Language:** Verilog (IEEE 1364-2005)
* **Environment:** Cadence Xcelium Design Suite
* **Verification:** Logical Equivalence Checking (LEC) & Scenario-Based Stress Testing.
* **Analysis:** Cycle-accurate waveform debugging via SimVision.
