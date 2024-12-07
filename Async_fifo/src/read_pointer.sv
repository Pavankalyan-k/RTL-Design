module read_pointer#(parameter DEPTH=128,PTR_SIZE=$clog2(DEPTH))(
  input rd_clk,
  input rd_reset,
  input rd_en,
  input [PTR_SIZE:0]g_wr_ptr,
  output reg [PTR_SIZE:0] b_rd_ptr,g_rd_ptr,
  output reg empty
);
  
  reg [PTR_SIZE:0] b_rd_ptr_next;
  reg [PTR_SIZE:0] g_rd_ptr_next;
  
  reg [PTR_SIZE:0] b_wr_ptr;
  
  
  
  assign b_rd_ptr_next=b_rd_ptr+(rd_en && !empty);
  assign g_rd_ptr_next=(b_rd_ptr>>1)^b_rd_ptr;
  
  
  // Instantiation of gray_2_bin module
gray_2_bin #(
  .DEPTH(128),                 // Parameter for depth
  .PTR_SIZE($clog2(128))       // Calculated parameter for pointer size
) R_gray_2_bin_inst (
  .g_ptr(g_wr_ptr),         // Connect gray-coded read pointer input
  .b_ptr(b_wr_ptr)          // Connect binary read pointer output
);

  always@(posedge rd_clk)
    begin
      if(rd_reset)
        begin
          b_rd_ptr<=0;
          g_rd_ptr<=0;
        end
      else
        begin
          if(rd_en && !empty) begin
          b_rd_ptr<=b_rd_ptr_next;
          g_rd_ptr<=g_rd_ptr_next;
        end
          else
            begin
              b_rd_ptr<=b_rd_ptr;
              g_rd_ptr<=g_rd_ptr;
            end
        end
    end
  

  
  assign empty=(b_rd_ptr==b_wr_ptr);
endmodule
