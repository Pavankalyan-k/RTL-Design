module dsp_axis#(parameter DATA_WIDTH=16)(
  input clk,
  input reset,
  input [DATA_WIDTH-1:0] s_axis_data_a,
  input s_axis_valid_a,
  input s_axis_last_a,
  input [DATA_WIDTH-1:0] s_axis_data_b,
  input s_axis_valid_b,
  input s_axis_last_b,
  input [DATA_WIDTH-1:0] s_axis_data_c,
  input s_axis_valid_c,
  input s_axis_last_c,
  input m_axis_ready,
  output [DATA_WIDTH+DATA_WIDTH:0] m_axis_data,
  output m_axis_valid,
  output m_axis_last,
  output s_axis_ready_a,
  output s_axis_ready_b,
  output s_axis_ready_c
);
  
  reg [DATA_WIDTH+DATA_WIDTH:0] m_axis_data_reg;
  reg m_axis_last_reg;
  
  always@(posedge clk)
    begin
      if(reset)
        begin
          m_axis_data_reg<=0;
          m_axis_last_reg<=0;
        end
      else
        begin
          if((s_axis_valid_a && s_axis_ready_a)&&(s_axis_valid_b && 
            s_axis_ready_b)&&(s_axis_valid_c&& s_axis_ready_c))
            begin
              m_axis_data_reg<=(s_axis_data_a+s_axis_data_b)*s_axis_data_c;
              m_axis_last_reg<=s_axis_last_a&&s_axis_last_b&&s_axis_last_c;
            end
          else
            begin
              m_axis_data_reg<=m_axis_data_reg;
              m_axis_last_reg<=1'b0;
            end
        end
    end
      
    assign s_axis_ready_a=m_axis_ready;
    assign s_axis_ready_b=m_axis_ready;
    assign s_axis_ready_c=m_axis_ready;
    assign m_axis_data=m_axis_ready?m_axis_data_reg:0;
    assign m_axis_last=m_axis_ready?m_axis_last_reg:0;
    assign m_axis_valid=m_axis_ready&&m_axis_data!=0;
  
endmodule
