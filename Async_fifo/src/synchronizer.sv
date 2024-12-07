module synchronizer#(DEPTH=128,PTR_SIZE=$clog2(DEPTH))(
  input clk,
  input reset,
  input [PTR_SIZE:0] data_in,
  output reg [PTR_SIZE:0] data_out
);
  reg [PTR_SIZE:0] q_1;
  
  always@(posedge clk)
    begin
      if(reset)
        begin
          q_1<=0;
          data_out<=0;
        end
      else
        begin
          q_1<=data_in;
          data_out<=q_1;
        end
    end
  
endmodule
