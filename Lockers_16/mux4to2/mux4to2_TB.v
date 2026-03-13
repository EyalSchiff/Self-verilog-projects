`timescale 1ns/1ps


module mux4to2_TB;
reg [1:0]sel;
reg [7:0]IN;
wire [1:0]out
;




 mux4to2 mux(
    .sel(sel),
    .IN(IN) ,

    .out(out)
);

integer i;


initial begin
sel=0;

for (i=0;i<8;i=i+1) begin
    IN[i]=0;
    if(i%3) begin
        IN[i]=1'b1;
    end
end    

#10

repeat(4) begin
     sel=sel + 1'b1;
    #10;
end

$finish;
end
endmodule