# Digital Design Project: FIFO8 & Locker16 System

This repository contains the design and verification of two core digital systems: a high-speed FIFO buffer and a hierarchical 16-unit locker management system. The projects focus on structural integrity, priority-based resource allocation, and race-condition prevention.

---

## 1. FIFO8 - First-In-First-Out Buffer
The `FIFO8` is an 8-bit wide memory buffer based on a Register File architecture, utilizing read and write pointers for efficient data streaming.

### Key Features:
* **Full & Empty Management:** Integrated flags to prevent data overflow (writing to a full buffer) or underflow (reading from an empty buffer).
* **Status Indicators:** Real-time feedback signals (e.g., Half-Full, Almost-Full) for flow control.
* **Sequential Logic:** Precise pointer-based synchronization to ensure data integrity across clock cycles.



---

## 2. Locker16 System - Priority Resource Management
The `Locker16_system` manages 16 independent storage units (lockers) using a hierarchical structure: `Locker16` -> `Locker4` -> `SRFF`. It implements a **Highest-Address-First** allocation policy.

### Edge-Case Verification (Verification Robustness)
The system was subjected to rigorous stress tests in the Testbench (`Locker16_system_TB.v`) to ensure reliability under conflicting hardware commands:

#### A. Arbitration Priority (Pop vs. Push)
* **The Scenario:** A simultaneous request to occupy (`pop_valid`) and release (`push_valid`) the **same locker address** in a single clock cycle.
* **The Logic:** The system is designed with a structural **Reset-Priority**.
* **Result:** The `Push` (Reset) command overrides the `Pop` (Set) command. The locker remains free, preventing "resource hijacking" during a hand-off between users.



#### B. Saturation & Overflow Protection
* **The Scenario:** Filling the system to 100% capacity (16/16 lockers) and attempting an additional `Pop`.
* **Result:** The `pop_ready` signal correctly transitions to `0` asynchronously, blocking further requests. This ensures that existing occupied lockers are never overwritten by new requests.

#### C. Parallel Independence (Multi-Address Concurrency)
* **The Scenario:** Executing different operations on different addresses simultaneously (e.g., Releasing Locker 10 while Popping Locker 13).
* **Result:** Confirmed that the Push-Decoder and Pop-Encoder operate on independent data paths, proving the structural isolation of the hierarchical design.

#### D. Dynamic Priority Integrity
* **The Scenario:** Releasing lockers in a non-sequential order (e.g., addresses 5, 9, 13).
* **Result:** The Priority Encoder immediately updated to point to the highest available index (13), ensuring optimal resource allocation without latency.



---

## How to Run the Simulation
To verify the design using Xrun/SimVision:

1.  **Compile and Run:**
    ```bash
    xrun Locker16_system.v Locker16_system_TB.v
    ```
2.  **View Waveforms:**
    Open `waves.shm` in SimVision to analyze the `negedge clk` arbitration and pointer transitions.

---
