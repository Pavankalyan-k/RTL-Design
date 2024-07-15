module axis_register#(parameter DATA_WIDTH=8)(
  input aclk,
  input aresetn,
  input [DATA_WIDTH-1:0] s_axis_data,
  input s_axis_valid,
  input s_axis_last,
  input m_axis_ready,
  output  [DATA_WIDTH-1:0] m_axis_data,
  output m_axis_valid,
  output m_axis_last,
  output s_axis_ready
);
  reg [DATA_WIDTH-1:0] m_axis_data_reg;
  reg m_axis_valid_reg;
  reg m_axis_last_reg;
  
  
 
  
  always@(posedge aclk or negedge aresetn)
    begin
      if(~aresetn)
        begin
          m_axis_data_reg<=0;
          m_axis_valid_reg<=1'b0;
          m_axis_last_reg<=1'b0;
        end
      else if(s_axis_valid && s_axis_ready)
        begin
          m_axis_data_reg<=s_axis_data;
          m_axis_valid_reg<=1'b1;
          m_axis_last_reg<=s_axis_last;
        end
      else
        begin
          m_axis_data_reg<=m_axis_data_reg;
          m_axis_valid_reg<=1'b0;
          m_axis_last_reg<=1'b0;
        end
    end
  assign m_axis_data=m_axis_ready?m_axis_data_reg:0;
  assign m_axis_valid=m_axis_ready && m_axis_data!=0;
  assign m_axis_last=m_axis_last_reg;
  assign s_axis_ready=m_axis_ready;

  
  
endmodule
