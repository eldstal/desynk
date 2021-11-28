module clk_div_3 (
  input rst,
  input clk_i,
  output clk_o
);

// Design taken straight from https://www.onsemi.com/pub/Collateral/AND8001-D.PDF


parameter WIDTH = 6;
parameter N = 6;

reg [WIDTH-1:0] pos_count, neg_count;

wire D0;
wire D1;
wire D2;

reg Q0;
reg Q1;
reg Q2;

assign D0 = !Q1 & !Q0;
assign D1 = Q0;
assign D2 = Q1;

assign clk_o = Q2 | Q1;


always_ff @(posedge clk_i) begin
  if (rst) Q0 <= 0;
  else Q0 <= D0;
end

always_ff @(posedge clk_i) begin
  if (rst) Q1 <= 0;
  else Q1 <= D1;
end

always_ff @(negedge clk_i) begin
  if (rst) Q2 <= 0;
  else Q2 <= D2;
end


endmodule
