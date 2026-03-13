`timescale 1ns/1ps

module mux4to2 (
    input wire [1:0]sel,
    input wire [7:0]IN,

    output reg [1:0]out
);


always @(*) begin

        case(sel) 
            2'b00: out = IN[1:0];
            2'b01: out = IN[3:2];
            2'b10: out = IN[5:4];
            2'b11: out = IN[7:6];
        endcase
    end

endmodule


