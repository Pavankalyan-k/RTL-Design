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
}pucch_top_configs;


typedef struct packed{
  logic [30:0] C_init;
  logic [15:0] Pn_Sequence_length;
  logic [12:0] dmrs_offset;
  logic [44:0] freq_bit_map;
}pdcch_controller_configs;
