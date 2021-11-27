module clk_div_3 (
  input rst,
  input clk_i,
  output clk_o
);

/*
 * This doesn't give a 50% duty cycle, so it's kind of a bad solution.
 * I don't have a good implementation yet.
 */


parameter WIDTH = 6;
parameter N = 6;

reg [WIDTH-1:0] pos_count, neg_count;
wire [WIDTH-1:0] r_nxt;

always @(posedge clk_i) begin
 if (rst) pos_count <=1;
 else if (pos_count ==N-1) pos_count <= 0;
 else pos_count<= pos_count +1;
end

always @(negedge clk_i) begin
 if (rst) neg_count <=0;
 else  if (neg_count ==N-1) neg_count <= 0;
 else neg_count<= neg_count +1;
end

assign clk_o = ((pos_count > (N>>1)) | (neg_count > (N>>1)));


endmodule
