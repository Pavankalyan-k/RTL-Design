module async_fifo_tb();
  parameter DATA_WIDTH=8,DEPTH=128,PTR_SIZE=$clog2(DEPTH);
  logic wr_clk;
  logic rd_clk;
  logic wr_reset;
  logic rd_reset;
  logic wr_en;
  logic rd_en;
  logic full;
  logic empty;
  logic [DATA_WIDTH-1:0] s_axis_top_data;
  logic s_axis_top_valid;
  logic s_axis_top_ready;
  logic [DATA_WIDTH-1:0] m_axis_top_data;
  logic m_axis_top_valid;
  logic m_axis_top_ready;
  
  localparam string datafile="data_file.csv";
  //Instantiation
  
  async_fifo_top#(DATA_WIDTH,DEPTH,PTR_SIZE) dut(wr_clk,
                                                rd_clk,
                                                wr_reset,
                                                rd_reset,
                                                wr_en,
                                                rd_en,
                                               
                                                
                                                s_axis_top_data,
                                                s_axis_top_valid,
                                                s_axis_top_ready,
                                                m_axis_top_data,
                                                m_axis_top_valid,
                                                 m_axis_top_ready,
                                                full,empty);
  
  
  initial
    begin
      wr_clk=0;
      rd_clk=0;
      wr_reset=1;
      rd_reset=1;
      s_axis_top_data=0;
      s_axis_top_valid=0;
      m_axis_top_ready=0;
      wr_reset_task(5);
      rd_reset_task(5);
      fork
        data_read(datafile,6);
        m_axis_top_ready_task(400);
      join
      $finish;
    end
  
  always#5 wr_clk=~wr_clk;
  always#10 rd_clk=~rd_clk;
  
  task automatic wr_reset_task(input int wr_reset_duration);
    int cycle_count_wr_reset;
    begin
      cycle_count_wr_reset=0;
      while(cycle_count_wr_reset<=wr_reset_duration)
        begin
          cycle_count_wr_reset=cycle_count_wr_reset+1;
          wr_reset<=wr_reset;
          @(posedge wr_clk);
        end
      wr_reset<=~wr_reset;
    end
  endtask
  
  task automatic data_read;
    input string filename;
    input int throttle;
    begin
      int fp,wait_n;
      logic [DATA_WIDTH-1:0] data;
      fp=$fopen(filename,"r");
      if(fp==0)
        $display("Error in Opening File");
      while($fscanf(fp,"%d",data)==1)
        begin
          s_axis_top_data<=data;
          s_axis_top_valid<=1;
          wr_en<=1;
          @(posedge wr_clk);
          while(!s_axis_top_ready)
            @(posedge wr_clk);
          s_axis_top_valid<=0;
          wr_en<=0;
          wait_n=$urandom%throttle;
          repeat(wait_n)
            begin
              @(posedge wr_clk);
            end
        end
      $fclose(fp);
    end
  endtask
  
  task automatic rd_reset_task(input int rd_reset_duration);
    int cycle_count_rd_reset;
    begin
      while(cycle_count_rd_reset<rd_reset_duration)
        begin
          cycle_count_rd_reset=cycle_count_rd_reset+1;
          rd_reset<=rd_reset;
          @(posedge rd_clk);
        end
      rd_reset<=~rd_reset;
    end
  endtask
  
  task automatic m_axis_top_ready_task;
    input int m_ready_duration;
    int cycle_count_m_ready;
    begin
      cycle_count_m_ready=0;
      while(cycle_count_m_ready<=m_ready_duration)
        begin
          cycle_count_m_ready=cycle_count_m_ready+1;
          m_axis_top_ready<=$urandom%2;
          @(posedge rd_clk);
        end
      m_axis_top_ready<=0;
    end
  endtask
  
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end
        assign  rd_en=m_axis_top_ready;
  
  
endmodule
