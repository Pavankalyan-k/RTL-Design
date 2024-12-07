module pdcch_controller#(
  parameter CONT_OP_CONFIG_BIT_WIDTH=$bits(pdcch_controller_configs),
  CONT_IP_CONFIG_BIT_WIDTH=$bits(pdcch_top_configs))(
  input clk,
  input reset,
  input [CONT_IP_CONFIG_BIT_WIDTH-1:0] s_axis_cont_config_data,
  input s_axis_cont_config_valid,
  output reg s_axis_cont_config_ready,
  output reg [CONT_OP_CONFIG_BIT_WIDTH-1:0] m_axis_cont_config_data,
  output reg m_axis_cont_config_valid,
  input m_axis_cont_config_ready
);
  pdcch_top_configs top_configs_1;
  pdcch_controller_configs cont_configs_1;
  
  typedef enum logic[1:0]{ 
    IDLE,
    CONT_CONFIG_READ,
    CONT_DATA_CALC,
    CONT_DATA_OUT
  }controller_state;
  
  controller_state cont_present_state,cont_next_state;
  
  always@(posedge clk)
    begin
      if(reset)
        begin
          cont_present_state<=IDLE;
        end
      else
        cont_present_state<=cont_next_state;
    end
  
  always@(*)
    begin
      case(cont_present_state)
        IDLE:begin
          cont_next_state=CONT_CONFIG_READ;
        end
        CONT_CONFIG_READ:begin
          if(s_axis_cont_config_valid && s_axis_cont_config_ready)
            cont_next_state=CONT_DATA_CALC;
          else
            cont_next_state=CONT_CONFIG_READ;
        end
        CONT_DATA_CALC:begin
          cont_next_state=CONT_DATA_OUT;
        end
        CONT_DATA_OUT:begin
          if(m_axis_cont_config_ready)
            cont_next_state=IDLE;
          else
            cont_next_state=CONT_DATA_OUT;
        end
        default:cont_next_state=IDLE;
      endcase
    end
  
  always@(posedge clk)
    begin
      if(reset)begin
        cont_configs_1.C_init<=0;
        cont_configs_1.Pn_Sequence_length<=0;
        cont_configs_1.dmrs_offset<=0;
        cont_configs_1.freq_bit_map<=0;
        top_configs_1<=0;
      end
      else
        begin
          case(cont_present_state)
            IDLE:begin
            end
            CONT_CONFIG_READ:begin
              if(s_axis_cont_config_valid && s_axis_cont_config_ready)
                begin
                  top_configs_1<=s_axis_cont_config_data;
                end
              else
                top_configs_1<=top_configs_1;
            end
            CONT_DATA_CALC:begin
              cont_configs_1.C_init<=((2^17)*((((14*top_configs_1.slotnumber*top_configs_1.start_symbol_index)+ (1))*(2*top_configs_1.N_id+1))+2*top_configs_1.N_id))%2^31;
              if(top_configs_1.coreset_type0==1)
                begin
                  cont_configs_1.Pn_Sequence_length<=(top_configs_1.Bwpsize*top_configs_1.Bwpstart)*6;
                  cont_configs_1.dmrs_offset<=cont_configs_1.dmrs_offset;
                end
              else
                begin
                  cont_configs_1.Pn_Sequence_length<=top_configs_1.Bwpsize*6;
                end              
              cont_configs_1.freq_bit_map<=cont_configs_1.freq_bit_map;
            end
            CONT_DATA_OUT:begin
              if(m_axis_cont_config_ready)
                begin
             	  m_axis_cont_config_data<=cont_configs_1;
              	  m_axis_cont_config_valid<=1;
                end
              else
                begin
                  m_axis_cont_config_data<=m_axis_cont_config_data;
                  m_axis_cont_config_valid<=0;
                end
            end
          endcase
        end
    end
  
  always@(*)
    begin
      if(reset)
        s_axis_cont_config_ready=0;
      else
        begin
          case(cont_present_state)
            IDLE:s_axis_cont_config_ready=0;
            CONT_CONFIG_READ:s_axis_cont_config_ready=1;
            CONT_DATA_CALC:s_axis_cont_config_ready=0;
            CONT_DATA_OUT:s_axis_cont_config_ready=0;
          endcase
        end
    end
  
endmodule
