`timescale 1ns/100ps

module desynk_tb;

  reg clk;
  reg rst;

  logic clk_2;
  logic clk_3;
  logic clk_4;

  parameter CLOCK_HALF_PERIOD = 1;

  initial begin
    clk = 0;
    #CLOCK_HALF_PERIOD;
    forever clk = #(CLOCK_HALF_PERIOD) ~clk;
  end

  initial begin
    string filename;

    // This is the +vcd=desynk_tb.vcd on the command line
    if (!$value$plusargs("vcd=%s", filename))
      filename = "default.vcd";
    $dumpfile(filename);

    $dumpvars(0, desynk_tb);

    rst <= 1;
    #4;
    rst <= 0;

    #40;
    $finish;

  end



  clkdiv #(.DIV(2)) DUT_2 (.rst(rst), .clk_i(clk), .clk_o(clk_2) );
  clkdiv #(.DIV(3)) DUT_3 (.rst(rst), .clk_i(clk), .clk_o(clk_3) );
  clkdiv #(.DIV(4)) DUT_4 (.rst(rst), .clk_i(clk), .clk_o(clk_4) );


endmodule
