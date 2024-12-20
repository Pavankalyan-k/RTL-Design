module fsm_design1#(parameter DATA_WIDTH=16)(
  input clk,
  input reset,
  input [DATA_WIDTH-1:0] s_axis_data,
  input s_axis_valid,
  input s_axis_last,
  input [7:0] s_axis_keep,
  input m_axis_ready,
  output reg [DATA_WIDTH-1:0] m_axis_data,
  output reg m_axis_valid,
  output reg m_axis_last,
  output reg [7:0] m_axis_keep,
  output s_axis_ready
  
  
);
  
  reg rd_en;
  reg [6:0] temp,temp1;
  reg [3:0] fifo[0:127];
  reg [6:0] wr_ptr,rd_ptr;
  
  parameter s0=3'd0,s1=3'd1,s2=3'd2,s3=3'd3,s4=3'd4,idle=3'd5;
  
  reg [2:0] present_state,next_state;
  
  integer i;
  
  always@(posedge clk)
    begin
      if(reset)
        begin
          wr_ptr<=0;
          rd_ptr<=0;
          for(i=0;i<128;i++)
            begin
              fifo[i]<=4'd0;
            end
          present_state<=idle;
        end
      else
        present_state<=next_state;
    end
  
  always@(*)
    begin
      case(present_state)
        idle:begin
          next_state=s0;
        end
        s0:begin
          if(s_axis_valid && s_axis_ready)
            begin
              case(s_axis_keep)
                8'd0:next_state=s0;
                8'd4:next_state=s1;
                8'd8:next_state=s2;
                8'd12:next_state=s3;
                8'd16:next_state=s4;
                default:next_state=s0;
              endcase
            end
        end
        s1:begin
          if(s_axis_valid && s_axis_ready)
            begin
              case(s_axis_keep)
                8'd0:next_state=s0;
                8'd4:next_state=s1;
                8'd8:next_state=s2;
                8'd12:next_state=s3;
                8'd16:next_state=s4;
                default:next_state=s0;
              endcase
            end
        end
        s2:begin
          if(s_axis_valid && s_axis_ready)
            begin
              case(s_axis_keep)
                8'd0:next_state=s0;
                8'd4:next_state=s1;
                8'd8:next_state=s2;
                8'd12:next_state=s3;
                8'd16:next_state=s4;
                default:next_state=s0;
              endcase
            end
        end
        s3:begin
          if(s_axis_valid && s_axis_ready)
            begin
              case(s_axis_keep)
                8'd0:next_state=s0;
                8'd4:next_state=s1;
                8'd8:next_state=s2;
                8'd12:next_state=s3;
                8'd16:next_state=s4;
                default:next_state=s0;
              endcase
            end
        end
        s4:begin
          if(s_axis_valid && s_axis_ready)
            begin
              case(s_axis_keep)
                8'd0:next_state=s0;
                8'd4:next_state=s1;
                8'd8:next_state=s2;
                8'd12:next_state=s3;
                8'd16:next_state=s4;
                default:next_state=s0;
              endcase
            end
        end
        default:next_state=s0;
      endcase
    end
  
  always@(posedge clk)
    begin
      case(next_state)
        s0:begin
          wr_ptr<=0;
        end
        s1:begin
          if(s_axis_valid && s_axis_ready) //&& !s_axis_last)
            begin
              fifo[wr_ptr]<=s_axis_data[3:0];
              wr_ptr<=wr_ptr+1;
            end
        end
        s2:begin
          if(s_axis_valid && s_axis_ready)// && !s_axis_last)
            begin
              fifo[wr_ptr]<=s_axis_data[3:0];
              fifo[wr_ptr+1]<=s_axis_data[7:4];
              wr_ptr<=wr_ptr+2;
            end
        end
        s3:begin
          if(s_axis_valid && s_axis_ready )//&& !s_axis_last)
            begin
              fifo[wr_ptr]<=s_axis_data[3:0];
              fifo[wr_ptr+1]<=s_axis_data[7:4];
              fifo[wr_ptr+2]<=s_axis_data[11:8];
              wr_ptr<=wr_ptr+3;
            end
        end
        s4:begin
          if(s_axis_valid && s_axis_ready)// && !s_axis_last)
            begin
              fifo[wr_ptr]<=s_axis_data[3:0];
              fifo[wr_ptr+1]<=s_axis_data[7:4];
              fifo[wr_ptr+2]<=s_axis_data[11:8];
              fifo[wr_ptr+3]<=s_axis_data[15:12];
              wr_ptr<=wr_ptr+4;
            end
        end
        idle:begin
          wr_ptr<=0;
        end
        default:begin
          wr_ptr<=wr_ptr;
          //fifo[wr_ptr]<=fifo[wr_ptr];
        end
      endcase
    end
  
  reg [6:0] wr_ptr1;
  
  always@(posedge clk)
    begin
      wr_ptr1<=wr_ptr;
      if(s_axis_last==1)
        begin
          temp<=wr_ptr;
          temp1<=wr_ptr+next_state;
          rd_en<=1;
        end
    end
  
  
  always@(posedge clk)
    begin
      if(rd_en && m_axis_ready)begin
        if(temp1 == rd_ptr ) 
          begin
            temp1<=0;
            m_axis_data<={{fifo[rd_ptr+3]},{fifo[rd_ptr+2]},{fifo[rd_ptr+1]},{fifo[rd_ptr]}};
            rd_ptr<=rd_ptr+4;
            m_axis_keep<=7'd16;
            m_axis_valid<=1;
            m_axis_last<=1;
          end
        
        else if(temp1==rd_ptr+1)
          begin
            m_axis_data<={{4'b0},{4'b0},{4'b0},{fifo[rd_ptr]}};
            rd_ptr<=rd_ptr+1;
            m_axis_keep<=7'd4;
            m_axis_valid<=1;
            m_axis_last<=1;
            temp1<=0;       
          end
        
        else if(temp1==rd_ptr+2)
         begin
           m_axis_data<={{4'b0},{4'b0},{fifo[rd_ptr+1]},{fifo[rd_ptr]}};
           rd_ptr<=rd_ptr+2;
           m_axis_keep<=7'd8;
           m_axis_valid<=1;
           m_axis_last<=1;
           temp1<=0;
         end
        else if(temp1==rd_ptr+3)
          begin          
            m_axis_data<={{4'b0},{fifo[rd_ptr+2]},{fifo[rd_ptr+1]},{fifo[rd_ptr]}};
            rd_ptr<=rd_ptr+3;
            m_axis_keep<=7'd12;
            m_axis_valid<=1;
            m_axis_last<=1;
            temp1<=0;  
          end
        
        else if(rd_ptr<wr_ptr)
          begin                   
            m_axis_data<={{fifo[rd_ptr+3],{fifo[rd_ptr+2]},{fifo[rd_ptr+1]},{fifo[rd_ptr]}}};
            rd_ptr<=rd_ptr+4;
            m_axis_keep<=7'd16;
            m_axis_valid<=1;
            m_axis_last<=0;
          end
        //else if()
        else
          begin
            m_axis_data<=0;
            rd_ptr<=rd_ptr;
            m_axis_keep<=0;
            m_axis_valid<=0;
            m_axis_last<=0;
          end
            
      end
      
      else
        begin
            m_axis_data<=0;
            m_axis_valid<=0;
            m_axis_last<=0;
            m_axis_keep<=0;
        end
        end
  assign s_axis_ready=m_axis_ready;
endmodule
             
