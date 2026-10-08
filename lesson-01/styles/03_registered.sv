// ===========================================================================
// 3. A REGISTER WAITS FOR THE CLOCK
// ===========================================================================

// --------------------------------------------------------------- THE CODE --

module follow_wire (
    input  logic d,
    output logic q
);
  assign q = d;
endmodule

module follow_register (
    input  logic clk,
    input  logic d,
    output logic q
);
  always_ff @(posedge clk) begin
    q <= d;
  end
endmodule

// ----------------------------------------------------------- THE TESTBENCH --
//
// Rising edges at 5, 15, 25, 35, 45. Three pulses on `d`, of three different
// shapes relative to those edges.

module tb_registered;

  logic clk;
  logic d;
  logic q_wire, q_reg;

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  follow_wire     u_wire (.d(d), .q(q_wire));
  follow_register u_reg  (.clk(clk), .d(d), .q(q_reg));

  initial begin
    d = 1'b0;
    $dumpfile("build/waves/registered.vcd");
    $dumpvars(0, tb_registered);

    #3  d = 1'b1;   // t=3
    #5  d = 1'b0;   // t=8
    #9  d = 1'b1;   // t=17
    #6  d = 1'b0;   // t=23
    #10 d = 1'b1;   // t=33
    #5  d = 1'b0;   // t=38
    #12 $finish;
  end

endmodule
