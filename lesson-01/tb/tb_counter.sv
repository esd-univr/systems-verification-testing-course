module tb_counter;

  logic clk = 1'b0;
  logic start = 1'b0;
  logic dec = 1'b0;
  logic [3:0] in4 = '0;
  logic [7:0] in8 = '0;
  logic [3:0] value4;
  logic [7:0] value8;
  logic stop4;
  logic stop8;
  int failures = 0;

  always #5 clk = ~clk;

  counter #(.WIDTH(4)) dut4 (
      .clk(clk), .start(start), .dec(dec), .in(in4),
      .value(value4), .stop(stop4)
  );

  counter #(.WIDTH(8)) dut8 (
      .clk(clk), .start(start), .dec(dec), .in(in8),
      .value(value8), .stop(stop8)
  );

  task automatic check(input string name, input logic condition);
    if (condition !== 1'b1) begin
      $display("FAIL %s", name);
      failures++;
    end else begin
      $display("ok   %s", name);
    end
  endtask

  task automatic drive(
      input logic next_start,
      input logic next_dec,
      input logic [3:0] next_in4,
      input logic [7:0] next_in8
  );
    @(negedge clk);
    start = next_start;
    dec   = next_dec;
    in4   = next_in4;
    in8   = next_in8;
  endtask

  task automatic sample_edge;
    @(posedge clk);
    #1;
  endtask

  initial begin
    $dumpfile("build/waves/counter.vcd");
    $dumpvars(0, tb_counter);

    // First load initializes the reset-less design.
    drive(1'b1, 1'b0, 4'h3, 8'hA5);
    sample_edge();
    check("counter.load.width4", value4 == 4'h3);
    check("counter.load.width8", value8 == 8'hA5);
    check("counter.stop.low_after_load.width4", !stop4);
    check("counter.stop.low_after_load.width8", !stop8);

    drive(1'b0, 1'b1, 4'h0, 8'h00);
    sample_edge();
    check("counter.decrement.width4", value4 == 4'h2);
    check("counter.decrement.width8", value8 == 8'hA4);

    drive(1'b0, 1'b0, 4'h0, 8'h00);
    sample_edge();
    check("counter.hold.width4", value4 == 4'h2);
    check("counter.hold.width8", value8 == 8'hA4);

    // Load against decrement, taken from a value the counter can actually
    // decrement. Sampled at zero the two orderings are indistinguishable,
    // because saturation makes the decrement a no-op either way.
    drive(1'b1, 1'b1, 4'h7, 8'h7F);
    sample_edge();
    check("counter.start_priority_from_nonzero.width4", value4 == 4'h7 && !stop4);
    check("counter.start_priority_from_nonzero.width8", value8 == 8'h7F && !stop8);

    drive(1'b1, 1'b0, 4'h1, 8'h01);
    sample_edge();
    check("counter.one_not_stopped.width4", value4 == 4'h1 && !stop4);
    check("counter.one_not_stopped.width8", value8 == 8'h01 && !stop8);

    drive(1'b0, 1'b1, 4'h0, 8'h00);
    // Before this edge the counter still holds one and is about to take zero.
    // That is the only instant at which a `stop` driven from the next value
    // differs from a `stop` driven from the registered one.
    #1;
    check("counter.stop_reflects_held_value.width4", value4 == 4'h1 && !stop4);
    check("counter.stop_reflects_held_value.width8", value8 == 8'h01 && !stop8);
    sample_edge();
    check("counter.zero_and_stop.width4", value4 == 4'h0 && stop4);
    check("counter.zero_and_stop.width8", value8 == 8'h00 && stop8);

    drive(1'b0, 1'b1, 4'h0, 8'h00);
    sample_edge();
    check("counter.saturates_at_zero.width4", value4 == 4'h0 && stop4);
    check("counter.saturates_at_zero.width8", value8 == 8'h00 && stop8);

    drive(1'b1, 1'b1, 4'h5, 8'h80);
    sample_edge();
    check("counter.start_priority.width4", value4 == 4'h5 && !stop4);
    check("counter.start_priority.width8", value8 == 8'h80 && !stop8);

    if (failures != 0)
      $display("FAIL tb_counter: %0d check(s) failed", failures);
    else
      $display("completed tb_counter");

    $finish;
  end

endmodule
