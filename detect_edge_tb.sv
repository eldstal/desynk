`timescale 1ns/100ps

module detect_edge_tb;

  reg rst;
  reg clk;
  reg clean_target_clock;

  reg arm_1;
  reg arm_3;
  reg arm_n_1;

  reg target;

  wire trig_1;
  wire trig_3;
  wire trig_n_1;

  initial begin
    clk = 0;
    #1;
    forever clk = #1 ~clk;
  end

  initial begin
    string filename;

    // This is the +vcd=desynk_tb.vcd on the command line
    if (!$value$plusargs("vcd=%s", filename))
      filename = "default.vcd";
    $dumpfile(filename);

    $dumpvars(0, detect_edge_tb);

    arm_1 <= 0;
    arm_3 <= 0;
    arm_n_1 <= 0;
    target <= 1;

    rst <= 1;
    #4;
    rst <= 0;

    #2
    arm_1 <= 1;
    arm_3 <= 1;
    #2
    arm_1 <= 0;
    arm_3 <= 0;

    #4
    target <= 0;
    #2
    target <= 1;

    #2
    arm_n_1 <= 1;
    #2
    arm_n_1 <= 0;

    #4
    target <= 0;
    #2
    target <= 1;

    #4
    arm_1 <= 1;
    arm_3 <= 1;
    arm_n_1 <= 1;
    #2
    arm_1 <= 0;
    arm_3 <= 0;
    arm_n_1 <= 0;

    #4
    target <= 0;
    #2
    target <= 1;
    #2
    target <= 0;


    #12;
    $finish;

  end



  detect_edge #(
                 .TRIG_CYCLES(1),
                 .LEADING_EDGE(1)
               ) DUT_1 (
      .rst(rst),
      .clk(clk),
      .target(target),
      .arm(arm_1),
      .trigger(trig_1)
  );

  detect_edge #(
                 .TRIG_CYCLES(3),
                 .LEADING_EDGE(1)
               ) DUT_3 (
      .rst(rst),
      .clk(clk),
      .target(target),
      .arm(arm_3),
      .trigger(trig_3)
  );

  detect_edge #(
                 .TRIG_CYCLES(1),
                 .LEADING_EDGE(0)
               ) DUT_N_1 (
      .rst(rst),
      .clk(clk),
      .target(target),
      .arm(arm_n_1),
      .trigger(trig_n_1)
  );




endmodule
