# ECE 748 Project 3 — LC3 bench (UVMF 2026.1)

Generated with the UVMF code generator (`$UVMF_HOME/scripts/yaml2uvmf.py`) from the
YAML in `uvmf_yaml/`. The LC3-specific code is written inside the generator's
`// pragma uvmf custom <name> begin/end` blocks.

## Layout

| Item | Where |
|---|---|
| 14 interface packages (imem, dmem + in/out for 6 stages) | `verification_ip/interface_packages/` |
| 6 stage environments + top `lc3` environment | `verification_ip/environment_packages/` |
| Course prediction models | `verification_ip/lc3_prediction_pkg/` |
| Scoreboards shared by the environments | `verification_ip/lc3_common_pkg/` |
| Bench (hdl_top, hvl_top, tests, sequences) | `project_benches/lc3/tb/` |
| LC3 RTL (from the professor) | `project_benches/lc3/rtl/` |
| Makefile, regression, test plan | `project_benches/lc3/sim/` |

* imem and dmem agents are ACTIVE RESPONDERS: they supply all instructions and data.
* The 12 stage agents are PASSIVE. Each stage environment predicts with the
  course model and checks in an in-order scoreboard.
* The LC3 environment checks that the decode stage receives exactly the instruction
  stream that imem delivered (`lc3_stream_scoreboard`).
* Coverage: 500 bins in 15 covergroups.
  * Instruction stream (386 bins, 7 covergroups): `imem_pkg/src/imem_transaction_coverage.svh`,
    enabled in `test_top`. Opcode x addressing mode, opcode pairs, operand crosses, distance-2
    data dependencies, 3-instruction sequences.
  * Pipeline behaviour (114 bins, 8 covergroups): `lc3_env_pkg/src/lc3_pipeline_coverage.svh`,
    sampled from the passive stage agents. Branch outcome per condition x psr, bypass paths,
    psr per writer, ALU result sign / overflow / operand corners, mem_state sequences, LDI/STI
    pointers, pipeline enable patterns.
  * Coverpoints that only feed a cross have weight 0, so nothing is counted twice.

## Run (grendel, Questa module loaded so `$UVMF_HOME` is set)

```
cd project_benches/lc3/sim
bash regress.sh                         # all tests + merge + report
make run TEST=lc3_closure_test          # one test (add BATCH=1 to skip the coverage GUI)
make p3_debug TEST=lc3_alu_test         # GUI debug
make view_coverage                      # merged coverage in the GUI
```

## Tests

| Test | Purpose |
|---|---|
| `lc3_closure_test` | Directed instruction and data stream that hits all 500 bins |
| `lc3_alu_test` | ADD/AND/NOT heavy random |
| `lc3_mem_test` | Load/store heavy random |
| `lc3_ctrl_test` | BR/JMP heavy random |

## Before submitting

```
cd project_benches/lc3/sim && make clean && cd ../../../..
mv groupXX_p3_uvmf group##_p3
zip -r group##_p3.zip group##_p3
```
Keep `project_benches/lc3/results/`: it holds the transcripts, merged UCDB and coverage report.
