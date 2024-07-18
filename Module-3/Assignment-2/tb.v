module axis_assign_2_final_tb();
  parameter DATA_WIDTH=8,DEPTH=64;
  reg clk,resetn;
  reg [DATA_WIDTH-1:0] s_axis_data;
  reg s_axis_valid;
  reg s_axis_last;
  reg m_axis_ready;
  reg [DATA_WIDTH-1:0] packet_length;
  reg [DATA_WIDTH-1:0] k;
  
  wire [DATA_WIDTH:0] m_axis_data;
  wire m_axis_valid,m_axis_last;
  wire s_axis_ready;
  reg [DATA_WIDTH-1:0] counter;
  
  axis_assign_2#(DATA_WIDTH,DEPTH) dut(clk,resetn,s_axis_data,
                                            s_axis_valid,s_axis_last,
                                            m_axis_ready,packet_length,k,
                                            m_axis_data,m_axis_valid,
                                             m_axis_last,s_axis_ready);
  
  
  initial
    begin
      clk=0;
      resetn=0;
      s_axis_data=0;
      s_axis_valid=0;
      s_axis_last=0;
      m_axis_ready=0;
      packet_length=8;
      k=4;
      repeat(2)@(posedge clk);
      for(int i=0;i<7;i++)begin
        @(posedge clk)begin
          resetn<=1;
          s_axis_data<=$random;
          s_axis_valid<=1;
          m_axis_ready<=$random;
        end
      end
      @(posedge clk)begin
        s_axis_data<=$random;
        //s_axis_last<=1;
      end
      
      for(int i=0;i<7;i++)begin
        @(posedge clk)begin
          resetn<=1;
          s_axis_data<=$random;
          s_axis_valid<=1;
          m_axis_ready<=$random;
          //s_axis_last<=0;
        end
      end
      @(posedge clk)begin
        s_axis_data<=$random;
        s_axis_last<=1;
      end
      for(int i=0;i<7;i++)begin
        @(posedge clk)begin
          resetn<=1;
          s_axis_data<=$random;
          s_axis_valid<=1;
          m_axis_ready<=$random;
          //s_axis_last<=0;
        end
      end
      @(posedge clk)begin
        s_axis_data<=$random;
        //s_axis_last<=1;
        
      end
      for(int i=0;i<19;i++)
        begin
          @(posedge clk)begin
            resetn<=1;
          s_axis_data<=$random;
          s_axis_valid<=1;
          m_axis_ready<=$random;
          end
        end
      
            
      
      
      repeat(1)@(posedge clk) 
        begin
          //s_axis_last<=0;
          resetn<=0;
          s_axis_data<=0;
          m_axis_ready<=0;
          s_axis_valid<=0;
        end
      @(posedge clk)resetn<=0;
      repeat(2)@(posedge clk);
      $finish;
      
    end
  always#5 clk=~clk;
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
      if(counter==packet_length-2 && s_axis_ready && s_axis_valid)
        begin
          s_axis_last<=1'b1;
        end
      else
        begin
          s_axis_last<=1'b0;
        end
    end
  
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end
  
  initial
    begin
      #230;
      for(int i=0;i<10;i++)begin
        $display("mem[%0d]=%0d",i,dut.mem[i]);
      end
    end
endmodule
