module top(
  input rst,
  input clk,
  output led1,
  output target_clk
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

// Signals controlled by the controller module
wire [31:0] delay_cycles;
wire set_delay;

/*
 * FPGA runs at 48MHz.
 * Target at 16MHz, so divide clock by 3
 * This clock will be fed through the glitcher
 * before being passed to the target device.
 *
 */
clkdiv #(.DIV(3)) Divider (
  .rst(rst),
  .clk_i(clk),
  .clk_o(clean_target_clock)
);

/*
 * Introduces a programmable delay to the trigger signal
 */
trigger_delay #(.TRIG_CYCLES(2)) Delay (
  .rst(rst),
  .clk(clk),
  .trig(trigger),
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


reg led;

assign led1 = led;

initial begin
  led <= 0;
end

always @(posedge clk) begin
  led <= !led;
end

endmodule
