/*
 * Detector module: edge
 * Waits for an edge of a single input pin, generates a trigger signal
 */

module detect_edge(
  input rst,
  input clk,
  input target,
  input arm,
  output reg trigger
);

parameter TRIG_CYCLES=1;
parameter RISING_EDGE=1;

// IDLE is waiting for the arm signal
// WAIT is armed, waiting for the target's signal to go inactive
// ARMED is armed, waiting fo the active edge
// ACTIVE is holding the output trigger high
// FINISHED is waiting for the arm signal to return to inactive
enum reg [2:0] { IDLE, WAIT, ARMED, ACTIVE, FINISHED } state;

reg [4:0] triggered_cycles;

always @(posedge clk) begin
  if (rst) begin
    state <= IDLE;
    triggered_cycles <= 0;
    trigger <= 0;
  end
  else begin

    if (state == IDLE) begin
      if (arm) begin
        state <= WAIT;
        triggered_cycles <= 0;
      end

    end
    else if (state == WAIT) begin
      if (target != RISING_EDGE) state <= ARMED;

    end
    else if (state == ARMED) begin
      if (target == RISING_EDGE) begin
        state <= ACTIVE;
        trigger <= 1;
        triggered_cycles <= 1;
      end

    end
    else if (state == ACTIVE) begin
      if (triggered_cycles >= TRIG_CYCLES) begin
        state <= FINISHED;
        trigger <= 0;
      end
      else triggered_cycles <= triggered_cycles + 1;

    end
    else if (state == FINISHED) begin
      if (!arm) state <= IDLE;

    end
  end
end


endmodule
