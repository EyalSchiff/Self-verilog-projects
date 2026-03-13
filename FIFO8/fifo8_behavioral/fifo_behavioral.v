`timescale 1ns/1ps

module fifo_behavioral #(
    parameter DEPTH = 8,
    parameter PTR_WIDTH = 3 
)(
    input  wire        wr_en,
    input  wire        re_en,
    input  wire [63:0] data_in,
    input  wire        neg_reset,
    input  wire        clk,

    output reg  [63:0] data_out,
    output wire        full,
    output wire        empty
);

// Memory and Pointers
reg [63:0]        fifo_mem [DEPTH-1:0]; //[64][8]
reg [PTR_WIDTH:0] wr_ptr;               //[4bits]
reg [PTR_WIDTH:0] re_ptr;               //[4bits]

//condition to full=1
assign full = (wr_ptr[PTR_WIDTH-1:0] == re_ptr[PTR_WIDTH-1:0]) && (wr_ptr[PTR_WIDTH] != re_ptr[PTR_WIDTH]);

//pointers equal => empty=1
assign empty = (wr_ptr == re_ptr);


always @(posedge clk or negedge neg_reset) begin
    //reset fifo
    if(!neg_reset) begin
        wr_ptr <= 4'd0;
        re_ptr <= 4'd0;
    end
    else begin
        /////////////////WRITE OP    
        //Smart FIFO: write if not full, OR if reading frees up space
        if(wr_en & (!full | re_en)) begin
            fifo_mem[wr_ptr[PTR_WIDTH-1:0]] <= data_in;
            wr_ptr <= wr_ptr + 1'b1;
        end
        
        /////////////////READ OP    
        //Strict FIFO read: read only if not empty to avoid garbage
        if(re_en & !empty) begin
            data_out <= fifo_mem[re_ptr[PTR_WIDTH-1:0]];
            //increment re_ptr 
            re_ptr <= re_ptr + 1'b1;
        end
    end
end

endmodule