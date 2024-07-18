module dsp_architecture#(parameter DATA_WIDTH=26,
DATA_WIDTH_2=16)(
  input [DATA_WIDTH-1:0] A,
  input [DATA_WIDTH-1:0] B,
  input [DATA_WIDTH-1:0] C,
  output [DATA_WIDTH-1:0] Z

);
  assign Z=A*B+C;
endmodule
