`timescale 1ns/100ps

module desynk_tb;

  reg clk;
  reg led1;

  parameter CLOCK_HALF_PERIOD = 5;

  initial begin
    clk = 0;
    #CLOCK_HALF_PERIOD;
    forever clk = #(CLOCK_HALF_PERIOD) ~clk;
  end

  initial begin
    string filename;

    if (!$value$plusargs("vcd=%s", filename))
      filename = "default.vcd";
    $dumpfile(filename);

    $dumpvars(0, desynk_tb);

    #40;
    $finish;

  end



  top DUT(.CLK(clk),
             .LED1(led1));


endmodule
