/*
 * Central control module
 *
 * 
 */

module controller (
  input rst,
  input clk,
  input trigger,
  input success,

  // To delay module
  output reg [31:0] delay,
  output reg set_delay,

  // To trigger detector module
  output reg trigger_arm,

  // To success detector module
  output reg success_arm,

  // A faster, softer target reset if it is available
  output reg target_soft_reset,

  // If the soft reset times out, this is a hard reset
  output reg target_hard_reset
);



always @(posedge clk) begin
  if (rst) begin
    delay <= 0;
    set_delay <= 0;
    trigger_arm <= 0;
    success_arm <= 0;
    target_soft_reset <= 0;
    target_hard_reset <= 0;
  end
  else begin

  end
end


endmodule
