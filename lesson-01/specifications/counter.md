# DS-SV1-002 — Parameterized down-counter with synchronous load

> **How to use this document in Lesson 1** Focus on the interface, the requirements, and the timing examples. Requirement identifiers let the lesson refer to an exact behaviour. The verification tables and document metadata are provided for traceability; you are not expected to learn their management in this lesson.

| | |
| --- | --- |
| Document ID | DS-SV1-002 |
| Revision | C |
| Status | Baselined |
| Applies to | `rtl/counter.sv`, module `counter` |

## 1. Scope and context

This document specifies a parameterized down-counter with a synchronous load path, used in Lesson 1 to introduce registered state, priority between two concurrent requests, and the difference between a registered value and a combinational function of it.

`shall` states a binding requirement. `should` states a recommendation. `may` states an option.

Out of scope: reset behaviour (see REQ-CNT-008), synthesis area or timing targets, and any bus or register interface.

## 2. Interface

| Port | Direction | Width | Description |
| --- | --- | --- | --- |
| `clk` | input | 1 | clock; state updates on the rising edge |
| `start` | input | 1 | load request, active high |
| `dec` | input | 1 | decrement request, active high |
| `in` | input | `WIDTH` | load data |
| `value` | output | `WIDTH` | the registered count |
| `stop` | output | 1 | asserted while the registered count is zero |

| Parameter | Type | Default | Legal range |
| --- | --- | --- | --- |
| `WIDTH` | `int` | 4 | ≥ 1 |

There is deliberately no reset port. See REQ-CNT-008.

## 3. Clock, reset and initialization

One clock domain, `clk`. State updates on the rising edge only.

No reset of any kind. The registered value is undefined until the first load, and the load path is the only initialization mechanism. This is a property of the exercise, not an omission.

## 4. Requirements

### 4.1 Behavioural requirements

#### REQ-CNT-001 — Parameterized width

The counter shall be parameterized by `WIDTH` and shall implement the same behaviour at every legal width. `WIDTH` shall be an elaboration-time parameter, not a fixed property of a four-bit design.

*Rationale:* the lesson's example is four bits; the parameter is what makes it a component rather than one instance.

*Verification:* Simulation — the `.width8` variant of every check below.

#### REQ-CNT-002 — Synchronous load

On a rising edge of `clk` with `start` asserted, the counter shall load `in` into the registered value.

*Verification:* Simulation — `counter.load.width4`, `counter.load.width8`

#### REQ-CNT-003 — Decrement

On a rising edge of `clk` with `dec` asserted, `start` deasserted and the registered value non-zero, the counter shall decrement the registered value by one.

*Verification:* Simulation — `counter.decrement.width4`, `counter.decrement.width8`

#### REQ-CNT-004 — Hold

On a rising edge of `clk` with neither `start` nor `dec` asserted, the counter shall retain its registered value.

*Verification:* Simulation — `counter.hold.width4`, `counter.hold.width8`

#### REQ-CNT-005 — Load has priority over decrement

When `start` and `dec` are both asserted at the same rising edge of `clk`, the counter shall load `in`. The decrement request shall have no effect on that edge.

*Rationale:* the multiplexer select is driven from `start`, and the load path is the only initialization path (REQ-CNT-008).

*Verification:* Simulation — `counter.start_priority.width4`, `counter.start_priority.width8`, `counter.start_priority_from_nonzero.width4`, `counter.start_priority_from_nonzero.width8`

*Negative evidence:* `qualification/mutants/counter_priority.sv`

#### REQ-CNT-006 — Decrement saturates at zero

Once the registered value is zero, a decrement request shall leave it at zero. The value shall not wrap to its maximum.

*Verification:* Simulation — `counter.saturates_at_zero.width4`, `counter.saturates_at_zero.width8`

*Negative evidence:* `qualification/mutants/counter_wrap.sv`

#### REQ-CNT-007 — `stop` reflects the registered value

`stop` shall be asserted if and only if the **registered** value is zero. It shall not anticipate the value being computed for the next edge.

*Rationale:* `stop` rises in the same cycle in which the value becomes zero, not one cycle earlier. This is the distinction between a registered value and a combinational function of it, which is the point of the example.

*Verification:* Simulation — `counter.stop.low_after_load.width4`, `counter.stop.low_after_load.width8`, `counter.one_not_stopped.width4`, `counter.one_not_stopped.width8`, `counter.zero_and_stop.width4`, `counter.zero_and_stop.width8`, `counter.stop_reflects_held_value.width4`, `counter.stop_reflects_held_value.width8`

*Negative evidence:* `qualification/mutants/counter_stop_early.sv`

#### REQ-CNT-008 — No reset

The counter shall have no reset input. The registered value shall be undefined until the first load.

*Rationale:* the exercise initializes the design through its own load path, which is what makes REQ-CNT-002 load-bearing rather than incidental.

*Verification:* Review — the interface table of §2 declares no reset port, and elaboration would fail if one were driven.

### 4.2 Exercise constraints

