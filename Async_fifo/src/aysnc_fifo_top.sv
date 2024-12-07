`include "async_fifo.sv"
`include "wr_pointer.sv"
`include "gray_2_bin.sv"
`include "read_pointer.sv"
`include "synchronizer.sv"
module async_fifo_top#(parameter DATA_WIDTH=8,DEPTH=128,PTR_SIZE=$clog2(DEPTH))(
  input wr_clk,
  input rd_clk,
  input wr_reset,
  input rd_reset,
  input wr_en,
  input rd_en,
//   input [PTR_SIZE:0] wr_ptr,
//   input [PTR_SIZE:0] rd_ptr,
  
  input [DATA_WIDTH-1:0] s_axis_top_data,
  input s_axis_top_valid,
  output reg s_axis_top_ready,
  output reg [DATA_WIDTH-1:0] m_axis_top_data,
  output reg m_axis_top_valid,
  input m_axis_top_ready,
  output reg full,empty
);
  
  //wire [PTR_SIZE] g_rd_ptr;         //wr_pointer && full
  wire [PTR_SIZE:0] b_wr_ptr,g_wr_ptr;// handler to fifo
  //wire w_full;						// and synchronizer
   
  //wire [PTR_SIZE] g_wr_ptr;			// read_pointer  
  wire [PTR_SIZE:0] g_rd_ptr,b_rd_ptr;// && empty handler to 
  //wire r_empty;						// to fifo and synchronizer
  
  
  wire [PTR_SIZE:0] g_wr_ptr_sync;//sync output to wr_pointer&& full handler
  wire [PTR_SIZE:0] g_rd_ptr_sync;//sync output to rd_pointer && full handler

// Instantiation of Write pointer synchronizer module
synchronizer #(
  .DEPTH(128),                 // Parameter for depth
  .PTR_SIZE($clog2(128))       // Calculated parameter for pointer size
) W_synchronizer_inst (
  .clk(wr_clk),                   // Connect clock signal
  .reset(wr_reset),               // Connect reset signal
  .data_in(g_wr_ptr),           // Connect input data
  .data_out(g_wr_ptr_sync)          // Connect output data
);

// Instantiation of Read pointer synchronizer module
synchronizer #(
  .DEPTH(128),                 // Parameter for depth
  .PTR_SIZE($clog2(128))       // Calculated parameter for pointer size
) R_synchronizer_inst (
  .clk(rd_clk),                   // Connect clock signal
  .reset(rd_reset),               // Connect reset signal
  .data_in(g_rd_ptr),           // Connect input data
  .data_out(g_rd_ptr_sync)          // Connect output data
);

// Instantiation of wr_pointer module
wr_pointer #(
  .DEPTH(128),                 // Parameter for depth
  .PTR_SIZE($clog2(128))       // Calculated parameter for pointer size
) wr_pointer_inst_1 (
  .w_clk(wr_clk),               // Connect write clock signal
  .w_reset(wr_reset),           // Connect write reset signal
  .wr_en(wr_en&&s_axis_top_ready),               // Connect write enable signal
  .g_rd_ptr(g_rd_ptr_sync),         // Connect gray-coded read pointer input
  .b_wr_ptr(b_wr_ptr),         // Connect binary write pointer output
  .g_wr_ptr(g_wr_ptr),         // Connect gray-coded write pointer output
  .full(full)                  // Connect full flag output
);

// Instantiation of read_pointer module  
read_pointer #(
  .DEPTH(128),                  // Parameter for depth
  .PTR_SIZE($clog2(128))        // Calculated parameter for pointer size
) read_pointer_inst (
  .rd_clk(rd_clk),              // Connect rd_clk signal
  .rd_reset(rd_reset),          // Connect rd_reset signal
  .rd_en(rd_en),                // Connect rd_en signal
  .g_wr_ptr(g_wr_ptr_sync),          // Connect write pointer (gray-coded input)
  .b_rd_ptr(b_rd_ptr),          // Connect binary read pointer (output)
  .g_rd_ptr(g_rd_ptr),          // Connect gray-coded read pointer (output)
  .empty(empty)                 // Connect empty flag output
);
 
  // Instantiation of async_fifo module
async_fifo #(
  .DATA_WIDTH(8),              // Parameter for data width
  .DEPTH(128),                 // Parameter for depth
  .PTR_SIZE($clog2(128))       // Calculated parameter for pointer size
) async_fifo_inst (
  .wr_clk(wr_clk),             // Connect write clock signal
  .rd_clk(rd_clk),             // Connect read clock signal
  .wr_en(wr_en),               // Connect write enable signal
  .rd_en(rd_en),               // Connect read enable signal
  .wr_reset(wr_reset),
  .rd_reset(rd_reset),
  .wr_ptr(b_wr_ptr),             // Connect write pointer input
  .rd_ptr(b_rd_ptr),             // Connect read pointer input
  .full(full),                 // Connect full flag input
  .empty(empty),               // Connect empty flag input
  .s_axis_fifo_data(s_axis_top_data), // Connect input data to FIFO
  .s_axis_fifo_valid(s_axis_top_valid), // Connect valid signal for input data
  .s_axis_fifo_ready(s_axis_top_ready), // Connect ready signal for input data
  .m_axis_fifo_data(m_axis_top_data), // Connect output data from FIFO
  .m_axis_fifo_data_valid(m_axis_top_valid), // Connect valid signal for output data
  .m_axis_fifo_data_ready(m_axis_top_ready) // Connect ready signal for output data
);

  
endmodule
