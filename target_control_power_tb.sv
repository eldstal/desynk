`timescale 1ns/100ps

module target_control_power_tb;

  reg clk;
  reg rst;

  logic trig;
  logic power;
  logic throttle;

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

    $dumpvars(0, target_control_power_tb);

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



  target_control_power #(
    .GUARD_CYCLES(4),
    .RESET_CYCLES(13)

  ) DUT (
    .rst(rst),
    .clk(clk),
    .trigger(trig),
    .target_power(power),
    .target_throttle(throttle)
  );


endmodule
