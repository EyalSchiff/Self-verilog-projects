`timescale 1ns/1ps
`include "Locker_4/Locker4_system.v"
`include "mux4to2/mux4to2.v"

module Locker16_system (
    input clk,
    input wire pop_valid,
    input wire push_valid,
    input wire [3:0]push_address,

    output wire pop_ready,
    output wire push_ready,
    output wire [3:0]pop_address

);

wire [3:0]pop_bus;
wire [3:0]push_bus;
wire pop_ready3, pop_ready2, pop_ready1, pop_ready0;
wire push_ready3, push_ready2, push_ready1, push_ready0;

wire [1:0]pop_add3, pop_add2, pop_add1, pop_add0;

wire pop_enable;
wire push_enable;

//at least 1 locker is locked
assign push_ready = push_ready3 | push_ready2 | push_ready1 | push_ready0 ; 

//enable of decoders depends on ready for both pop/push
assign pop_enable = pop_valid & pop_ready;
assign push_enable = push_valid & push_ready ;


//instantiate 4 lockers4
Locker4_system locker3 (.pop_valid(pop_bus[3]), .push_valid(push_bus[3]), .push_address(push_address[1:0]) , .clk(clk), .pop_ready(pop_ready3), .push_ready(push_ready3) ,.pop_address(pop_add3));
Locker4_system locker2 (.pop_valid(pop_bus[2]), .push_valid(push_bus[2]), .push_address(push_address[1:0]) , .clk(clk), .pop_ready(pop_ready2), .push_ready(push_ready2) ,.pop_address(pop_add2));
Locker4_system locker1 (.pop_valid(pop_bus[1]), .push_valid(push_bus[1]), .push_address(push_address[1:0]) , .clk(clk), .pop_ready(pop_ready1), .push_ready(push_ready1) ,.pop_address(pop_add1));
Locker4_system locker0 (.pop_valid(pop_bus[0]), .push_valid(push_bus[0]), .push_address(push_address[1:0]) , .clk(clk), .pop_ready(pop_ready0), .push_ready(push_ready0) ,.pop_address(pop_add0));

//instantiate 2 decoders

decoder_2to4 decoder_pop32(
    .IN(pop_address[3:2]),
    .enable(pop_enable),
    .out(pop_bus)
);

decoder_2to4 decoder_push32(
    .IN(push_address[3:2]),
    .enable(push_enable),
    .out(push_bus)
);


//instantiate 1 encoder

encoder_4to2 encoder_pop32(
    .IN({pop_ready3,pop_ready2,pop_ready1,pop_ready0}),
    .valid(pop_ready),
    .out(pop_address[3:2])
);

 mux4to2 mux(
    .sel(pop_address[3:2]),
    .IN({pop_add3,pop_add2,pop_add1,pop_add0}) ,
    .out(pop_address[1:0])
);


endmodule

