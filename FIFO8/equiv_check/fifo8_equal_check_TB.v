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
    
    // Outputs from Behavioral Model
    wire [63:0] data_out_b;
    wire        full_b;
    wire        empty_b;

    // Outputs from Structural Model
    wire [63:0] data_out_s;
    wire        full_s;
    wire        empty_s;

    integer i;

    // 1. Instantiate Behavioral Model (Golden Reference)
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

    // 2. Instantiate Structural Model (Design Under Test)
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

    // 3. SCOREBOARD: Continuous Equivalence Checking
    // Checks every cycle that Structural matches Behavioral perfectly
    always @(negedge clk) begin
        if (neg_reset === 1'b1) begin
            if ((data_out_b !== data_out_s) || (full_b !== full_s) || (empty_b !== empty_s)) begin
                $display(" [%t] !! MISMATCH DETECTED !!", $time);
                $display(" Expected (Beh): Data=%h, F=%b, E=%b", data_out_b, full_b, empty_b);
                $display(" Actual (Struct): Data=%h, F=%b, E=%b", data_out_s, full_s, empty_s);
                $finish;
            end else if (wr_en || re_en) begin
                $display(" [%t] MATCH: Data=%h | Flags (F,E): Beh(%b,%b) Str(%b,%b)", 
                          $time, data_out_s, full_b, empty_b, full_s, empty_s);
            end
        end
    end

    // Clock Generation
    always #5 clk = ~clk;

    // Tasks for cleaner stimulus
    task write_data(input [63:0] w_data);
        begin
            @(negedge clk);
            wr_en = 1'b1; data_in = w_data;
            @(negedge clk);
            wr_en = 1'b0;
        end
    endtask

    task read_data;
        begin
            @(negedge clk);
            re_en = 1'b1;
            @(negedge clk);
            re_en = 1'b0;
        end
    endtask

    // 4. Integrated Stimulus
    initial begin
        // Init signals
        clk = 0; wr_en = 0; re_en = 0; data_in = 64'd0; neg_reset = 1'b0;
        
        $display("========================================");
        $display("Starting Integrated Equivalence Check...");
        $display("========================================");

        // SCENARIO 1: Reset & Underflow Challenge on Empty
        #20 neg_reset = 1'b1;
        repeat(5) write_data(64'hAAAA); 
        repeat(5) read_data; // Should hit Empty flag
        
        $display("Testing Underflow: 3 Ping-Pongs on EMPTY...");
        repeat(3) begin
            @(negedge clk); wr_en = 1'b1; re_en = 1'b1; data_in = 64'hBBBB;
        end
        @(negedge clk); wr_en = 0; re_en = 0;
        
        if (empty_s !== 1'b0) $display("[PASS] Scenario 1: Empty handled, write was successful.");

        // SCENARIO 2: Overfill Challenge (Writing 9 items into FIFO8)
        $display("Testing Overfill: 9 consecutive writes...");
        for (i = 1; i <= 9; i = i + 1) write_data({60'd0, i[3:0]}); 
        
        if (full_s === 1'b1) $display("[PASS] Scenario 2: Full detected. 9th write blocked correctly.");

        // SCENARIO 3: Throughput on FULL Edge Case
        $display("Testing Full-Throughput: 4 Ping-Pongs on FULL...");
        repeat(4) begin
            @(negedge clk); wr_en = 1'b1; re_en = 1'b1; data_in = 64'hCCCC;
        end
        @(negedge clk); wr_en = 0; re_en = 0;
        
        if (full_s === 1'b1) $display("[PASS] Scenario 3: FIFO remained Full during simultaneous R/W.");

        // SCENARIO 4: Final Reset & First-Entry Recovery
        $display("Testing Reset Recovery...");
        #10 neg_reset = 1'b0; #10 neg_reset = 1'b1;
        write_data(64'h1234);
        read_data;
        
        if (data_out_s === 64'h1234) $display("[PASS] Scenario 4: Post-reset recovery matched.");

        $display("========================================");
        $display("Equivalence Verification Complete.");
        $display("========================================");
        #50 $finish;
    end

endmodule