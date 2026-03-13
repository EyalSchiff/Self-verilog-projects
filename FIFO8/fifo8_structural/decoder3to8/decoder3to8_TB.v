`timescale 1ns/1ps

module decoder_3to8_tb;

    // 1. Variable Declarations
    reg        enable;
    reg  [2:0] IN;
    wire [7:0] out;
    
    integer i;

    // 2. Instantiate DUT (Device Under Test)
    decoder_3to8 decoder (
        .enable(enable),
        .IN(IN),
        .out(out)
    );

    // 3. Test Stimulus
    initial begin
        $display("Starting Decoder 3-to-8 Test...");

        // Test 1: Verify Enable functionality (when disabled, output must be 0)
        enable = 1'b0;
        IN = 3'b101; // Random input to ensure output remains 0
        #10;
        $display("Time=%0t | enable=%b | IN=%b | out=%b (Expected: 00000000)", $time, enable, IN, out);
        if (out !== 8'b00000000) $display("ERROR: Decoder is not disabled properly!");

        // Test 2: Sweep all input combinations when Enable is active
        enable = 1'b1;
        
        for (i = 0; i < 8; i = i + 1) begin
            IN = i;
            #10;
            
            $display("Time=%0t | enable=%b | IN=%b | out=%b", $time, enable, IN, out);
            
            // Self-checking logic using left shift operation
            if (out !== (8'b00000001 << IN)) begin
                $display("ERROR at IN=%b! Expected: %b", IN, (8'b00000001 << IN));
            end
        end
        
        $display("-------------------------------------------------");
        $display("Test Finished Successfully.");
        $finish;
    end

    // Optional: Dump waveforms for SimVision
    initial begin
        $shm_open("waves.shm");
        $shm_probe("AS");
    end

endmodule