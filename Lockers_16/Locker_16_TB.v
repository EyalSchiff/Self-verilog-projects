`timescale 1ns/1ps

module Locker16_system_TB;

    reg clk;
    reg pop_valid;
    reg push_valid;
    reg [3:0] push_address;

    wire pop_ready;
    wire push_ready;
    wire [3:0] pop_address;

    // Instance of the Top Module
    Locker16_system locker16 (
        .clk(clk),
        .pop_valid(pop_valid),
        .push_valid(push_valid),
        .push_address(push_address),
        .pop_ready(pop_ready),
        .push_ready(push_ready),
        .pop_address(pop_address)
    );

    // Clock Generation
    always #5 clk = ~clk;

    initial begin
        // --- STEP 1: INITIALIZATION ---
        clk = 0;
        pop_valid = 0;
        push_valid = 0;
        push_address = 0;

        // Force all 16 SRFFs to 0 to prevent 'X' states
        // Locker 0
        force locker16.locker0.sr0.out = 0; force locker16.locker0.sr1.out = 0;
        force locker16.locker0.sr2.out = 0; force locker16.locker0.sr3.out = 0;
        // Locker 1
        force locker16.locker1.sr0.out = 0; force locker16.locker1.sr1.out = 0;
        force locker16.locker1.sr2.out = 0; force locker16.locker1.sr3.out = 0;
        // Locker 2
        force locker16.locker2.sr0.out = 0; force locker16.locker2.sr1.out = 0;
        force locker16.locker2.sr2.out = 0; force locker16.locker2.sr3.out = 0;
        // Locker 3
        force locker16.locker3.sr0.out = 0; force locker16.locker3.sr1.out = 0;
        force locker16.locker3.sr2.out = 0; force locker16.locker3.sr3.out = 0;

        #15; // Wait for stable state
        
        // Release all forced values
        release locker16.locker0.sr0.out; release locker16.locker0.sr1.out;
        release locker16.locker0.sr2.out; release locker16.locker0.sr3.out;
        release locker16.locker1.sr0.out; release locker16.locker1.sr1.out;
        release locker16.locker1.sr2.out; release locker16.locker1.sr3.out;
        release locker16.locker2.sr0.out; release locker16.locker2.sr1.out;
        release locker16.locker2.sr2.out; release locker16.locker2.sr3.out;
        release locker16.locker3.sr0.out; release locker16.locker3.sr1.out;
        release locker16.locker3.sr2.out; release locker16.locker3.sr3.out;

        // Waveform setup for Xrun
        $shm_open("waves.shm");
        $shm_probe("AS");

        #10;

        //trying to pop and push on same time to highest locker
            @(negedge clk);
            pop_valid = 1'b1;
            push_valid = 1'b1;
            push_address = 4'd15;

            @(negedge clk);
            pop_valid = 1'b0;
            push_valid = 1'b0;
            if (push_ready == 1'b0 && pop_address == 4'd15)begin
                $display("simultanious pop/push successful , pull address is %d" , pop_address);
            end
            else begin
                $display("simultanious pop/push failed , pull address is %d" , pop_address);
            end


        // --- STEP 2: FILL ALL 16 LOCKERS ---
        $display("Filling all 16 lockers...");
        repeat(16) begin
            @(negedge clk);
            pop_valid = 1;
            @(negedge clk);
            pop_valid = 0;
        end

        #50; // Pause to observe full state

        //trying to pop and push on same time to lowest locker
            @(negedge clk);
            pop_valid = 1'b1;
            push_valid = 1'b1;
            push_address = 4'd0;

            @(negedge clk);
            pop_valid = 1'b0;
            push_valid = 1'b0;
            if (pop_ready == 1'b0)begin
                $display("simultanious pop/push successful" );
            end
            else begin
                $display("simultanious pop/push failed ");
            end


        // --- RELEASE SPECIFIC LOCKERS (5, 9, 13) ---

        $display("Releasing locker 5...");
        @(negedge clk);
        push_address = 4'd5;
        push_valid = 1;
        @(negedge clk);
        push_valid = 0;

        #20;

        $display("Releasing locker 9...");
        @(negedge clk);
        push_address = 4'd9;
        push_valid = 1;
        @(negedge clk);
        push_valid = 0;

        #20;

        $display("Releasing locker 13...");
        @(negedge clk);
        push_address = 4'd13;
        push_valid = 1;
        @(negedge clk);
        push_valid = 0;

        $display("catching locker 13  and Releasing locker 10...");

        @(negedge clk);
        pop_valid = 1'b1;
        push_valid = 1'b1;
        push_address = 4'd10;
        $display("pop address is %d " ,pop_address );

        $display("catching locker 10  and Releasing locker 12...");

        @(negedge clk);
        pop_valid = 1'b1;
        push_valid = 1'b1;
        push_address = 4'd12;
        $display("pop address now is %d " ,pop_address );






        //trying to pop and push on same time to 12 locker

        @(negedge clk);
        pop_valid = 1'b1;
        push_valid = 1'b1;
        push_address = 4'd12;

        @(negedge clk);
        pop_valid = 1'b0;
        push_valid = 1'b0;
        if (pop_address == 4'd12)begin
            $display("pop and push success,pop address is still %d" , pop_address );
        end
        else begin            
            $display("pop and push fail,pop address is %d" , pop_address );
        end




        #100;
        $display("Testbench complete. Check SimVision.");
        $finish;
    end

endmodule 