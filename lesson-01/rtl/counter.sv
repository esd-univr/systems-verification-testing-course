// ===========================================================================
// THE EXERCISE. This file is yours.
//
// A down-counter with a load. Everything it must do is in README.md, and the
// six files under styles/ are where the pieces come from.
//
// Keep the module name, the parameter and the ports exactly as they are:
// tb/tb_counter.sv connects to them and will not find them under other names.
// ===========================================================================

module counter #(
    parameter int WIDTH = 4
) (
    input  logic             clk,
    input  logic             start,  // load `in` at the next edge
    input  logic             dec,    // otherwise, count down by one
    input  logic [WIDTH-1:0] in,     // the value a load writes
    output logic [WIDTH-1:0] value,  // what the counter is holding
    output logic             stop    // high while the held value is zero
);

  // Your code goes here. You need four things, and styles/ has all four:
  //
  //   a local signal for the next value          styles/03
  //   a continuous assignment for `stop`         styles/01
  //   an always_comb that decides the next value styles/01, styles/02
  //   an always_ff that stores it                styles/03, styles/04
  //
  // There is no reset. The counter starts life holding whatever it holds, and
  // the first load is what makes it mean something.

endmodule
