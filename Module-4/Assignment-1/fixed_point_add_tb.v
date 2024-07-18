module fixed_point_tb(

    );
    parameter I_P1=5,F_P1=6,I_P2=5,F_P2=6,I_P3=6,F_P3=6;
    
    reg [I_P1+F_P1-1:0] a;
    reg [I_P2+F_P2-1:0] b;
    wire overflow;
    wire [I_P3+F_P3-1:0] c;
    
    Fixed_point_arithmetic #(I_P1,F_P1,I_P2,F_P2,I_P3,F_P3) dut(a,b,overflow,c);
    
    initial
        begin
            a=0;
            b=0;
            repeat(100)begin
                #5;
                a=$random;
                b=$random;
            end
        $finish;
        end
endmodule
    
