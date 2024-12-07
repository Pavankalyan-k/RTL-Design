module skid_buffer#(parameter DATA_WIDTH=$bits(pdcch_top_configs),OPT_LOWPOWER=1,OPT_OUTREG=1)(
    input clk,
    input reset,
    //Input interface
    input s_axis_valid,
    input [DATA_WIDTH-1:0] s_axis_data,
    output reg s_axis_ready,
    // output interface
    output reg [DATA_WIDTH-1:0] m_axis_data,
    output  reg m_axis_valid,
    input m_axis_ready
);
    // Internal register
    reg r_valid;
    reg [DATA_WIDTH-1:0] r_data;

    always@(posedge clk)
        begin
            if(reset)
                begin
                    r_valid<=0;
                end
          else if((((s_axis_valid && s_axis_ready) && (  m_axis_valid && !m_axis_ready))) || ((s_axis_valid && s_axis_ready)  && (!m_axis_ready)))
                begin
                    r_valid<=1;
                end
            else if(m_axis_ready)
                begin
                    r_valid<=0;
                end
        end
  
 initial r_data=0;
  always@(posedge clk)
    begin
      if(OPT_LOWPOWER && reset)
        begin
          r_data<=0;
        end
      else if(OPT_LOWPOWER && ( m_axis_ready))
        begin
          r_data<=0;
        end
      else if((!OPT_LOWPOWER || s_axis_valid ) && (s_axis_ready))
        begin
          r_data<=s_axis_data;
        end
      else if((!OPT_LOWPOWER || !OPT_OUTREG || s_axis_valid) && s_axis_ready)
        begin
          r_data<=s_axis_data;
        end
      else
        begin
        end
    end
  
  always@(*)
    begin
      s_axis_ready=!r_valid;
    end
  
  
  generate if(!OPT_OUTREG)
    begin
      always@(*)
        begin
          m_axis_valid=s_axis_valid || r_valid;
        end
      
      always@(*)
        begin
          if(r_valid)
            m_axis_data=r_data;
          else
            m_axis_data=s_axis_data;
        end
      
      always@(*)
        begin
          if(r_valid)
            m_axis_data=r_data;
          else if(!OPT_LOWPOWER || s_axis_valid)
            m_axis_data=s_axis_data;
          else
            m_axis_data=0;
        end
    end
    else
      begin
        initial
          m_axis_valid<=0;
        always@(posedge clk)
          begin
            if(reset)
              begin
                m_axis_valid<=0;
              end
            else if( m_axis_ready)
              begin
                m_axis_valid<=r_valid || s_axis_valid;
              end
            else
              begin
              end
          end
        
        initial m_axis_data=0;
        always@(posedge clk)
          begin
            if(OPT_LOWPOWER && reset)
              m_axis_data<=0;
            else if( m_axis_ready)
              begin
                if(r_valid)
                  m_axis_data<=r_data;
                else if(!OPT_LOWPOWER || s_axis_valid)
                  m_axis_data<=s_axis_data;
                else
                  m_axis_data<=0;
              end
            else
              begin
              end
          end
      end
  endgenerate
  
endmodule
