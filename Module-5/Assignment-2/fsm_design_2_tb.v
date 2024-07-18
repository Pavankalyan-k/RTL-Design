module fsm_design_2_tb();
  reg clk;
  reg reset;
  reg [15:0] s_axis_data;
  reg s_axis_valid;
  reg s_axis_last;
  reg [7:0] s_axis_keep;
  reg m_axis_ready;
  reg [6:0] block_len;
  wire [15:0] m_axis_data;
  wire m_axis_valid;
  wire m_axis_last;
  wire [7:0] m_axis_keep;
  wire s_axis_ready;
  wire block_last;
  
  fsm_design_2 dut(clk,reset,s_axis_data,s_axis_valid,s_axis_last,
                  s_axis_keep,m_axis_ready,block_len,m_axis_data,m_axis_valid,
                   m_axis_last,m_axis_keep,s_axis_ready,block_last);
  
  
  initial
    begin
      clk=0;
      reset=1;
      s_axis_data=0;
      s_axis_valid=0;
      s_axis_last=0;
      s_axis_keep=0;
      m_axis_ready=0;
      repeat(1)@(posedge clk);
      @(posedge clk)begin
        reset<=0;
        block_len<=40;
      end
   
      
      for(int i=0;i<12;i++)
        begin
          @(posedge clk)
          begin
            reset<=0;
            s_axis_data<=$random;
            s_axis_valid<=1'b1;
            m_axis_ready<=1'b1;
          end
        end
      
      @(posedge clk)begin
        s_axis_data<=$random;
        s_axis_last<=1'b1;
      end
      @(posedge clk)
      begin
        s_axis_last<=0;
        s_axis_data<=0;
        s_axis_valid<=0;
        m_axis_ready<=1;
      end
      repeat(10)@(posedge clk)m_axis_ready<=1;
      repeat(18)@(posedge clk)m_axis_ready<=0;
      $finish;
      
    end
  
  always#5 clk=~clk;
  
  initial
    begin
      repeat(2) @(posedge clk);
      @(posedge clk) s_axis_keep<=4;
      @(posedge clk) s_axis_keep<=8;
      @(posedge clk) s_axis_keep<=12;
      @(posedge clk) s_axis_keep<=4;
      @(posedge clk) s_axis_keep<=16;
      @(posedge clk) s_axis_keep<=16;
      @(posedge clk) s_axis_keep<=8;
      @(posedge clk) s_axis_keep<=4;
      @(posedge clk) s_axis_keep<=12;
      @(posedge clk) s_axis_keep<=4;
      @(posedge clk) s_axis_keep<=12;
      @(posedge clk) s_axis_keep<=16;
      @(posedge clk) s_axis_keep<=16;
    end
 
  
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end
  
  initial
    begin
      #130;
      for(int i=0;i<50;i++)
        begin
          $display("%0t fifo[%0d]=%0h",$time,i,dut.fifo[i]);
          //$display("t_keep_array[%0d]=%0d",i,dut.t_keep_array[i]);
        end
    end
    
  
endmodule
