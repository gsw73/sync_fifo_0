module fifo
    #(
        parameter DW=24,
        parameter AW=14,
        parameter HEADROOM=6
    )
    (
        input logic clk,
        input logic rst_n,

        input logic push,
        input logic [DW-1:0] data_in,
        output logic full,
        output logic alFull,

        input logic pop,
        output logic vld,
        output logic [DW-1:0] data_out,
        output logic empty
    );

// =======================================================================
// Declarations & Parameters

    localparam CW=AW+1;
    localparam DEPTH=2**AW;

    logic [CW-1:0] cnt;
    logic [DW-1:0] rd_data;
    logic [DW-1:0] wr_data;
    logic wen;
    logic ren;
    logic [AW-1:0] wr_addr;
    logic [AW-1:0] rd_addr;

// =======================================================================
// Combinational Logic

// only pop a non-empty FIFO... note that user may assert pop without regard
// to empty.  Data should be sampled only when pop and !empty are
// asserted together i.e., pop && vld
    assign ren = pop && !empty;

    assign data_out = rd_data;

// user samples data when pop && vld are both true... user drives pop, FIFO
// logic determines vld here
    assign vld = !empty;

// =======================================================================
// Registered Logic

// Register:  wen
//
// Only push data into a non-full FIFO to avoid corrupting data already
// in FIFO.  User must, however, avoid pushing data into a full FIFO
// using the almost full signal, alFull

    always_ff @(posedge clk)
        if (!rst_n)
            wen <= 1'b0;
        else
            wen <= push && !full;

// Register:  wr_data
//
// push and data input are registered before going into memory for timing.

    always_ff @(posedge clk)
        if (!rst_n)
            wr_data <= {DW{1'b0}};
        else
            wr_data <= data_in;

// Register: cnt 
//
// Track number of elements in the FIFO.

    always_ff @(posedge clk)
        if (!rst_n)
            cnt <= {CW{1'b0}};

        else if (wen && ~ren)
            cnt <= cnt+'d1;

        else if (~wen && ren)
            cnt <= cnt-'d1;

// Register: empty
//
// Empty on the next clock when no elements and no write or one element
// and no write but a read.

    always_ff @(posedge clk)
        if (!rst_n)
            empty <= 1'b1;

        else if (cnt == 'd0 && ~wen ||
            cnt == 'd1 && ~wen && ren)
            empty <= 1'b1;

        else
            empty <= 1'b0;

// Register: alFull
//
// External logic should use alFull to determine when to stop pushing into
// the FIFO.

    always_ff @(posedge clk)
        if (!rst_n)
            alFull <= 1'b0;

        else if (cnt >= DEPTH-HEADROOM)
            alFull <= 1'b1;

        else
            alFull <= 1'b0;

// Register: full
//
// FIFO goes full if it's already full and there's no read or if it's one less
// than full and there's a write and no read.

    always_ff @(posedge clk)
        if (!rst_n)
            full <= 1'b0;

        else if (cnt == DEPTH && ~ren ||
            cnt == DEPTH-1 && wen && ~ren)
            full <= 1'b1;

        else
            full <= 1'b0;

// Register:  wr_addr
//
// Write address into memory.

    always_ff @(posedge clk)
        if (!rst_n)
            wr_addr <= {AW{1'b0}};

        else if (wen)
            wr_addr <= wr_addr+'d1;

// Register:  rd_addr
//
// Read address into memory.  Sufficient to change address with each
// read since the read data appears immediately on the memory bus i.e.,
// 0-clock read latency.

    always_ff @(posedge clk)
        if (!rst_n)
            rd_addr <= {AW{1'b0}};

        else if (ren)
            rd_addr <= rd_addr+'d1;

// =======================================================================
// Module Instantiations
    ram2p_0clk#(.DW(DW), .AW(AW)) u_ram2p_0clk(.*);

endmodule
