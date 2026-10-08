// ===========================================================================
// 2. A COMBINATIONAL BLOCK THAT DOES NOT ASSIGN ON EVERY PATH
// ===========================================================================

// --------------------------------------------------------------- THE CODE --

module gate_complete (
    input  logic en,
    input  logic d,
    output logic y
);
  always_comb begin
    y = 1'b0;
    if (en) y = d;
  end
endmodule

module gate_incomplete (
    input  logic en,
    input  logic d,
    output logic y
);
  always_comb begin
    if (en) y = d;
  end
endmodule

// ----------------------------------------------------------- THE TESTBENCH --
//
// It drives the inputs and records everything. It decides nothing: you read
// the trace yourself.

module tb_incomplete;

  logic en, d;
  logic y_complete, y_incomplete;

  gate_complete   u_complete   (.en(en), .d(d), .y(y_complete));
  gate_incomplete u_incomplete (.en(en), .d(d), .y(y_incomplete));

  initial begin
    $dumpfile("build/waves/incomplete.vcd");
    $dumpvars(0, tb_incomplete);

    en = 1; d = 1; #10;
    en = 0; d = 0; #10;
    en = 1; d = 0; #10;
    en = 0; d = 1; #10;
    en = 1; d = 1; #10;
    en = 0; d = 1; #10;

    $finish;
  end

endmodule
