module fixed_point_mul
#(parameter i_p1=3,f_p1=4,
            i_p2=3,f_p2=4,
            i_p3=6,f_p3=8,
            o_ip=i_p1+i_p2,
            o_fp=f_p1+f_p2)
 (input clk,
  input [i_p1+f_p1-1:0] a,
  input [i_p2+f_p2-1:0] b,
  input sign,
  output reg overflow,
  output reg underflow,
  output [i_p3+f_p3-1:0] c );
  
  reg [o_ip+o_fp-1:0] temp_out;
  
  always@(posedge clk)
    begin
        if(sign)
            begin
                temp_out=$signed(a)*$signed(b);
            end
        else
            begin
                temp_out=a*b;
            end
            
    end
    
    always@(posedge clk)
        begin
            if(sign)
                begin
                   if(i_p3>=o_ip)begin
                        overflow=0;
                    end
                    else
                        begin
                        if (temp_out[o_ip+o_fp-1]==1)
                            overflow=~(&(temp_out[o_ip+o_fp-1:i_p3+o_fp]));
                        else
                            overflow=|temp_out[o_ip+o_fp-1:i_p3+o_fp]; 
                        end
                end
            else
                begin
                    if(i_p3 >= o_ip)
                        begin
                            overflow=0;
                        end
                    else
                        begin
                            overflow=|temp_out[o_ip+o_fp-1:i_p3+o_fp];
                        end
               end
          end
   always@(posedge clk)begin
        if(sign)
            begin
                if(f_p3>=o_fp)
                    begin
                        underflow=0;
                    end
                else
                    begin
                        if(temp_out[o_ip+o_fp-1==0])
                            underflow=|temp_out[o_fp-f_p3-1:0];
                        else
                            underflow=~(&temp_out[o_fp-f_p3-1:0]);
                    end
            end
        else
            begin
                if(f_p3>=o_fp)
                    underflow=0;
                else
                    begin
                        underflow=|(temp_out[o_fp-f_p3-1:0]);
                    end
            end
     end
     assign c=temp_out;
     
                            
            
                    
                    
                    
          
          
endmodule
