module axis_mux2_1#(parameter DATA_WIDTH=16)(
  input aclk,
  input aresetn,
  input select,
  
  input [DATA_WIDTH-1:0] s_axis_data1,
  input s_axis_valid1,
  input s_axis_last1,
  input m_axis_ready,
  
  input [DATA_WIDTH-1:0] s_axis_data2,
  input s_axis_valid2,
  input s_axis_last2,
  //input m_axis_ready2,
  
  
  output [DATA_WIDTH-1:0] m_axis_data,
  output m_axis_valid,
  output m_axis_last,
  output s_axis_ready1,
  output s_axis_ready2
);
  
  reg [DATA_WIDTH-1:0] m_axis_data_reg;
  reg m_axis_valid_reg;
  reg m_axis_last_reg;
  
  always@(posedge aclk or negedge aresetn )
  //always@(*)
    begin
      if(~aresetn)
        begin
          m_axis_data_reg<=0;
          m_axis_valid_reg<=1'b0;
          m_axis_last_reg<=1'b0;
        end
      else if(~select)
        begin
          if(s_axis_ready1 && s_axis_valid1)
            begin
              m_axis_data_reg<=s_axis_data1;
              m_axis_valid_reg<=1'b1;
              m_axis_last_reg<=s_axis_last1;
            end
          else
            begin
              m_axis_data_reg<=m_axis_data_reg;
              m_axis_valid_reg<=1'b0;
              m_axis_last_reg<=1'b0;
            end
        end
      else if(select)
        begin
          if(s_axis_valid2 && s_axis_ready2)
            begin
              m_axis_data_reg<=s_axis_data2;
              m_axis_valid_reg<=1'b1;
              m_axis_last_reg<=s_axis_last2;
            end
          else
            begin
              m_axis_data_reg<=m_axis_data_reg;
              m_axis_valid_reg<=1'b0;
              m_axis_last_reg<=1'b0;
            end
          end
    end
  assign s_axis_ready1=m_axis_ready;
  assign s_axis_ready2=m_axis_ready;
  assign m_axis_data=m_axis_data_reg;
  assign m_axis_valid=m_axis_valid_reg;
  assign m_axis_last=m_axis_last_reg;
endmodule
