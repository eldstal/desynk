module top(
  input rst,
  input clk,
  output led1,


  output target_clk,

  input target_ready_gpio,
  input target_success_gpio
);

// This goes to all over the place
// It has no glitches introduced, and is never disabled.
// It is the basis for the target's clock and everything
// that needs to be synchronized to it.
// clean_target_clock is slower than clk.
wire clean_target_clock;

// Signals to and from external modules
wire trigger;
wire delayed_trigger;
wire success;

// Signals controlled by the controller module
wire [31:0] delay_cycles;
wire set_delay;
wire trigger_arm;
wire success_arm;

/*
 * FPGA runs at 48MHz.
 * Target at 16MHz, so divide clock by 3
 * This clock will be fed through the glitcher
 * before being passed to the target device.
 *
 */
clk_div_3 Divider (
  .rst(rst),
  .clk_i(clk),
  .clk_o(clean_target_clock)
);

/*
 * Main state machine
 */
controller Controller (
  .rst(rst),
  .clk(clk),
  .trigger(trigger),
  .success(success),
  .delay(delay_cycles),
  .set_delay(set_delay),
  .trigger_arm(trigger_arm),
  .success_arm(success_arm)
);

/*
 * The target's READY signal is a basic I/O pin.
 * On a rising edge, our countdown begins
 */
detect_edge #(
   .TRIG_CYCLES(2),
   .RISING_EDGE(1)
 ) Trigger (

  .rst(rst),
  .clk(clk),
  .target(target_ready_gpio),
  .arm(trigger_arm),
  .trigger(trigger)

);

/*
 * Introduces a programmable delay to the trigger signal
 */
trigger_delay #(.TRIG_CYCLES(2)) Delay (
  .rst(rst),
  .clk(clk),
  .trigger(trigger),
  .clean_target_clock(clean_target_clock),
  .delay(delay_cycles),
  .set_delay(set_delay),
  .delayed_trigger(delayed_trigger)
);


/*
 * This module introduces a clock glitch when triggered
 */
glitch_clk_fast #(.N_CYCLES(2)) Glitch (
  .rst(rst),
  .clk(clk),
  .trig(delayed_trigger),
  .clean_target_clock(clean_target_clock),
  .clk_o(target_clk)
);

/*
 * The target's SUCCESS signal is a basic I/O pin.
 * On a falling edge, we know our attack was successful
 */
detect_edge #(
   .TRIG_CYCLES(2),
   .RISING_EDGE(1)
 ) Success (

  .rst(rst),
  .clk(clk),
  .target(target_success_gpio),
  .arm(success_arm),
  .trigger(success)

);


reg led;

assign led1 = led;

initial begin
  led <= 0;
end

always @(posedge clk) begin
  led <= !led;
end

endmodule
