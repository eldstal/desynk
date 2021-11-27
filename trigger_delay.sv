/*
 * Delay module: basic
 * Delays a trigger signal for a set number of target clock cycles
 */

module trigger_delay(
  input rst,
  input clk,
  input trigger,
  input clean_target_clock,
  input [31:0] delay,
  input set_delay,
  output delayed_trigger
);

parameter TRIG_CYCLES=1;

// IDLE is waiting for the input trigger
// WAIT is triggered, counting down the delay time
// ACTIVE is holding the output trigger high
// FINISHED is waiting for input trigger to go low again
enum reg [2:0] { IDLE, WAIT, ACTIVE, FINISHED} state;

reg [31:0] delay_cycles;
reg [31:0] elapsed_cycles;
reg [4:0] triggered_cycles;
reg trig_out;

assign delayed_trigger = trig_out;

always @(posedge clk) begin
  if (rst) begin
    state <= IDLE;
    elapsed_cycles <= 0;
    triggered_cycles <= 0;
    delay_cycles <= 0;
    trig_out <= 0;
  end
  else begin
    if (set_delay) delay_cycles <= delay;

    if (state == IDLE) begin
      if (trigger) begin
        state <= WAIT;
        elapsed_cycles <= 0;
        triggered_cycles <= 0;
      end

    end
    else if (state == WAIT) begin
      if (elapsed_cycles >= delay_cycles) state <= ACTIVE;
    end
    else if (state == ACTIVE) begin
      if (triggered_cycles >= TRIG_CYCLES) state <= FINISHED;
    end
    else if (state == FINISHED) begin
      if (!trigger) state <= IDLE;
    end
  end
end


// Our state changes synchronize with the target clock
// This way we don't confuse the target device prematurely
always @(posedge clean_target_clock) begin
  if (state == WAIT) begin

    trig_out <= 0;
    elapsed_cycles <=  elapsed_cycles + 1;

  end
  else if (state == ACTIVE) begin

    trig_out <= 1;
    triggered_cycles <= triggered_cycles + 1;

  end
  else trig_out <= 0;

end


endmodule
