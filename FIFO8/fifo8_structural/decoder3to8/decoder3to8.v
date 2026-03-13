`timescale 1ns/1ps

module decoder_3to8 (
    input wire enable,
    input wire [2:0]IN,

    output reg [7:0]out
);


always @(*) begin
    if(!enable) begin
    out = 8'b00000000;
    end 

    else begin
        case(IN) 
            3'b000: out = 8'b00000001;
            3'b001: out = 8'b00000010;
            3'b010: out = 8'b00000100;
            3'b011: out = 8'b00001000;
            3'b100: out = 8'b00010000;
            3'b101: out = 8'b00100000;
            3'b110: out = 8'b01000000;
            3'b111: out = 8'b10000000;

        endcase
    end
end
endmodule


