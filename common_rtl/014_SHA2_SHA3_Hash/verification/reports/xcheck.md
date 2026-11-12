# X check by random power-up state (TEST-025, 15.3)

X policy of 15.3 (TEST-025): "no X on any output after reset; resetless memories are read only after a write". Verilator is two-state, so a four-state X is not available. Substitute: the same vectors run with all registers and memories set to zero at power-up and with random power-up values (`--x-initial unique`, three seeds). The hash of the outputs (OUTHASH of the testbench, outputs counted only while they are meaningful) and the scoreboard shall be identical in all four runs: no output depends on a register or memory word that was never written or reset. This does NOT find X pessimism or optimism of a four-state simulator. Run: python xcheck.py    Writes reports/xcheck.md; exit 1 on a difference.

| Run | Power-up | Scoreboard pass/fail | Output hash core | Output hash apb |
|---|---|---|---|---|
| zero | 0 | 2546 / 0 | 84107ecbdb04c005 | 14f56035de893077 |
| unique seed 1 | unique | 2546 / 0 | 84107ecbdb04c005 | 14f56035de893077 |
| unique seed 2 | unique | 2546 / 0 | 84107ecbdb04c005 | 14f56035de893077 |
| unique seed 3 | unique | 2546 / 0 | 84107ecbdb04c005 | 14f56035de893077 |

| Control run (mutant: error read data from the FIFO memory) | Power-up | Output hash core |
|---|---|---|
| mutant | 0 | 84107ecbdb04c005 |
| mutant | unique | c3d6907bafcd9aa9 |
Control: the hashes differ, the check sees the dependence

Result: PASS: the four runs agree
