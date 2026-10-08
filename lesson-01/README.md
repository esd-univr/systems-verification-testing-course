# Lesson 1 — RTL modelling

## Start here

This repository already runs inside the course HDL environment in GitHub Codespaces.

```bash
cd lesson-01
make help
```

Everything below is run from this directory.

To restart the tracked Lesson 1 files from the repository version:

```bash
make clean
git restore .
```

`git restore .` discards your changes to tracked files in `lesson-01`.

## What is in here

| Path | What it is |
| --- | --- |
| `styles/` | six small files, one language idea each. The code on top, the testbench that drives it below |
| **`rtl/counter.sv`** | **the exercise. You write this** |
| `tb/tb_counter.sv` | the checker that judges your counter. Do not modify it |
| `specifications/counter.md` | the requirements, one named clause each |
| `build/` | generated output. Delete it whenever you like |

No specimen prints a verdict. Each one drives its inputs, records a trace, and
stops. Reading the trace is the exercise.

## How to compile

```bash
mkdir -p build/obj/combinational build/waves

verilator -Wall -f verilator.cfg \
    -Mdir build/obj/combinational --top-module tb_combinational -o sim \
    styles/01_combinational.sv
```

| Argument | What it does |
| --- | --- |
| `-Wall` | report the style warnings, not only the errors. **Two of the three diagnostics in this part are reported only under `-Wall`.** Drop it and they disappear without a word, leaving a clean-looking build of code that is wrong |
| `-f verilator.cfg` | the flags every build here shares. It is given to you, and it must come after `-Wall`, which it would otherwise undo |
| `-Mdir` | where the generated files go. Verilator does **not** create this directory, which is what the `mkdir` is for |
| `--top-module` | which module is the top of the hierarchy |
| `-o sim` | call the result `sim` |
| the last argument | the source file, and the testbench with it |

## How to execute

```bash
./build/obj/combinational/sim
```

It writes `build/waves/combinational.vcd`, prints a short report of its own and
stops. Add `+verilator+quiet` to silence that report.

## How to see the trace

```bash
vcdtui build/waves/combinational.vcd --scope tb_combinational \
       -s sel,a,b,y_proc,y_cont --dump
```

`--dump` prints one row per tick at which something changed, carrying every
selected signal's settled value. Leave it out for the interactive viewer.

## Part 1 — six ideas, same three commands

Do the first one by hand, with the three commands above. Understand every flag
before you move on.

For the other five, `make style2` … `make style6` compiles and runs for you, and
**prints each command before running it**, so nothing happens out of sight. Run
at least one more by hand anyway.

Only one name changes between specimens, and it is the same name in all three
commands. For `02_incomplete.sv` that name is `incomplete`: `-Mdir` becomes
`build/obj/incomplete`, `--top-module` becomes `tb_incomplete`, and the trace is
`build/waves/incomplete.vcd`.

| File | Name | Signals for `-s` |
| --- | --- | --- |
| `01_combinational.sv` | `combinational` | `sel,a,b,y_proc,y_cont` |
| `02_incomplete.sv` | `incomplete` | `en,d,y_complete,y_incomplete` |
| `03_registered.sv` | `registered` | `clk,d,q_wire,q_reg` |
| `04_blocking.sv` | `blocking` | `clk,d,q_nb,q_b` |
| `05_two_drivers.sv` | `two_drivers` | `clk,d,q_one,q_two` |
| `06_parameters.sv` | `parameters` | `d4,q4,d8,q8` |

- [ ] **1 — two spellings, one circuit**
  - `always_comb` and `assign`, the same multiplexer, all eight inputs.
  - There is no clock in the file. Why does it not need one?
- [ ] **2 — a path that assigns nothing**
  - One warning comes out of the compiler. Read it before you run anything.
  - The two circuits differ at ticks 10 and 50. What is the second one doing?
  - At tick 30 they agree. Is it right there, or lucky?
- [ ] **3 — a register waits for the clock**
  - A wire and a register, driven by the same input. `d` pulses at 3, 17 and 33.
  - List the ticks where `q_reg` changes. What do they have in common?
  - One pulse never reaches `q_reg`. Which, and what is different about it?
- [ ] **4 — `=` and `<=` are two different circuits**
  - The same three lines, one operator apart. One pulse, sampled once.
  - `q_b` rises at tick 5, `q_nb` at tick 15. How many storage stages each?
  - Two warnings come out, both naming the same file and the same module. Why
    that module and not the other one in it?
- [ ] **5 — one signal, two writers**
  - `q_two` has a value in the trace. Should you rely on it?
  - Read what the compiler said before the simulation ran.
- [ ] **6 — one source file, several circuits**
  - One module, instantiated at two widths.
  - When did the `for` loop run?

## Part 2 — write the counter

`rtl/counter.sv` has the module header and nothing else. Write the body.

**What it must do.** There is no reset. At every rising edge of `clk`:

- if `start` is high, the counter takes the value on `in`;
- otherwise, if `dec` is high and the counter is not already at zero, it goes
  down by one;
- otherwise it keeps what it has.

And at all times:

- `stop` is high exactly when the value the counter is **holding** is zero, and
  not when the value it is about to take is zero;
- if `start` and `dec` are both high, the load wins.

`WIDTH` is a parameter. The checker builds your file at 4 bits and at 8, so
write it once and let the parameter do the rest.

- [ ] **Write it**
  - Four pieces, and `styles/` has all four. The comment in the file says which
    specimen each one comes from
- [ ] **`make check` until it passes**
  - Each check reports by name. A failure names the behaviour that is wrong,
    like `FAIL counter.start_priority.width4`; `specifications/counter.md`
    says what that behaviour is.
  - You are done at `PASS Lesson 1 student workspace`
- [ ] **Look at what you built**
  - `make wave` prints the command.
  - Find a **load**, a **decrement**, the edge where the value **reaches zero**
    and `stop` rises with it, a **blocked decrement** with `dec` high while the
    value is already zero, and the edge where **both** `start` and `dec` are high
- [ ] **One of those is not what it looks like**
  - The value drops by exactly one at three edges. Only two are decrements.
  - Which input tells them apart? Did you pick one that was not one?
  - Add `value8` and `in8` to the view. The edge that fools you at four bits
    is obvious at eight. Say why
