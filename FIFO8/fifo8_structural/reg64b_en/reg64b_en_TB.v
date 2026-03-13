`timescale 1ns/1ps

module reg64b_en_TB;
    reg [63:0] data_in;
    reg clk;
    reg enable;
    wire [63:0] data_out;

    reg64b_en reg64(
        .data_in(data_in),
        .clk(clk),
        .enable(enable),
        .data_out(data_out)
    );

    initial begin
        $shm_open("waves.shm");
        $shm_probe("AS");
    end

    // Clock Generation
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Test Sequence
    initial begin
        data_in = 64'd0;
        enable = 1'b1;
        
        #15

        repeat(2) begin
            @(negedge clk);
            data_in = data_in + 64'd10;
            enable = 1'b1;
            
            @(negedge clk);
            data_in = 64'd0;
            enable = 1'b0;

            @(negedge clk);
            data_in = data_in + 64'd200;
            enable = 1'b1;
    
        end 


        $display("Test Finished.");
        $finish;
    end

endmodule