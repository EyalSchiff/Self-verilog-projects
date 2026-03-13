`timescale 1ns/1ps

//TB MODULE
module encoder_4to2_TB;
reg [3:0]IN;
wire [1:0]out;
wire valid;

//connect DUT to TB enviornment
encoder_4to2 encoder(
    .IN(IN),
    .valid(valid),
    .out(out)
);

initial begin
        $shm_open("waves.shm");
        $shm_probe("AS");
    end

//monitoring the outputs
initial begin
    $display("Time\t IN\t Out"); 
    $monitor("%t\t %b\t %b", $time, IN, out);
end


//test sequence

initial begin
    IN = 4'b0000;

    //check out while enable=0
    #5
    repeat(16) begin
        #10 IN=IN + 1'b1;
        end


$finish;
end

endmodule








