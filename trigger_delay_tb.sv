`timescale 1ns/100ps

module trigger_delay_tb;

  reg rst;
  reg clk;
  reg clean_target_clock;

  reg trig;
  reg [31:0] delay;

  reg set_delay_1;
  reg set_delay_3;

  wire trig_1;
  wire trig_3;

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

    $dumpvars(0, trigger_delay_tb);

    delay <= 6;
    set_delay_1 <= 0;
    set_delay_3 <= 0;
    trig <= 0;

    rst <= 1;
    #8;
    rst <= 0;

    #12;
    set_delay_1 <= 1;
    #8;
    set_delay_1 <= 0;

    delay <= 4;

    #12;
    set_delay_3 <= 1;
    #8;
    set_delay_3 <= 0;

    #19
    trig <= 1;
    #8
    trig <= 0;

    #60
    trig <= 1;
    #8
    trig <= 0;

    #80;
    $finish;

  end



  trigger_delay #(.TRIG_CYCLES(1)) DUT_1 (
      .rst(rst),
      .clk(clk),
      .trigger(trig),
      .clean_target_clock(clean_target_clock),
      .delay(delay),
      .set_delay(set_delay_1),
      .delayed_trigger(trig_1)
  );

  trigger_delay #(.TRIG_CYCLES(3)) DUT_3 (
      .rst(rst),
      .clk(clk),
      .trigger(trig),
      .clean_target_clock(clean_target_clock),
      .delay(delay),
      .set_delay(set_delay_3),
      .delayed_trigger(trig_3)
  );


endmodule
