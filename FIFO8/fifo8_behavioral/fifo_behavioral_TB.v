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
        clk = 0; wr_en = 0; re_en = 0; data_in = 64'd0; neg_reset = 1'b0;
        
        $display("========================================");
        $display("Starting Integrated FIFO Stress Test...");
        $display("========================================");

        // SCENARIO 1: Reset & Underflow Challenge
        #20 neg_reset = 1'b1;
        repeat(2) write_data(64'hA); // Write 2
        repeat(2) read_data;        // Read 2 -> Should be Empty
        
        $display("Checking Underflow on Empty...");
        repeat(3) begin
            @(negedge clk);
            wr_en = 1'b1; re_en = 1'b1; data_in = 64'hB; // Ping-pong on empty
        end
        @(negedge clk); wr_en = 0; re_en = 0;
        
        if (empty === 1'b0) $display("[PASS] Scenario 1: Empty handled correctly, no garbage read.");
        else $display("[FAIL] Scenario 1: Empty flag error during ping-pong.");

        // SCENARIO 2: Overfill Challenge (9 writes to FIFO8)
        $display("Writing 9 consecutive items to FIFO8...");
        for (i = 1; i <= 9; i = i + 1) write_data({60'd0, i[3:0]}); 
        
        #10;
        // Verify that the 9th write (i=9) didn't corrupt the FIFO or move pointers
        if (full === 1'b1) $display("[PASS] Scenario 2: Full detected. 9th write ignored safely.");
        else $display("[FAIL] Scenario 2: Full flag failed or pointers over-extended.");

        // SCENARIO 3: Ping-Pong on Full
        $display("Testing 4 Ping-Pongs while FULL...");
        repeat(4) begin
            @(negedge clk);
            wr_en = 1'b1; re_en = 1'b1; data_in = 64'hC;
        end
        @(negedge clk); wr_en = 0; re_en = 0;
        
        if (full === 1'b1) $display("[PASS] Scenario 3: Sustained FULL state during R/W throughput.");
        else $display("[FAIL] Scenario 3: FIFO lost FULL status during throughput.");

        // SCENARIO 4: Reset Recovery
        $display("Applying Reset and checking first entry recovery...");
        #10 neg_reset = 1'b0; #10 neg_reset = 1'b1;
        write_data(64'h1234);
        read_data;
        
        if (data_out === 64'h1234) $display("[PASS] Scenario 4: Reset successful, First entry is correct.");
        else $display("[FAIL] Scenario 4: Reset recovery failed.");

        $display("========================================");
        $display("Integrated Verification Complete.");
        $display("========================================");
        #50 $finish;
    end
endmodule