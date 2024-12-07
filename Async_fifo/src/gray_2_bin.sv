module gray_2_bin#(parameter DEPTH=128,PTR_SIZE=$clog2(DEPTH))(
  input [PTR_SIZE:0] g_ptr,
  output reg [PTR_SIZE:0] b_ptr
);
  genvar i;
  generate
    for(i=PTR_SIZE-1;i>=0;i--)begin
      assign b_ptr[i]=b_ptr[i+1'b1]^g_ptr[i];
    end
  endgenerate
  assign b_ptr[PTR_SIZE]=g_ptr[PTR_SIZE];
endmodule
