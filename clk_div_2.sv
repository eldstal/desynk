module clk_div_2 (
  input rst,
  input clk_i,
  output reg clk_o
);

always @(posedge clk_i) begin
  if (rst) begin
    clk_o <= clk_i;
  end
  else begin
    clk_o <= !clk_o;
  end
end


endmodule
