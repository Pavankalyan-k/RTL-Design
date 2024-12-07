typedef struct packed{
  logic [8:0] Bwpsize;
  logic [11:0] Bwpstart;
  logic [1:0] coreset;
  logic [6:0] slotnumber;
  logic [15:0] N_id;
  logic [3:0] start_symbol;
  logic [1:0] start_symbol_index;
  logic [12:0] dmrs_offset;
  logic [44:0] freq_bitmap;
}pucch_top_configs_1;


typedef struct packed{
  logic [30:0] C_init;
  logic [15:0] Pn_Sequence_length;
  logic [12:0] dmrs_offset;
  logic [44:0] freq_bit_map;
}pdcch_controller_configs_1;

module data_generator();
  parameter DATA_WIDTH=64,DEPTH=2048,PTR_SIZE=$clog2(DEPTH),OP_DW_1=$bits(pucch_top_configs_1);
  
  logic clk;
  logic reset;
  logic [DATA_WIDTH-1:0] s_axis_data;
  logic s_axis_valid;
  logic s_axis_ready;
  logic [OP_DW_1-1:0] m_axis_data_1;
  logic m_axis_valid_1;
  logic m_axis_ready_1;
  logic [DATA_WIDTH-1:0] m_axis_data_2;
  logic m_axis_valid_2;
  logic m_axis_ready_2;
  
  
  
  
  //Design Instantiation
  
  top#(DATA_WIDTH,DEPTH,PTR_SIZE,OP_DW_1) t1(clk,
                                            reset,
                                            s_axis_data,
                                            s_axis_valid,
                                            s_axis_ready,
                                            m_axis_data_1,
                                            m_axis_valid_1,
                                             m_axis_ready_1,
                                            m_axis_data_2,
                                            m_axis_valid_2,
                                            m_axis_ready_2);
  localparam string datafile="file.mem";
  
  always#5 clk=~clk;
  
  
  initial
    begin
      clk=0;
      reset=1;
      s_axis_data=0;
      s_axis_valid=0;
      m_axis_ready_1=0;
      m_axis_ready_2=0;
      reset_task;
      fork
        data_gen(datafile,1);
        m_axis_ready_task(200);
        m_axis_ready_task_2(200);
      join
      
      $finish;
        
    end
  
  task automatic reset_task;
    begin
      repeat(2)@(posedge clk);
      reset<=~reset;
    end
  endtask
  
  task automatic data_gen;
    input string filename;
    input int throttle;
    begin
      int fp,wait_n;
      logic [7:0] pio=2;
      logic [63:0] file_mem;
      fp=$fopen(filename,"r");
      if(fp == 0)
        $display("Error in Opening file");
      else
        begin
        end
      if(pio == 2)
        begin
          while($fscanf(fp,"%h",file_mem)==1)
            begin
              s_axis_data<=file_mem;
              s_axis_valid<=1;
              @(posedge clk);
              while(!s_axis_ready)
                @(posedge clk);
              s_axis_valid<=0;
              wait_n=$urandom%throttle;
              repeat(wait_n)
                begin
                  @(posedge clk);
                end
            end
        end
      $fclose(fp);
      end
  endtask
  
  task automatic m_axis_ready_task(input int duration_cycles);
    int cycle_count;
    begin
      cycle_count=0;
      while(cycle_count < duration_cycles)
        begin
          m_axis_ready_1<=$urandom%2;
          cycle_count=cycle_count+1;
          @(posedge clk);
        end
      m_axis_ready_1<=1;
    end
  endtask
  
  task automatic m_axis_ready_task_2(input int duration_cycles);
    int cycle_count;
    begin
      cycle_count=0;
      while(cycle_count < duration_cycles)
        begin
          m_axis_ready_2<=$urandom%2;
          cycle_count=cycle_count+1;
          @(posedge clk);
        end
      m_axis_ready_2<=1;
    end
  endtask
  
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end
  
endmodule
              
      
      
