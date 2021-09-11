module top(
  input rst,
  input clk,
  output led1
);

wire clean_target_clock;

/*
 * FPGA runs at 48MHz.
 * Target at 16MHz, so divide clock by 3
 * This clock will be fed through the glitcher
 * before being passed to the target device.
 *
 */
clkdiv #(.DIV(3)) divider (
  .rst(rst),
  .clk_i(clk),
  .clk_o(clean_target_clock)
);

reg led;

assign led1 = led;

initial begin
  led <= 0;
end

always @(posedge clk) begin
  led <= !led;
end

endmodule
