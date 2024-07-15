module axis_register_tb();
  parameter DATA_WIDTH=8;
  reg aclk,aresetn;
  reg [DATA_WIDTH-1:0] s_axis_data;
  reg s_axis_valid,s_axis_last,m_axis_ready;
  wire [DATA_WIDTH-1:0] m_axis_data;
  wire m_axis_valid,m_axis_last,s_axis_ready;
  
  
  
  //reg m_axis_ready;
  
  axis_register #(DATA_WIDTH) dut(aclk,aresetn,s_axis_data,s_axis_valid,
                                s_axis_last,m_axis_ready,m_axis_data,
                                 m_axis_valid,m_axis_last,s_axis_ready);


  initial
    begin
      aclk=1'b0;
      aresetn=1'b0;
      s_axis_data=0;
      s_axis_valid=1'b0;
      s_axis_last=1'b0;
      m_axis_ready=1'b0;
      repeat(2)@(posedge aclk);
      @(posedge aclk) 
      begin
        aresetn<=1'b1;
        //s_axis_data<=$random;
        //s_axis_valid<=1'b1;
      end
      //repeat(2)@(posedge aclk);
      for(int i=0;i<10;i++)
        begin
          @(posedge aclk)
          begin
            s_axis_data<=$random;
            s_axis_valid<=1'b1;
            s_axis_last<=1'b0;
            m_axis_ready<=$random;
          end
        end
      @(posedge aclk) 
      begin
        s_axis_data<=$random;
        s_axis_last<=1'b1;
      end
      @(posedge aclk)
      begin
        m_axis_ready=1'b1;
        s_axis_data<=0;
        s_axis_valid<=1'b0;
        s_axis_last<=1'b0;
      end
      
      repeat(5)@(posedge aclk)
        begin
          s_axis_data<=0;
          s_axis_valid<=1'b0;
          s_axis_last<=1'b0;
          m_axis_ready<=1'b0;
        end
      /*@(posedge aclk) begin
        s_axis_data<=$random;
        s_axis_valid<=1'b1;
      end
      repeat(2)@(posedge aclk);*/
      for(int i=0;i<10;i++)
        begin
          @(posedge aclk)
          begin
            s_axis_data<=$random;
            s_axis_valid<=1'b1;
            s_axis_last<=1'b0;
            m_axis_ready<=$random;
          end
        end
      @(posedge aclk)
        begin
          s_axis_data<=$random;
          s_axis_last<=1'b1;
        end
      @(posedge aclk)
      begin
      s_axis_last<=1'b0;
        s_axis_valid<=1'b0;
      end
      @(posedge aclk)
      begin
        m_axis_ready<=1'b0;
      end
      
      repeat(10)@(posedge aclk);
      $finish;
    end
  always #5 aclk=~aclk;
  
 
  
  
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end
endmodule
