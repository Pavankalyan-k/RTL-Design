`include "pdcch.svh"
`include "skid_buffer.sv"
`include "pdcch_controller.sv"
`include "pdcch_main_module.sv"
`include "fifo.sv"

module pdcch_top#(parameter
  TOP_CONFIG_BIT_WIDTH=$bits(pdcch_top_configs),
  CONT_CONFIG_BIT_WIDTH=$bits(pdcch_controller_configs),
  OP_DATA_WIDTH=8,
  FIFO_DEPTH=2048,
  PTR_SIZE=$clog2(FIFO_DEPTH)
)
  (
    input 								clk,
  	input 								reset,
  
  	input [TOP_CONFIG_BIT_WIDTH-1:0]  	s_axis_top_config_data,
  	input 								s_axis_top_config_valid,
  	output 								s_axis_top_config_ready,
  
  	output logic [OP_DATA_WIDTH-1:0] 	m_axis_top_data,
  	output logic 						m_axis_top_valid,
  	input 								m_axis_top_ready
);
  // skid_instantiation for top_configs
  // skid wires
  wire [TOP_CONFIG_BIT_WIDTH-1:0] 		skid_data;
  wire 									skid_valid;
  wire 									skid_ready;
  
  
  skid_buffer#(
    TOP_CONFIG_BIT_WIDTH) 
  s1(
    clk,
    reset,
    s_axis_top_config_valid,
    s_axis_top_config_data,
    s_axis_top_config_ready,
    skid_data,
    skid_valid,
    skid_ready
  );
  
  // Controller Instantiation
  
  // controller wires
  wire [CONT_CONFIG_BIT_WIDTH-1:0] 		cont_data;
  wire 									cont_valid;
  wire 									cont_ready;
  
  pdcch_controller#(
    CONT_CONFIG_BIT_WIDTH,
    TOP_CONFIG_BIT_WIDTH)
  p1(
    clk,
    reset,
    skid_data,
    skid_valid,
    skid_ready,
    cont_data,
    cont_valid,
    cont_ready
  );
  
  // Controller-skid 
  // skid 2nd Instantiation
  wire [CONT_CONFIG_BIT_WIDTH-1:0] 		skid_2_main_data;
  wire 									skid_2_main_valid;
  wire 									skid_2_main_ready;
  
  skid_buffer#(
    CONT_CONFIG_BIT_WIDTH)
  s2(
    clk,
    reset,
    cont_valid,
    cont_data,
    cont_ready,
    skid_2_main_data,
    skid_2_main_valid,
    skid_2_main_ready
  );
  
  // Main Module Instantiation
  
  wire [OP_DATA_WIDTH-1:0] 				main_2_fifo_data;
  wire 									main_2_fifo_valid;
  wire 									main_2_fifo_ready;
  
  pdcch_main_module#(
    CONT_CONFIG_BIT_WIDTH,
    OP_DATA_WIDTH)
  m1(
    clk,
    reset,
    skid_2_main_data,
    skid_2_main_valid,
    skid_2_main_ready,
    main_2_fifo_data,
    main_2_fifo_valid,
    main_2_fifo_ready
  );
  // FIFO Instantiation
  reg full,empty;
  
  sync_fifo#(
    OP_DATA_WIDTH,
    FIFO_DEPTH,
    PTR_SIZE) 
  sf_1(
    clk,
    reset,
    main_2_fifo_valid && main_2_fifo_ready,
    m_axis_top_ready,
    main_2_fifo_data,
    main_2_fifo_valid,
    m_axis_top_ready,
    m_axis_top_data,
    m_axis_top_valid,
    main_2_fifo_ready,
    full,
    empty
  );
  
  
  
  
endmodule
  
