# VLSIT Default Verification Rules for Simulation Testbenches and Assertions (v1)

> **Purpose:** Default rules for simulation testbenches, protocol assertions and the analysis of failing checks in VLSIT projects. They complement `VLSIT_RTL_Design_Rule.md`, which covers design RTL only (SCP-01 of that file).
> **Repository:** https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
> **Tag `[NEW]`:** none yet; this is the first version of this file.

## 0. How to apply this document (for AI agents)

- **MUST / MUST NOT** = mandatory. **SHOULD** = default; deviation needs a written reason in the testbench header or review notes.
- The rules do not change the phases, gates or approvals of any flow that uses them. A flow decides when verification code is written; these rules decide how it is written and judged.

## 1. Scope

- **SCOPE-01** Covers verification source sets: testbenches, bus functional models, reference models, protocol assertions, adapters and the logs of their runs. Design RTL is covered by `VLSIT_RTL_Design_Rule.md`.

## 2. Sources of truth

- **VER-01** Every stimulus, expected value and check MUST be derived from the approved specification and from the exact standard revision and clause of each protocol on the ports, and MUST name the requirement ID or the clause it comes from (in its name or in a comment). It MUST NOT be derived from the behavior of the RTL.
- **VER-02** The RTL MAY be read only for port names, widths, parameters and connectivity. A mismatch between the RTL and the verification contract or specification is a finding to report, never a reason to change the expected behavior.
- **VER-03** When the specification and a standard conflict, or either is silent about a behavior the test needs, the test MUST NOT choose the behavior by itself. Record the open point and ask the designer.

## 3. Separation

- **VER-04** Verification code MUST be kept in its own source set and folders, outside the design file set and its `filelist.f`. The design rules (naming, `always_ff`, reset style, no delays, and so on) do not apply to it and the RTL rule check and RTL lint run on the design folder only.

## 4. Assertions

- **VER-05** Each protocol assertion MUST be named with the standard and clause (for example `APB-04 ... (IHI0024D 3.1, 4.1)`) or with the requirement ID, and MUST count how many times its antecedent was true (hits) and how many times its consequent failed (fails). The run prints this table.
- **VER-06** Assertions MUST sample at the active clock edge before the flip-flops of the design update. A simulator without concurrent assertions MAY implement them as clocked checks with the same sampling.
- **VER-07** A rule that binds the requester or the device checks that the stimulus is legal. When a test breaks such a rule on purpose (for example an orphan response or a wrong response code), the test MUST mask exactly that assertion for exactly that cycle through a named input and state it in the header. An assertion MUST NOT be removed or weakened to make a run pass.
- **VER-08** A check or assertion that reports a failure MUST make the process exit with a non-zero status. A test passes only when its checking logic and its exit status both pass.

## 5. Failing checks

- **VER-09** When a check or assertion fails, first read the clause or requirement it comes from, the RTL that drives the signals, the test (stimulus, expected value, assertion and masks) and the cycle trace. When this shows which of them is wrong, fix that one and say what was changed and why.
- **VER-10** When the cause is **not** clear, the agent MUST give the designer a detailed analysis and wait for the decision before changing the RTL or the test. The analysis has these parts:

| Part | Content |
|---|---|
| Failure | Test, check or assertion name, simulation time, seed, signal values and the cycle trace around it. |
| Specification says | The requirement ID or protocol clause, quoted, with file and section. |
| RTL does | File and lines that produce the observed behavior and what they do in these cycles. |
| Test does | Stimulus, expected value and assertion with file and lines, and how the expected value was derived. |
| Candidates | A. the RTL is wrong, B. the test is wrong, C. the specification is silent or contradictory: the evidence for and against each one. |
| Impact | What each candidate means for the design and for the other tests. |
| Options | What the designer can decide (fix the RTL, fix the test, clarify the specification) and the change each needs; a recommendation may be given and is marked as such. |

## 6. Strength of the testbench

- **VER-11** A testbench SHOULD be shown able to fail: on a copy of the RTL, inject bugs that match requirements (a rule not applied, a signal stuck, a phase one cycle late), run it and record which check or assertion caught each one. A bug nothing catches means a missing check or stimulus. Report how many bugs were injected, how many were caught, and which were equivalent to the original design. Never inject bugs into the delivered RTL.
- **VER-12** The report SHOULD state which standards, clauses and requirements the testbench was derived from, the seeds used, every failure with its decision, and what was not verified (formal proof, coverage, a protocol feature the stimulus does not drive).
