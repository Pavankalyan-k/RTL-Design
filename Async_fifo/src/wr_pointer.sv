module wr_pointer#(parameter DEPTH=128,PTR_SIZE=$clog2(DEPTH))(
  input w_clk,
  input w_reset,
  input wr_en,
  input [PTR_SIZE:0]g_rd_ptr,
  output reg [PTR_SIZE:0] b_wr_ptr,g_wr_ptr,
  output reg full
);
   reg [PTR_SIZE:0] b_wr_ptr_next;
   reg [PTR_SIZE:0] g_wr_ptr_next;
   reg [PTR_SIZE:0] b_rd_ptr;
  //wire w_full;
  
   assign b_wr_ptr_next=b_wr_ptr+(wr_en&&!full);
   assign g_wr_ptr_next=(b_wr_ptr>>1)^b_wr_ptr;
  
//   gray_2_bin#(DEPTH,PTR_SIZE) g_2_b_1(g_rd_ptr,b_rd_ptr);
  gray_2_bin #(
  .DEPTH(128),                 // Parameter for depth
  .PTR_SIZE($clog2(128))       // Calculated parameter for pointer size
  ) W_gray_2_bin_inst (
  .g_ptr(g_rd_ptr),         // Connect gray-coded read pointer input
  .b_ptr(b_rd_ptr)          // Connect binary read pointer output
);
  
  always@(posedge w_clk)
    begin
      if(w_reset)
        begin
          b_wr_ptr<=0;
          g_wr_ptr<=0;
        end
      else
        begin
          b_wr_ptr<=b_wr_ptr_next;
          g_wr_ptr<=g_wr_ptr_next;
        end
    end
  

  
  assign full=(b_wr_ptr[PTR_SIZE]!=b_rd_ptr[PTR_SIZE])&&(b_wr_ptr[PTR_SIZE-1:0]==b_rd_ptr[PTR_SIZE-1:0]);
  
endmodule
