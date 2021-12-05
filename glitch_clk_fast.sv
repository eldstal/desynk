/*
 * Glitching module: Fast-cycle upset
 * When the trig signal goes high, the next target
 * clock cycle will have N_CYCLES fast cycles injected
 */

module glitch_clk_fast(
  input rst,
  input clk,
  input trig,
  input clean_target_clock,
  output clk_o
);

parameter N_CYCLES=1;

// WAIT is triggered, waiting for a new target cycle to start
// ACTIVE is injecting fast clock cycles
// RECOVER is waiting for the next target cycle, to avoid additional short cycles
// FINISHED is waiting for the trigger signal to go low again
enum reg [3:0] { IDLE, WAIT, ACTIVE, RECOVER, FINISHED } state;

reg [15:0] injected_cycles;
reg fast_clock;

assign clk_o = ((state == WAIT) & clean_target_clock) |
               ((state == IDLE) & clean_target_clock) |
               ((state == ACTIVE & fast_clock) & clk) |
               ((state == ACTIVE & !fast_clock) & 1'b0) |
               ((state == RECOVER) & 1'b0);



always @(posedge clk) begin
  if (rst) begin
    injected_cycles <= 0;
    fast_clock <= 0;
  end
  else begin
    if (state == WAIT) begin
      injected_cycles <= 0;
      fast_clock <= 1;
    end
    else if (state == ACTIVE) begin
      if (injected_cycles >= N_CYCLES-1) fast_clock <= 0;
      else injected_cycles <= injected_cycles + 1;
    end
  end
end


// Our state changes synchronize with the target clock
// This way we don't confuse the target device prematurely
always @(posedge clean_target_clock) begin
  if (rst) begin
    state <= IDLE;
  end
  else begin
    if (state == IDLE) begin
      if (trig) state <= WAIT;

    end
    else if (state == WAIT) begin

      state <= ACTIVE;

    end
    else if (state == ACTIVE) begin
      if (!fast_clock) state <= RECOVER;
    end
    else if (state == RECOVER) begin

      if (!trig) state <= IDLE;
      else state <= FINISHED;

    end
    else if (state == FINISHED) begin

      if (!trig) state <= IDLE;

    end

  end

end


endmodule
