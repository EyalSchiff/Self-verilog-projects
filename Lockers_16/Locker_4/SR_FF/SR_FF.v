`timescale 1ns/1ps

module SR_FF(
    input wire s,
    input wire r,
    input wire clk,

    output reg out
);


always @(posedge clk) begin 
     if (r) begin
         out <= 1'b0;
        end
    else if (s) begin
        out <= 1'b1;
        end
    else begin
        out <= out;
       
    end
end   
endmodule        

