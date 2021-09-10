module top(
  input CLK,
  output LED1
);

reg led;

assign LED1 = led;

initial begin
  led <= 0;
end

always @(posedge CLK) begin
  led <= !led;
end

endmodule
