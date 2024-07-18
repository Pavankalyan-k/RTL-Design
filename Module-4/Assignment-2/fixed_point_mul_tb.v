module fixed_point_mul_tb(

    );
    parameter i_p1=3,f_p1=4,
              i_p2=3,f_p2=4,
              i_p3=6,f_p3=8,
              o_ip=i_p1+i_p2,
              o_fp=f_p1+f_p2;
              
    reg clk;
    reg [i_p1+f_p1-1:0] a;
    reg [i_p2+f_p2-1:0] b;
    reg sign;
    wire overflow;
    wire underflow;
    wire [i_p3+f_p3-1:0] c;
    
    fixed_point_mul #(i_p1,f_p1,i_p2,f_p2,
                      i_p3,f_p3,o_ip,o_fp) dut(clk,a,b,sign,overflow,underflow,c);
                      
    initial
        begin
            clk=1'b0;
            a=0;
            b=0;
            sign=1;
            repeat(2)@(posedge clk);
            repeat(10)@(posedge clk)
                begin
                    a=$random;
                    b=$random;
                    
                end
            $finish;
        end
    always #5 clk=~clk;
    
    
                
                    
                      
    
              
endmodule
