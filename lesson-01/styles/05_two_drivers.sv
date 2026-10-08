// ===========================================================================
// 5. ONE SIGNAL, TWO WRITERS
// ===========================================================================

// --------------------------------------------------------------- THE CODE --

module single_writer (
    input  logic clk,
    input  logic d,
    output logic q
);
  always_ff @(posedge clk) begin
    q <= d;
  end
endmodule

// Two processes write `q`. Which one decides it?
//
// These are plain `always` blocks, not `always_ff`. Written as `always_ff` the
// tool would object for a second, independent reason: `always_ff` is a promise
// about where a signal is written, and a promise stated explicitly is one a
// tool can hold you to.
module double_writer (
    input  logic clk,
    input  logic d,
    output logic q
);
  always @(posedge clk) q <= d;
  always @(posedge clk) q <= ~d;
endmodule

// ----------------------------------------------------------- THE TESTBENCH --

module tb_two_drivers;

  logic clk;
  logic d;
  logic q_one, q_two;

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  single_writer u_one (.clk(clk), .d(d), .q(q_one));
  double_writer u_two (.clk(clk), .d(d), .q(q_two));

  initial begin
    d = 1'b0;
    $dumpfile("build/waves/two_drivers.vcd");
    $dumpvars(0, tb_two_drivers);

    repeat (4) begin
      @(posedge clk);
      #1 d = ~d;
    end
    $finish;
  end

endmodule
