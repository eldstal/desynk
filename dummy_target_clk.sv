/*
 * Simulated target device, vulnerable to a single clock upset
 * This is never meant to be synthesized, only used in test benches.
 *
 * Contains a trap door, where a clock glitch within a certain time frame
 * will make the soft reset not work - DESYNK should detect this as a timeout
 * and perform a hard reset instead
 */
module dummy_target_clk (
  input clk,
  input rst,    // Start of simulation, not really target reset

  input soft_reset,
  input power,
  input throttle,

  output reg ready,
  output reg success,

  /* Diagnostics about the trap door */
  output reg trap_is_active,
  output reg test_passed_trap,
  output reg crashed

);

parameter READY_CYCLES = 15;
parameter READY_LEN   = 5;
parameter VULN_CYCLES = 80;  // Glitch at this time to win
parameter TRAP_CYCLES = 40;   // Glitch at this time to spring the trap


int current_cycle;

realtime clk_high;
realtime regular_half_period;
realtime current_half_period;

always begin
  @(posedge clk) if (!rst) clk_high = $realtime;
  @(negedge clk) begin
      current_half_period = $realtime - clk_high;

    if (current_cycle == 2) begin
      // This is what we'll base our measurements off of
      if (regular_half_period == 0) regular_half_period = current_half_period;
    end
  end
end

always @(posedge clk) begin
  if (rst) begin
    clk_high = 0;
    regular_half_period = 0;
    current_half_period = 0;
    current_cycle = 0;
    ready <= 0;
    success <= 0;
    crashed <= 0;
    trap_is_active <= 0;
    test_passed_trap <= 0;
  end
  else begin
    if (!crashed) begin
      current_cycle = current_cycle + 1;
    end

    if (soft_reset && !trap_is_active) begin
      current_cycle = 0;
      crashed <= 0;
    end
    else if (!power && throttle) begin
      current_cycle = 0;
      crashed <= 0;
      if (trap_is_active) begin
        trap_is_active <= 0;
        test_passed_trap <= 1;
      end

    end
    else if (success) begin
      /* Nothing left to do */
    end
    else begin

      if (current_half_period < (0.8 * regular_half_period)) begin
        // The glitch has come in
        if (current_cycle == VULN_CYCLES) begin
          success <= 1;
        end
        else if (current_cycle == TRAP_CYCLES) begin
          trap_is_active = 1;
          crashed <= 1;
        end
        else begin
          crashed <= 1;
        end

      end
      else begin
        if (current_cycle >= READY_CYCLES && current_cycle < (READY_CYCLES+READY_LEN)) begin
          ready <= 1;
        end
        else if (current_cycle >= READY_CYCLES+READY_LEN)
          ready <= 0;
        end

      end

  end

end



endmodule
