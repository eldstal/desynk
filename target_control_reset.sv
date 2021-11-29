/*
 * Target control module: RESET
 * Simply controls the target's reset input
 */

module target_control_reset(
  input rst,
  input clk,
  input trigger,            // High to reset target device
  output reg target_reset
);


// Cycles of the fast clock.
// At 48MHz, 10ms is 480000 cycles
parameter RESET_CYCLES=480000;

// 1 means "high to reset target"
// 0 means "low to reset target"
parameter ACTIVE_HIGH=1;

// IDLE has the device powered up
// DRAINING has power pin floating
// LOW has power pin forced to ground
// GUARDING has power pin floating
enum reg [1:0] { IDLE, RESETTING } state;

reg [31:0] elapsed_cycles;

always @(posedge clk) begin
  if (rst) begin
    // Start in the floating state, counting down to power up the target device
    state <= IDLE;
    elapsed_cycles <= 0;
    target_reset <= !ACTIVE_HIGH;

  end
  else begin

    if (state != IDLE) begin
      elapsed_cycles <= elapsed_cycles + 1;
    end

    if (state == IDLE) begin
      if (trigger) begin
        state <= RESETTING;
        elapsed_cycles <= 1;
        target_reset <= ACTIVE_HIGH;
      end

    end
    else if (state == RESETTING) begin
      if (elapsed_cycles >= RESET_CYCLES) begin
        state <= IDLE;
        target_reset <= !ACTIVE_HIGH;
      end
    end
  end
end



endmodule
