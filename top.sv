module top (
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

desynk #(
/*
 * Parameters
 */

) Desynk (
/*
 * I/O pin mapping
 * Change these as you please
 */
  .clk(CLK),
  .io_reset(BTN1),
  .io_target_clk(P1A1),
  .io_target_reset(P1A2),
  .io_target_power(P1A3),
  .io_target_throttle(P1A4),
  .io_target_ready(P1A7),
  .io_target_success(P1A8)

);

endmodule
