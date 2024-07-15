module axis_mux_tb();
  parameter DATA_WIDTH=16;
  reg aclk,aresetn,select;
  reg [DATA_WIDTH-1:0] s_axis_data1;
  reg s_axis_valid1,s_axis_last1,m_axis_ready;
  reg [DATA_WIDTH-1:0] s_axis_data2;
  reg s_axis_valid2,s_axis_last2;
  wire [DATA_WIDTH-1:0] m_axis_data;
  wire m_axis_valid,m_axis_last,s_axis_ready1,s_axis_ready2;
  
  axis_mux2_1 #(DATA_WIDTH) dut(aclk,aresetn,select,s_axis_data1,
                               s_axis_valid1,s_axis_last1,m_axis_ready,
                               s_axis_data2,s_axis_valid2,s_axis_last2,
                               m_axis_data,m_axis_valid,
                                m_axis_last,s_axis_ready1,s_axis_ready2);
  initial
    begin
      aclk=1'b0;
      aresetn=1'b0;
      select=1'b0;
      s_axis_data1=0;
      s_axis_valid1=1'b0;
      s_axis_last1=1'b0;
      m_axis_ready=1'b0;
      s_axis_data2=0;
      s_axis_valid2=1'b0;
      s_axis_last2=1'b0;
      //m_axis_ready2=1'b0;
      repeat(2)@(posedge aclk);
      @(posedge aclk) begin 
        aresetn<=1'b1;
        m_axis_ready<=1'b1;
      end
      repeat(2)@(posedge aclk);
      for(int i=0;i<8;i++)
        begin
          @(posedge aclk)
          begin
            s_axis_data1<=$random;
            s_axis_valid1<=1'b1;
            s_axis_last1<=1'b0;
            //m_axis_ready<=1'b1;
          end
        end
      @(posedge aclk) 
      begin
        s_axis_data1<=$random;
        s_axis_last1<=1'b1;
      end
      @(posedge aclk)
      begin
        //s_axis_data1<=$random;
        s_axis_valid1<=1'b0;
        s_axis_last1<=1'b0;
        m_axis_ready<=1'b0;
        
      end
      @(posedge aclk)
      begin
        m_axis_ready<=1'b1;
      end
      repeat(2)@(posedge aclk);
      @(posedge aclk)
      begin
        select=1'b1;
      end
      for(int i=0;i<8;i++)
        begin
          @(posedge aclk)
          begin
        	s_axis_data2<=$random;
        	s_axis_valid2<=1'b1;
        	s_axis_last2<=1'b0;
        	m_axis_ready<=1'b1;
          end
      end
      @(posedge aclk) 
        begin
          s_axis_last2<=1'b1;
          s_axis_data2<=$random;
        end
      @(posedge aclk)
      begin
        
            s_axis_valid2<=1'b0;
            s_axis_last2<=1'b0;
            m_axis_ready<=1'b0;
      end
      repeat(10)@(posedge aclk);
      $finish;
    end
  always #5 aclk = ~aclk;
  initial
    begin
    	$dumpfile("dump.vcd");
  		$dumpvars;
    end
endmodule
