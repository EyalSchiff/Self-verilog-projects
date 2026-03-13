 `timescale 1ns/1ps
`include "../fifo8_structural/fifo8_structural.v"
`include "../fifo8_behavioral/fifo_behavioral.v"

module fifo8_equivalence_check_tb;

    // Parameters & Signals
    parameter DEPTH = 8;
    parameter PTR_WIDTH = 3;

    reg         clk;
    reg         neg_reset;
    reg         wr_en;
    reg         re_en;
    reg  [63:0] data_in;
    
    //outputs fifo_behave
    wire [63:0] data_out_b;
    wire        full_b;
    wire        empty_b;


    //outputs fifo_struct
    wire [63:0] data_out_s;
    wire        full_s;
    wire        empty_s;

    integer i;

    // Instantiate the fifo_behavioral
    fifo_behavioral #(
        .DEPTH(DEPTH),
        .PTR_WIDTH(PTR_WIDTH)
    ) fifo_b (
        .wr_en(wr_en),
        .re_en(re_en),
        .data_in(data_in),
        .neg_reset(neg_reset),
        .clk(clk),
        .data_out(data_out_b),
        .full(full_b),
        .empty(empty_b)
    );

        // Instantiate the fifo8_structural
    fifo8_structural fifo_s (
        .wr_en(wr_en),
        .re_en(re_en),
        .data_in(data_in),
        .neg_reset(neg_reset),
        .clk(clk),
        .data_out(data_out_s),
        .full(full_s),
        .empty(empty_s)
    );


////check output equivalence every cycle! scoreboard
always @(negedge clk) begin
    if (neg_reset === 1'b1) begin
        if ((data_out_b !== data_out_s) || (full_b !== full_s) || (empty_b !== empty_s)) begin
            $display(" [%t] !! MISMATCH !! Beh_Out: %h, Str_Out: %h", $time, data_out_b, data_out_s);
            $finish;
        end else if (wr_en || re_en) begin
            $display(" [%t] SCOREBOARD: Match! Data: %h | Flags (F,E): behave(%b,%b) Struct(%b,%b)", 
                      $time, data_out_s, full_b, empty_b, full_s, empty_s);
        end
    end
end


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
        if (empty_b !== 1'b1 || full_b !== 1'b0) $display("[FAIL] TEST 1: Reset state incorrect");
        else $display("[PASS] TEST 1: Reset correct (empty_b=1, full_b=0)");

        // TEST 2: Write to full_b
        for (i = 1; i <= 8; i = i + 1) write_data({60'd0, i[3:0]});
        #10;
        if (full_b !== 1'b1) $display("[FAIL] TEST 2: Not full_b after 8 writes");
        else $display("[PASS] TEST 2: FIFO full_b logic verified");

        // TEST 3: Read to empty_b
        for (i = 1; i <= 8; i = i + 1) read_data;
        #10;
        if (empty_b !== 1'b1) $display("[FAIL] TEST 3: Not empty_b after 8 reads");
        else $display("[PASS] TEST 3: FIFO empty_b logic verified");

        // TEST 4: Wrap-Around
        for (i = 0; i < 5; i = i + 1) write_data(64'hAAAA);
        for (i = 0; i < 5; i = i + 1) read_data;
        for (i = 0; i < 8; i = i + 1) write_data(64'hBBBB); // Fills it completely
        #10;
        if (full_b !== 1'b1) $display("[FAIL] TEST 4: Wrap-around logic failed");
        else $display("[PASS] TEST 4: Pointer wrap-around works perfectly");

        // TEST 5: Ping-Pong on full_b Edge Case (SMART FIFO BEHAVIOR)
        // Expectation: Smart FIFO allows write because read frees space. FIFO remains full_b.
        $display("TEST 5: Ping-Pong on full_b condition...");
        @(negedge clk);
        wr_en = 1'b1; re_en = 1'b1; data_in = 64'hCCCC;
        @(negedge clk);
        wr_en = 1'b0; re_en = 1'b0;
        #10;
        if (full_b !== 1'b1) $display("[FAIL] TEST 5: Should still be full_b (1 out, 1 in)");
        else $display("[PASS] TEST 5: Simultaneous R/W allowed on full_b. FIFO remained full_b.");

        // Clear FIFO for next test (Since it stayed full_b, we have 8 items to read!)
        for (i = 0; i < 8; i = i + 1) read_data;
        
        // TEST 6: Ping-Pong on empty_b Edge Case
        // Expectation: Blocks read to prevent garbage, allows write.
        $display("TEST 6: Ping-Pong on empty_b condition...");
        @(negedge clk);
        wr_en = 1'b1; re_en = 1'b1; data_in = 64'hDDDD;
        @(negedge clk);
        wr_en = 1'b0; re_en = 1'b0;
        #10;
        if (empty_b === 1'b1) $display("[FAIL] TEST 6: Should not be empty_b (1 written in)");
        else $display("[PASS] TEST 6: Read blocked safely, Write passed.");

        // TEST 7: Normal Ping-Pong
        // Currently 1 item in FIFO.
        $display("TEST 7: Normal Ping-Pong (Mid-level)...");
        @(negedge clk);
        wr_en = 1'b1; re_en = 1'b1; data_in = 64'hEEEE;
        @(negedge clk);
        wr_en = 1'b0; re_en = 1'b0;
        #10;
        if (empty_b === 1'b1 || full_b === 1'b1) $display("[FAIL] TEST 7: Status changed unexpectedly");
        else $display("[PASS] TEST 7: Normal Ping-Pong passed.");

        // TEST 8: Async Reset during active operation
        $display("TEST 8: Async Reset execution...");
        @(negedge clk);
        wr_en = 1'b1; data_in = 64'hFFFF;
        #2; 
        neg_reset = 1'b0; // Assert Async Reset!
        #5;
        if (empty_b !== 1'b1) $display("[FAIL] TEST 8: Async Reset failed to clear pointers immediately");
        else $display("[PASS] TEST 8: Async Reset instantly interrupted operation.");
        
        neg_reset = 1'b1;
        wr_en = 1'b0;

        $display("========================================");
        $display("Verification Complete.");
        $display("========================================");
        #50 $finish;
    end

endmodule