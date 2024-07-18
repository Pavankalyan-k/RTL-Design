module Fixed_point_arithmetic #(
parameter I_P1=5,F_P1=6,
I_P2=5,F_P2=6,I_P3=6,F_P3=6,O_IP=I_P1>I_P2?I_P1:I_P2,
O_FP=F_P1>F_P2?F_P1:F_P2)
(input clk,
 input  [I_P1+F_P1-1:0] a,
 input  [I_P2+F_P2-1:0] b,
 input signed_add,
 output reg overflow,
 output [I_P3+F_P3:0] c);
 
 
 
 reg [I_P1+F_P1-1:F_P1] a_int;
 reg [F_P1-1:0] a_frac;
 reg [I_P2+F_P2-1:F_P2] b_int;
 reg [F_P2-1:0] b_frac;
 
 reg [O_IP+O_FP-1:O_FP] a_int_temp;
 reg [O_FP-1:0] a_frac_temp;
 reg [O_IP+O_FP-1:O_FP] b_int_temp;
 reg [O_FP-1:0] b_frac_temp;
 
 reg [O_IP+O_FP-1:0] temp_a;
 reg [O_IP+O_FP-1:0] temp_b;
 reg signed [O_IP+O_FP-1:0] signed_temp_a;
 reg signed [O_IP+O_FP-1:0] signed_temp_b; 
 
 reg [O_IP+O_FP:0] temp_out;
 
 
 always@(*)
    begin
        a_int=a[I_P1+F_P1-1:F_P1];
        a_frac=a[F_P1-1:0];
        b_int=b[I_P2+F_P2-1:F_P1];
        b_frac=b[F_P2-1:0];
    end
    

always@(posedge clk)
    begin
        if(!signed_add)
            begin
                if(I_P1>I_P2)
                    begin
                        //b_int_temp={{(I_P1-I_P2){b_int[I_P2+F_P2-1]}},b};
                        b_int_temp={{(I_P1-I_P2){1'b0}},b_int};
                        a_int_temp=a;
                    end
                else if(I_P1==I_P2)
                    begin
                        a_int_temp=a_int;
                        b_int_temp=b_int;
                    end
                else
                    begin
                        //a_int_temp={{(I_P2-I_P1){a_int[I_P1+F_P1-1]}},a};
                        a_int_temp={(I_P2-I_P1){1'b0}};
                        b_int_temp=b;
                    end
            end
        else
            begin
                if(I_P1>I_P2)
                    begin
                        a_int_temp=a_int;
                        b_int_temp={{(I_P1-I_P2){b[I_P2+F_P2-1]}},b_int};
                    end
                else if(I_P1==I_P2)
                    begin
                        a_int_temp=a_int;
                        b_int_temp=b_int;
                    end
                else 
                    begin
                        a_int_temp={{(I_P2-I_P1){a_int[I_P1+F_P1-1]}},a_int};
                        b_int_temp=b_int;
                    end
            end
                        
          
 
 // zero padding for fractional part
 
 always@(posedge clk)
    begin
        if(!sign_add)
            begin
                if(F_P1>F_P2)
                    begin
                        b_frac_temp={b_frac,{(F_P1-F_P2){1'b0}}};
                        a_frac_temp=a_frac;
                    end
                else if(F_P1==F_P2)
                    begin
                        a_frac_temp=a_frac;
                        b_frac_temp=b_frac;
                    end
                else
                    begin
                        a_frac_temp={a_frac,{(F_P2-F_P1){1'b0}}};
                        b_frac_temp=b_frac;
                    end
            end
        else
            begin
                if(F_P1>F_P2)
                    begin
                        b_frac_temp={b_frac,{(F_P1-F_P2){1'b0}}};
                        a_frac_temp=a_frac;
                    end
                else if(F_P1==F_P2)
                    begin
                        b_frac_temp=b_frac;
                        a_frac_temp=a_frac;
                    end
               else
                    begin
                        a_frac_temp={a_frac,{(F_P2-F_P1){1'b0}}};
                        b_frac_temp=b_frac;
                    end
           end
       end                    
    
 always@(posedge clk)
    begin
        if(signed_add)
            begin
                temp_a={a_int_temp,a_frac_temp};
                temp_b={b_int_temp,b_frac_temp};
                temp_out=$signed(temp_a)+$signed(temp_b);
           end
        else
            begin
                temp_a={a_int_temp,a_frac_temp};
                temp_b={b_int_temp,b_frac_temp};
                temp_out=temp_a+temp_b;
            end
    end
    
 
 
 //assign temp_out=$signed(temp_a)+$signed(temp_b);
 
 
 always@(posedge clk)
    begin
        if(!signed_add)
            begin
                if(I_P3>O_IP)
                    begin
                        overflow=1'b0;
                    end
                else if(I_P3==O_IP)
                    begin
                        if(temp_out[O_IP+O_FP]==1)
                            begin
                                overflow=1'b1;
                            end
                        else
                            overflow=1'b0;
                    end
                else
                    begin
                        overflow=|(temp_out[O_IP+O_FP:O_IP+O_FP-I_P3]);
                    end
            end
        else
            begin
                if(I_P3>O_IP)
                    begin 
                       overflow=1'b0;
                    end
                else if(I_P3==O_IP)
                    begin
                        overflow=(temp_a[O_IP+O_FP-1]^temp_sum[O_IP+O_FP-1]) && (temp_b[O_IP+O_FP-1]^temp_sum[O_IP+O_FP-1]);
                    end
                else if(temp_out[O_IP+O_FP-1]==0)
                    begin
                        overflow=|temp_out[O_IP+O_FP:(O_IP+O_FP-(O_IP-(I_P3)))];
                    end
                else if(temp_out[O_IP+O_FP-1]==1)
                    begin
                        overflow=(~(&temp_out[O_IP+O_FP:O_FP+I_P3]));
                    end
                       
                     
      
            
  assign c=temp_out;
            
                
endmodule
