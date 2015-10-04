module ram2p_0clk
#(
    parameter DW = 18,
    parameter AW = 7
)
(
    input logic clk,
    input logic wen,
    input logic [ AW - 1:0 ] wr_addr,
    input logic [ DW - 1:0 ] wr_data,
  
    input logic [ AW - 1:0 ] rd_addr,
    output logic [ DW - 1:0 ] rd_data
);

// =======================================================================
// Declarations

localparam DEPTH = 2**AW;
logic [ DW - 1:0 ] mem [ DEPTH ];

// =======================================================================
// Combinational Logic

always_comb
  	rd_data = mem[ rd_addr ];

// =======================================================================
// Registered Logic

always @( posedge clk )
    if ( wen )
      mem[ wr_addr ] <= wr_data;
  
endmodule;
