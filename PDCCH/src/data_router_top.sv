`include "fifo.sv"
`include "pdcch.svh"
`include "data_router.sv"

module top#(DATA_WIDTH=64,
            DEPTH=2048,
            PTR_SIZE=$clog2(DEPTH),
            OP_DW_1=$bits(pucch_top_configs))(
  input clk,
  input reset,
  
  input [DATA_WIDTH-1:0] s_axis_data,
  input s_axis_valid,
  output reg s_axis_ready,
  
  output reg[OP_DW_1-1:0] m_axis_data_1,
  output reg m_axis_valid_1,
  input m_axis_ready_1,
  
  output reg[DATA_WIDTH-1:0] m_axis_data_2,
  output reg m_axis_valid_2,
  input m_axis_ready_2

);
  
  wire[DATA_WIDTH-1:0] fifo_out;
  wire fifo_out_valid;
  wire fifo_out_ready;
  reg full,empty;
   
  // fifo Instantiation
  sync_fifo#(DATA_WIDTH,DEPTH,PTR_SIZE) s1(clk,
                                           reset,
                                            s_axis_valid&&s_axis_ready,
                                            fifo_out_ready,
                                           s_axis_data,
                                           s_axis_valid,
                                           fifo_out_ready,
                                           fifo_out,
                                           fifo_out_valid,
                                           s_axis_ready,
                                           full,
                                            empty);
  
  //data_router Instantiation
  
  data_router#(DATA_WIDTH,
               OP_DW_1) d1(clk,
                            reset,
                            fifo_out,
                            fifo_out_valid,
                            fifo_out_ready,
                            m_axis_data_1,
                            m_axis_valid_1,
                            m_axis_ready_1,
                            m_axis_data_2,
                            m_axis_valid_2,
                            m_axis_ready_2
                           );
endmodule
