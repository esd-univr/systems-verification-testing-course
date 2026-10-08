// ===========================================================================
// 4. `=` AND `<=` IN A CLOCKED BLOCK
// ===========================================================================

// --------------------------------------------------------------- THE CODE --

module shift_nonblocking (
    input  logic clk,
    input  logic d,
    output logic q
);
  logic stage1;
  always_ff @(posedge clk) begin
    stage1 <= d;
    q      <= stage1;
  end
endmodule

// The same three lines with `=`. Nothing here is suppressed: the warning this
// draws is part of the point.
module shift_blocking (
    input  logic clk,
    input  logic d,
    output logic q
);
  logic stage1;
  always_ff @(posedge clk) begin
    stage1 = d;
    q      = stage1;
  end
endmodule

// ----------------------------------------------------------- THE TESTBENCH --
//
// Rising edges at 5, 15, 25, 35, 45. One pulse, high across the edge at 5 and
// across no other.

module tb_blocking;

  logic clk;
  logic d;
  logic q_nb, q_b;

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  shift_nonblocking u_nb (.clk(clk), .d(d), .q(q_nb));
  shift_blocking    u_b  (.clk(clk), .d(d), .q(q_b));

  initial begin
    d = 1'b0;
    $dumpfile("build/waves/blocking.vcd");
    $dumpvars(0, tb_blocking);

    #2  d = 1'b1;
    #8  d = 1'b0;
    #40 $finish;
  end

endmodule
