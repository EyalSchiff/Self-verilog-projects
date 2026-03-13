`timescale 1ns/1ps

module counter(
    input wire inc,
    input wire clk,
    input wire neg_reset,

    output reg [3:0] count
);

always @(posedge clk or negedge neg_reset) begin //asynchronous neg_reset counter
    if (!neg_reset) begin
         count <= 4'b0000;
        end
    else if (inc) begin
        count <= count + 1'b1;
    end
end   
endmodule        

       

