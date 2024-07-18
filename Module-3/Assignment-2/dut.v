module axis_assign_2#(parameter DATA_WIDTH=8,DEPTH=64)(
  input clk,
  input resetn,
  input [DATA_WIDTH-1:0] s_axis_data,
  input s_axis_valid,
  input s_axis_last,
  input m_axis_ready,
  input [DATA_WIDTH-1:0] packet_length,
  input [DATA_WIDTH-1:0] k,
  output reg [DATA_WIDTH:0] m_axis_data,
  output m_axis_valid,
  output m_axis_last,
  output s_axis_ready
);
  reg [DATA_WIDTH-1:0] counter=0;
  reg [DATA_WIDTH-1:0] mem[0:DEPTH-1];
  reg [DATA_WIDTH-1:0] wr_ptr=0,rd_ptr;
  reg [DATA_WIDTH-3:0] last_count=0;
  reg rd_en,wr_en;
  
  always@(posedge clk)
    begin 
      if(counter==packet_length-1 && resetn && s_axis_valid && s_axis_ready)
        last_count<=last_count+1;
      else
        last_count<=last_count;
    end
         
  
  always@(posedge clk)
    begin
      if(resetn && s_axis_valid && s_axis_ready)
        begin
          if(counter<packet_length-1)
            counter<=counter+1;
          else
            counter<=0;
        end
      else
        begin
          counter<=counter;
        end
    end
  
  always@(*)
    begin
      if(resetn && s_axis_ready && s_axis_valid)
        begin
          if(counter>packet_length-1-k)
            wr_en<=1;
          else
            wr_en<=0;
        end
      else
        wr_en<=0;
    end
  always@(*)
    begin
      if(resetn && m_axis_ready && s_axis_valid )
        begin
          if(counter<k && last_count>=1)
            rd_en<=1;
          else
            rd_en<=0;
        end
      else
        begin
          rd_en<=0;
        end
    end
  always@(posedge clk)
    begin
      if(counter==packet_length-1)
        rd_ptr<=k-1;
      else if(resetn && m_axis_ready && s_axis_valid)
        begin
          rd_ptr<=rd_ptr-1;
        end
      else
        rd_ptr<=rd_ptr;
    end
  
  always@(negedge clk)
    begin
      if(wr_ptr==k)
        wr_ptr<=0;
      else if(wr_en && s_axis_valid && s_axis_ready)
        begin
          if(wr_ptr<k)
            begin
              mem[wr_ptr]<=s_axis_data;
              wr_ptr<=wr_ptr+1;
            end
          else
            begin
              wr_ptr<=0;
            end
            
        end
      else
        wr_ptr<=wr_ptr;
    end
  
  always@(*)
    begin
      if(~resetn)
        m_axis_data<=0;
      else
        begin
          if(rd_en)
            begin
              m_axis_data<=mem[rd_ptr]+s_axis_data;
            end
          else
            m_axis_data<=0;
        end
    end
  
  
  
  
      
  assign m_axis_last=s_axis_last;      
  assign m_axis_valid=m_axis_data==0?0:1;        
  assign s_axis_ready=m_axis_ready;
endmodule
