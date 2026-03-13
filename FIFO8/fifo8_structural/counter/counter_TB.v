`timescale 1ns/1ps
//`include "counter.v"


// Testbench for the counter module
module counter_TB;
    reg inc;
    reg clk;
    reg neg_reset;

    wire [3:0] count;

//instantiate the counter module
counter counts(
    .inc(inc),
    .clk(clk),
    .neg_reset(neg_reset),
    .count(count)
);


//initial block to open the waveform file and set up the probe
initial begin
    $shm_open("waves.shm");
    $shm_probe("AS");
end

// Clock generation
initial clk = 0;
always #5 clk = ~clk;

// Test sequence
initial begin
    inc =0;
    neg_reset=0;
    #10 neg_reset=1;

repeat(4) begin
    #5 inc = ~inc;
    #101
    $display("Count: %d", count);
       $display("the time is: %t", $time);

end 
neg_reset=0;
#25
inc=1;


// Finish the simulation after some time
#10 $display("simulation finished");
$finish;
end

endmodule