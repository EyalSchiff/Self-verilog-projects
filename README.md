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
    * **Pointer Management:** Dual 4-bit **Synchronous Counters** handling wrap-around logic.
* **Equivalence Verification:** A real-time **Scoreboard** monitors both models every clock cycle, ensuring 100% bit-accurate equivalence in data and flags.

### Robust Verification & Edge-Case Coverage:
The system was validated using an optimized, high-stress testbench designed to cover the entire operational space through four critical scenarios:

1. **Underflow Protection:** Verified by challenging the `empty` state with simultaneous Read/Write (Ping-Pong) operations. The test confirmed that the system blocks invalid reads and prevents garbage data propagation.
2. **Overfill Protection (The 9th Write):** Attempted 9 consecutive writes into the 8-entry FIFO. Verified that the internal pointers remained locked and the 9th entry was ignored, preserving data integrity.
3. **Full-State Throughput:** Executed multiple simultaneous Read/Write cycles while the FIFO was at maximum capacity (`full=1`). This confirmed the system's ability to maintain peak throughput without dropping flags or corrupting pointers.
4. **Reset Recovery:** Applied an asynchronous reset during active high-load operations, verifying immediate synchronization and correct data retrieval from the first address post-reset.

---

## 2. Hierarchical Locker16 System
A 16-bit priority-based resource management system emphasizing modularity, pre-planned component reuse, and structural hardware constraints.

### Component-Based Hierarchy:
1. **Primitive Layer:** Custom-designed **SR Flip-Flops (SRFF)** with gate-level logic.
2. **Locker4 Module:** A 4-bit unit integrating **Decoder/Encoder** logic with state storage.
3. **Locker16 (Top Level):** A 16-bit architecture realized by interconnecting four Locker4 modules via a priority-bus.



### Design Philosophy & Structural Arbitration:
Unlike behavioral models, this design mimics real-world hardware constraints using a **Reset-Priority** mechanism. The verification process focused on high-concurrency scenarios to ensure system stability.

### Critical Edge-Case Validation:
The system was verified against several critical hardware scenarios to ensure no data "collision" or unintended overrides occur:

* **Simultaneous Pop & Push (Arbitration):**
    * **The Scenario:** Triggering `pop_valid` (occupy) and `push_valid` (release) for the **same locker address** in a single clock cycle.
    * **The Priority:** Due to the structural **Reset-Priority** design of the SRFF, the `Push` signal (Reset) overrides the `Pop` (Set). 
    * **Result:** The locker remains free, preventing "Resource Hijacking" during a hand-off between users.
* **Saturation & Overflow Protection:**
    * **The Scenario:** Filling the system to 100% capacity (16/16) and attempting an additional `Pop`.
    * **Result:** The `pop_ready` signal transitions to `0` asynchronously, blocking any further allocations and protecting existing data from being overwritten.
* **Parallel Independence (Multi-Address Concurrency):**
    * **The Scenario:** Releasing one locker (e.g., Addr 10) while simultaneously popping another (e.g., Addr 13).
    * **Result:** Confirmed that the Push-Decoder and Pop-Encoder operate on independent data paths, proving structural isolation across the hierarchy.
* **Dynamic Priority Integrity:**
    * **The Scenario:** Releasing lockers in a non-sequential order (e.g., addresses 5, 9, 13).
    * **Result:** The Priority Encoder immediately updated `pop_address` to point to the highest available index (13) without latency.



---

## Technical Summary
* **Language:** Verilog (IEEE 1364-2005)
* **Environment:** Cadence Xcelium Design Suite
* **Verification:** Logical Equivalence Checking (LEC) & Scenario-Based Stress Testing.
* **Analysis:** Cycle-accurate waveform debugging via SimVision.
