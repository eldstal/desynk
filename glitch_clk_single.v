/*
 * Glitching module: Single-cycle upset
 * When the trig signal goes high, a single target
 * clock cycle will be garbled
 */

module glitch_clk_single(
  input rst,
  input clk,
  input trig,
  input clean_target_clock,
  output clk_o
);

parameter N_HALFCYCLES=2;

reg active = 0;
reg [N_HALFCYCLES-1:0] counter;

always @(posedge clk) begin
  if (rst) begin
    clock_select <= 0;
    counter <= 0;
    active <= 0;
  end
  else begin
    if (counter == 0) begin
      active <= 1;
    else
    counter[N-1:0] <= { counter[N-2:0], 1'b0 };
    if (counter == 0) active <= 0;
  end
end

always @(negedge clk) begin
  if (!rst) begin
    counter[N-1:0] <= { counter[N-2:0], 1'b0 };

    if (counter == 0) active <= 0;
  end
end

always @(posedge trig) begin
  if (!rst) begin
    if (!clock_select) begin
      counter[0] <= 1;
    end
  end
end

endmodule