None. Lesson 1 constrains how the Moore machine is written, because building an explicit state machine is its final exercise; it places no constraint on how this counter is written. Compare §4.2 of [`moore-fsm.md`](moore-fsm.md), which does.

## 5. Timing behaviour

### REQ-CNT-005 — load wins over decrement

Intended behaviour. `in` is 5; the registered value is 2 before the edge.

```text
            :    :    :    :
clk     ____/‾‾‾‾\____/‾‾‾‾\____
start   _________/‾‾‾‾‾‾‾‾‾\____
dec     _________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾
value   ======2=======X==5======
                      ^
                      both asserted: the load wins, no decrement is applied
```

### REQ-CNT-007 — `stop` rises with the registered zero, not before

Intended behaviour. The registered value is 1 before the edge and `dec` is asserted.

```text
            :    :    :    :
clk     ____/‾‾‾‾\____/‾‾‾‾\____
dec     _________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾
value   ======1=======X==0======
stop    ______________/‾‾‾‾‾‾‾‾‾
                      ^
                      same edge on which value becomes 0, not the edge before
```

### Observed behaviour

Regenerate the measured trace inside the environment:

```bash
make wave
vcdtui build/waves/counter.vcd --dump --no-color \
    --scope tb_counter -s clk,start,dec,in4,value4,stop4
```

You can also render the same selection as a static waveform:

```bash
$ vcdtui build/waves/counter.vcd \
    --scope tb_counter \
    -s clk,start,dec,in4,value4,stop4 \
    --dump-wave --wave-width 80 --no-color
```

which produces:

```bash
             0ps             20ps              40ps             60ps        76ps
             ┼───┊──┊───┊──┊───┼───┊──┊───┊──┊───┼──┊───┊──┊───┊──┼───┊──┊───┊─┼
clk          _____/‾‾‾\____/‾‾‾\___/‾‾‾‾\___/‾‾‾‾\___/‾‾‾\____/‾‾‾\____/‾‾‾\___/
start        _________/‾‾‾‾‾‾‾‾\_________________/‾‾‾‾‾‾‾\_________________/‾‾‾‾
dec          __________________/‾‾‾‾‾‾‾‾\________________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
in4[3:0]     ──0000───│──0011──│──────0000───────│─0001──│──────0000───────│0101
value4[3:0]  ─────0000─────│─0011──│──────0010───────│──0001──│──────0000──────│
stop4        ‾‾‾‾‾‾‾‾‾‾‾‾‾‾\__________________________________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\
```

The trace contains the testbench signals rather than the design port names. The testbench instantiates the counter twice, so `in4`, `value4`, and `stop4` are the connections for the `WIDTH=4` instance.

`--dump` prints exact value changes as a table and exits. `--dump-wave` renders the selected interval as a deterministic static waveform. Without either option, `vcdtui` opens the interactive viewer.

## 6. Assumptions and constraints

- One clock domain; no clock-domain crossing.
- `in` is stable at the rising edge on which `start` is asserted.
- The value at simulation time zero is not specified by this document. Do not infer reset semantics from it (REQ-CNT-008).

## 7. Verification

| Requirement | Method | Evidence | Negative evidence |
| --- | --- | --- | --- |
| `REQ-CNT-001` | Simulation | `counter.load.width8`, `counter.decrement.width8`, `counter.hold.width8`, `counter.stop.low_after_load.width8`, `counter.one_not_stopped.width8`, `counter.zero_and_stop.width8`, `counter.saturates_at_zero.width8`, `counter.start_priority.width8`, `counter.start_priority_from_nonzero.width8`, `counter.stop_reflects_held_value.width8` | — |
| `REQ-CNT-002` | Simulation | `counter.load.width4`, `counter.load.width8` | — |
| `REQ-CNT-003` | Simulation | `counter.decrement.width4`, `counter.decrement.width8` | — |
| `REQ-CNT-004` | Simulation | `counter.hold.width4`, `counter.hold.width8` | — |
| `REQ-CNT-005` | Simulation | `counter.start_priority.width4`, `counter.start_priority.width8`, `counter.start_priority_from_nonzero.width4`, `counter.start_priority_from_nonzero.width8` | `counter_priority.sv` |
| `REQ-CNT-006` | Simulation | `counter.saturates_at_zero.width4`, `counter.saturates_at_zero.width8` | `counter_wrap.sv` |
| `REQ-CNT-007` | Simulation | `counter.stop.low_after_load.width4`, `counter.stop.low_after_load.width8`, `counter.one_not_stopped.width4`, `counter.one_not_stopped.width8`, `counter.zero_and_stop.width4`, `counter.zero_and_stop.width8`, `counter.stop_reflects_held_value.width4`, `counter.stop_reflects_held_value.width8` | `counter_stop_early.sv` |
| `REQ-CNT-008` | Review | interface table, §2 | — |

## 8. Open issues

None.

## Revision history

| Revision | Date | Change |
| --- | --- | --- |
| A | 2026-08-20 | First baselined issue. Authored from the design intent recorded in the course-owned reference implementation. |
| B | 2026-08-21 | Clean up format. |
| C | 2026-08-22 | Add --dump-wave explanation in documentation. |
