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
reg polarity = 0;
reg [N_HALFCYCLES:0] counter;

assign clk_o = clean_target_clock ^ (active & (clk ^ polarity));

always @(posedge clk) begin
  if (rst) begin
    counter <= 0;
    active <= 0;
  end
  else begin
    if (active) begin
      counter[N_HALFCYCLES:0] <= { counter[N_HALFCYCLES-1:0], 1'b0 };
      if (counter == 0) active <= 0;
    end
  end
end

always @(negedge clk) begin
  if (!rst) begin
    counter[N_HALFCYCLES:0] <= { counter[N_HALFCYCLES-1:0], 1'b0 };

    if (counter[N_HALFCYCLES-1:0] == 0) active <= 0;
  end
end

always @(posedge trig) begin
  if (!rst) begin
    if (!active) begin
      counter[0] <= 1;
      active <= 1;
      //polarity <= !clk;
    end
  end
end

endmodule
