`timescale 1ns/1ps

module reg64b_en(
    input wire [63:0]data_in,
    input wire clk,
    input wire enable,

    output reg [63:0]data_out
);

always @(posedge clk) begin 
    if(enable)begin
        data_out <= data_in;
        end
    else begin
        data_out <= data_out;
    end
end   
endmodule        

       

