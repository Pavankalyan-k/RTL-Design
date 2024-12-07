module skid_buffer_tb();
  parameter DATA_WIDTH=8,OPT_LOWPOWER=1,OPT_OUTREG=0;
  logic clk;
  logic reset;
  logic s_axis_valid;
  logic [DATA_WIDTH-1:0] s_axis_data;
  logic s_axis_ready;
  logic [DATA_WIDTH-1:0] m_axis_data;
  logic m_axis_valid;
  logic m_axis_ready;
  
  localparam string data_file="input_data.csv";
  
  skid_buffer#(DATA_WIDTH,OPT_LOWPOWER,OPT_OUTREG) dut(clk,reset,
                                                      s_axis_valid,
                                                      s_axis_data,
                                                      s_axis_ready,
                                                      m_axis_data,
                                                      m_axis_valid,
                                                       m_axis_ready);
  
  
  initial
    begin
      clk=0;
      reset=1;
      s_axis_valid=0;
      s_axis_data=0;
      m_axis_ready=0;
      reset_task;
      m_axis_ready=1;
      
      fork
        m_ready;
        read_csv(data_file,1);
      join
      
      $finish;
    end
  
  always #5 clk=~clk;
  
  task automatic reset_task;
    begin
      @(posedge clk);
      reset=~reset;
    end
  endtask
  
  task automatic read_csv;
    input string filename;
    input int throttle;
    begin
      int fp,wait_n;
      logic[DATA_WIDTH-1:0] data;
      fp=$fopen(filename,"r");
      
      if(fp == 0)
        begin
          $display("Error in opening file");
        end
      
      while($fscanf(fp,"%d",data)==1)
        begin
          s_axis_data<=data;
          s_axis_valid<=1;
          @(posedge clk);
          while(!s_axis_ready)
            @(posedge clk);
          s_axis_valid<=0;
          wait_n=$urandom % throttle;
          repeat(wait_n)
            begin
              @(posedge clk);
            end
        end
      $fclose(fp);
    end
  endtask
  
  task automatic m_ready;
    begin
      repeat(20)begin
        @(posedge clk)begin
          m_axis_ready<=$random;
        end
      end
    end
  endtask
      
  
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end
  
  
endmodule
