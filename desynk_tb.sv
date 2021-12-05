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

  wire target_clk;


  dummy_target_clk #(

  ) TARGET (
    .clk(target_clk),
    .rst(rst),

    .soft_reset(target_reset),
    .power(target_power),
    .throttle(target_throttle),

    .ready(target_ready),
    .success(target_success)

  );


  desynk #(
  /*
   * Parameters
   */

  ) DUT (
    .clk(clk),
    .io_reset(rst),
    .io_target_clk(target_clk),
    .io_target_reset(target_reset),
    .io_target_power(target_power),
    .io_target_throttle(target_throttle),
    .io_target_ready(target_ready),
    .io_target_success(target_success)

  );


endmodule
