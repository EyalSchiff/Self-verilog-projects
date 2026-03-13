`timescale 1ns/1ps


module mux8to3_64bits_TB;
    reg [2:0]sel;
    reg [63:0] in0,in1,in2,in3,in4,in5,in6,in7;

    wire [63:0]out;

integer i;


mux8to3_64bits mux(
    .sel(sel),
    .in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7),

    .out(out)
);


initial begin
        $shm_open("waves.shm");
        $shm_probe("AS");
    end


initial begin
        // אתחול ערכים ייחודיים לכל כניסה (כדי שיהיה קל לזהות בעין ובקוד)
        in0 = 64'h1111_1111_1111_1111;
        in1 = 64'h2222_2222_2222_2222;
        in2 = 64'h3333_3333_3333_3333;
        in3 = 64'h4444_4444_4444_4444;
        in4 = 64'h5555_5555_5555_5555;
        in5 = 64'h6666_6666_6666_6666;
        in6 = 64'h7777_7777_7777_7777;
        in7 = 64'h8888_8888_8888_8888;
        
        sel = 3'd1;
        #15

        $display("Starting MUX 8-to-1 Test...");

        // לולאה שעוברת על כל אפשרויות ה-Select
        for (i = 0; i < 8; i = i + 1) begin
            sel = i;
            #10
            $display("Time=%0t | sel=%d | out=%h", $time, sel, out);
            
            case (sel)
                3'd0: if (out !== in0) $display("ERROR at sel=0");
                3'd1: if (out !== in1) $display("ERROR at sel=1");
                3'd2: if (out !== in2) $display("ERROR at sel=2");
                3'd3: if (out !== in3) $display("ERROR at sel=3");
                3'd4: if (out !== in4) $display("ERROR at sel=4");
                3'd5: if (out !== in5) $display("ERROR at sel=5");
                3'd6: if (out !== in6) $display("ERROR at sel=6");
                3'd7: if (out !== in7) $display("ERROR at sel=7");
            endcase
        end


        $display("Test Finished.");
        $finish;
    end


endmodule