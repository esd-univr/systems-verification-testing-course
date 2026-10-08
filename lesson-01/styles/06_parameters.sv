// ===========================================================================
// 6. ONE SOURCE FILE, SEVERAL CIRCUITS
// ===========================================================================

// --------------------------------------------------------------- THE CODE --

module bit_reverse #(
    parameter int WIDTH = 8
) (
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
  always_comb begin
    for (int i = 0; i < WIDTH; i++) begin
      q[i] = d[WIDTH-1-i];
    end
  end
endmodule

// ----------------------------------------------------------- THE TESTBENCH --
//
// The same module, instantiated at two widths.

module tb_parameters;

  logic [3:0] d4, q4;
  logic [7:0] d8, q8;

  bit_reverse #(.WIDTH(4)) u4 (.d(d4), .q(q4));
  bit_reverse #(.WIDTH(8)) u8 (.d(d8), .q(q8));

  initial begin
    $dumpfile("build/waves/parameters.vcd");
    $dumpvars(0, tb_parameters);

    d4 = 4'b0001; d8 = 8'b1100_0000; #10;
    d4 = 4'b0010; d8 = 8'b0000_0011; #10;
    d4 = 4'b0100; d8 = 8'b1010_1010; #10;
    d4 = 4'b1000; d8 = 8'b0001_1000; #10;

    $finish;
  end

endmodule
