`timescale 1ns/1ps
//`include "SR_FF.v"


// Testbench for the counter module
module SR_FF_TB;
    reg s;
    reg clk;
    reg r;

    wire out;

//instantiate the counter module
SR_FF sr_ff(
    .s(s),
    .clk(clk),
    .r(r),
    .out(out)
);


//initial block to open the waveform file and set up the probe
initial begin
    $shm_open("waves.shm");
    $shm_probe("AS");
end

// Clock generation
initial clk = 0;
always #5 clk = ~clk;

//test sequence
initial begin
r=1;
s=1;
//out=0


//
#15
s = 0;
#27
r = 0;
#23

s = 1;
#24
s = 0;
#22
r=1;
#17
r=0;

//finish simulation
#10 $display("simulation finished");
$finish;
end

endmodule



