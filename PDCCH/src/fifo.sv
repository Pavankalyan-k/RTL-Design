module sync_fifo #(parameter DATA_WIDTH=8,DEPTH=2048,PTR_SIZE=$clog2(DEPTH))(
  input aclk,
  input reset,
  input wr_en,
  input rd_en,
  
  input [DATA_WIDTH-1:0] s_axis_data,
  input s_axis_valid,
  //input s_axis_last,
  input m_axis_ready,
  
  output [DATA_WIDTH-1:0] m_axis_data,
  output  m_axis_valid,
  //output  m_axis_last,
  output s_axis_ready,
  
  output full,
  output empty
);
  reg [DATA_WIDTH:0] fifo[0:DEPTH-1];
  reg [PTR_SIZE:0] wr_ptr=0,rd_ptr=0;
  reg [DATA_WIDTH:0] m_axis_data_reg;
  reg m_axis_valid_reg;
  reg m_axis_last_reg;
  
  always@(posedge aclk)
    begin
      if(!reset)
        begin
          if(wr_en && !full)
            begin
              if(s_axis_valid && s_axis_ready)
                begin
                  fifo[wr_ptr]<={s_axis_data};
                  //m_axis_valid_reg<=1'b1;
                  //m_axis_last_reg<=s_axis_last;
                  wr_ptr<=wr_ptr+1;
                end
              else
                begin
                  fifo[wr_ptr]<=0;
                  wr_ptr<=wr_ptr;
                  //m_axis_valid_reg<=1'b0;
                  //m_axis_last_reg<=1'b0;
                end
            end
        end
    end
  
  // read
  
  always@(posedge aclk)
    begin
      if(!reset)
        begin
          
          if(rd_en && !empty)
            begin
              if(m_axis_ready )
                begin
                  m_axis_data_reg<=fifo[rd_ptr];
                  m_axis_valid_reg<=1'b1;
                  rd_ptr<=rd_ptr+1;
                end
              else
                begin
                  m_axis_data_reg<=0;
                  m_axis_valid_reg<=1'b0;
                end
              
            end
        end
    end
  
  assign s_axis_ready=m_axis_ready;
  assign m_axis_data=m_axis_data_reg[DATA_WIDTH-1:0];
  assign m_axis_valid=m_axis_valid_reg;
  //assign m_axis_last=m_axis_data_reg[DATA_WIDTH];
  assign full=wr_ptr[PTR_SIZE] != rd_ptr[PTR_SIZE] && wr_ptr[PTR_SIZE-1:0] == 
    rd_ptr[PTR_SIZE];
  assign empty = wr_ptr == rd_ptr;
endmodule
