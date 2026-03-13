`timescale 1ns/1ps

//TB MODULE
module decoder_2to4_TB;
reg [1:0]IN;
reg enable;
wire [3:0]out;

//connect DUT to TB enviornment
decoder_2to4 decoder(
    .IN(IN),
    .enable(enable),
    .out(out)
);

initial begin
        $shm_open("waves.shm");
        $shm_probe("AS");
    end

//monitoring the outputs
initial begin
    $display("Time\t Enable\t IN\t Out"); 
    $monitor("%t\t %b\t %b\t %b", $time, enable, IN, out);
end


//test sequence

initial begin
    IN = 2'b00;
    enable = 0;

    //check out while enable=0
    #5
    repeat(2) begin
        #10 IN[0]= ~IN[0];
        #10 IN[1]= ~IN[1];
        end

    #5 enable = 1;

    ////check out while enable=1

    repeat(2) begin
        #10 IN[0]= ~IN[0];
        #10 IN[1]= ~IN[1];
    end


$finish;
end

endmodule








