`timescale 1ns/100ps

module target_control_reset_tb;

  reg clk;
  reg rst;

  logic trig;
  logic target_reset_h;
  logic target_reset_l;

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

    $dumpvars(0, target_control_reset_tb);

    trig <= 0;

    rst <= 1;
    #4;
    rst <= 0;

    #20
    trig <= 1;
    #4
    trig <= 0;

    #8
    trig <= 1;
    #4
    trig <= 0;

    #32
    trig <= 1;
    #4
    trig <= 0;

    #40;
    $finish;

  end



  target_control_reset #(
    .RESET_CYCLES(4),
    .ACTIVE_HIGH(1)

  ) DUT_H (
    .rst(rst),
    .clk(clk),
    .trigger(trig),
    .target_reset(target_reset_h)
  );

  target_control_reset #(
    .RESET_CYCLES(5),
    .ACTIVE_HIGH(0)

  ) DUT_L (
    .rst(rst),
    .clk(clk),
    .trigger(trig),
    .target_reset(target_reset_l)
  );


endmodule
