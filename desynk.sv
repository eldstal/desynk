module top(
  input CLK,

  input BTN1,
  output LED1,

  output P1A1,
  output P1A2,
  output P1A3,
  output P1A4,
  input  P1A7,
  input  P1A8

);

/*
 * I/O pin mapping
 * Change these as you please
 */
wire io_reset;           assign io_reset           = BTN1;
wire io_target_clk;      assign io_target_clk      = P1A1;
wire io_target_reset;    assign io_target_reset    = P1A2;
wire io_target_power;    assign io_target_power    = P1A3;
wire io_target_throttle; assign io_target_throttle = P1A4;
wire io_target_ready;    assign io_target_ready    = P1A7;
wire io_target_success;  assign io_target_success  = P1A8;

/* This goes to all over the place
 * It has no glitches introduced, and is never disabled.
 * It is the basis for the target's clock and everything
 * that needs to be synchronized to it.
 * clean_target_clock is slower than CLK.
 */
wire rst; assign rst = io_reset;
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
wire target_soft_reset;
wire target_hard_reset;

/*
 * FPGA runs at 32MHz
 * Target at 16MHz, so divide clock by 2
 * This clock will be fed through the glitcher
 * before being passed to the target device.
 *
 */
clk_div_2 Divider (
  .rst(rst),
  .clk_i(CLK),
  .clk_o(clean_target_clock)
);

/*
 * Main state machine
 */
controller Controller (
  .rst(rst),
  .clk(CLK),
  .trigger(trigger),
  .success(success),
  .delay(delay_cycles),
  .set_delay(set_delay),
  .trigger_arm(trigger_arm),
  .success_arm(success_arm)
);

/*
 * The target control modules
 * A soft reset might control the target's RESET pin
 * while a hard reset controls the power directly
 */

target_control_reset #(
  .RESET_CYCLES(320000),   // 10ms at 32MHz
  .ACTIVE_HIGH(1)
) TargetReset (
  .rst(rst),
  .clk(CLK),
  .trigger(target_soft_reset),
  .target_reset(io_target_reset)
);

target_control_power #(
  .GUARD_CYCLES(100),
  .RESET_CYCLES(3200000)   // 100ms at 32MHz
) TargetPower (
  .rst(rst),
  .clk(CLK),
  .trigger(target_hard_reset),
  .target_power(io_target_power),
  .target_throttle(io_target_throttle)
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
  .clk(CLK),
  .target(io_target_ready),
  .arm(trigger_arm),
  .trigger(trigger)

);

/*
 * Introduces a programmable delay to the trigger signal
 */
trigger_delay #(.TRIG_CYCLES(2)) Delay (
  .rst(rst),
  .clk(CLK),
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
  .clk(CLK),
  .trig(delayed_trigger),
  .clean_target_clock(clean_target_clock),
  .clk_o(io_target_clk)
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
  .clk(CLK),
  .target(io_target_success),
  .arm(success_arm),
  .trigger(success)

);


reg led;

assign LED1 = led;

initial begin
  led <= 0;
end

always @(posedge CLK) begin
  led <= !led;
end

endmodule
