/*
 * Target control module: Power
 * Grounds or connects the target's main power feed
 */

module target_control_power(
  input rst,
  input clk,
  input trigger,            // High to reset target device
  output target_power,      // High to enable target's power feed
  output target_throttle    // High to ground target's power feed
);


// Cycles of the fast clock.
// At 48MHz, 100ms is 4800000 cycles
// GUARD_CYCLES are maintained between powering and grounding the target, to prevent short circuit.
parameter GUARD_CYCLES=100;
parameter RESET_CYCLES=4800000;

// Safeguard against short circuit
reg request_power;
reg request_throttle;

assign target_power = request_power & !request_throttle;
assign target_throttle = request_throttle & !request_power;

// IDLE has the device powered up
// DRAINING has power pin floating
// LOW has power pin forced to ground
// GUARDING has power pin floating
enum reg [2:0] { IDLE, DRAINING, LOW, GUARDING } state;

reg [31:0] elapsed_cycles;

always @(posedge clk) begin
  if (rst) begin
    // Start in the floating state, counting down to power up the target device
    state <= GUARDING;
    elapsed_cycles <= RESET_CYCLES + GUARD_CYCLES;
    request_power <= 0;
    request_throttle <= 0;

  end
  else begin

    if (state != IDLE) begin
      elapsed_cycles <= elapsed_cycles + 1;
    end

    if (state == IDLE) begin
      if (trigger) begin
        state <= DRAINING;
        elapsed_cycles <= 1;
        request_power <= 0;
        request_throttle <= 0;
      end

    end
    else if (state == DRAINING) begin
      if (elapsed_cycles >= GUARD_CYCLES) begin
        state <= LOW;
        request_power <= 0;
        request_throttle <= 1;
      end
    end
    else if (state == LOW) begin
      if (elapsed_cycles >= (RESET_CYCLES - GUARD_CYCLES)) begin
        state <= GUARDING;
        request_power <= 0;
        request_throttle <= 0;
      end
    end
    else if (state == GUARDING) begin
      if (elapsed_cycles >= RESET_CYCLES) begin
        state <= IDLE;
        request_power <= 1;
        request_throttle <= 0;
      end
    end
  end
end



endmodule
