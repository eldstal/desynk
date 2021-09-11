module clkdiv(
  input rst,
  input clk_i,
  output reg clk_o
);

// Divide by 3 to get 16MHz from a 48MHz input
parameter DIV=3;

// Counts half-cycles on the real clock
reg [DIV-1:0] half_counter;

always @(posedge clk_i) begin
  if (rst) begin
    half_counter <= 1;
    clk_o <= 0;

  end
  else begin
    half_counter[DIV-1:0] <= { half_counter[DIV-2:0], half_counter[DIV-1] };
    if (half_counter[DIV-2]) begin
      clk_o <= ~ clk_o;
    end
  end
end


always @(negedge clk_i) begin
  if (!rst) begin
    half_counter[DIV-1:0] <= { half_counter[DIV-2:0], half_counter[DIV-1] };
    if (half_counter[DIV-2]) begin
      clk_o <= ~ clk_o;
    end
  end
end

endmodule
