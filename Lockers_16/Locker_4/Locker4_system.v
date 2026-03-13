`timescale 1ns/1ps
`include "Locker_4/SR_FF/SR_FF.v"
`include "Locker_4/decoder/decoder_2to4.v"
`include "Locker_4/encoder/encoder_4to2.v"

module Locker4_system (
    input clk,
    input wire pop_valid,
    input wire push_valid,
    input wire [1:0]push_address,

    output wire pop_ready,
    output wire push_ready,
    output wire [1:0]pop_address

);

wire [3:0]pop_bus;
wire [3:0]push_bus;
wire sr_out3, sr_out2, sr_out1, sr_out0;
wire pop_enable;
wire push_enable;

//at least 1 locker is locked
assign push_ready = sr_out3 | sr_out2 | sr_out1 | sr_out0 ; 

//enable of decoders depends on ready for both pop/push
assign pop_enable = pop_valid & pop_ready;
assign push_enable = push_valid & push_ready;


//instantiate 4 lockers
SR_FF sr3(.s(pop_bus[3]), .r(push_bus[3]), .clk(clk), .out(sr_out3));
SR_FF sr2(.s(pop_bus[2]), .r(push_bus[2]), .clk(clk), .out(sr_out2));
SR_FF sr1(.s(pop_bus[1]), .r(push_bus[1]), .clk(clk), .out(sr_out1));
SR_FF sr0(.s(pop_bus[0]), .r(push_bus[0]), .clk(clk), .out(sr_out0));

//instantiate 2 decoders

decoder_2to4 decoder_pop(
    .IN(pop_address),
    .enable(pop_enable),
    .out(pop_bus)
);

decoder_2to4 decoder_push(
    .IN(push_address),
    .enable(push_enable),
    .out(push_bus)
);


//instantiate 1 encoder

encoder_4to2 encoder_pop(
    .IN({~sr_out3,~sr_out2,~sr_out1,~sr_out0}),
    .valid(pop_ready),
    .out(pop_address)
);


endmodule

