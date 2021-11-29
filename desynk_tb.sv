`timescale 1ns/100ps

module desynk_tb;

  reg rst;
  reg clk;
  reg led1;

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



  top DUT (
           .BTN1(rst),
           .CLK(clk),
           .LED1(led1)
          );


endmodule
