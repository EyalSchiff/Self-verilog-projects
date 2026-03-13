`timescale 1ns/1ps

module encoder_4to2 (
    input wire [3:0]IN,

    output reg [1:0]out,
    output reg valid
);


always @(*) begin

    if(IN == 4'b0000)begin
    valid = 1'b0;
    end
    else begin
    valid = 1'b1;
    end


    if(IN[3]) begin
    out = 2'b11;
    end 
    else  if(IN[2]) begin
    out = 2'b10;
    end 
    else  if(IN[1]) begin
    out = 2'b01;
    end    
    else  if(IN[0]) begin
    out = 2'b00;
    end 



end
endmodule


