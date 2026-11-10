# 32-Bit Arithmetic Logic Unit (ALU) Using Verilog

A small, synthesizable, combinational 32-bit ALU written in Verilog-2001. The repository includes the RTL, a self-checking testbench, a block diagram, simulation instructions, and a short project report.

## Features

- 32-bit operands and result
- 16 operation encodings: arithmetic, bitwise logic, shifts, comparisons, pass-through, and clear
- `zero`, `carry`, and signed `overflow` status outputs
- Self-checking testbench with known benchmark vectors
- No clock required: this is a combinational datapath block

## Repository layout

```text
alu32-verilog/
├── src/
│   └── alu32.v
├── tb/
│   └── tb_alu32.v
├── docs/
│   ├── block_diagram.png
│   ├── block_diagram.svg
│   └── project_report.md
├── sim/
│   └── .gitkeep
├── .github/
│   └── workflows/
│       └── iverilog.yml
├── .gitignore
└── README.md
```

## ALU operation table

| `alu_ctrl` | Operation | Result |
|---|---|---|
| `0000` | ADD | `a + b` |
| `0001` | SUB | `a - b` |
| `0010` | AND | `a & b` |
| `0011` | OR | `a \| b` |
| `0100` | XOR | `a ^ b` |
| `0101` | NOR | `~(a \| b)` |
| `0110` | NOT A | `~a` |
| `0111` | Logical left shift | `a << b[4:0]` |
| `1000` | Logical right shift | `a >> b[4:0]` |
| `1001` | Arithmetic right shift | `$signed(a) >>> b[4:0]` |
| `1010` | Signed less-than | `signed(a) < signed(b)` |
| `1011` | Unsigned less-than | `a < b` |
| `1100` | Equality | `a == b` |
| `1101` | Pass B | `b` |
| `1110` | Pass A | `a` |
| `1111` | Clear / reserved | `0` |

Shift amount uses the low five bits of `b`, giving a range from 0 to 31.

## Status outputs

- `zero`: asserted when `result` is zero, for every operation.
- `carry`: for ADD, the unsigned carry-out; for SUB, 1 means no unsigned borrow (`a >= b`). It is 0 for other operations.
- `overflow`: signed two's-complement overflow for ADD and SUB. It is 0 for other operations.

## Run simulation with Icarus Verilog

Install Icarus Verilog (`iverilog` and `vvp`) from its official project/package source. From the repository root:

```bash
iverilog -g2001 -Wall -o sim/alu32_tb.vvp src/alu32.v tb/tb_alu32.v
vvp sim/alu32_tb.vvp
```

The testbench checks 18 operation results plus 4 arithmetic status-flag cases (22 checks total). A successful run ends with:

```text
TEST SUMMARY: 22 passed, 0 failed
ALL TESTS PASSED
```

The testbench prints each vector and its result. If a test fails, the output identifies the operation, operands, expected value, and actual value. The testbench checks both operation results and selected zero/carry/overflow flag cases. GitHub Actions automatically installs Icarus Verilog, compiles the design, runs the testbench, and fails the workflow if the success marker is missing.

## Automatic simulation on GitHub

The workflow in `.github/workflows/iverilog.yml` runs on every push and pull request. After uploading the repository, open the **Actions** tab on GitHub and select **Verilog ALU Simulation**. A green check means the compile and testbench steps completed successfully. The workflow uploads `sim/simulation_output.txt` as a downloadable artifact named `alu32-simulation-output` on the Actions run; it is not automatically committed back into the repository.

## Run with another simulator

Compile `src/alu32.v` and `tb/tb_alu32.v` together, select `tb_alu32` as the simulation top, and run the simulation. Simulator commands differ by tool.

## Upload to GitHub

1. Create a new public or private repository named `alu32-verilog`.
2. Upload the folders and files in this project, preserving the folder structure.
3. Commit with a message such as `Add 32-bit Verilog ALU and self-checking testbench`.
4. Run the simulation locally and, if required, upload the generated transcript as `sim/simulation_output.txt`.

## Limitations and design notes

This is a combinational educational ALU, not a complete CPU. It has no instruction decoder, register file, pipeline, memory interface, or clocked state. The carry and overflow flags are meaningful only for the arithmetic operations as described above. Synthesis area and timing depend on the target FPGA/ASIC library and tool settings.
