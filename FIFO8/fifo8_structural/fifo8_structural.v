`timescale 1ns/1ps
`include "counter/counter.v"
`include "decoder3to8/decoder3to8.v"     
`include "mux8to3_64b/mux8to3_64b.v"   
`include "reg64b_en/reg64b_en.v"

module fifo8_structural (
    input  wire        wr_en,
    input  wire        re_en,
    input  wire [63:0] data_in,
    input  wire        neg_reset,
    input  wire        clk,

    output wire  [63:0] data_out,
    output wire        full,
    output wire        empty
);

//Pointers and enables and fifo_mem_output outputs
wire [3:0] wr_ptr;                      //[4bits]
wire [3:0] re_ptr;                      //[4bits]
wire wr_full_en;                        //enable of write decoder
wire re_empty_en;                       //enable of inc read_count
wire [7:0]decoder_out;                  //decoder out connects the enable of fifo_mem_output regs
wire [63:0]fifo_mem_output[7:0];        //fifo_mem_output outputs to mux
wire [63:0]outmux;
//***************************************************************************************************

//condition to full=1, [2:0]pointers equal and [3]pointers not equal
assign full = (wr_ptr[2:0] == re_ptr[2:0]) && (wr_ptr[3] != re_ptr[3]);

//pointers equal => empty=1
assign empty = (wr_ptr == re_ptr);

//if full=1 ,cant do write op
assign wr_full_en = wr_en & (~full | re_en);

//if empty=1 ,cant do read op
assign re_empty_en = re_en & ~empty;


//***************************************************************************************************


//////counters 

//write counter
counter wr_counter(
    .inc(wr_full_en),
    .clk(clk),
    .neg_reset(neg_reset),
    .count(wr_ptr)
);

//read counter
counter re_counter(
    .inc(re_empty_en),
    .clk(clk),
    .neg_reset(neg_reset),
    .count(re_ptr)
);

//***************************************************************************************************

///////decoder to write fifo-mem[wr_ptr]
decoder_3to8 decoder (
    .enable(wr_full_en),
    .IN(wr_ptr[2:0]),
    .out(decoder_out)
    );

//***************************************************************************************************

///////mux to read fifo-mem[re_ptr]
mux8to3_64bits mux(
    .sel(re_ptr[2:0]),
    .in0(fifo_mem_output[0]), .in1(fifo_mem_output[1]), .in2(fifo_mem_output[2]), .in3(fifo_mem_output[3]), .in4(fifo_mem_output[4]), .in5(fifo_mem_output[5]), .in6(fifo_mem_output[6]), .in7(fifo_mem_output[7]),

    .out(outmux)
);

//***************************************************************************************************

/////generate 8 reg_64b_en modules

genvar i;

generate 
    for(i=0; i<8; i=i+1) begin : fifo_arr
    reg64b_en reg64b(
        .data_in(data_in),
        .clk(clk),
        .enable(decoder_out[i]),
        .data_out(fifo_mem_output[i])
    );
    end
endgenerate

//creating reg for output of the mux
reg64b_en data_out_reg(
        .data_in(outmux),
        .clk(clk),
        .enable(re_empty_en),
        .data_out(data_out)
    );


endmodule




