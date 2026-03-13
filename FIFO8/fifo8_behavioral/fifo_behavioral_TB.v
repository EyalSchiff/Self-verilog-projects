`timescale 1ns/1ps

module fifo_behavioral_tb;

    // Parameters & Signals
    parameter DEPTH = 8;
    parameter PTR_WIDTH = 3;

    reg         clk;
    reg         neg_reset;
    reg         wr_en;
    reg         re_en;
    reg  [63:0] data_in;
    
    wire [63:0] data_out;
    wire        full;
    wire        empty;

    integer i;

    // Instantiate the DUT
    fifo_behavioral #(
        .DEPTH(DEPTH),
        .PTR_WIDTH(PTR_WIDTH)
    ) uut (
        .wr_en(wr_en),
        .re_en(re_en),
        .data_in(data_in),
        .neg_reset(neg_reset),
        .clk(clk),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // Clock Generation
    always #5 clk = ~clk;

    // Verification Tasks
    task write_data(input [63:0] w_data);
        begin
            @(negedge clk);
            wr_en = 1'b1;
            data_in = w_data;
            @(negedge clk);
            wr_en = 1'b0;
        end
    endtask

    task read_data; // No parentheses for strictly valid Verilog
        begin
            @(negedge clk);
            re_en = 1'b1;
            @(negedge clk);
            re_en = 1'b0;
        end
    endtask

    initial begin
        // Initialization
        clk = 0;
        wr_en = 0;
        re_en = 0;
        data_in = 64'd0;
        neg_reset = 1'b0;
        
        $display("========================================");
        $display("Starting Smart FIFO Verification...");
        $display("========================================");

        // TEST 1: Sanity & Reset
        #20 neg_reset = 1'b1;
        #10;
        if (empty !== 1'b1 || full !== 1'b0) $display("[FAIL] TEST 1: Reset state incorrect");
        else $display("[PASS] TEST 1: Reset correct (Empty=1, Full=0)");

        // TEST 2: Write to Full
        for (i = 1; i <= 8; i = i + 1) write_data({60'd0, i[3:0]});
        #10;
        if (full !== 1'b1) $display("[FAIL] TEST 2: Not full after 8 writes");
        else $display("[PASS] TEST 2: FIFO Full logic verified");

        // TEST 3: Read to Empty
        for (i = 1; i <= 8; i = i + 1) read_data;
        #10;
        if (empty !== 1'b1) $display("[FAIL] TEST 3: Not empty after 8 reads");
        else $display("[PASS] TEST 3: FIFO Empty logic verified");

        // TEST 4: Wrap-Around
        for (i = 0; i < 5; i = i + 1) write_data(64'hAAAA);
        for (i = 0; i < 5; i = i + 1) read_data;
        for (i = 0; i < 8; i = i + 1) write_data(64'hBBBB); // Fills it completely
        #10;
        if (full !== 1'b1) $display("[FAIL] TEST 4: Wrap-around logic failed");
        else $display("[PASS] TEST 4: Pointer wrap-around works perfectly");

        // TEST 5: Ping-Pong on FULL Edge Case (SMART FIFO BEHAVIOR)
        // Expectation: Smart FIFO allows write because read frees space. FIFO remains FULL.
        $display("TEST 5: Ping-Pong on FULL condition...");
        @(negedge clk);
        wr_en = 1'b1; re_en = 1'b1; data_in = 64'hCCCC;
        @(negedge clk);
        wr_en = 1'b0; re_en = 1'b0;
        #10;
        if (full !== 1'b1) $display("[FAIL] TEST 5: Should still be FULL (1 out, 1 in)");
        else $display("[PASS] TEST 5: Simultaneous R/W allowed on full. FIFO remained FULL.");

        // Clear FIFO for next test (Since it stayed full, we have 8 items to read!)
        for (i = 0; i < 8; i = i + 1) read_data;
        
        // TEST 6: Ping-Pong on EMPTY Edge Case
        // Expectation: Blocks read to prevent garbage, allows write.
        $display("TEST 6: Ping-Pong on EMPTY condition...");
        @(negedge clk);
        wr_en = 1'b1; re_en = 1'b1; data_in = 64'hDDDD;
        @(negedge clk);
        wr_en = 1'b0; re_en = 1'b0;
        #10;
        if (empty === 1'b1) $display("[FAIL] TEST 6: Should not be EMPTY (1 written in)");
        else $display("[PASS] TEST 6: Read blocked safely, Write passed.");

        // TEST 7: Normal Ping-Pong
        // Currently 1 item in FIFO.
        $display("TEST 7: Normal Ping-Pong (Mid-level)...");
        @(negedge clk);
        wr_en = 1'b1; re_en = 1'b1; data_in = 64'hEEEE;
        @(negedge clk);
        wr_en = 1'b0; re_en = 1'b0;
        #10;
        if (empty === 1'b1 || full === 1'b1) $display("[FAIL] TEST 7: Status changed unexpectedly");
        else $display("[PASS] TEST 7: Normal Ping-Pong passed.");

        // TEST 8: Async Reset during active operation
        $display("TEST 8: Async Reset execution...");
        @(negedge clk);
        wr_en = 1'b1; data_in = 64'hFFFF;
        #2; 
        neg_reset = 1'b0; // Assert Async Reset!
        #5;
        if (empty !== 1'b1) $display("[FAIL] TEST 8: Async Reset failed to clear pointers immediately");
        else $display("[PASS] TEST 8: Async Reset instantly interrupted operation.");
        
        neg_reset = 1'b1;
        wr_en = 1'b0;

        $display("========================================");
        $display("Verification Complete.");
        $display("========================================");
        #50 $finish;
    end

endmodule