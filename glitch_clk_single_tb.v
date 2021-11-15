`timescale 1ns/100ps

module desynk_tb;

  reg rst;
  reg clk;
  reg clean_target_clock;

  reg trig;

  wire clk_target;

  initial begin
    clk = 0;
    #1;
    forever clk = #1 ~clk;
  end

  initial begin
    clean_target_clock = 0;
    #4;
    forever clean_target_clock = #4 ~clean_target_clock;
  end

  initial begin
    string filename;

    // This is the +vcd=desynk_tb.vcd on the command line
    if (!$value$plusargs("vcd=%s", filename))
      filename = "default.vcd";
    $dumpfile(filename);

    $dumpvars(0, desynk_tb);

    trig <= 0;

    rst <= 1;
    #4;
    rst <= 0;

    #19
    trig <= 1;
    #2
    trig <= 0;

    #10
    trig <= 1;
    #2
    trig <= 0;

    #40;
    $finish;

  end



  glitch_clk_single DUT (
      .rst(rst),
      .clk(clk),
      .trig(trig),
      .clean_target_clock(clean_target_clock),
      .clk_o(clk_target)
  );


endmodule
