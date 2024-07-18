module dsp_axis_tb();
  parameter DATA_WIDTH=16;
  reg clk,reset;
  reg [DATA_WIDTH-1:0] s_axis_data_a;
  reg s_axis_valid_a,s_axis_last_a;
  reg [DATA_WIDTH-1:0] s_axis_data_b;
  reg s_axis_valid_b,s_axis_last_b;
  reg [DATA_WIDTH-1:0] s_axis_data_c;
  reg s_axis_valid_c,s_axis_last_c;
  reg m_axis_ready;
  wire [2*DATA_WIDTH:0] m_axis_data;
  wire m_axis_valid;
  wire m_axis_last;
  wire s_axis_ready_a,s_axis_ready_b,s_axis_ready_c;
  
  dsp_axis#(DATA_WIDTH) dut(clk,reset,s_axis_data_a,s_axis_valid_a,
                            s_axis_last_a,s_axis_data_b,s_axis_valid_b,
                           s_axis_last_b,s_axis_data_c,s_axis_valid_c,
                           s_axis_last_c,m_axis_ready,m_axis_data,
                            m_axis_valid,m_axis_last,s_axis_ready_a,
                            s_axis_ready_b,s_axis_ready_c);
  
  initial
    begin
      clk=1'b0;
      reset=1'b1;
      s_axis_data_a=0;
      s_axis_valid_a=0;
      s_axis_last_a=0;
      s_axis_data_b=0;
      s_axis_valid_b=0;
      s_axis_last_b=0;
      s_axis_data_c=0;
      s_axis_valid_c=0;
      s_axis_last_c=0;
      m_axis_ready=0;
      repeat(2)@(posedge clk);
      for(int i=0;i<10;i++) begin
        @(posedge clk)begin
          reset<=1'b0;
          s_axis_data_a<=$random;
          s_axis_valid_a<=1'b1;
          s_axis_data_b<=$random;
          s_axis_valid_b<=1'b1;
          s_axis_data_c<=$random;
          s_axis_valid_c<=1'b1;
          m_axis_ready<=1'b1;
      end
      end
      @(posedge clk) begin
        s_axis_data_a<=$random;
        s_axis_data_b<=$random;
        s_axis_data_c<=$random;
        s_axis_last_a<=1'b1;
        s_axis_last_b<=1'b1;
        s_axis_last_c<=1'b1;
      end
      @(posedge clk) begin
        s_axis_data_a<=0;
          s_axis_valid_a<=0;
          s_axis_data_b<=0;
          s_axis_valid_b<=0;
          s_axis_data_c<=0;
          s_axis_valid_c<=0;
          m_axis_ready<=1'b1;
      end
      @(posedge clk)m_axis_ready<=1'b0;
      repeat(2)@(posedge clk);
      $finish;
      /*for(int i=0;i<12;i++)begin
        @(posedge clk)begin
          m_axis_ready=1
          */
      end
  always#5 clk=~clk;
  
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end
endmodule
        
    
        
        
