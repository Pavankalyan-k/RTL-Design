module pdcch_main_module#(
  parameter MAIN_MOD_CONFIG_BIT_WIDTH=$bits(pdcch_controller_configs),
  			MAIN_MOD_OP_DATA_WIDTH=8)(
  input clk,
  input reset,
  input [MAIN_MOD_CONFIG_BIT_WIDTH-1:0] s_axis_main_config_data,
  input s_axis_main_config_valid,
  output reg s_axis_main_config_ready,
  output reg [MAIN_MOD_OP_DATA_WIDTH-1:0] m_axis_main_data,
  output reg m_axis_main_valid,
  input m_axis_main_ready
);
  // Internal Implementation
  
  pdcch_controller_configs cont_configs_2;
  
  logic [30:0] x1,x2;
  logic [30:0] lfsr_x1,lfsr_x2;
  logic [44:0] freq_bit_map_sum;
  logic [10:0] count;
  
  typedef enum logic[2:0]{
    IDLE,
    CONT_CONFIG_READ,
    DATA_CALC,
    LFSR_READ,
    DATA_OUT
  }state;
  
  state present_state,next_state;
  
  always@(posedge clk)
    begin
      if(reset)
        present_state=IDLE;
      else
        present_state=next_state;
    end
  
  always@(*)
    begin
      case(present_state)
        IDLE:begin
          next_state=CONT_CONFIG_READ;
        end
        CONT_CONFIG_READ:begin
          if(s_axis_main_config_valid&&s_axis_main_config_ready)
            next_state=DATA_CALC;
          else
            next_state=CONT_CONFIG_READ;
        end
        DATA_CALC:begin
          next_state=LFSR_READ;
        end
        LFSR_READ:begin
          next_state=DATA_OUT;
        end
         DATA_OUT:begin
           if(m_axis_main_ready)
             next_state=IDLE;
           else
             next_state=DATA_OUT;
         end
        default:begin
          next_state=IDLE;
        end
      endcase
    end
  always@(posedge clk)
    
    begin
      if(reset)
        begin
          count<=0;
          cont_configs_2<=0;
          x1<=0;
          x2<=0;
      	  lfsr_x1<=0;
          lfsr_x2<=0;
          freq_bit_map_sum<=0;
          m_axis_main_data<=0;
          m_axis_main_valid<=0;
        end
      else
        begin
          case(present_state)
            IDLE:begin
            end
            CONT_CONFIG_READ:begin
              if(s_axis_main_config_valid&&s_axis_main_config_ready)
                cont_configs_2<=s_axis_main_config_data;
              else
                cont_configs_2<=cont_configs_2;
            end
            DATA_CALC:begin
              x2[0]<=cont_configs_2.C_init[1] ^ cont_configs_2.C_init[2] ^ cont_configs_2.C_init[3] ^ cont_configs_2.C_init[8] ^ cont_configs_2.C_init[12] ^ cont_configs_2.C_init[16] ^ cont_configs_2.C_init[19] ^ cont_configs_2.C_init[20] ^ cont_configs_2.C_init[23];
              x2[1]<=cont_configs_2.C_init[2] ^ cont_configs_2.C_init[3] ^ cont_configs_2.C_init[4] ^ cont_configs_2.C_init[9] ^ cont_configs_2.C_init[13] ^ cont_configs_2.C_init[17] ^ cont_configs_2.C_init[20] ^ cont_configs_2.C_init[21] ^ cont_configs_2.C_init[24];
              x2[2]<=cont_configs_2.C_init[3] ^ cont_configs_2.C_init[4] ^ cont_configs_2.C_init[5] ^ cont_configs_2.C_init[10] ^ cont_configs_2.C_init[14] ^ cont_configs_2.C_init[18] ^ cont_configs_2.C_init[21] ^ cont_configs_2.C_init[22] ^ cont_configs_2.C_init[25];
              x2[3]<=cont_configs_2.C_init[4] ^ cont_configs_2.C_init[5] ^ cont_configs_2.C_init[6] ^ cont_configs_2.C_init[11] ^ cont_configs_2.C_init[15] ^ cont_configs_2.C_init[19] ^ cont_configs_2.C_init[22] ^ cont_configs_2.C_init[23] ^ cont_configs_2.C_init[26];
              x2[4]<=cont_configs_2.C_init[5] ^ cont_configs_2.C_init[6] ^ cont_configs_2.C_init[7] ^ cont_configs_2.C_init[12] ^ cont_configs_2.C_init[16] ^ cont_configs_2.C_init[20] ^ cont_configs_2.C_init[23] ^ cont_configs_2.C_init[24] ^ cont_configs_2.C_init[27];
              x2[5] <= cont_configs_2.C_init[6] ^ cont_configs_2.C_init[7] ^ cont_configs_2.C_init[8] ^ cont_configs_2.C_init[13] ^ cont_configs_2.C_init[17] ^ cont_configs_2.C_init[21] ^ cont_configs_2.C_init[24] ^ cont_configs_2.C_init[25] ^ cont_configs_2.C_init[28];
              x2[6] <= cont_configs_2.C_init[7] ^ cont_configs_2.C_init[8] ^ cont_configs_2.C_init[9] ^ cont_configs_2.C_init[14] ^ cont_configs_2.C_init[18] ^ cont_configs_2.C_init[22] ^ cont_configs_2.C_init[25] ^ cont_configs_2.C_init[26] ^ cont_configs_2.C_init[29];
              x2[7] <= cont_configs_2.C_init[8] ^ cont_configs_2.C_init[9] ^ cont_configs_2.C_init[10] ^ cont_configs_2.C_init[15] ^ cont_configs_2.C_init[19] ^ cont_configs_2.C_init[23] ^ cont_configs_2.C_init[26] ^ cont_configs_2.C_init[27] ^ cont_configs_2.C_init[30];
              x2[8] <= cont_configs_2.C_init[0] ^ cont_configs_2.C_init[1] ^ cont_configs_2.C_init[2] ^ cont_configs_2.C_init[3] ^ cont_configs_2.C_init[9] ^ cont_configs_2.C_init[10] ^ cont_configs_2.C_init[11] ^ cont_configs_2.C_init[16] ^ cont_configs_2.C_init[20] ^ cont_configs_2.C_init[24] ^ cont_configs_2.C_init[27] ^ cont_configs_2.C_init[28];
              x2[9]<=cont_configs_2.C_init[1] ^ cont_configs_2.C_init[2] ^ cont_configs_2.C_init[3] ^ cont_configs_2.C_init[4] ^ cont_configs_2.C_init[10] ^ cont_configs_2.C_init[11] ^ cont_configs_2.C_init[12] ^ cont_configs_2.C_init[17] ^ cont_configs_2.C_init[21] ^ cont_configs_2.C_init[25] ^ cont_configs_2.C_init[28] ^ cont_configs_2.C_init[29];
              x2[10] <= cont_configs_2.C_init[2] ^ cont_configs_2.C_init[3] ^ cont_configs_2.C_init[4] ^ cont_configs_2.C_init[5] ^ cont_configs_2.C_init[11] ^ cont_configs_2.C_init[12] ^ cont_configs_2.C_init[13] ^ cont_configs_2.C_init[18] ^ cont_configs_2.C_init[22] ^ cont_configs_2.C_init[26] ^ cont_configs_2.C_init[29] ^ cont_configs_2.C_init[30];
              x2[11] <= cont_configs_2.C_init[0] ^ cont_configs_2.C_init[1] ^ cont_configs_2.C_init[2] ^ cont_configs_2.C_init[4] ^ cont_configs_2.C_init[5] ^ cont_configs_2.C_init[6] ^ cont_configs_2.C_init[12] ^ cont_configs_2.C_init[13] ^ cont_configs_2.C_init[14] ^ cont_configs_2.C_init[19] ^ cont_configs_2.C_init[23] ^ cont_configs_2.C_init[27] ^ cont_configs_2.C_init[30];
              x2[12] <= cont_configs_2.C_init[0] ^ cont_configs_2.C_init[5] ^ cont_configs_2.C_init[6] ^ cont_configs_2.C_init[7] ^ cont_configs_2.C_init[13] ^ cont_configs_2.C_init[14] ^ cont_configs_2.C_init[15] ^ cont_configs_2.C_init[20] ^ cont_configs_2.C_init[24] ^ cont_configs_2.C_init[28];
              x2[13] <= cont_configs_2.C_init[1] ^ cont_configs_2.C_init[6] ^ cont_configs_2.C_init[7] ^ cont_configs_2.C_init[8] ^ cont_configs_2.C_init[14] ^ cont_configs_2.C_init[15] ^ cont_configs_2.C_init[16] ^ cont_configs_2.C_init[21] ^ cont_configs_2.C_init[25] ^ cont_configs_2.C_init[29];
              x2[14] <= cont_configs_2.C_init[2] ^ cont_configs_2.C_init[7] ^ cont_configs_2.C_init[8] ^ cont_configs_2.C_init[9] ^ cont_configs_2.C_init[15] ^ cont_configs_2.C_init[16] ^ cont_configs_2.C_init[17] ^ cont_configs_2.C_init[22] ^ cont_configs_2.C_init[26] ^ cont_configs_2.C_init[30];
              x2[15] <= cont_configs_2.C_init[0] ^ cont_configs_2.C_init[1] ^ cont_configs_2.C_init[2] ^ cont_configs_2.C_init[8] ^ cont_configs_2.C_init[9] ^ cont_configs_2.C_init[10] ^ cont_configs_2.C_init[16] ^ cont_configs_2.C_init[17] ^ cont_configs_2.C_init[18] ^ cont_configs_2.C_init[23] ^ cont_configs_2.C_init[27];
              x2[16] <= cont_configs_2.C_init[1] ^ cont_configs_2.C_init[2] ^ cont_configs_2.C_init[3] ^ cont_configs_2.C_init[9] ^ cont_configs_2.C_init[10] ^ cont_configs_2.C_init[11] ^ cont_configs_2.C_init[17] ^ cont_configs_2.C_init[18] ^ cont_configs_2.C_init[19] ^ cont_configs_2.C_init[24] ^ cont_configs_2.C_init[28];
              x2[17] <= cont_configs_2.C_init[2] ^ cont_configs_2.C_init[3] ^ cont_configs_2.C_init[4] ^ cont_configs_2.C_init[10] ^ cont_configs_2.C_init[11] ^ cont_configs_2.C_init[12] ^ cont_configs_2.C_init[18] ^ cont_configs_2.C_init[19] ^ cont_configs_2.C_init[20] ^ cont_configs_2.C_init[25] ^ cont_configs_2.C_init[29];
              x2[18] <= cont_configs_2.C_init[3] ^ cont_configs_2.C_init[4] ^ cont_configs_2.C_init[5] ^ cont_configs_2.C_init[11] ^ cont_configs_2.C_init[12] ^ cont_configs_2.C_init[13] ^ cont_configs_2.C_init[19] ^ cont_configs_2.C_init[20] ^ cont_configs_2.C_init[21] ^ cont_configs_2.C_init[26] ^ cont_configs_2.C_init[30];
              x2[19] <= cont_configs_2.C_init[0] ^ cont_configs_2.C_init[1] ^ cont_configs_2.C_init[2] ^ cont_configs_2.C_init[3] ^ cont_configs_2.C_init[4] ^ cont_configs_2.C_init[5] ^ cont_configs_2.C_init[6] ^ cont_configs_2.C_init[12] ^ cont_configs_2.C_init[13] ^ cont_configs_2.C_init[14] ^ cont_configs_2.C_init[20] ^ cont_configs_2.C_init[21] ^ cont_configs_2.C_init[22] ^ cont_configs_2.C_init[27];
              x2[20] <= cont_configs_2.C_init[1] ^ cont_configs_2.C_init[2] ^ cont_configs_2.C_init[3] ^ cont_configs_2.C_init[4] ^ cont_configs_2.C_init[5] ^ cont_configs_2.C_init[6] ^ cont_configs_2.C_init[7] ^ cont_configs_2.C_init[13] ^ cont_configs_2.C_init[14] ^ cont_configs_2.C_init[15] ^ cont_configs_2.C_init[21] ^ cont_configs_2.C_init[22] ^ cont_configs_2.C_init[23] ^ cont_configs_2.C_init[28];
              x2[21] <= cont_configs_2.C_init[2] ^ cont_configs_2.C_init[3] ^ cont_configs_2.C_init[4] ^ cont_configs_2.C_init[5] ^ cont_configs_2.C_init[6] ^ cont_configs_2.C_init[7] ^ cont_configs_2.C_init[8] ^ cont_configs_2.C_init[14] ^ cont_configs_2.C_init[15] ^ cont_configs_2.C_init[16] ^ cont_configs_2.C_init[22] ^ cont_configs_2.C_init[23] ^ cont_configs_2.C_init[24] ^ cont_configs_2.C_init[29];
              x2[22] <= cont_configs_2.C_init[3] ^ cont_configs_2.C_init[4] ^ cont_configs_2.C_init[5] ^ cont_configs_2.C_init[6] ^ cont_configs_2.C_init[7] ^ cont_configs_2.C_init[8] ^ cont_configs_2.C_init[9] ^ cont_configs_2.C_init[15] ^ cont_configs_2.C_init[16] ^ cont_configs_2.C_init[17] ^ cont_configs_2.C_init[23] ^ cont_configs_2.C_init[24] ^ cont_configs_2.C_init[25] ^ cont_configs_2.C_init[30];
              x2[23] <= cont_configs_2.C_init[0] ^ cont_configs_2.C_init[1] ^ cont_configs_2.C_init[2] ^ cont_configs_2.C_init[3] ^ cont_configs_2.C_init[4] ^ cont_configs_2.C_init[5] ^ cont_configs_2.C_init[6] ^ cont_configs_2.C_init[7] ^ cont_configs_2.C_init[8] ^ cont_configs_2.C_init[9] ^ cont_configs_2.C_init[10] ^ cont_configs_2.C_init[16] ^ cont_configs_2.C_init[17] ^ cont_configs_2.C_init[18] ^ cont_configs_2.C_init[24] ^ cont_configs_2.C_init[25] ^ cont_configs_2.C_init[26];
              x2[24] <= cont_configs_2.C_init[1] ^ cont_configs_2.C_init[2] ^ cont_configs_2.C_init[3] ^ cont_configs_2.C_init[4] ^ cont_configs_2.C_init[5] ^ cont_configs_2.C_init[6] ^ cont_configs_2.C_init[7] ^ cont_configs_2.C_init[8] ^ cont_configs_2.C_init[9] ^ cont_configs_2.C_init[10] ^ cont_configs_2.C_init[11] ^ cont_configs_2.C_init[17] ^ cont_configs_2.C_init[18] ^ cont_configs_2.C_init[19] ^ cont_configs_2.C_init[25] ^ cont_configs_2.C_init[26] ^ cont_configs_2.C_init[27];
             x2[25] <= cont_configs_2.C_init[2] ^ cont_configs_2.C_init[3] ^ cont_configs_2.C_init[4] ^ cont_configs_2.C_init[5] ^ cont_configs_2.C_init[6] ^ cont_configs_2.C_init[7] ^ cont_configs_2.C_init[8] ^ cont_configs_2.C_init[9] ^ cont_configs_2.C_init[10] ^ cont_configs_2.C_init[11] ^ cont_configs_2.C_init[12] ^ cont_configs_2.C_init[18] ^ cont_configs_2.C_init[19] ^ cont_configs_2.C_init[20] ^ cont_configs_2.C_init[26] ^ cont_configs_2.C_init[27] ^ cont_configs_2.C_init[28];
             x2[26] <= cont_configs_2.C_init[3] ^ cont_configs_2.C_init[4] ^ cont_configs_2.C_init[5] ^ cont_configs_2.C_init[6] ^ cont_configs_2.C_init[7] ^ cont_configs_2.C_init[8] ^ cont_configs_2.C_init[9] ^ cont_configs_2.C_init[10] ^ cont_configs_2.C_init[11] ^ cont_configs_2.C_init[12] ^ cont_configs_2.C_init[13] ^ cont_configs_2.C_init[19] ^ cont_configs_2.C_init[20] ^ cont_configs_2.C_init[21] ^ cont_configs_2.C_init[27] ^ cont_configs_2.C_init[28] ^ cont_configs_2.C_init[29];
            x2[27] <= cont_configs_2.C_init[4] ^ cont_configs_2.C_init[5] ^ cont_configs_2.C_init[6] ^ cont_configs_2.C_init[7] ^ cont_configs_2.C_init[8] ^ cont_configs_2.C_init[9] ^ cont_configs_2.C_init[10] ^ cont_configs_2.C_init[11] ^ cont_configs_2.C_init[12] ^ cont_configs_2.C_init[13] ^ cont_configs_2.C_init[14] ^ cont_configs_2.C_init[20] ^ cont_configs_2.C_init[21] ^ cont_configs_2.C_init[22] ^ cont_configs_2.C_init[28] ^ cont_configs_2.C_init[29] ^ cont_configs_2.C_init[30];
            x2[28] <= cont_configs_2.C_init[0] ^ cont_configs_2.C_init[1] ^ cont_configs_2.C_init[2] ^ cont_configs_2.C_init[3] ^ cont_configs_2.C_init[4] ^ cont_configs_2.C_init[5] ^ cont_configs_2.C_init[6] ^ cont_configs_2.C_init[7] ^ cont_configs_2.C_init[8] ^ cont_configs_2.C_init[9] ^ cont_configs_2.C_init[10] ^ cont_configs_2.C_init[11] ^ cont_configs_2.C_init[12] ^ cont_configs_2.C_init[13] ^ cont_configs_2.C_init[14] ^ cont_configs_2.C_init[20] ^ cont_configs_2.C_init[21] ^ cont_configs_2.C_init[22] ^ cont_configs_2.C_init[28] ^ cont_configs_2.C_init[29] ^ cont_configs_2.C_init[30];
            x2[29] <= cont_configs_2.C_init[1] ^ cont_configs_2.C_init[2] ^ cont_configs_2.C_init[3] ^ cont_configs_2.C_init[4] ^ cont_configs_2.C_init[5] ^ cont_configs_2.C_init[6] ^ cont_configs_2.C_init[7] ^ cont_configs_2.C_init[8] ^ cont_configs_2.C_init[9] ^ cont_configs_2.C_init[10] ^ cont_configs_2.C_init[11] ^ cont_configs_2.C_init[12] ^ cont_configs_2.C_init[13] ^ cont_configs_2.C_init[14] ^ cont_configs_2.C_init[15] ^ cont_configs_2.C_init[21] ^ cont_configs_2.C_init[22] ^ cont_configs_2.C_init[23] ^ cont_configs_2.C_init[29] ^ cont_configs_2.C_init[30];
            x2[30] <= cont_configs_2.C_init[2] ^ cont_configs_2.C_init[3] ^ cont_configs_2.C_init[4] ^ cont_configs_2.C_init[5] ^ cont_configs_2.C_init[6] ^ cont_configs_2.C_init[7] ^ cont_configs_2.C_init[8] ^ cont_configs_2.C_init[9] ^ cont_configs_2.C_init[10] ^ cont_configs_2.C_init[11] ^ cont_configs_2.C_init[12] ^ cont_configs_2.C_init[13] ^ cont_configs_2.C_init[14] ^ cont_configs_2.C_init[15] ^ cont_configs_2.C_init[16] ^ cont_configs_2.C_init[22] ^ cont_configs_2.C_init[23] ^ cont_configs_2.C_init[24] ^ cont_configs_2.C_init[30];
        x1<=500;
            end
            LFSR_READ:begin
              if(m_axis_main_ready)
                freq_bit_map_sum <= (cont_configs_2.freq_bit_map[44] + cont_configs_2.freq_bit_map[43] + cont_configs_2.freq_bit_map[42] + cont_configs_2.freq_bit_map[41] + cont_configs_2.freq_bit_map[40] + cont_configs_2.freq_bit_map[39] + cont_configs_2.freq_bit_map[38] + cont_configs_2.freq_bit_map[37] + cont_configs_2.freq_bit_map[36] + cont_configs_2.freq_bit_map[35] + cont_configs_2.freq_bit_map[34] + cont_configs_2.freq_bit_map[33] + cont_configs_2.freq_bit_map[32] + cont_configs_2.freq_bit_map[31] + cont_configs_2.freq_bit_map[30] + cont_configs_2.freq_bit_map[29] + cont_configs_2.freq_bit_map[28] + cont_configs_2.freq_bit_map[27] + cont_configs_2.freq_bit_map[26] + cont_configs_2.freq_bit_map[25] + cont_configs_2.freq_bit_map[24] + cont_configs_2.freq_bit_map[23] + cont_configs_2.freq_bit_map[22] + cont_configs_2.freq_bit_map[21] + cont_configs_2.freq_bit_map[20] + cont_configs_2.freq_bit_map[19] + cont_configs_2.freq_bit_map[18] + cont_configs_2.freq_bit_map[17] + cont_configs_2.freq_bit_map[16] + cont_configs_2.freq_bit_map[15] + cont_configs_2.freq_bit_map[14] + cont_configs_2.freq_bit_map[13] + cont_configs_2.freq_bit_map[12] + cont_configs_2.freq_bit_map[11] + cont_configs_2.freq_bit_map[10] + cont_configs_2.freq_bit_map[9] + cont_configs_2.freq_bit_map[8] + cont_configs_2.freq_bit_map[7] + cont_configs_2.freq_bit_map[6] + cont_configs_2.freq_bit_map[5] + cont_configs_2.freq_bit_map[4] + cont_configs_2.freq_bit_map[3] + cont_configs_2.freq_bit_map[2] + cont_configs_2.freq_bit_map[1] + cont_configs_2.freq_bit_map[0]);
              lfsr_x1<=x1;
              lfsr_x2<=x2;
            end
            DATA_OUT:begin
              if((count >= cont_configs_2.dmrs_offset) && (count <= cont_configs_2.Pn_Sequence_length)) 
                begin
                  if(m_axis_main_ready)
                    begin
                      lfsr_x1 <={lfsr_x1[(count+3)]^lfsr_x1[count],lfsr_x1[30:1]};
                      lfsr_x2 <={(lfsr_x2[(count+3)]^lfsr_x2[(count+2)]^lfsr_x2[(count+1)]^lfsr_x2[count]),lfsr_x2[30:1]};
                      m_axis_main_data[0] <= lfsr_x1[0] ^ lfsr_x2[0];
                      m_axis_main_data[1] <= lfsr_x1[1] ^ lfsr_x2[1];
                      m_axis_main_data[7:2] <= 0;
                      m_axis_main_valid <= 1'b1;
                      count <= count + 1'b1;
                   end
                  else
                    begin
                  	  lfsr_x1<= lfsr_x1;
                      lfsr_x2<=lfsr_x2;
                      m_axis_main_data<=m_axis_main_data;
                      m_axis_main_valid<=0;
                      count<=count;
                    end
                end
              else
            	begin
               	  count <= count + 1'b1;
            	end
            end
            default:begin
              m_axis_main_data<=0;
          	  m_axis_main_valid<=0;
            end
      endcase
    end
    end
  
  
  
  always@(*)
    begin
      if(reset)
        begin
          s_axis_main_config_ready=0;
        end
      else
        begin
          case(present_state)
            IDLE:s_axis_main_config_ready=0;
            CONT_CONFIG_READ:s_axis_main_config_ready=1;
            DATA_CALC:s_axis_main_config_ready=0;
            LFSR_READ:s_axis_main_config_ready=0;
            DATA_OUT:s_axis_main_config_ready=0;
          endcase
        end
    end
  
          
  
endmodule
