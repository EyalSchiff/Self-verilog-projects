`timescale 1ns/1ps

module Locker4_system_TB;

    // Inputs
    reg clk;
    reg pop_valid;
    reg push_valid;
    reg [1:0] push_address;

    // Outputs
    wire pop_ready;
    wire push_ready;
    wire [1:0] pop_address;

    // UUT Instance
    Locker4_system dut (
        .clk(clk),
        .pop_valid(pop_valid),
        .push_valid(push_valid),
        .push_address(push_address),
        .pop_ready(pop_ready),
        .push_ready(push_ready),
        .pop_address(pop_address)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        // --- STEP 1: INITIALIZATION ---
        clk = 0;
        pop_valid = 0;
        push_valid = 0;
        push_address = 2'b00;

        // Force internal SRFFs to 0 to prevent 'X'
        force dut.sr0.out = 0;
        force dut.sr1.out = 0;
        force dut.sr2.out = 0;
        force dut.sr3.out = 0;
        
        #15; // Initial delay
        
        release dut.sr0.out;
        release dut.sr1.out;
        release dut.sr2.out;
        release dut.sr3.out;

        // Waveform setup
        $shm_open("waves.shm");
        $shm_probe("AS");

        #10;

        // --- STEP 2: FILLING ALL LOCKERS ---
        // We change signals on the FALLING edge (negedge) 
        // to ensure stability on the next rising edge.
        repeat(4) begin
            wait(pop_ready == 1'b1); 
            @(negedge clk);          // Sync to falling edge
            pop_valid = 1;
            @(negedge clk);          // Stay high for one full cycle
            pop_valid = 0;
        end

        #30;

        // --- STEP 3: RELEASE LOCKER #2 ---
        @(negedge clk);
        push_address = 2'b10;
        push_valid = 1;
        @(negedge clk);
        push_valid = 0;

        #100;
        $display("Simulation Finished");
        $finish;
    end

endmodule