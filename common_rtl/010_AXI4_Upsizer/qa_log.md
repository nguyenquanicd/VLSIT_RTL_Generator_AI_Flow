# Question and answer log of the specification (rules R-003, R-004, R-026)

All answers were given by the user in the chat on 2026-10-27 (rounds 1 to 5) and 2026-10-28 (rounds 6 to 10). The recommended option is marked (R).

| Round | Question | Answer | Recorded as |
|---|---|---|---|
| 1 | Naming rule | Default rule of the RTL generator v2 (R) | DEC-001 |
| 1 | Output folder | `common_rtl\010_AXI4_Upsizer` (R) | DEC-002 |
| 1 | AXI protocol scope | AXI4 and AXI3 (not the recommended AXI4-only option) | DEC-003 |
| 1 | Ratio configuration | Two parameters, S and M data width (R) | DEC-004 |
| 2 | Clock domains | One clock, one reset (R) | DEC-005 |
| 2 | Packing policy | Pack when Modifiable, lane steering otherwise (R) | DEC-006 |
| 2 | Outstanding and read interleaving | In order, no interleaving (R) | DEC-008, ASM-002 |
| 2 | Burst types packed | INCR and WRAP (not the recommended INCR-only option) | DEC-007 |
| 3 | Width limits | M larger than S, each 8 to 1024 (R) | DEC-009 |
| 3 | Profile selection | Two separate top modules (R) | DEC-010 |
| 3 | Exclusive and FIXED | Lane steering (R) | DEC-011 |
| 3 | Register slices | Always a register on every channel (not the recommended per-channel parameter) | DEC-012 |
| 4 | W before AW | Wait for the AW, then accept W (R) | DEC-013 |
| 4 | Address, ID and outstanding limits | As `003_AsyncAXI4Bridge` plus outstanding depth parameters (R) | DEC-014, ASM-004 |
| 5 | WRAP not aligned to M | Pack under the right conditions, otherwise lane steering (R); the question showed the constraint of REF-001 A3.4.1 (WRAP start aligned to the transfer size) | DEC-015 |
| 5 | Narrow transactions | No pack, lane steering (R) | DEC-016 |
| 5 | Sections not needed | All seven confirmed (R) | DEC-017 |
| 5 | Waveform plan (R-024) | Option A, all 12 waveforms (R) | DEC-018 |
| 6 | Address width limit | 12 to 64 (R) | ASM-004 confirmed |
| 6 | AXI3 write data order (ASM-003) | Support WID interleave (not the recommended no-interleave option) | DEC-019, ASM-003 replaced |
| 6 | PPA targets (TBD-001) | Stay TBD until a technology is chosen (R) | TBD-001 |
| 6 | Remaining assumptions ASM-001, ASM-005, ASM-006, ASM-007 | Confirmed as written (R) | Section 20 |
| 7 | Number of interleaved write transactions | Parameter PARA_AXI_WR_INTERLEAVE_DEPTH (R) | DEC-019, REQ-PARAM-005 |
| 7 | Downstream and M-side interleave | The downstream shall accept interleaved write data (R) | DEC-019, DEP-004 |
| 7 | Scope of the change | AXI3 top only; the AXI4 top and the read path unchanged (R) | DEC-019 |
| 7 | Waveform for the interleave | Add WF-013 (R) | DEC-020 |
| 8 | ASM-002 (read data in AR order, no interleave) | Confirmed as written (R) | ASM-002 |
| 8 | ASM-003 and DEP-004 (AXI3 manager and downstream interleave) | Confirmed as written (R) | ASM-003, DEP-004 |
| 8 | ASM-008 (AXI3 interleave rules, issue F not available locally) | Search the Arm site; if not found propose the most feasible option. Found the Arm AXI Protocol Specification v1.0 (IHI 0022B) sections 8.4 and 8.5 | ASM-008, REF-006, `research/axi3_write_interleave_source.md` |
| 8 | Next step | Stop at the specification (not the recommended RTL generation) | - |
| 9 | Convert the Arm IHI 0022B PDF to Markdown | Convert and add to the `md_doc` of the skill (not the recommended IP-folder-only option); the PDF is kept in `research/source_docs/`, ignored by git, not deleted | REF-006, ASM-008 |
| 9 | Read issue F too | No, v1.0 is enough (R) | ASM-008 |
| 9 | Add 010 to `common_rtl/README.md` | Not yet | - |
| 9 | Status of the specification | Keep Draft 0.1 (R) | front matter |
| 10 | Open points | Leave all as TBD, not to be reviewed now (statement of the user) | DEC-022, TBD-001 |
| 10 | Combinational circuit | It should be optimized (statement of the user) | DEC-021, REQ-RTL-004, PPA-004, TEST-022 |

Assumptions still open are listed in section 20 of the specification (TBD-001 only; ASM-008 is checked against REF-006 in md_doc, issue F not read).
