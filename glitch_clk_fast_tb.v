`timescale 1ns/100ps

module glitch_clk_fast_tb;

  reg rst;
  reg clk;
  reg clean_target_clock;

  reg trig;

  wire clk_target_1;
  wire clk_target_2;
  wire clk_target_7;

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

    $dumpvars(0, glitch_clk_fast_tb);

    trig <= 0;

    rst <= 1;
    #8;
    rst <= 0;

    #19
    trig <= 1;
    #8
    trig <= 0;

    #40
    trig <= 1;
    #8
    trig <= 0;

    #40;
    $finish;

  end



  glitch_clk_fast #(.N_CYCLES(1)) DUT_1 (
      .rst(rst),
      .clk(clk),
      .trig(trig),
      .clean_target_clock(clean_target_clock),
      .clk_o(clk_target_1)
  );

  glitch_clk_fast #(.N_CYCLES(2)) DUT_2 (
      .rst(rst),
      .clk(clk),
      .trig(trig),
      .clean_target_clock(clean_target_clock),
      .clk_o(clk_target_2)
  );

  glitch_clk_fast #(.N_CYCLES(7)) DUT_7 (
      .rst(rst),
      .clk(clk),
      .trig(trig),
      .clean_target_clock(clean_target_clock),
      .clk_o(clk_target_7)
  );


endmodule
