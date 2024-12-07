module async_fifo#(parameter DATA_WIDTH=8,DEPTH=128,PTR_SIZE=$clog2(DEPTH))(
  input wr_clk,
  input rd_clk,
  input wr_en,
  input rd_en,
  input wr_reset,
  input rd_reset,
  input [PTR_SIZE:0]wr_ptr,
  input [PTR_SIZE:0]rd_ptr,
  input full,empty,
  input [DATA_WIDTH-1:0] s_axis_fifo_data,
  input s_axis_fifo_valid,
  output reg s_axis_fifo_ready,
  output reg [DATA_WIDTH-1:0] m_axis_fifo_data,
  output reg m_axis_fifo_data_valid,
  input  m_axis_fifo_data_ready
);
  
  reg [DATA_WIDTH-1:0] fifo[0:DEPTH-1];
  always@(posedge wr_clk)
    begin
    if(wr_reset)
      fifo[wr_ptr]<=fifo[wr_ptr];
    else
      begin
      if(wr_en && !full)
          begin
            fifo[wr_ptr]<=s_axis_fifo_data;
          end
      else
          begin
            fifo[wr_ptr]<=fifo[wr_ptr];
          end
        end
    end
  
  always@(posedge rd_clk)
    begin
      if(rd_reset)
        begin
          m_axis_fifo_data<=0;
          m_axis_fifo_data_valid<=0;
        end
      else
        begin
      if(rd_en && !empty)
            begin
              m_axis_fifo_data<=fifo[rd_ptr];
              m_axis_fifo_data_valid<=1;
            end
          else
            begin
              if(!m_axis_fifo_data_ready)
                begin
                  m_axis_fifo_data<=m_axis_fifo_data;
                  m_axis_fifo_data_valid<=m_axis_fifo_data_valid;
                end
              else
                begin
                  m_axis_fifo_data<=m_axis_fifo_data;
                  m_axis_fifo_data_valid<=0;
                end
            end
        end
    end
  
  

  always@(*)
    begin
        s_axis_fifo_ready=m_axis_fifo_data_ready;
    end
endmodule
