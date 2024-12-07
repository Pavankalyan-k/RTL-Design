module data_router#
  (parameter
   DATA_WIDTH=64,
   OP_DW_1=$bits(pucch_top_configs))(
    input clk,
    input reset,
    
    input  [DATA_WIDTH-1:0] 		s_axis_router_input,
    input   						s_axis_router_input_valid,
    output 	reg			    		s_axis_router_input_ready,
    
    output reg [OP_DW_1-1:0]		m_axis_router_output_1,
    output reg						m_axis_router_output_1_valid,
    input 							m_axis_router_output_1_ready,
    
    output 	reg	[DATA_WIDTH-1:0] 	m_axis_router_output_2,
    output 	reg						m_axis_router_output_2_valid,
    input 							m_axis_router_output_2_ready

  );
  reg[9:0] CONFIG_LENGTH;
  reg [53:0] NO_OF_DATA_PACKETS;
  reg [3:0] config_counter;
  
  typedef enum logic[1:0] {
    IDLE,
    DATA_DIV,
    DATA_CONFIG_OUT,
    DATA_OUT
  }state;
  
  state present_state,next_state;
  
  always@(posedge clk)
    begin
      if(reset)
        present_state<=IDLE;
      else
        present_state<=next_state;
    end
  
  always@(*)
    begin
      case(present_state)
        IDLE:begin
          next_state=DATA_DIV;
        end
        DATA_DIV:begin
          if(s_axis_router_input_valid && s_axis_router_input_ready)
          	next_state=DATA_CONFIG_OUT;
          else
            next_state=DATA_DIV;
        end
        DATA_CONFIG_OUT:begin
          if(config_counter!=CONFIG_LENGTH)begin
            if(s_axis_router_input_valid && s_axis_router_input_ready )
              next_state=DATA_CONFIG_OUT;
            else
              next_state=DATA_CONFIG_OUT;
          end
          else
            next_state=DATA_OUT;
        end
        DATA_OUT:begin
          if(s_axis_router_input_valid && s_axis_router_input_ready && NO_OF_DATA_PACKETS==0)
            next_state=IDLE;
          else
            next_state=DATA_OUT;
        end
      endcase
    end
          
          
  
  always@(posedge clk)
    begin
      if(reset)
        begin
          m_axis_router_output_1<=0;
          m_axis_router_output_1_valid<=0;
          m_axis_router_output_2<=0;
          m_axis_router_output_2_valid<=0;
          CONFIG_LENGTH<=0;
          NO_OF_DATA_PACKETS<=0;
          config_counter<=0;
        end
      else
        begin
          case(present_state)
            IDLE:begin
              config_counter<=0;
            end
        	DATA_DIV:begin
              if(s_axis_router_input_valid && s_axis_router_input_ready)
                begin
              	  CONFIG_LENGTH<=s_axis_router_input[9:0];
              	  //m_axis_router_output_1_valid<=1;
              	  NO_OF_DATA_PACKETS<=s_axis_router_input[63:10];
              	  //m_axis_router_output_2_valid<=1;
            	end
          	  else
            	begin
              	  CONFIG_LENGTH<=CONFIG_LENGTH;
				//m_axis_router_output_1_valid<=m_axis_router_output_1_valid;
              	  NO_OF_DATA_PACKETS<=NO_OF_DATA_PACKETS;
				//m_axis_router_output_2_valid<=m_axis_router_output_2_valid;
            	end
            end
            DATA_CONFIG_OUT:begin
              if(config_counter<CONFIG_LENGTH)
              begin
                if(config_counter==CONFIG_LENGTH-1)
                  begin
                    m_axis_router_output_1_valid<=1;
                  end
                
                if(s_axis_router_input_valid && s_axis_router_input_ready)
                  begin
                    m_axis_router_output_1[config_counter*DATA_WIDTH+:DATA_WIDTH]<=s_axis_router_input;
                    //{s_axis_router_input,m_axis_router_output_1[OP_DW_1-DATA_WIDTH:0]};
                    //m_axis_router_output_1_valid<=0;
                    config_counter<=config_counter+1;
                  end
                else
                  begin
					m_axis_router_output_1<=m_axis_router_output_1;
                    m_axis_router_output_1_valid<=0;
                    CONFIG_LENGTH=CONFIG_LENGTH;
                  end
              end
              else
                begin
                  m_axis_router_output_1<=m_axis_router_output_1;
                  m_axis_router_output_1_valid<=0;
                  CONFIG_LENGTH=CONFIG_LENGTH;
                end
            end
            DATA_OUT:begin
              if(NO_OF_DATA_PACKETS!=0)
                begin
                  if(s_axis_router_input_valid && s_axis_router_input_ready)
                    begin
                      m_axis_router_output_2<=s_axis_router_input;
                      m_axis_router_output_2_valid<=1;
                      NO_OF_DATA_PACKETS<=NO_OF_DATA_PACKETS-1;
                    end
                  else
                    begin
                      m_axis_router_output_2<=m_axis_router_output_2;
                      m_axis_router_output_2_valid<=0;
                      NO_OF_DATA_PACKETS<=NO_OF_DATA_PACKETS;
                    end
                end
              else
                begin
                  m_axis_router_output_2<=m_axis_router_output_2;
                  NO_OF_DATA_PACKETS<=NO_OF_DATA_PACKETS;
                  m_axis_router_output_2_valid<=0;
                end
            end
          endcase
        end
    end
  
  always@(*)
    begin
      if(reset)
        s_axis_router_input_ready=0;
      else
        begin
          case(present_state)
            IDLE:begin
              s_axis_router_input_ready=0;
            end
            DATA_DIV:begin
              s_axis_router_input_ready=1;
            end
            DATA_CONFIG_OUT:begin
              s_axis_router_input_ready=m_axis_router_output_1_ready ;
            end
            DATA_OUT:begin
              s_axis_router_input_ready=m_axis_router_output_2_ready;
              end
          endcase
        end
    end
endmodule
      
