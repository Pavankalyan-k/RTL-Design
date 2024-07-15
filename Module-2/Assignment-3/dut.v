module fifo_4096_axis#(parameter DATA_WIDTH=16,DEPTH_FIFO=4096
                       ,DEPTH_RAM=2048,PTR_SIZE=$clog2(DEPTH_FIFO))(
  input clk,
  input resetn,
  input wr_en,
  input rd_en,
  input [DATA_WIDTH-1:0] s_axis_data,
  input s_axis_valid,
  input s_axis_last,
  input m_axis_ready,
  
  output [DATA_WIDTH-1:0] m_axis_data,
  output m_axis_valid,
  output m_axis_last,
  output s_axis_ready,
  
  output full,
  output empty

);
 reg m_axis_valid_reg;
  always@(posedge clk)
    begin
      if(resetn)
        begin
          if(m_axis_ready)
            begin
              if(rd_en&&!empty)
                begin
                  m_axis_valid_reg<=1'b1;
                end
            end
        end
    end
  
    
  wire fifo_wr_en;
  wire fifo_rd_en;
  wire [DATA_WIDTH:0] m_axis_data1;
  
  assign fifo_wr_en=s_axis_valid && s_axis_ready && wr_en;
  assign fifo_rd_en= m_axis_ready && rd_en;
  
  
  
  fifo_4096#(DATA_WIDTH,DEPTH_FIFO,DEPTH_RAM,PTR_SIZE)
  dut(clk,resetn,fifo_wr_en,fifo_rd_en,{s_axis_last,s_axis_data},m_axis_data1,
      full,empty);
  
  assign m_axis_last=m_axis_data1[DATA_WIDTH];
  assign m_axis_valid=m_axis_valid_reg;
      //m_axis_ready && rd_en&&resetn&&!empty;
  assign s_axis_ready=m_axis_ready;
  assign m_axis_data=m_axis_data1[DATA_WIDTH-1:0];
endmodule
    
module ram #(parameter DATA_WIDTH=16,DEPTH=2048,ADDR_SIZE=$clog2(DEPTH))
  (
    input clk,
    input en,
    input wr_en,
    input rd_en,
    input [ADDR_SIZE-1:0] wr_addr,
    input [ADDR_SIZE-1:0] rd_addr,
    input [DATA_WIDTH:0] data_in,
    output reg [DATA_WIDTH:0] data_out
    
  );
  
  reg [DATA_WIDTH:0] mem[0:DEPTH-1];
  
  always@(posedge clk)
    begin
      if(en)
        begin
          if(wr_en)
            begin
              mem[wr_addr]<=data_in;
            end
          
        end
    end
  always@(posedge clk)
    begin
      if(en)
        begin
          if(rd_en)
            begin
              data_out<=mem[rd_addr];
            end
          else
            begin
              data_out<=0;
            end
        end
      else
        data_out<=0;
      
        
    end
endmodule

module ram_4096 #(parameter DATA_WIDTH=16,DEPTH=2048,ADDR_SIZE=$clog2(DEPTH))
  (
    input clk,
    input en,
    input wr_en,
    input rd_en,
    input [ADDR_SIZE:0] wr_addr,
    input [ADDR_SIZE:0] rd_addr,
    
    input [DATA_WIDTH:0] data_in,
    output [DATA_WIDTH:0] data_out
    
  
  );
  
  wire en1,en2;
  wire en1_read;
  wire en2_read;
  reg en1_delay ;
  reg en2_delay;
  
  wire [DATA_WIDTH:0] data_out1;
  wire [DATA_WIDTH:0] data_out2;
  
  assign en1=(wr_en && ~wr_addr[11]) | (rd_en && ~rd_addr[11]);
  
  assign en2=(wr_en && wr_addr[11]) | (rd_en && rd_addr[11]);
  
  always@(posedge clk)
    begin
      en1_delay<=en1;
      en2_delay<=en2;
    end
  assign en1_read=en1||en1_delay;
  assign en2_read=en2||en2_delay;
  
  assign data_out=en1_read?data_out1:en2_read?data_out2:0;
  
  ram#(DATA_WIDTH,DEPTH,ADDR_SIZE) uut1(clk,en1,wr_en,rd_en,
                                         wr_addr[ADDR_SIZE-1:0],
                                         rd_addr[ADDR_SIZE-1:0],
                                         data_in,data_out1);
  ram#(DATA_WIDTH,DEPTH,ADDR_SIZE) uut2(clk,en2,wr_en,rd_en,
                                         wr_addr[ADDR_SIZE-1:0],
                                         rd_addr[ADDR_SIZE-1:0],
                                         data_in,data_out2);
  
endmodule

module fifo_4096#(parameter DATA_WIDTH=16,DEPTH_FIFO=4096,
                  DEPTH_RAM=2048,PTR_SIZE=$clog2(DEPTH_FIFO))
  (
    input clk,
    input resetn,
    input wr_en,
    input rd_en,
    
    input [DATA_WIDTH:0] data_in,
    output [DATA_WIDTH:0] data_out,
    
    output full,
    output empty
  );
  
  reg [PTR_SIZE:0] wr_ptr;
  reg [PTR_SIZE:0] rd_ptr;
  
  wire write_en_ram;
  wire read_en_ram;
  
  assign write_en_ram=wr_en && ~full;
  assign read_en_ram=rd_en && ~empty;
  
  always@(posedge clk)
    begin
      if(~resetn)
        begin
          wr_ptr<=0;
          rd_ptr<=0;
        end
      else if(( wr_en && ~full) && (rd_en && ~empty))
        begin
          wr_ptr<=wr_ptr+1;
          rd_ptr<=rd_ptr+1;
        end
      else if(wr_en && ~full)
        begin
          wr_ptr<=wr_ptr+1;
          rd_ptr<=rd_ptr;
        end
      else if(rd_en && ~empty)
        begin
          rd_ptr<=rd_ptr+1;
          wr_ptr<=wr_ptr;
        end
      else 
        begin
          wr_ptr<=wr_ptr;
          rd_ptr<=rd_ptr;
        end
    end
  
  ram_4096#(DATA_WIDTH,DEPTH_RAM,PTR_SIZE-1) uuttt(clk,resetn,wr_en,
                                                     rd_en,wr_ptr[11:0],
                                                     rd_ptr[11:0],
                                                     data_in,data_out);
  assign full=(rd_ptr == {~wr_ptr[12],wr_ptr[11:0]});
  assign empty= wr_ptr==rd_ptr;
  
endmodule
          
