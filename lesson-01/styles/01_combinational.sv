// ===========================================================================
// 1. COMBINATIONAL LOGIC: TWO SPELLINGS
// ===========================================================================

// --------------------------------------------------------------- THE CODE --

module mux_procedural (
    input  logic sel,
    input  logic a,
    input  logic b,
    output logic y
);
  always_comb begin
    if (sel) y = a;
    else     y = b;
  end
endmodule

module mux_continuous (
    input  logic sel,
    input  logic a,
    input  logic b,
    output logic y
);
  assign y = sel ? a : b;
endmodule

// ----------------------------------------------------------- THE TESTBENCH --
//
// It drives the inputs and records everything. It decides nothing.

module tb_combinational;

  logic sel, a, b;
  logic y_proc, y_cont;

  mux_procedural u_proc (.sel(sel), .a(a), .b(b), .y(y_proc));
  mux_continuous u_cont (.sel(sel), .a(a), .b(b), .y(y_cont));

  initial begin
    $dumpfile("build/waves/combinational.vcd");
    $dumpvars(0, tb_combinational);

    for (int i = 0; i < 8; i++) begin
      {sel, a, b} = i[2:0];
      #10;
    end

    $finish;
  end

endmodule
