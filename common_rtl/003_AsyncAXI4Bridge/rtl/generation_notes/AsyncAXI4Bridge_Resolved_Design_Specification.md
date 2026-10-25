---
document_type: asic_ip_design_specification
document_id: "VLSIT-AAXI-SPEC"
title: "Asynchronous AXI Bridge Design Specification"
ip_name: "Asynchronous AXI Bridge"
version: "0.1"
status: "Draft"
language: "SystemVerilog IEEE 1800-2017"
rtl_rules: "VLSIT_RTL_Design_Rule.md"
csr_spec: "Not required (no software-visible registers)"
---

# Asynchronous AXI Bridge Design Specification

> **Purpose:** Normative design contract for architecture, RTL, verification, DFT, and physical integration of this IP.
>
> **Status of this resolved working copy:** The designer's confirmed choices for DEC-021 to DEC-028 and the three fixed port profiles are recorded in Section 23. RTL generated from this copy is in the sibling `axi4_base/`, `axi4_user/` and `axi3/` folders. The waveforms and the latency and throughput figures still come from the prototype in `waveforms/proto/`; they are not measurements of this RTL.
>
> Requirement terms: **shall** = mandatory and testable; **should** = recommended; **may** = optional.

## Document map

1. [Purpose, scope, and product context](#1-purpose-scope-and-product-context)
2. [Normative references and precedence](#2-normative-references-and-precedence)
3. [Requirements and traceability](#3-requirements-and-traceability)
4. [Features and configurations](#4-features-and-configurations)
5. [Architecture](#5-architecture)
6. [External interfaces and ports](#6-external-interfaces-and-ports)
7. [Clock, reset, and power](#7-clock-reset-and-power)
8. [Parameters and elaboration configurations](#8-parameters-and-elaboration-configurations)
9. [Data representation and arithmetic](#9-data-representation-and-arithmetic)
10. [Detailed functional behavior](#10-detailed-functional-behavior)
11. [Register and programming model (CSR from workbook)](#11-register-and-programming-model)
12. [Error handling and recovery](#12-error-handling-and-recovery)
13. [Performance, power, and area](#13-performance-power-and-area)
14. [RTL implementation contract](#14-rtl-implementation-contract)
15. [Verification specification](#15-verification-specification)
16. [DFT and testability](#16-dft-and-testability)
17. [Physical design and timing integration](#17-physical-design-and-timing-integration)
18. [Security, safety, and reliability](#18-security-safety-and-reliability)
19. [Requirement-to-verification traceability](#19-requirement-to-verification-traceability)
20. [Assumptions, dependencies, and decisions](#20-assumptions-dependencies-and-decisions)
21. [Glossary](#21-glossary)
22. [References used to shape this template](#22-references-used-to-shape-this-template)

## 1. Purpose, scope, and product context

### 1.1 Purpose and scope

The IP connects an AXI manager and an AXI subordinate that run on **asynchronous clocks** of any frequency and any phase relation. Its subordinate-side interface (clock `i_clk_sub`) is connected to the external manager. Its manager-side interface (clock `i_clk_mgr`) is connected to the external subordinate. The bridge carries the five AXI channels (AW, W, B, AR, R) across the clock boundary. Each channel is one asynchronous Gray-code FIFO, the sibling IP `001_AsyncGrayFIFO`, with a configurable depth per channel (DEC-004, DEC-011). The optional user signals travel with their channel (DEC-005). The bridge supports AXI4 (the default) and, as an option, AXI3 (DEC-008).

The bridge **forwards** the information: it does not check, interpret, reorder or modify the AXI traffic (DEC-019). The terms Manager and Subordinate follow the converted standard (`reference/md_doc/vlsit_axi_amba_axi_ihi0022h_c.md`, Arm IHI 0022 issue H.c, section A1.3).

**Included:**

- Structural top `m_vlsit_axi_async_top`.
- Five channel modules (AW, W, B, AR, R). Each packs the fields of its channel into one FIFO word, instantiates one `m_vlsit_afifo_top` and unpacks the word on the other side.
- Parameterized address, data and ID widths; optional QOS and REGION fields; optional user signals per channel; AXI3 option.
- Selectable FIFO depth per channel, selectable synchronizer cell option (common to the five FIFOs), selectable memory branch (common to the five FIFOs).

**Excluded:**

- Any check of the AXI protocol, any response generation, any address decode, ordering or ID translation (DEC-019).
- Data-width, address-width or protocol conversion (AXI4-Lite, AXI5, ACE, APB, TL-UL).
- Software reset (DEC-009): the software reset function of `001_AsyncGrayFIFO` is not used.
- FIFO status outputs, threshold flags, overflow and underflow indications (DEC-016).
- Reset synchronizers (each reset input is already synchronized to its own clock, REQ-RESET-001).
- Clock generation and clock gating, ECC or parity, security and safety functions, DFT structures.

### 1.2 Deployment assumptions

| Item | Specification |
|---|---|
| Target SoC / product class | Generic ASIC clock-domain-crossing bridge between an AXI manager and an AXI subordinate (an interconnect port, a peripheral, a memory controller) |
| Technology / library assumptions | Standard-cell library; the synchronizer cells and the optional SRAM macro are provided through the wrappers and cell models of `001_AsyncGrayFIFO` and `000_Common` |
| Operating modes and workload | Two asynchronous clocks with no restriction on frequency or ratio; bursts of up to 256 beats (AXI4) or 16 beats (AXI3) |
| Security / privilege context | None (the AXI protection attributes pass through unchanged) |
| External dependencies | Two clock sources, one reset controller per domain, the sibling IP `001_AsyncGrayFIFO` and the libraries of `000_Common` |

### 1.3 Feature summary

| Feature ID | Feature | Required / optional | Configuration condition | Requirements |
|---|---|---|---|---|
| FEAT-001 | Five-channel clock-domain-crossing bridge for AXI (AW, W, B, AR, R) | Required | Always present | REQ-FUNC-001 to REQ-FUNC-006 |
| FEAT-002 | Asynchronous clocks of any frequency and ratio | Required | Always present | REQ-CLK-001, REQ-CLK-002 |
| FEAT-003 | Parameterized address, data and ID width | Required | Always present | REQ-PARAM-001, REQ-IF-001 |
| FEAT-004 | Selectable FIFO depth per channel | Required | `PARA_AXI_AW_DEPTH` and the four other depths | REQ-PARAM-002, REQ-PERF-001 |
| FEAT-005 | User signals on each channel | Optional | `PARA_AXI_AWUSER_W` and the four other user widths greater than 0 | REQ-FUNC-007 |
| FEAT-006 | AXI3 option | Optional | `PARA_AXI_AXI3_EN` = 1 | REQ-FUNC-008, REQ-FUNC-009 |
| FEAT-007 | Optional QOS and REGION fields | Optional | `PARA_AXI_QOS_EN`, `PARA_AXI_REGION_EN` | REQ-FUNC-010 |
| FEAT-008 | Synchronizer cell option | Required | `PARA_AXI_CELL_TYPE` 1 to 4 | REQ-PARAM-003, REQ-PERF-002 |
| FEAT-009 | Library SRAM branch of the FIFO storage | Optional | `PARA_AXI_MEM_USE_MACRO` = 1 | REQ-RTL-003 |

## 2. Normative references and precedence

### 2.1 Normative references

| Ref ID | Document and revision | Applicable clauses | Authority / notes |
|---|---|---|---|
| REF-001 | Arm IHI 0022 issue H.c, AMBA AXI and ACE Protocol Specification, converted to `reference/md_doc/vlsit_axi_amba_axi_ihi0022h_c.md` (Arm proprietary licence, no redistribution) | Part A (AXI3, AXI4): chapters A2, A3, A5, A7, A8; table E1-31 | Authority for every protocol statement of this document. Parts C to F (AXI5, ACE) are out of scope |
| REF-002 | `VLSIT_RTL_Generator_AI_Model\common_rtl\001_AsyncGrayFIFO\AsyncGrayFIFO_Design_Specification.md` draft 0.1 and its RTL | Ports (6.2), clock-domain crossing (7.2), parameters (8), latency (10.3, 10.4), constraints (17.1) | The FIFO of every channel. Its behavior is inherited, not redefined here |
| REF-003 | VLSIT RTL Design Rules v2, `VLSIT_RTL_Generator_AI_Model\spec_template\VLSIT_RTL_Design_Rule.md` | All applicable rules, section 9 (protocol interface naming) | Mandatory RTL coding, hierarchy, reset, CDC and naming baseline |
| REF-004 | IEEE 1800-2017 SystemVerilog | Synthesizable subset | Subject to REF-003 and the selected frontend |
| REF-005 | Decisions of the designer, 2026-10-25 (Section 20) | DEC-001 to DEC-020 | Product behavior; no external product document exists |
| REF-006 | Prototype and its logs, `waveforms/proto/` and `waveforms/axi_perf_table.txt` | Sections 10.3, 10.4 and 15 | Evidence for the waveforms, the latency and the throughput; not the delivered RTL |

### 2.2 Source-of-truth and conflict handling

1. This specification and the decisions of Section 20 define the behavior of the IP.
2. REF-001 defines the AXI protocol. Where this specification restricts the protocol (for example no AXI5), the restriction is stated explicitly.
3. REF-002 defines the FIFO. A conflict between this specification and REF-002 about the FIFO is resolved in REF-002; this specification only uses the FIFO as it is.
4. REF-003 is the mandatory RTL coding, hierarchy, reset, CDC and naming baseline. The latest designer-approved fixed-profile interface in Section 23.1 supersedes earlier placeholder-port text in this draft.
5. The IP has no registers, so there is no CSR workbook.
6. Conflicts are resolved through an explicit decision recorded in Section 20.

**Naming rule:** the default naming rule of vlsit-rtl-generator, section 2 and section 9 (protocol interface naming) of VLSIT_RTL_Design_Rule.md v2 (clauses NAM-01 to NAM-09 and PRT-01 to PRT-04), path `VLSIT_RTL_Generator_AI_Model\spec_template\VLSIT_RTL_Design_Rule.md`, version v2, chosen by the designer on 2026-10-25 (answer 1A, rule R-026, DEC-001).

### 2.3 Compliance declaration

| Standard | Revision / profile | Role implemented | Options | Deviations |
|---|---|---|---|---|
| AMBA AXI4 | Arm IHI 0022 issue H.c, Part A (AXI4) | Subordinate interface (towards the external manager) and Manager interface (towards the external subordinate) of a clock-domain-crossing bridge | User signals (optional per channel), QOS and REGION (optional) | The bridge does not check the protocol (DEC-019) |
| AMBA AXI3 | Arm IHI 0022 issue H.c, Part A (AXI3) | The same two roles | `PARA_AXI_AXI3_EN` = 1 | None |

The two names of the interfaces follow the standard: the interface that receives the requests is the Subordinate interface, the one that issues the requests is the Manager interface (section A1.3).

## 3. Requirements and traceability

| ID | Requirement using shall/should/may | Source | Applies to | Verification method |
|---|---|---|---|---|
| REQ-FUNC-001 | The bridge shall transfer every information word of each channel from the clock domain in which the source asserts VALID to the clock domain of the destination, unchanged in every payload bit, in the order of acceptance, with no loss and no duplication, for every legal parameter value and every clock ratio. | DEC-002, REF-001 A3.2 | All configurations | Scoreboard simulation: TEST-002, TEST-003, TEST-014 |
| REQ-FUNC-002 | The channels AW, W and AR shall carry information from the subordinate-side interface (CLK-SUB) to the manager-side interface (CLK-MGR). The channels B and R shall carry information from the manager-side interface to the subordinate-side interface. | REF-001 A2.2 to A2.6 | All configurations | Simulation: TEST-002, TEST-003 |
| REQ-FUNC-003 | A transfer shall be accepted on the source side of a channel at the rising edge of the source clock at which VALID and READY are both 1, and shall be presented on the destination side with VALID = 1 until the destination samples READY = 1 at a rising edge of the destination clock. | REF-001 A3.2 | All configurations | Assertions SVA-001 to SVA-004; simulation: TEST-002 |
| REQ-FUNC-004 | Once VALID is 1 on a destination-side output, VALID and all payload signals of the channel shall stay unchanged until the handshake takes place. VALID shall not depend on READY. | REF-001 A3.2, A3.3.1 | All configurations | Assertions SVA-003, SVA-004; simulation: TEST-004 |
| REQ-FUNC-005 | The bridge shall have no combinational path from any input port to any output port. Each READY output of a source-side interface shall come from a flip-flop-based flag of the channel FIFO, and each VALID and payload output of a destination-side interface from the FIFO output flag and output register. | REF-001 A3.1.1, DEC-011 | All configurations | Structural check: TEST-012 |
| REQ-FUNC-006 | The bridge shall not generate, alter, delay beyond the FIFO latency, drop, reorder within a channel, or check any transfer. It shall not impose a relationship between channels other than the one the FIFOs introduce by their latency. In particular it shall not generate a write response, and the write response of the external subordinate shall reach the subordinate-side interface only after it was issued on the manager side, which follows the last write data transfer of the transaction. | DEC-019, REF-001 A3.3 | All configurations | Simulation: TEST-002, TEST-005 |
| REQ-FUNC-007 | When a user width parameter of a channel is greater than 0, the user signal of that channel shall be carried with the channel, bit for bit, with the same validity as the other signals of the channel. When it is 0 the user port shall be ignored (input) or driven to 0 (output) and no FIFO bit shall be spent on it. | DEC-005, REF-001 A8.3 | `PARA_AXI_*USER_W` | Simulation: TEST-006; waveform WF-007 |
| REQ-FUNC-008 | With `PARA_AXI_AXI3_EN` = 1 the bridge shall use the AXI3 field set: AWLEN and ARLEN have 4 bits, AWLOCK and ARLOCK have 2 bits, the write data channel carries WID, and QOS, REGION and all user signals are not present (their ports are ignored or driven to 0). With `PARA_AXI_AXI3_EN` = 0 the bridge shall use the AXI4 field set: AWLEN and ARLEN have 8 bits, AWLOCK and ARLOCK have 1 bit, WID is not present. | DEC-008, REF-001 A2.2 to A2.6, A3.4, A7.3 | `PARA_AXI_AXI3_EN` | Simulation: TEST-007; waveform WF-008 |
| REQ-FUNC-009 | The ID of the write data channel (WID) shall be carried only when `PARA_AXI_AXI3_EN` = 1, so that the W channel FIFO word has `PARA_AXI_ID_W` more bits in AXI3 mode. | DEC-008, REF-001 A2.3 | `PARA_AXI_AXI3_EN` | Simulation: TEST-007 |
| REQ-FUNC-010 | When `PARA_AXI_QOS_EN` = 0 (or AXI3 mode) the QOS fields shall not be carried and the QOS output ports shall be driven to 0; the same holds for `PARA_AXI_REGION_EN` and the REGION fields. | DEC-015, REF-001 A2.2, A2.5 | `PARA_AXI_QOS_EN`, `PARA_AXI_REGION_EN` | Simulation: TEST-008 |
| REQ-IF-001 | The IP shall expose exactly the ports of Section 6.2. Their names follow REF-003 PRT-01. The widths depend on the parameters of Section 8 only. | REF-003 PRT-01, PRT-03 | All configurations | Lint and port-list review: TEST-012 |
| REQ-IF-002 | A port of an optional field that is not present (a user signal with width 0, QOS or REGION disabled, WID in AXI4 mode, the upper bits of a narrower field) shall remain in the port list with the minimum width of 1 bit (or the stated width), its input shall be ignored and its output shall be driven to 0. | DEC-022 | Optional fields | Lint and simulation: TEST-008, TEST-012 |
| REQ-CLK-001 | The two clocks `i_clk_sub` and `i_clk_mgr` shall be unrelated: any frequency, any ratio, any phase. No relation shall be assumed. | DEC-003 | All configurations | Simulation with several ratios: TEST-002, TEST-013 |
| REQ-CLK-002 | Every crossing between the clock domains shall be inside the channel FIFOs (Gray-coded pointers through the synchronizers of `001_AsyncGrayFIFO`). The bridge shall add no other crossing and shall not place logic between a source register and a synchronizer. | DEC-011, REF-002 CDC-001 to CDC-003 | All configurations | CDC review: TEST-011, TEST-012 |
| REQ-RESET-001 | The resets `i_rst_n_sub` and `i_rst_n_mgr` shall be active-low, asserted asynchronously and released synchronously to their own clock by logic outside the IP. The two resets shall be asserted together. No transfer shall start before both resets are released. | DEC-020, REF-001 A3.1.2 | All configurations | Simulation: TEST-001, TEST-010 |
| REQ-RESET-002 | During reset the bridge shall drive every VALID output (AWVALID, WVALID, ARVALID on the manager side; BVALID, RVALID on the subordinate side) low. All other outputs may have any value. | REF-001 A3.1.2 | All configurations | Assertion SVA-007; simulation: TEST-001; waveform WF-009 |
| REQ-RESET-003 | After the release of both resets every channel FIFO shall be empty and every VALID output shall be 0 until a transfer was accepted at the source side. A reset applied while transfers are in flight shall discard them. | REF-002 REQ-RESET | All configurations | Simulation: TEST-010 |
| REQ-PARAM-001 | The IP shall accept the parameter values of Section 8. The behavior with an illegal value is not specified and the IP does not check it. | DEC-001, REF-002 DEC-002 | All configurations | Elaboration of the legal ranges: TEST-009 |
| REQ-PARAM-002 | Each of the five FIFO depths shall be a power of 2 with a minimum of 2. The correctness shall not depend on the depth; the throughput does (Section 10.4). | DEC-004, REF-002 Section 8 | All configurations | Simulation: TEST-003, TEST-014 |
| REQ-PARAM-003 | `PARA_AXI_CELL_TYPE` (common to the five FIFOs) shall be 1, 2, 3 or 4. The option 0 (bypass) shall not be used. | DEC-013, REF-002 Section 8 | All configurations | Elaboration: TEST-009 |
| REQ-PERF-001 | Each channel shall accept one transfer per cycle of its source clock and present one transfer per cycle of its destination clock, as far as the FIFO is neither full nor empty. With a FIFO depth of at least 8 (equal clocks) or at least 4 (the unequal ratios of Section 10.4) and `PARA_AXI_CELL_TYPE` = 2, a burst shall stream at one beat per cycle of the slower clock. | DEC-004 | All configurations | Throughput sweep: TEST-013; waveform WF-010 |
| REQ-PERF-002 | The latency from the source-side handshake edge to the first assertion of VALID on the destination side shall be at most S + 2 destination-clock periods, S being the number of synchronizer stages of `PARA_AXI_CELL_TYPE` (2 for the options 1 and 2, 3 for the option 3, 4 for the option 4). | DEC-027, REF-002 Section 10.3 | All configurations | Latency measurement: TEST-013 |
| REQ-PERF-003 | The READY output of a source-side interface shall be 0 while its channel FIFO is full, and shall return to 1 after the destination side accepted a word and the read pointer reached the source domain. A source-side master that holds VALID shall therefore be held back without loss. | REF-001 A3.2 | All configurations | Simulation: TEST-004; waveforms WF-003, WF-005 |
| REQ-RTL-001 | The RTL shall comply with REF-003 and shall use the hierarchy of Section 14.2. | REF-003 | All configurations | Lint and rule check: TEST-012 |
| REQ-RTL-002 | Each channel shall instantiate `m_vlsit_afifo_top` of `001_AsyncGrayFIFO` without modification. The bridge shall tie `i_rst_n_sw` to 1, shall tie the thresholds `i_full_thr` to the depth and `i_empty_thr` to 0, and shall leave the status outputs (full and empty threshold, overflow, underflow, software reset busy) unconnected. | DEC-009, DEC-016, REF-002 | All configurations | Inspection and lint: TEST-012 |
| REQ-RTL-003 | `PARA_AXI_CELL_TYPE` and `PARA_AXI_MEM_USE_MACRO` shall be passed unchanged to the five FIFOs. | DEC-013, DEC-017 | All configurations | Simulation of both branches: TEST-002 |
| REQ-VER-001 | Every waveform of the waveform plan (Section 10.3) shall exist as an image with its WaveJSON source, and the prototype scripts shall reproduce them. | DEC-018 | All configurations | File check and rerun: TEST-015 |
| REQ-VER-002 | The scoreboard regression shall cover AXI4 and AXI3, user signals, several depths, both clock ratios (fast to slow, slow to fast), equal clocks, and shall report no error. | DEC-018 | All configurations | Regression: TEST-014 |

Suggested ID areas: FUNC, IF, CLK, RESET, PARAM, PERF, RTL, VER.

## 4. Features and configurations

| Configuration ID | Enabled features | Disabled features | Interfaces / widths | Intended use | Verification target |
|---|---|---|---|---|---|
| CFG-AXI4 | FEAT-001 to FEAT-004, FEAT-007, FEAT-008 | FEAT-005, FEAT-006, FEAT-009 (all defaults) | ADDR 32, DATA 32, ID 4, depths 4 / 16 / 4 / 4 / 16 | Default delivery | All tests |
| CFG-USER | CFG-AXI4 plus FEAT-005 | FEAT-006 | User widths greater than 0 | Bridge that carries side information | TEST-006 |
| CFG-AXI3 | FEAT-001 to FEAT-004, FEAT-006, FEAT-008 | FEAT-005, FEAT-007 | `PARA_AXI_AXI3_EN` = 1 | AXI3 components | TEST-007 |
| CFG-WIDE | CFG-AXI4 | FEAT-005, FEAT-006 | ADDR 64, DATA 1024, ID 32 | Widest legal instance | TEST-009 |
| CFG-MIN | CFG-AXI4 | FEAT-005, FEAT-006 | ADDR 1, DATA 8, ID 1, all depths 2 | Smallest legal instance | TEST-009, TEST-003 |
| CFG-MACRO | CFG-AXI4 plus FEAT-009 | FEAT-005, FEAT-006 | `PARA_AXI_MEM_USE_MACRO` = 1 | Deep FIFOs in a library SRAM | TEST-002 |
| CFG-CELL | CFG-AXI4 | FEAT-005, FEAT-006 | `PARA_AXI_CELL_TYPE` = 1, 3 or 4 | Other synchronizer cells | TEST-002, TEST-013 |

The features are selected by parameters at elaboration. The port list is the same for every configuration except for widths (REQ-IF-001, REQ-IF-002).

## 5. Architecture

### 5.1 Overview and block responsibilities

The bridge has five independent channels. Each channel is an asynchronous FIFO whose write side is in the clock domain of the source of the channel and whose read side is in the clock domain of the destination. The handshake maps directly onto the FIFO: READY of the source side is the inverse of the FIFO full flag, VALID of the destination side is the inverse of the FIFO empty flag, the source VALID is the FIFO write request and the destination READY is the FIFO read request. The FIFO is a show-ahead FIFO, so the destination payload is stable while VALID is 1 and READY is 0 (REF-002, the show-ahead read requirement).

| Block | Responsibility | Inputs / outputs | Clock/reset domain | State or storage |
|---|---|---|---|---|
| m_vlsit_axi_async_top | Structural top: ports, parameters, derived widths, five channel instances | All ports of Section 6.2 | CLK-SUB, CLK-MGR | None |
| m_vlsit_axi_async_aw | AW channel: packs AWID to AWUSER into one word, FIFO, unpacks | AW signals of both sides | Source CLK-SUB / RST-SUB, destination CLK-MGR / RST-MGR | FIFO depth `PARA_AXI_AW_DEPTH` |
| m_vlsit_axi_async_w | W channel: packs WID (AXI3), WDATA, WSTRB, WLAST, WUSER | W signals of both sides | Source CLK-SUB, destination CLK-MGR | FIFO depth `PARA_AXI_W_DEPTH` |
| m_vlsit_axi_async_b | B channel: packs BID, BRESP, BUSER | B signals of both sides | Source CLK-MGR, destination CLK-SUB | FIFO depth `PARA_AXI_B_DEPTH` |
| m_vlsit_axi_async_ar | AR channel: packs ARID to ARUSER | AR signals of both sides | Source CLK-SUB, destination CLK-MGR | FIFO depth `PARA_AXI_AR_DEPTH` |
| m_vlsit_axi_async_r | R channel: packs RID, RDATA, RRESP, RLAST, RUSER | R signals of both sides | Source CLK-MGR, destination CLK-SUB | FIFO depth `PARA_AXI_R_DEPTH` |
| m_vlsit_afifo_top | Asynchronous Gray FIFO (sibling IP `001_AsyncGrayFIFO`, one instance per channel) | Write side, read side | Source and destination domain | Pointers, flags, storage |

### 5.2 Block diagram

![Block diagram of the asynchronous AXI bridge: five channel modules in the top frame, one FIFO per channel (diagram spec: figures/axi_bridge_diagram_spec.json)](figures/axi_bridge_block_diagram.svg)

*Figure 5-1. Block diagram of the asynchronous AXI bridge: five channel modules in the top frame, one FIFO per channel (diagram spec: figures/axi_bridge_diagram_spec.json). Source: `figures/axi_bridge_block_diagram.drawio` (draw.io, VLSIT library, drawn by `vlsit_spec_diagram.py`). The frame is the top module, the blocks are its instances, each connector is one interface with its mnemonic, and the two tables under the diagram in the source file describe the blocks and the interfaces.*

### 5.3 Transaction and dataflow

1. **Write transaction.** The external manager drives AW and W on the subordinate side. Each channel stores a word per accepted transfer. On the manager side the AW word and the W words appear after the FIFO latency, independently of each other (data may appear before the address, REF-001 A3.3). The external subordinate answers with a B word on the manager side, which crosses back through the B FIFO.
2. **Read transaction.** AR crosses to the manager side. The external subordinate sends the R beats, which cross back through the R FIFO.
3. **Back-pressure.** When a FIFO is full its source-side READY falls, so the source holds its VALID and payload (AXI A3.2). When a destination does not assert READY, the FIFO keeps the word and its VALID stays 1.
4. **Reset.** Both resets are asserted together; the FIFOs are empty after release.

### 5.4 Invariants

- Each channel preserves the order of the words it accepted (FIFO).
- A source-side transfer happens only when its VALID and READY are 1 at the source clock edge, and a destination-side transfer only when VALID and READY are 1 at the destination clock edge.
- The bridge never changes the value of a payload bit; a disabled optional field is replaced by 0 at the output.
- No input port is combinationally connected to an output port (REQ-FUNC-005).
- No state of the bridge exists outside the five FIFOs.

## 6. External interfaces and ports

### 6.1 Interface inventory

| Interface ID | Type and revision | Role | Direction at IP boundary | Clock domain | Required / optional | Configurations |
|---|---|---|---|---|---|---|
| IF-001 | AMBA AXI4 (or AXI3 when `PARA_AXI_AXI3_EN` = 1), Arm IHI 0022 issue H.c | Subordinate (towards the external manager): AW, W, AR in; B, R out | Requests in, responses out | CLK-SUB | Required | All |
| IF-002 | AMBA AXI4 (or AXI3), Arm IHI 0022 issue H.c | Manager (towards the external subordinate): AW, W, AR out; B, R in | Requests out, responses in | CLK-MGR | Required | All |
| IF-003 | Clocks and hardware resets | Receiver | Inputs | CLK-SUB, CLK-MGR | Required | All |

### 6.2 Complete port list

Port names follow the default naming rule (DEC-001) and PRT-01: `<direction>_axi_<signal>` with the exact lowercase mnemonic of the protocol, where the direction is `i` or `o` at the boundary of this module (not the manager or subordinate role). The two interfaces use the same mnemonics in opposite directions, so the names are distinct: the subordinate side has `i_axi_awvalid` and `o_axi_awready`, the manager side `o_axi_awvalid` and `i_axi_awready`. The meaning column names the side. Widths use `LPARA_*` (Section 8). Optional fields that are not present keep their port (REQ-IF-002, DEC-022). The ports of the internal modules are in Section 14.2.1. Every port has a function, a clock domain and a **signal type**.

**m_vlsit_axi_async_top**

| Port | Direction | Width | Meaning (function) | Clock domain | Signal type | Reset / idle value | Timing / sampling | Configurations |
|---|---|---:|---|---|---|---|---|---|
| i_clk_sub | Input | 1 | Clock of the subordinate-side interface (towards the external manager) | CLK-SUB | Clock (free running, rising edge) | Not applicable | Rising edge | All |
| i_rst_n_sub | Input | 1 | Hardware reset of all subordinate-side state of the five FIFOs | CLK-SUB | Reset (active-low level, asserted asynchronously, released synchronously to i_clk_sub outside the IP) | Not applicable | Level; asserted together with i_rst_n_mgr | All |
| i_clk_mgr | Input | 1 | Clock of the manager-side interface (towards the external subordinate) | CLK-MGR | Clock (free running, rising edge) | Not applicable | Rising edge | All |
| i_rst_n_mgr | Input | 1 | Hardware reset of all manager-side state of the five FIFOs | CLK-MGR | Reset (active-low level, asserted asynchronously, released synchronously to i_clk_mgr outside the IP) | Not applicable | Level; asserted together with i_rst_n_sub | All |
| i_axi_awvalid | Input | 1 | Subordinate interface, write address channel: AWVALID of the source; the channel word is accepted when it is 1 and READY is 1 (A3.2) | CLK-SUB | Level (active-high; held until READY is 1) | 0 (shall be 0 in reset) | Sampled at the rising edge of i_clk_sub | All |
| o_axi_awready | Output | 1 | Subordinate interface, write address channel: AWREADY towards the source, 1 whenever the channel FIFO is not full | CLK-SUB | Level (flop-based flag, active-high) | 1 (FIFO not full) | Changes after a rising edge of i_clk_sub; may be 1 before VALID | All |
| i_axi_awid | Input | PARA_AXI_ID_W | Subordinate interface, write address channel: Identification tag of the write transaction (A2.2) | CLK-SUB | Data (valid when AWVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_awaddr | Input | PARA_AXI_ADDR_W | Subordinate interface, write address channel: Address of the first transfer of the write transaction | CLK-SUB | Data (valid when AWVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_awlen | Input | LPARA_LEN_W | Subordinate interface, write address channel: Burst length minus 1: 8 bits in AXI4, 4 bits in AXI3 (A3.4) | CLK-SUB | Data (valid when AWVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_awsize | Input | 3 | Subordinate interface, write address channel: Number of bytes of each transfer, as a power of 2 | CLK-SUB | Data (valid when AWVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_awburst | Input | 2 | Subordinate interface, write address channel: Burst type | CLK-SUB | Data (valid when AWVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_awlock | Input | LPARA_LOCK_W | Subordinate interface, write address channel: Atomic characteristics: 1 bit in AXI4, 2 bits in AXI3 (A7.3) | CLK-SUB | Data (valid when AWVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_awcache | Input | 4 | Subordinate interface, write address channel: Memory type attributes | CLK-SUB | Data (valid when AWVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_awprot | Input | 3 | Subordinate interface, write address channel: Protection attributes | CLK-SUB | Data (valid when AWVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_awqos | Input | 4 | Subordinate interface, write address channel: Quality of Service identifier; ignored input and output 0 when `PARA_AXI_QOS_EN` = 0 or AXI3 | CLK-SUB | Data (valid when AWVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | AXI4, `PARA_AXI_QOS_EN` |
| i_axi_awregion | Input | 4 | Subordinate interface, write address channel: Region indicator; ignored input and output 0 when `PARA_AXI_REGION_EN` = 0 or AXI3 | CLK-SUB | Data (valid when AWVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | AXI4, `PARA_AXI_REGION_EN` |
| i_axi_awuser | Input | LPARA_AWUSER_W | Subordinate interface, write address channel: User-defined write address extension; ignored input and output 0 when `PARA_AXI_AWUSER_W` = 0 or AXI3 | CLK-SUB | Data (valid when AWVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | AXI4, `PARA_AXI_AWUSER_W` |
| i_axi_wvalid | Input | 1 | Subordinate interface, write data channel: WVALID of the source; the channel word is accepted when it is 1 and READY is 1 (A3.2) | CLK-SUB | Level (active-high; held until READY is 1) | 0 (shall be 0 in reset) | Sampled at the rising edge of i_clk_sub | All |
| o_axi_wready | Output | 1 | Subordinate interface, write data channel: WREADY towards the source, 1 whenever the channel FIFO is not full | CLK-SUB | Level (flop-based flag, active-high) | 1 (FIFO not full) | Changes after a rising edge of i_clk_sub; may be 1 before VALID | All |
| i_axi_wid | Input | PARA_AXI_ID_W | Subordinate interface, write data channel: Write data ID tag; present in AXI3 only, ignored input and output 0 in AXI4 (A2.3) | CLK-SUB | Data (valid when WVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | AXI3 |
| i_axi_wdata | Input | PARA_AXI_DATA_W | Subordinate interface, write data channel: Write data | CLK-SUB | Data (valid when WVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_wstrb | Input | LPARA_STRB_W | Subordinate interface, write data channel: Write strobes, one bit per byte lane | CLK-SUB | Data (valid when WVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_wlast | Input | 1 | Subordinate interface, write data channel: Last transfer of the write burst | CLK-SUB | Data (valid when WVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_wuser | Input | LPARA_WUSER_W | Subordinate interface, write data channel: User-defined write data extension; ignored input and output 0 when `PARA_AXI_WUSER_W` = 0 or AXI3 | CLK-SUB | Data (valid when WVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | AXI4, `PARA_AXI_WUSER_W` |
| o_axi_bvalid | Output | 1 | Subordinate interface, write response channel: BVALID towards the destination, 1 whenever the channel FIFO is not empty | CLK-SUB | Level (flop-based flag, active-high; held until READY is 1) | 0 (empty FIFO) | Changes after a rising edge of i_clk_sub | All |
| i_axi_bready | Input | 1 | Subordinate interface, write response channel: BREADY of the destination; a word is taken when it is 1 and VALID is 1 | CLK-SUB | Level (active-high; may be 1 before VALID) | Any value in reset | Sampled at the rising edge of i_clk_sub | All |
| o_axi_bid | Output | PARA_AXI_ID_W | Subordinate interface, write response channel: Identification tag of the write response | CLK-SUB | Data (valid when BVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_sub | All |
| o_axi_bresp | Output | 2 | Subordinate interface, write response channel: Write response status | CLK-SUB | Data (valid when BVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_sub | All |
| o_axi_buser | Output | LPARA_BUSER_W | Subordinate interface, write response channel: User-defined write response extension; ignored input and output 0 when `PARA_AXI_BUSER_W` = 0 or AXI3 | CLK-SUB | Data (valid when BVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_sub | AXI4, `PARA_AXI_BUSER_W` |
| i_axi_arvalid | Input | 1 | Subordinate interface, read address channel: ARVALID of the source; the channel word is accepted when it is 1 and READY is 1 (A3.2) | CLK-SUB | Level (active-high; held until READY is 1) | 0 (shall be 0 in reset) | Sampled at the rising edge of i_clk_sub | All |
| o_axi_arready | Output | 1 | Subordinate interface, read address channel: ARREADY towards the source, 1 whenever the channel FIFO is not full | CLK-SUB | Level (flop-based flag, active-high) | 1 (FIFO not full) | Changes after a rising edge of i_clk_sub; may be 1 before VALID | All |
| i_axi_arid | Input | PARA_AXI_ID_W | Subordinate interface, read address channel: Identification tag of the read transaction | CLK-SUB | Data (valid when ARVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_araddr | Input | PARA_AXI_ADDR_W | Subordinate interface, read address channel: Address of the first transfer of the read transaction | CLK-SUB | Data (valid when ARVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_arlen | Input | LPARA_LEN_W | Subordinate interface, read address channel: Burst length minus 1: 8 bits in AXI4, 4 bits in AXI3 | CLK-SUB | Data (valid when ARVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_arsize | Input | 3 | Subordinate interface, read address channel: Number of bytes of each transfer, as a power of 2 | CLK-SUB | Data (valid when ARVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_arburst | Input | 2 | Subordinate interface, read address channel: Burst type | CLK-SUB | Data (valid when ARVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_arlock | Input | LPARA_LOCK_W | Subordinate interface, read address channel: Atomic characteristics: 1 bit in AXI4, 2 bits in AXI3 | CLK-SUB | Data (valid when ARVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_arcache | Input | 4 | Subordinate interface, read address channel: Memory type attributes | CLK-SUB | Data (valid when ARVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_arprot | Input | 3 | Subordinate interface, read address channel: Protection attributes | CLK-SUB | Data (valid when ARVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_arqos | Input | 4 | Subordinate interface, read address channel: Quality of Service identifier; ignored input and output 0 when `PARA_AXI_QOS_EN` = 0 or AXI3 | CLK-SUB | Data (valid when ARVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | AXI4, `PARA_AXI_QOS_EN` |
| i_axi_arregion | Input | 4 | Subordinate interface, read address channel: Region indicator; ignored input and output 0 when `PARA_AXI_REGION_EN` = 0 or AXI3 | CLK-SUB | Data (valid when ARVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | AXI4, `PARA_AXI_REGION_EN` |
| i_axi_aruser | Input | LPARA_ARUSER_W | Subordinate interface, read address channel: User-defined read address extension; ignored input and output 0 when `PARA_AXI_ARUSER_W` = 0 or AXI3 | CLK-SUB | Data (valid when ARVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | AXI4, `PARA_AXI_ARUSER_W` |
| o_axi_rvalid | Output | 1 | Subordinate interface, read data channel: RVALID towards the destination, 1 whenever the channel FIFO is not empty | CLK-SUB | Level (flop-based flag, active-high; held until READY is 1) | 0 (empty FIFO) | Changes after a rising edge of i_clk_sub | All |
| i_axi_rready | Input | 1 | Subordinate interface, read data channel: RREADY of the destination; a word is taken when it is 1 and VALID is 1 | CLK-SUB | Level (active-high; may be 1 before VALID) | Any value in reset | Sampled at the rising edge of i_clk_sub | All |
| o_axi_rid | Output | PARA_AXI_ID_W | Subordinate interface, read data channel: Identification tag of the read data | CLK-SUB | Data (valid when RVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_sub | All |
| o_axi_rdata | Output | PARA_AXI_DATA_W | Subordinate interface, read data channel: Read data | CLK-SUB | Data (valid when RVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_sub | All |
| o_axi_rresp | Output | 2 | Subordinate interface, read data channel: Read response status | CLK-SUB | Data (valid when RVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_sub | All |
| o_axi_rlast | Output | 1 | Subordinate interface, read data channel: Last transfer of the read burst | CLK-SUB | Data (valid when RVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_sub | All |
| o_axi_ruser | Output | LPARA_RUSER_W | Subordinate interface, read data channel: User-defined read data and response extension; ignored input and output 0 when `PARA_AXI_RUSER_W` = 0 or AXI3 | CLK-SUB | Data (valid when RVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_sub | AXI4, `PARA_AXI_RUSER_W` |
| o_axi_awvalid | Output | 1 | Manager interface, write address channel: AWVALID towards the destination, 1 whenever the channel FIFO is not empty | CLK-MGR | Level (flop-based flag, active-high; held until READY is 1) | 0 (empty FIFO) | Changes after a rising edge of i_clk_mgr | All |
| i_axi_awready | Input | 1 | Manager interface, write address channel: AWREADY of the destination; a word is taken when it is 1 and VALID is 1 | CLK-MGR | Level (active-high; may be 1 before VALID) | Any value in reset | Sampled at the rising edge of i_clk_mgr | All |
| o_axi_awid | Output | PARA_AXI_ID_W | Manager interface, write address channel: Identification tag of the write transaction (A2.2) | CLK-MGR | Data (valid when AWVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_awaddr | Output | PARA_AXI_ADDR_W | Manager interface, write address channel: Address of the first transfer of the write transaction | CLK-MGR | Data (valid when AWVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_awlen | Output | LPARA_LEN_W | Manager interface, write address channel: Burst length minus 1: 8 bits in AXI4, 4 bits in AXI3 (A3.4) | CLK-MGR | Data (valid when AWVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_awsize | Output | 3 | Manager interface, write address channel: Number of bytes of each transfer, as a power of 2 | CLK-MGR | Data (valid when AWVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_awburst | Output | 2 | Manager interface, write address channel: Burst type | CLK-MGR | Data (valid when AWVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_awlock | Output | LPARA_LOCK_W | Manager interface, write address channel: Atomic characteristics: 1 bit in AXI4, 2 bits in AXI3 (A7.3) | CLK-MGR | Data (valid when AWVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_awcache | Output | 4 | Manager interface, write address channel: Memory type attributes | CLK-MGR | Data (valid when AWVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_awprot | Output | 3 | Manager interface, write address channel: Protection attributes | CLK-MGR | Data (valid when AWVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_awqos | Output | 4 | Manager interface, write address channel: Quality of Service identifier; ignored input and output 0 when `PARA_AXI_QOS_EN` = 0 or AXI3 | CLK-MGR | Data (valid when AWVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | AXI4, `PARA_AXI_QOS_EN` |
| o_axi_awregion | Output | 4 | Manager interface, write address channel: Region indicator; ignored input and output 0 when `PARA_AXI_REGION_EN` = 0 or AXI3 | CLK-MGR | Data (valid when AWVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | AXI4, `PARA_AXI_REGION_EN` |
| o_axi_awuser | Output | LPARA_AWUSER_W | Manager interface, write address channel: User-defined write address extension; ignored input and output 0 when `PARA_AXI_AWUSER_W` = 0 or AXI3 | CLK-MGR | Data (valid when AWVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | AXI4, `PARA_AXI_AWUSER_W` |
| o_axi_wvalid | Output | 1 | Manager interface, write data channel: WVALID towards the destination, 1 whenever the channel FIFO is not empty | CLK-MGR | Level (flop-based flag, active-high; held until READY is 1) | 0 (empty FIFO) | Changes after a rising edge of i_clk_mgr | All |
| i_axi_wready | Input | 1 | Manager interface, write data channel: WREADY of the destination; a word is taken when it is 1 and VALID is 1 | CLK-MGR | Level (active-high; may be 1 before VALID) | Any value in reset | Sampled at the rising edge of i_clk_mgr | All |
| o_axi_wid | Output | PARA_AXI_ID_W | Manager interface, write data channel: Write data ID tag; present in AXI3 only, ignored input and output 0 in AXI4 (A2.3) | CLK-MGR | Data (valid when WVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | AXI3 |
| o_axi_wdata | Output | PARA_AXI_DATA_W | Manager interface, write data channel: Write data | CLK-MGR | Data (valid when WVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_wstrb | Output | LPARA_STRB_W | Manager interface, write data channel: Write strobes, one bit per byte lane | CLK-MGR | Data (valid when WVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_wlast | Output | 1 | Manager interface, write data channel: Last transfer of the write burst | CLK-MGR | Data (valid when WVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_wuser | Output | LPARA_WUSER_W | Manager interface, write data channel: User-defined write data extension; ignored input and output 0 when `PARA_AXI_WUSER_W` = 0 or AXI3 | CLK-MGR | Data (valid when WVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | AXI4, `PARA_AXI_WUSER_W` |
| i_axi_bvalid | Input | 1 | Manager interface, write response channel: BVALID of the source; the channel word is accepted when it is 1 and READY is 1 (A3.2) | CLK-MGR | Level (active-high; held until READY is 1) | 0 (shall be 0 in reset) | Sampled at the rising edge of i_clk_mgr | All |
| o_axi_bready | Output | 1 | Manager interface, write response channel: BREADY towards the source, 1 whenever the channel FIFO is not full | CLK-MGR | Level (flop-based flag, active-high) | 1 (FIFO not full) | Changes after a rising edge of i_clk_mgr; may be 1 before VALID | All |
| i_axi_bid | Input | PARA_AXI_ID_W | Manager interface, write response channel: Identification tag of the write response | CLK-MGR | Data (valid when BVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_bresp | Input | 2 | Manager interface, write response channel: Write response status | CLK-MGR | Data (valid when BVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_buser | Input | LPARA_BUSER_W | Manager interface, write response channel: User-defined write response extension; ignored input and output 0 when `PARA_AXI_BUSER_W` = 0 or AXI3 | CLK-MGR | Data (valid when BVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | AXI4, `PARA_AXI_BUSER_W` |
| o_axi_arvalid | Output | 1 | Manager interface, read address channel: ARVALID towards the destination, 1 whenever the channel FIFO is not empty | CLK-MGR | Level (flop-based flag, active-high; held until READY is 1) | 0 (empty FIFO) | Changes after a rising edge of i_clk_mgr | All |
| i_axi_arready | Input | 1 | Manager interface, read address channel: ARREADY of the destination; a word is taken when it is 1 and VALID is 1 | CLK-MGR | Level (active-high; may be 1 before VALID) | Any value in reset | Sampled at the rising edge of i_clk_mgr | All |
| o_axi_arid | Output | PARA_AXI_ID_W | Manager interface, read address channel: Identification tag of the read transaction | CLK-MGR | Data (valid when ARVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_araddr | Output | PARA_AXI_ADDR_W | Manager interface, read address channel: Address of the first transfer of the read transaction | CLK-MGR | Data (valid when ARVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_arlen | Output | LPARA_LEN_W | Manager interface, read address channel: Burst length minus 1: 8 bits in AXI4, 4 bits in AXI3 | CLK-MGR | Data (valid when ARVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_arsize | Output | 3 | Manager interface, read address channel: Number of bytes of each transfer, as a power of 2 | CLK-MGR | Data (valid when ARVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_arburst | Output | 2 | Manager interface, read address channel: Burst type | CLK-MGR | Data (valid when ARVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_arlock | Output | LPARA_LOCK_W | Manager interface, read address channel: Atomic characteristics: 1 bit in AXI4, 2 bits in AXI3 | CLK-MGR | Data (valid when ARVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_arcache | Output | 4 | Manager interface, read address channel: Memory type attributes | CLK-MGR | Data (valid when ARVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_arprot | Output | 3 | Manager interface, read address channel: Protection attributes | CLK-MGR | Data (valid when ARVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | All |
| o_axi_arqos | Output | 4 | Manager interface, read address channel: Quality of Service identifier; ignored input and output 0 when `PARA_AXI_QOS_EN` = 0 or AXI3 | CLK-MGR | Data (valid when ARVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | AXI4, `PARA_AXI_QOS_EN` |
| o_axi_arregion | Output | 4 | Manager interface, read address channel: Region indicator; ignored input and output 0 when `PARA_AXI_REGION_EN` = 0 or AXI3 | CLK-MGR | Data (valid when ARVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | AXI4, `PARA_AXI_REGION_EN` |
| o_axi_aruser | Output | LPARA_ARUSER_W | Manager interface, read address channel: User-defined read address extension; ignored input and output 0 when `PARA_AXI_ARUSER_W` = 0 or AXI3 | CLK-MGR | Data (valid when ARVALID is 1; stable until READY) | Not defined while VALID is 0 (0 for an absent optional field) | Output register of the FIFO storage; changes after a rising edge of i_clk_mgr | AXI4, `PARA_AXI_ARUSER_W` |
| i_axi_rvalid | Input | 1 | Manager interface, read data channel: RVALID of the source; the channel word is accepted when it is 1 and READY is 1 (A3.2) | CLK-MGR | Level (active-high; held until READY is 1) | 0 (shall be 0 in reset) | Sampled at the rising edge of i_clk_mgr | All |
| o_axi_rready | Output | 1 | Manager interface, read data channel: RREADY towards the source, 1 whenever the channel FIFO is not full | CLK-MGR | Level (flop-based flag, active-high) | 1 (FIFO not full) | Changes after a rising edge of i_clk_mgr; may be 1 before VALID | All |
| i_axi_rid | Input | PARA_AXI_ID_W | Manager interface, read data channel: Identification tag of the read data | CLK-MGR | Data (valid when RVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_rdata | Input | PARA_AXI_DATA_W | Manager interface, read data channel: Read data | CLK-MGR | Data (valid when RVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_rresp | Input | 2 | Manager interface, read data channel: Read response status | CLK-MGR | Data (valid when RVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_rlast | Input | 1 | Manager interface, read data channel: Last transfer of the read burst | CLK-MGR | Data (valid when RVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | All |
| i_axi_ruser | Input | LPARA_RUSER_W | Manager interface, read data channel: User-defined read data and response extension; ignored input and output 0 when `PARA_AXI_RUSER_W` = 0 or AXI3 | CLK-MGR | Data (valid when RVALID is 1) | Not applicable | Captured at the edge where the word is accepted; ignored otherwise | AXI4, `PARA_AXI_RUSER_W` |

**Signal-type legend**

| Type | Meaning | What the user shall know |
|---|---|---|
| Clock | Free-running clock | Rising edge active; no gating inside the IP |
| Reset | Reset level | A level, not a pulse. Active-low, asserted asynchronously, released synchronously outside the IP |
| Level | A signal that holds its value | VALID and READY are levels sampled at every rising edge of their clock. A transfer takes place at each edge at which both are 1. VALID of a source stays 1 until the handshake (REF-001 A3.2) |
| Data | A bus with a qualifier | Valid only while the VALID of its channel is 1 (REF-001 A2) |

Test, interrupt and status ports: none (see Sections 6.4 and 16).

### 6.3 Protocol behavior

The bridge implements two AXI interfaces (REF-001, Part A). The rules below come from the converted standard; the section numbers refer to it.

- **Handshake (A3.2).** Each channel has its own VALID and READY pair. A source asserts VALID when information is available and holds VALID and the payload until READY is 1; a destination may wait for VALID before asserting READY and may assert READY before VALID. In this bridge READY of the source side is 1 whenever the channel FIFO is not full (it may be 1 before VALID), and VALID of the destination side is 1 whenever the FIFO is not empty (it never waits for READY).
- **Dependencies (A3.3.1).** The VALID of an interface does not depend on the READY of the same interface (REQ-FUNC-004). The bridge adds no dependency between channels; it neither waits for nor generates a signal of another channel.
- **Relationships (A3.3).** A write response follows the last write transfer, and read data follows the read address. Both are kept: the bridge issues no response and the response of the external subordinate comes after the events it answers.
- **Clock and reset (A3.1).** All inputs are sampled on the rising edge of the clock of their side; all outputs change after the rising edge; there is no combinational path from an input to an output (REQ-FUNC-005). During reset the manager side drives AWVALID, WVALID and ARVALID low and the subordinate side drives BVALID and RVALID low (REQ-RESET-002); the other outputs may have any value.
- **Burst length (A3.4).** AXI3 uses AxLEN[3:0] (1 to 16 beats), AXI4 uses AxLEN[7:0] (1 to 256 beats for INCR). The bridge forwards the field and does not use it (the length is not needed to forward the beats, because every beat carries its own LAST).
- **Locked access (A7.3).** AXI3 has AxLOCK[1:0], AXI4 has a 1-bit AxLOCK. The bridge forwards the field and implements no locking (it has no arbiter).
- **User signals (A8.3).** The user signals have the same validity as the other signals of their channel. Their width is a property of the interface (A8-1: USER_REQ_WIDTH for AWUSER and ARUSER up to 128, USER_DATA_WIDTH for WUSER up to DATA_WIDTH/2, USER_RESP_WIDTH for BUSER up to 16, RUSER = USER_DATA_WIDTH + USER_RESP_WIDTH); a width of 0 removes the signal.
- **Write data interleaving.** AXI3 allows write data of different IDs to interleave (REF-001 A5.2.2 states that it is deprecated in AXI4 and later). The W FIFO keeps the order of the beats as the manager presented them, so interleaved beats cross unchanged with their WID.

| Case | Legal behavior | Illegal / unsupported case | IP response | Requirement IDs |
|---|---|---|---|---|
| Transfer with VALID and READY at the source edge | Word accepted into the FIFO | None | Stored, READY may fall if the FIFO became full | REQ-FUNC-003 |
| VALID asserted while READY is 0 | Source holds VALID and payload | Source drops VALID before the handshake | Not checked; the word is lost only if the source withdrew it before the FIFO accepted it | REQ-FUNC-006 |
| Destination does not assert READY | VALID and payload stay unchanged | None | FIFO holds the word | REQ-FUNC-004 |
| Burst across the 4 KB boundary, wrong WLAST, wrong response code, illegal burst type | None | Protocol violation of the external master or slave | Not checked and not corrected; the information is forwarded | REQ-FUNC-006 |
| Request while a reset is asserted | None | Source drives VALID in reset | Not defined (the IP is in reset) | REQ-RESET-001 |
| Only one of the two resets asserted after traffic | None | Unsupported reset scheme | The pointer state of the two sides becomes inconsistent; the IP neither detects nor repairs it (REF-002 ASM-005) | REQ-RESET-001 |

The key waveforms of the interfaces (the full plan is in Section 10.3):

![Write burst across the bridge](waveforms/axi_wf001_write_burst.svg)

*Figure 6-1. Write burst of 4 beats (WF-001, source `waveforms/axi_wf001_write_burst.json`).*

![Read burst across the bridge](waveforms/axi_wf002_read_burst.svg)

*Figure 6-2. Read burst of 4 beats (WF-002, source `waveforms/axi_wf002_read_burst.json`).*

![Error responses](waveforms/axi_wf006_error_response.svg)

*Figure 6-3. Error responses pass unchanged (WF-006, source `waveforms/axi_wf006_error_response.json`).*

### 6.4 Interrupts and events

| Signal/event | Polarity | Assert condition | Clear/deassert condition | Mask/priority | Crossing | Reset state |
|---|---|---|---|---|---|---|
| Not applicable | Not applicable | **Not required (confirmed by user, 2026-10-25):** the IP has no interrupt, error or status output (DEC-016) | Not applicable | Not applicable | Not applicable | Not applicable |

## 7. Clock, reset, and power

### 7.1 Clock domains

| Domain | Clock port | Edge | Frequency range | Source | Relationship to other clocks | Gating policy |
|---|---|---|---|---|---|---|
| CLK-SUB | i_clk_sub | Rising | No restriction | SoC | Asynchronous to CLK-MGR | No clock gating inside the IP |
| CLK-MGR | i_clk_mgr | Rising | No restriction | SoC | Asynchronous to CLK-SUB | No clock gating inside the IP |

### 7.2 CDC and RDC

Each channel crosses exactly as `001_AsyncGrayFIFO` (REF-002, section 7.2). The software reset crossings of the FIFO (REF-002 CDC-005, CDC-006) are idle because the software reset is not used.

| Crossing ID | From → to | Signals | Structure | Reset handling | Constraints / verification |
|---|---|---|---|---|---|
| CDC-AW | CLK-SUB → CLK-MGR and back | AW write Gray pointer (CLK-SUB to CLK-MGR), AW read Gray pointer (CLK-MGR to CLK-SUB), AW stored words (bundled data) | FIFO of the AW channel: Gray register, then `m_vlsit_afifo_sync` with `PARA_AXI_CELL_TYPE`; storage data stable by the pointer protocol (REF-002 CDC-001 to CDC-003) | Synchronizers reset by the reset of the receiving domain | Constraints of Section 17.1.3, CDC lint |
| CDC-W | CLK-SUB → CLK-MGR and back | W pointers and data | Same structure in the W channel FIFO | Same | Same |
| CDC-B | CLK-MGR → CLK-SUB and back | B pointers and data | Same structure in the B channel FIFO | Same | Same |
| CDC-AR | CLK-SUB → CLK-MGR and back | AR pointers and data | Same structure in the AR channel FIFO | Same | Same |
| CDC-R | CLK-MGR → CLK-SUB and back | R pointers and data | Same structure in the R channel FIFO | Same | Same |

Rules: the bridge adds no crossing of its own (REQ-CLK-002). No logic is placed between a source-domain register and a synchronizer stage (REF-003 P28); the packing logic of the channel module is in the source domain in front of the FIFO write data port, which is bundled data and not a synchronized signal. The status outputs of the FIFO that are not used (REF-002 `o_full_thr`, `o_empty_thr`, `o_overflow`, `o_underflow`, `o_sw_rst_busy`) are left unconnected. RDC: the two hardware resets are independent inputs but shall be asserted together (REQ-RESET-001); the bridge has no reset-domain crossing of its own.

### 7.3 Reset domains and sequencing

| Reset ID | Port | Polarity / assertion | Sync or async | Scope | Deassertion | Reset value |
|---|---|---|---|---|---|---|
| RST-SUB | i_rst_n_sub | Active-low | Asynchronous assertion at the flops; already synchronized to `i_clk_sub` outside the IP | The subordinate-side state of the five FIFOs: write side of AW, W, AR; read side of B, R | Controlled by the integrator, synchronous to `i_clk_sub` | Pointers 0, FIFOs empty, `o_axi_bvalid` 0, `o_axi_rvalid` 0 |
| RST-MGR | i_rst_n_mgr | Active-low | Asynchronous assertion at the flops; already synchronized to `i_clk_mgr` outside the IP | The manager-side state of the five FIFOs: read side of AW, W, AR; write side of B, R | Controlled by the integrator, synchronous to `i_clk_mgr` | Pointers 0, FIFOs empty, `o_axi_awvalid`, `o_axi_wvalid`, `o_axi_arvalid` 0 |

Both resets shall be asserted together and released synchronously to their own clock (DEC-020, ASM-001). The FIFO storage is resetless (REF-002 section 7.3). The VALID outputs are low during reset because the empty flag of a FIFO is 1 after reset (REQ-RESET-002). The READY outputs of the source sides are 1 during reset (the FIFO is not full), which the standard allows (REF-001 A3.1.2: all other signals can be driven to any value). The stopped-clock, warm-reset and retention cases are not supported.

### 7.4 Power intent (if applicable)

**Not required (confirmed by user, 2026-10-25):** the IP is in one always-on power domain of the SoC and has no isolation, retention or power sequencing of its own.

## 8. Parameters and elaboration configurations

Parameters use `parameter logic [31:0]` with names `PARA_AXI_*`, with the three comment lines of REF-003 PAR-02. Derived constants use `localparam logic [31:0]` with names `LPARA_*`, placed in the parameter port list after the parameters. The IP has no elaboration check for illegal values (REQ-PARAM-001); `$clog2` may be used for derived widths. The limits are those of the standard (REF-001 table E1-31) unless stated.

| Parameter | Purpose | Default | Legal values / range | Dependencies / invalid combinations | Effect |
|---|---|---|---|---|---|
| PARA_AXI_ADDR_W | Address width of AWADDR and ARADDR | 32 | 1 to 64 | None | Port widths, FIFO word width of AW and AR |
| PARA_AXI_DATA_W | Data width of WDATA and RDATA | 32 | 8, 16, 32, 64, 128, 256, 512, 1024 | WSTRB has DATA_W / 8 bits | Port widths, FIFO word width of W and R |
| PARA_AXI_ID_W | Width of AWID, WID, BID, ARID and RID | 4 | 1 or greater; no design-specific maximum | None; width 0 is not supported (DEC-023) | Port widths, FIFO word width of all channels |
| PARA_AXI_AXI3_EN | 0 = AXI4 field set, 1 = AXI3 field set | 0 | 0 or 1 | When 1: QOS, REGION and user signals are not present | Port widths of AxLEN and AxLOCK, presence of WID |
| PARA_AXI_QOS_EN | Carry AWQOS and ARQOS | 1 | 0 or 1 | Ignored (treated as 0) when `PARA_AXI_AXI3_EN` = 1 | FIFO word width of AW and AR |
| PARA_AXI_REGION_EN | Carry AWREGION and ARREGION | 1 | 0 or 1 | Ignored when `PARA_AXI_AXI3_EN` = 1 | FIFO word width of AW and AR |
| PARA_AXI_AWUSER_W | Width of AWUSER in the AXI4_USER profile | 1 | 1 to 128 | Exists only in AXI4_USER; width 0 selects AXI4_BASE | AW word width |
| PARA_AXI_WUSER_W | Width of WUSER in the AXI4_USER profile | 1 | 1 to `PARA_AXI_DATA_W` / 2 | Exists only in AXI4_USER; width 0 selects AXI4_BASE | W word width |
| PARA_AXI_BUSER_W | Width of BUSER in the AXI4_USER profile | 1 | 1 to 16 | Exists only in AXI4_USER; width 0 selects AXI4_BASE | B word width |
| PARA_AXI_ARUSER_W | Width of ARUSER in the AXI4_USER profile | 1 | 1 to 128 | Exists only in AXI4_USER; width 0 selects AXI4_BASE | AR word width |
| PARA_AXI_RUSER_W | Width of RUSER in the AXI4_USER profile | 1 | 1 to `PARA_AXI_DATA_W` / 2 + 16 | Exists only in AXI4_USER; width 0 selects AXI4_BASE | R word width |
| PARA_AXI_AW_DEPTH | Entries of the AW FIFO | 4 | Power of 2, 2 or more | None | AW throughput and storage |
| PARA_AXI_W_DEPTH | Entries of the W FIFO | 16 | Power of 2, 2 or more | None | W throughput and storage |
| PARA_AXI_B_DEPTH | Entries of the B FIFO | 4 | Power of 2, 2 or more | None | B throughput and storage |
| PARA_AXI_AR_DEPTH | Entries of the AR FIFO | 4 | Power of 2, 2 or more | None | AR throughput and storage |
| PARA_AXI_R_DEPTH | Entries of the R FIFO | 16 | Power of 2, 2 or more | None | R throughput and storage |
| PARA_AXI_CELL_TYPE | Synchronizer cell of the five FIFOs: 1 = two D flip-flop cells, 2 = one 2-FF cell, 3 = one 3-FF cell, 4 = one 4-FF cell | 2 | 1, 2, 3, 4 | Option 0 (bypass) shall not be used | Latency (Section 10.3), MTBF |
| PARA_AXI_MEM_USE_MACRO | 0 = RTL array, 1 = library SRAM wrapper, in the five FIFOs | 0 | 0 or 1 | The macro model of `000_Common` is used until a real macro is mapped | Storage branch |
| LPARA_LEN_W | Width of AWLEN and ARLEN | Derived | 8 (AXI4) or 4 (AXI3) | `PARA_AXI_AXI3_EN` | Port width |
| LPARA_LOCK_W | Width of AWLOCK and ARLOCK | Derived | 1 (AXI4) or 2 (AXI3) | `PARA_AXI_AXI3_EN` | Port width |
| LPARA_STRB_W | Width of WSTRB | Derived | `PARA_AXI_DATA_W` / 8 | `PARA_AXI_DATA_W` | Port width |
| LPARA_AWUSER_W | Port width of AWUSER in AXI4_USER | Derived | Equal to `PARA_AXI_AWUSER_W`; legal 1 to 128; default 1 | `PARA_AXI_AWUSER_W` | Port width in AXI4_USER only |
| LPARA_WUSER_W | Port width of WUSER in AXI4_USER | Derived | Equal to `PARA_AXI_WUSER_W`; legal 1 to `PARA_AXI_DATA_W` / 2; default 1 | `PARA_AXI_WUSER_W` | Port width in AXI4_USER only |
| LPARA_BUSER_W | Port width of BUSER in AXI4_USER | Derived | Equal to `PARA_AXI_BUSER_W`; legal 1 to 16; default 1 | `PARA_AXI_BUSER_W` | Port width in AXI4_USER only |
| LPARA_ARUSER_W | Port width of ARUSER in AXI4_USER | Derived | Equal to `PARA_AXI_ARUSER_W`; legal 1 to 128; default 1 | `PARA_AXI_ARUSER_W` | Port width in AXI4_USER only |
| LPARA_RUSER_W | Port width of RUSER in AXI4_USER | Derived | Equal to `PARA_AXI_RUSER_W`; legal 1 to `PARA_AXI_DATA_W` / 2 + 16; default 1 | `PARA_AXI_RUSER_W` | Port width in AXI4_USER only |
| LPARA_AW_W, LPARA_W_W, LPARA_B_W, LPARA_AR_W, LPARA_R_W | FIFO word width of the channel | Derived | Formulas of Section 9 | The parameters above | Parameter `PARA_AFIFO_DATA_W` of the channel FIFO |

| Configuration | Parameter overrides | Features/interfaces | Expected hierarchy | Elaboration/lint/synthesis target |
|---|---|---|---|---|
| CFG-AXI4 | Defaults | AXI4, no user signals, QOS and REGION | top → five channel modules → FIFOs | Elaborate, lint, synthesize |
| CFG-USER | Any user width greater than 0 | User signals | Same | Elaborate, lint |
| CFG-AXI3 | `PARA_AXI_AXI3_EN` = 1 | AXI3 | Same | Elaborate, lint |
| CFG-WIDE | ADDR 64, DATA 1024, ID 32 | Widest instance | Same | Elaborate, lint |
| CFG-MIN | ADDR 1, DATA 8, ID 1, all depths 2 | Smallest instance | Same | Elaborate, lint |
| CFG-MACRO | `PARA_AXI_MEM_USE_MACRO` = 1 | Library SRAM in the five FIFOs | `m_vlsit_afifo_ram_macro` under each FIFO memory | Elaboration with the macro model |
| CFG-CELL | `PARA_AXI_CELL_TYPE` = 1, 3 or 4 | Other synchronizer cell | Cell wrappers of 001 | Elaboration with the cell models |

Illegal configurations are a depth that is not a power of 2 or below 2, a data width outside the list, an ID width of 0, a cell option outside 1 to 4, and an option parameter outside 0..1. The IP does not check them and its behavior with them is not specified.

## 9. Data representation and arithmetic

All data are unsigned four-state vectors, bit 0 the least significant. Each channel word is the concatenation of the fields of the channel, the first field in the least significant bits. A field that is not present has width 0 and is skipped. The values are not interpreted.

| Channel | Fields from the LSB (width) | Word width |
|---|---|---|
| AW | AWID (`PARA_AXI_ID_W`), AWADDR (`PARA_AXI_ADDR_W`), AWLEN (`LPARA_LEN_W`), AWSIZE (3), AWBURST (2), AWLOCK (`LPARA_LOCK_W`), AWCACHE (4), AWPROT (3), AWQOS (4 if `LPARA_QOS_PRESENT`), AWREGION (4 if `LPARA_REGION_PRESENT`), AWUSER (`PARA_AXI_AWUSER_W` in AXI4 mode, else 0) | `LPARA_AW_W` = sum of the present fields |
| W | WID (`PARA_AXI_ID_W` in AXI3 mode, else 0), WDATA (`PARA_AXI_DATA_W`), WSTRB (`LPARA_STRB_W`), WLAST (1), WUSER (`PARA_AXI_WUSER_W` in AXI4 mode) | `LPARA_W_W` |
| B | BID (`PARA_AXI_ID_W`), BRESP (2), BUSER (`PARA_AXI_BUSER_W` in AXI4 mode) | `LPARA_B_W` |
| AR | ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARLOCK, ARCACHE, ARPROT, ARQOS, ARREGION, ARUSER (as AW with the AR parameters) | `LPARA_AR_W` |
| R | RID (`PARA_AXI_ID_W`), RDATA (`PARA_AXI_DATA_W`), RRESP (2), RLAST (1), RUSER (`PARA_AXI_RUSER_W` in AXI4 mode) | `LPARA_R_W` |

`LPARA_QOS_PRESENT` is 1 when `PARA_AXI_QOS_EN` = 1 and `PARA_AXI_AXI3_EN` = 0; `LPARA_REGION_PRESENT` likewise. Example (defaults, AXI4): AW word = 4 + 32 + 8 + 3 + 2 + 1 + 4 + 3 + 4 + 4 = 65 bits; W word = 32 + 4 + 1 = 37 bits; B word = 4 + 2 = 6 bits; R word = 4 + 32 + 2 + 1 = 39 bits.

| Quantity | Width | Encoding / range | Extension / truncation | Overflow / invalid behavior |
|---|---:|---|---|---|
| Channel word | See above | Concatenation | None | The width is derived, so no truncation |
| Address, data, ID | Parameters | Opaque | None | Not applicable |
| Optional field not present | 0 in the word | Port: ignored input, output 0 | Port has 1 bit minimum | Not applicable |
| FIFO depth | Parameter | Power of 2, 2 or more | None | Illegal depth is not checked |

## 10. Detailed functional behavior

### 10.1 Modes and state transitions

The data path has no mode and no state machine of its own. The only mode is the elaboration option `PARA_AXI_AXI3_EN`. The software reset FSMs of the FIFOs stay in RUN because `i_rst_n_sw` is tied to 1.

### 10.2 Operations

| Operation ID | Inputs / preconditions | Processing semantics | Result / completion | Latency / ordering |
|---|---|---|---|---|
| OP-001 | AWVALID = 1 and AWREADY = 1 at an edge of `i_clk_sub` | The AW word is written into the AW FIFO | AW appears on the manager side with `o_axi_awvalid` = 1 | Latency of Section 10.3; in order |
| OP-002 | WVALID = 1 and WREADY = 1 at an edge of `i_clk_sub` | The W word is written into the W FIFO | W beat appears on the manager side | One beat per source cycle at best; in order; independent of OP-001 |
| OP-003 | `i_axi_bvalid` = 1 and `o_axi_bready` = 1 at an edge of `i_clk_mgr` | The B word is written into the B FIFO | B appears on the subordinate side with `o_axi_bvalid` = 1 | In order of acceptance |
| OP-004 | ARVALID = 1 and ARREADY = 1 at an edge of `i_clk_sub` | The AR word is written into the AR FIFO | AR appears on the manager side | In order |
| OP-005 | `i_axi_rvalid` = 1 and `o_axi_rready` = 1 at an edge of `i_clk_mgr` | The R word is written into the R FIFO | R beat appears on the subordinate side | One beat per source cycle at best; in order |
| OP-006 | `i_rst_n_sub` or `i_rst_n_mgr` low | Asynchronous clear of the FIFO state of the domain | FIFOs empty, VALID outputs 0 | Immediate |

On the destination side of each channel the transfer completes when VALID and READY are 1 at an edge of the destination clock; the FIFO then presents the next word.

### 10.3 Cycle-level behavior

**Waveform plan (rule R-024).** The plan below was proposed from sections 6.3 and 10.2 and confirmed by the designer on 2026-10-25 (answer 16A, the proposed list). It covers every operation of 10.2, the success and the error case of the subordinate-side and the manager-side interface, and the special cases (back-pressure, data before address, user signals, AXI3, reset, streaming, small depth). The waveforms come from the prototype (`waveforms/proto/gen_axi_waves.py`); the signal names follow the port names of Section 6.2.

| Waveform ID | Function / operation | Scenario (success / error / corner) | Signals shown | Figure | Confirmed by user |
|---|---|---|---|---|---|
| WF-001 | OP-001, OP-002, OP-003 write burst of 4 beats | success (subordinate clock faster) | AW, W, B of both sides | waveforms/axi_wf001_write_burst.svg | 2026-10-25 |
| WF-002 | OP-004, OP-005 read burst of 4 beats | success (manager clock faster) | AR, R of both sides | waveforms/axi_wf002_read_burst.svg | 2026-10-25 |
| WF-003 | OP-001 back-pressure on AW | corner | AWVALID, AWREADY of both sides, AW FIFO full | waveforms/axi_wf003_aw_backpressure.svg | 2026-10-25 |
| WF-004 | OP-001, OP-002 write data before write address | corner | AW and W of both sides | waveforms/axi_wf004_w_before_aw.svg | 2026-10-25 |
| WF-005 | OP-005 back-pressure on R | corner | AR and R of both sides, R FIFO of depth 2 | waveforms/axi_wf005_r_backpressure.svg | 2026-10-25 |
| WF-006 | OP-003, OP-005 error responses (SLVERR, DECERR) | error | B and R of both sides | waveforms/axi_wf006_error_response.svg | 2026-10-25 |
| WF-007 | OP-001 to OP-005 user signals | corner (option) | All channels and the five user signals | waveforms/axi_wf007_user_signals.svg | 2026-10-25 |
| WF-008 | OP-001, OP-002 AXI3 mode | corner (option) | AW, W, WID, AWLOCK | waveforms/axi_wf008_axi3_mode.svg | 2026-10-25 |
| WF-009 | OP-006 hardware reset exit | corner | AW, B, both resets | waveforms/axi_wf009_reset_exit.svg | 2026-10-25 |
| WF-010 | OP-002 streaming of a 16-beat burst | corner (back-to-back) | W of both sides | waveforms/axi_wf010_streaming.svg | 2026-10-25 |
| WF-011 | OP-002 small FIFO (depth 2) | corner (throughput limit) | W of both sides | waveforms/axi_wf011_small_depth.svg | 2026-10-25 |

Active edge: the rising edge of the clock of the signal's own side. Inputs are sampled at the edge that ends a cycle; flop outputs change after the edge that starts it. The waveforms use a grid of the common divisor of the two half periods, so every clock edge is at a slot boundary. Values are shown only while the qualifier (the VALID of the channel) is 1.

![AW back-pressure](waveforms/axi_wf003_aw_backpressure.svg)

*Figure 10-1. WF-003: the manager side does not accept, the AW FIFO (depth 4) fills and o_axi_awready falls (source `waveforms/axi_wf003_aw_backpressure.json`).*

![W before AW](waveforms/axi_wf004_w_before_aw.svg)

*Figure 10-2. WF-004: write data crosses before the write address (source `waveforms/axi_wf004_w_before_aw.json`).*

![R back-pressure](waveforms/axi_wf005_r_backpressure.svg)

*Figure 10-3. WF-005: the master holds RREADY low, the R FIFO (depth 2) fills (source `waveforms/axi_wf005_r_backpressure.json`).*

![User signals](waveforms/axi_wf007_user_signals.svg)

*Figure 10-4. WF-007: user signals of width 4 travel with their channels (source `waveforms/axi_wf007_user_signals.json`).*

![AXI3 mode](waveforms/axi_wf008_axi3_mode.svg)

*Figure 10-5. WF-008: AXI3 mode with WID and a 2-bit lock (source `waveforms/axi_wf008_axi3_mode.json`).*

![Reset exit](waveforms/axi_wf009_reset_exit.svg)

*Figure 10-6. WF-009: VALID outputs low during reset, first AWVALID after the release (source `waveforms/axi_wf009_reset_exit.json`).*

![Streaming](waveforms/axi_wf010_streaming.svg)

*Figure 10-7. WF-010: a 16-beat burst streams through the W FIFO of depth 16 (source `waveforms/axi_wf010_streaming.json`).*

![Small depth](waveforms/axi_wf011_small_depth.svg)

*Figure 10-8. WF-011: a W FIFO of depth 2 limits the rate (source `waveforms/axi_wf011_small_depth.json`).*

Let S be the number of synchronizer stages (2 for `PARA_AXI_CELL_TYPE` 1 and 2, 3 for 3, 4 for 4). The behavior of one channel, counting destination clock edges after the source edge that accepted the transfer (REF-002 section 10.3):

| Cycle / event | Input condition | State/action | Output condition |
|---|---|---|---|
| Source edge t0 | VALID = 1 and READY = 1 | The word is written into the FIFO; the Gray write pointer updates | READY may fall if the FIFO is now full |
| Destination edges 1 to S | None | The pointer crosses the synchronizer | Destination VALID is 0 |
| After destination edge S (up to S + 2 with the metastability model) | None | The empty flag falls | Destination VALID = 1 and the payload shows the word |
| Destination edge with READY = 1 | VALID = 1 | The word is read; the read pointer updates and crosses back | The next word appears at once if the FIFO holds one (show-ahead) |
| Source edges after the read pointer crossed back | None | The full flag falls | Source READY = 1 again |

### 10.4 Arbitration, buffering, and throughput

There is no arbitration: each channel has one source and one destination. A write and a read transaction use disjoint channels.

**Latency** (measured on the prototype, `waveforms/axi_perf_table.txt`; AW depth 4, `PARA_AXI_CELL_TYPE` = 2). Time from the source-side handshake edge to the first destination-side VALID:

| Clock half periods (subordinate / manager, ns) | Latency (ns) | Latency (manager clock periods) |
|---|---:|---:|
| 5 / 5 (equal) | 20.0 | 2.00 |
| 4 / 6 | 14.0 | 1.17 |
| 6 / 4 | 14.0 | 1.75 |
| 3 / 7 | 26.0 | 1.86 |
| 7 / 3 | 8.0 | 1.33 |
| 2 / 9 | 25.0 | 1.39 |
| 9 / 2 | 5.0 | 1.25 |

The latency is between 1.17 and 2.00 destination periods for these seven ratios and one phase per ratio (REQ-PERF-002 states the bound S + 2 periods, which covers other phases and the metastability model).

**Throughput** of the W channel for a 64-beat burst with an always-ready destination, in cycles of the **slower** clock per beat (1.00 is the best a single stream can reach; 0.99 is a rounding of the measurement). `PARA_AXI_CELL_TYPE` = 2:

| Clock half periods (subordinate / manager, ns) | Depth 2 | Depth 4 | Depth 8 | Depth 16 | Depth 32 |
|---|---:|---:|---:|---:|---:|
| 5 / 5 (equal) | 2.97 | 1.48 | 1.00 | 1.00 | 1.00 |
| 4 / 6 | 1.98 | 1.00 | 1.00 | 1.00 | 1.00 |
| 6 / 4 | 1.98 | 0.99 | 0.99 | 0.99 | 0.99 |
| 3 / 7 | 1.98 | 1.00 | 1.00 | 1.00 | 1.00 |
| 7 / 3 | 1.99 | 1.00 | 1.00 | 1.00 | 1.00 |

The throughput of a channel is limited by the round trip of the pointers (about 2 x S destination periods, REF-002 section 10.4). A depth of 8 reaches the full rate for equal clocks and a depth of 4 for the unequal ratios above. The rule of REQ-PERF-001 is a measured sufficient condition on the prototype, not a proof for every ratio and every phase. The defaults (4 for AW, AR and B; 16 for W and R) give full rate for the beats of a burst because only W and R carry many beats.

### 10.5 Memories and storage

| Storage ID | Kind | Depth × width | Ports | Read latency | Write mask | Reset/init | ECC/parity | Implementation |
|---|---|---|---|---|---|---|---|---|
| MEM-001 | FIFO array of each channel (inside `m_vlsit_afifo_mem`) | Channel depth × channel word width | One write port (source clock), one read port (destination clock) | 1 destination-clock cycle | None (whole word) | None (resetless) | None | Inferred array (default) |
| MEM-002 | Library SRAM of each channel | Same | One write port, one read port | 1 destination-clock cycle | None | None | None | Wrapper `m_vlsit_afifo_ram_macro` of 001 when `PARA_AXI_MEM_USE_MACRO` = 1 |

The storage is not part of this document beyond these rows; its behavior (collision, initialization) is that of REF-002 section 10.5.

### 10.6 Handshake mapping

| Channel | Source-side VALID (FIFO write request) | Source-side READY | Destination-side VALID | Destination-side READY (FIFO read request) |
|---|---|---|---|---|
| AW | `i_axi_awvalid` | `o_axi_awready` = not full | `o_axi_awvalid` = not empty | `i_axi_awready` |
| W | `i_axi_wvalid` | `o_axi_wready` = not full | `o_axi_wvalid` = not empty | `i_axi_wready` |
| B | `i_axi_bvalid` | `o_axi_bready` = not full | `o_axi_bvalid` = not empty | `i_axi_bready` |
| AR | `i_axi_arvalid` | `o_axi_arready` = not full | `o_axi_arvalid` = not empty | `i_axi_arready` |
| R | `i_axi_rvalid` | `o_axi_rready` = not full | `o_axi_rvalid` = not empty | `i_axi_rready` |

For the B and R channels the source is the manager-side interface; the port names follow the direction at the boundary, as in Section 6.2.

## 11. Register and programming model

**Not required (confirmed by user, 2026-10-25):** the IP has no software-visible registers; it is configured by parameters (Section 8). No CSR workbook is delivered.

## 12. Error handling and recovery

| Error ID | Detection condition | Observable response/status | Interrupt | Clear/recovery | Reset behavior |
|---|---|---|---|---|---|
| ERR-001 | AXI protocol violation of an external master or slave | Not detected; the information is forwarded unchanged | None | The external component is responsible | Not applicable |
| ERR-002 | Source drops VALID before the handshake or changes the payload while VALID = 1 and READY = 0 | Not detected; a word that the FIFO accepted in the cycle before is forwarded, the rest is not | None | The source follows A3.2 | Not applicable |
| ERR-003 | Illegal parameter value | Not detected; behavior not specified | None | The integrator fixes the configuration | Not applicable |
| ERR-004 | Only one reset asserted after traffic | Not detected; the FIFO pointer state becomes inconsistent | None | The integrator asserts both resets together | Cleared by asserting both |

There is no error status and no error interrupt (DEC-016, DEC-019). The overflow and underflow flags of the FIFOs are not used: the handshake makes them impossible as long as the bridge is used as specified.

## 13. Performance, power, and area

| Metric ID | Metric | Target / limit | Conditions | Measurement method | Hard / goal |
|---|---|---|---|---|---|
| PERF-001 | Throughput of a channel | One word per cycle of the slower clock in steady state | Depth of at least 8 (equal clocks) or 4 (unequal ratios), `PARA_AXI_CELL_TYPE` = 2 | Throughput sweep: TEST-013 | Hard (REQ-PERF-001) |
| PERF-002 | Latency of a channel | At most S + 2 destination periods | Any ratio | Latency measurement: TEST-013 | Hard (REQ-PERF-002) |
| PPA-001 | Maximum frequency | Not specified; set by the integrator (OI-001) | Library, corner and voltage chosen by the integrator | STA with the delivered constraints | Goal |
| PPA-002 | Area | Not specified; set by the integrator (OI-001). It is the sum of the five FIFOs: storage = (depths x word widths); every FIFO also holds the idle software reset logic of 001 | Library chosen by the integrator | Cell area report | Goal |
| PPA-003 | Dynamic and leakage power | Not specified; set by the integrator (OI-001) | Activity and corner chosen by the integrator | Power analysis | Goal |

No timing closure is claimed from RTL alone. The unused software reset logic of each FIFO costs area; removing it needs a change of `001_AsyncGrayFIFO` and is outside this specification (OI-002).

## 14. RTL implementation contract

### 14.1 Required coding baseline

The VLSIT RTL Design Rules v2 in VLSIT_RTL_Design_Rule.md (REF-003) are the mandatory RTL coding authority. Items applied here: one module per file with a matching file name; a structural top that contains instances only; ANSI ports with untyped `input` declarations and `output logic`; `i_axi_` and `o_axi_` port names followed by standard signal mnemonics; `PARA_AXI_*` parameters with the three PAR-02 comment lines; at most 30 characters per name; and ports grouped by channel and side (FIL-06). Section 23.1 defines fixed profiles, so absent optional fields have no ports. Each channel module packs and unpacks one channel around one FIFO. No testbench, assertion or prototype code belongs in the synthesis file list.

### 14.2 RTL hierarchy

| Module | Responsibility | Parent / instance | Clock/reset domains | Interface |
|---|---|---|---|---|
| m_vlsit_axi_async_top | Structural top | Top | CLK-SUB and CLK-MGR | All ports of Section 6.2 |
| m_vlsit_axi_async_aw | AW channel: pack, FIFO, unpack | m_vlsit_axi_async_top / u_aw | Source CLK-SUB, destination CLK-MGR | AW signals of both sides, clocks and resets |
| m_vlsit_axi_async_w | W channel | m_vlsit_axi_async_top / u_w | Source CLK-SUB, destination CLK-MGR | W signals of both sides |
| m_vlsit_axi_async_b | B channel | m_vlsit_axi_async_top / u_b | Source CLK-MGR, destination CLK-SUB | B signals of both sides |
| m_vlsit_axi_async_ar | AR channel | m_vlsit_axi_async_top / u_ar | Source CLK-SUB, destination CLK-MGR | AR signals of both sides |
| m_vlsit_axi_async_r | R channel | m_vlsit_axi_async_top / u_r | Source CLK-MGR, destination CLK-SUB | R signals of both sides |
| m_vlsit_afifo_top | Asynchronous Gray FIFO of `001_AsyncGrayFIFO` | Each channel module / u_vlsit_afifo_top | Source and destination domain | FIFO ports of REF-002 section 6.2 |

State is owned by the FIFOs; the channel modules and the top have no flip-flops. There is no register logic and no protocol checker.

#### 14.2.1 Ports of the channel modules

Each channel module has the ports of its channel from Section 6.2 (the same names, directions, widths and types, both sides), plus `i_clk_sub`, `i_rst_n_sub`, `i_clk_mgr` and `i_rst_n_mgr`, and the parameters it needs: `PARA_AXI_ID_W`, the width parameters of its fields, `PARA_AXI_AXI3_EN`, its depth, `PARA_AXI_CELL_TYPE` and `PARA_AXI_MEM_USE_MACRO`. Example: `m_vlsit_axi_async_aw` has the AW inputs `i_axi_aw*` and the output `o_axi_awready` of the subordinate side and the outputs `o_axi_aw*` and the input `i_axi_awready` of the manager side. The FIFO of the channel is connected as follows.

| FIFO port of `m_vlsit_afifo_top` | Connection in the channel module |
|---|---|
| `i_clk_wr`, `i_rst_n_wr` | Clock and reset of the source side (CLK-SUB for AW, W, AR; CLK-MGR for B, R) |
| `i_wr_en`, `i_wr_data` | Source VALID and the packed word |
| `o_full` | Inverted to the source READY |
| `i_full_thr` | Tied to the FIFO depth |
| `o_full_thr`, `o_overflow`, `o_sw_rst_busy` | Unconnected |
| `i_rst_n_sw` | Tied to 1 (software reset not used) |
| `i_clk_rd`, `i_rst_n_rd` | Clock and reset of the destination side |
| `i_rd_en` | Destination READY |
| `o_rd_data` | Unpacked to the destination payload |
| `o_empty` | Inverted to the destination VALID |
| `i_empty_thr` | Tied to 0 |
| `o_empty_thr`, `o_underflow` | Unconnected |

### 14.3 Synthesis assumptions

| Item | Value / source |
|---|---|
| Top / source file list | m_vlsit_axi_async_top, the five channel modules, the RTL of `001_AsyncGrayFIFO`, the wrappers and cells of `000_Common` |
| Frontend version and options | Recorded per run (REF-003 SCP-02) |
| Parameters/configuration | CFG-AXI4, CFG-USER, CFG-AXI3, CFG-WIDE, CFG-MIN, CFG-MACRO, CFG-CELL |
| Libraries/corners | Chosen by the integrator (OI-001) |
| Memory flow | Flop array by default; library SRAM through the wrapper for CFG-MACRO |
| Lint rule configuration | The project lint set with `default_nettype none` checking |

## 15. Verification specification

### 15.1 Scope and strategy

Block-level simulation with a scoreboard per channel, directed tests for the handshake and the options, random traffic with random back-pressure over several clock ratios, assertions on the AXI handshake, lint and structural and CDC review. The environment is an AXI manager model on the subordinate side and an AXI subordinate model on the manager side. Each simulation records its seed. The metastability model of the synchronizer cell wrapper is active in simulation.

**Evidence from the prototype** (not from the delivered RTL, which does not exist yet): `waveforms/proto/` contains a prototype that follows this specification, uses the RTL of `001_AsyncGrayFIFO`, and produced the eleven waveforms, the latency table and the throughput table. It was simulated for the scenarios of the waveform plan only. No regression, no assertion and no coverage were run on it.

### 15.2 Requirement-based test plan

| Test ID | Requirements | Scenario / stimulus | Expected result | Test type | Configuration |
|---|---|---|---|---|---|
| TEST-001 | REQ-RESET-001, REQ-RESET-002 | Assert both resets, check the VALID outputs, release synchronously | VALID outputs low in reset and until the first transfer; FIFOs empty | Directed | CFG-AXI4 |
| TEST-002 | REQ-FUNC-001 to REQ-FUNC-003, REQ-FUNC-006, REQ-CLK-001, REQ-RTL-003 | Random write and read transactions of random length with random READY back-pressure on both sides | Scoreboard match of every field; order kept; no loss | Constrained random | CFG-AXI4, CFG-MACRO, CFG-CELL |
| TEST-003 | REQ-FUNC-001, REQ-PARAM-002 | Bursts with depths 2, 4, 8, 16, 32 and every channel depth different | No loss or duplication for every depth | Directed and random | CFG-MIN, CFG-AXI4 |
| TEST-004 | REQ-FUNC-004, REQ-PERF-003 | Destination holds READY low, source keeps VALID | VALID and payload stay unchanged; source READY falls at full and returns | Directed | CFG-AXI4 |
| TEST-005 | REQ-FUNC-006 | Write transaction with the subordinate model answering after the last beat | B reaches the master only after the last W beat was issued on the manager side | Directed | CFG-AXI4 |
| TEST-006 | REQ-FUNC-007 | User widths 1, 4, maximum on all channels | User bits equal at the output; width 0 gives output 0 | Directed and random | CFG-USER |
| TEST-007 | REQ-FUNC-008, REQ-FUNC-009 | AXI3 mode with WID, 4-bit length, 2-bit lock | Fields as in the standard; WID carried | Directed and random | CFG-AXI3 |
| TEST-008 | REQ-FUNC-010, REQ-IF-002 | QOS and REGION enabled and disabled; ports of absent fields | Disabled outputs 0; enabled values equal | Directed | CFG-AXI4 |
| TEST-009 | REQ-PARAM-001, REQ-PARAM-003 | Elaborate the legal extremes | Elaboration, lint and simulation pass | Elaboration | CFG-WIDE, CFG-MIN |
| TEST-010 | REQ-RESET-001, REQ-RESET-003 | Reset in the middle of transfers | FIFOs empty, no stale word after release | Directed | CFG-AXI4 |
| TEST-011 | REQ-CLK-002 | CDC analysis of the five channels | Only the crossings of Section 7.2 exist | Static (CDC tool) | CFG-AXI4 |
| TEST-012 | REQ-FUNC-005, REQ-IF-001, REQ-IF-002, REQ-RTL-001, REQ-RTL-002, REQ-CLK-002 | Lint, rule check, port-list review, structural check of tie-offs and of the absence of combinational input-to-output paths | No violation | Static | All |
| TEST-013 | REQ-PERF-001, REQ-PERF-002, REQ-CLK-001 | Throughput and latency sweep over depths, clock ratios and cell options | Tables of Section 10.4 reproduced; latency bound met | Directed sweep | CFG-AXI4, CFG-CELL |
| TEST-014 | REQ-VER-002, REQ-FUNC-001, REQ-PARAM-002 | Scoreboard regression over the configurations | No error | Regression | All |
| TEST-015 | REQ-VER-001 | Rerun `gen_axi_waves.py`; check that every figure and source of Section 10.3 exists | Files identical to the delivered ones | Review | All |

### 15.3 Assertions and coverage

Assertions and coverage live outside the synthesis file list. They are disabled while a reset is asserted. An unknown value on an input is a checker error when VALID is 1.

| Property / coverage ID | Intent | Requirements | Checker / source set | Acceptance criterion |
|---|---|---|---|---|
| SVA-001 | A source-side transfer takes place only with VALID and READY at the edge, and the FIFO accepts it (scoreboard count) | REQ-FUNC-003 | Verification source set | Never fails |
| SVA-002 | A destination-side transfer takes place only with VALID and READY at the edge and takes the oldest word | REQ-FUNC-001, REQ-FUNC-003 | Verification source set | Never fails |
| SVA-003 | Destination VALID stays 1 until READY is 1 | REQ-FUNC-004 | Verification source set | Never fails |
| SVA-004 | Destination payload is stable while VALID = 1 and READY = 0 | REQ-FUNC-004 | Verification source set | Never fails |
| SVA-005 | Destination VALID does not depend on READY (checked by sampling VALID before READY changes) | REQ-FUNC-004 | Verification source set | Never fails |
| SVA-006 | READY of a source side is 0 whenever the FIFO is full (word count equals the depth) | REQ-PERF-003 | Verification source set | Never fails |
| SVA-007 | VALID outputs are 0 while a reset is asserted | REQ-RESET-002 | Verification source set | Never fails |
| SVA-008 | Every output signal of an absent optional field is 0 | REQ-FUNC-007, REQ-FUNC-010 | Verification source set | Never fails |
| SVA-009 | Latency from the source handshake to the destination VALID is at most S + 2 destination periods | REQ-PERF-002 | Verification source set | Never fails |
| SVA-010 | No output changes in the same time step as an input change of the same side (no combinational path) | REQ-FUNC-005 | Verification source set | Never fails |
| COV-001 | Each channel full, source held, released | REQ-PERF-003 | Verification source set | All bins hit |
| COV-002 | Each channel empty with the destination ready | REQ-FUNC-003 | Verification source set | All bins hit |
| COV-003 | Clock ratios (fast to slow, slow to fast, equal) | REQ-CLK-001 | Verification source set | All ratios of TEST-013 |
| COV-004 | User widths, AXI3 and AXI4, QOS and REGION on and off | REQ-FUNC-007, REQ-FUNC-008, REQ-FUNC-010 | Verification source set | All bins hit |
| COV-005 | Write data before write address, and after | REQ-FUNC-006 | Verification source set | Both hit |

### 15.4 Formal, CDC, and RDC

| Analysis | Scope | Assumptions / constraints | Evaluation method |
|---|---|---|---|
| Formal | **Not required (confirmed by user, 2026-10-25):** verification is by simulation and assertions in this version | Not applicable | Not applicable |
| CDC / RDC | Each channel FIFO crossing (Section 7.2) | Constraints of Section 17.1.3; the two resets are asserted together | CDC tool run on the bridge top (TEST-011) |

## 16. DFT and testability

| Topic | Requirement / decision |
|---|---|
| Scan architecture and scan eligibility | **Not required (confirmed by user, 2026-10-25):** no detailed DFT specification in this version. The RTL shall contain no latch, no combinational loop, no tri-state, no clock gating and no derived clock, so that scan insertion is possible |
| Scan/test clocks, controls, reset behavior | **Not required (confirmed by user, 2026-10-25):** the IP has no DFT ports; a test reset override belongs to the wrapper or reset controller of the SoC (REF-003 RST-04) |
| Test-mode entry/exit and safe state | **Not required (confirmed by user, 2026-10-25):** handled by the SoC |
| MBIST, memory repair, LBIST | **Not required (confirmed by user, 2026-10-25):** the SRAM branch is tested by the SoC memory flow if used |
| Test access, wrappers, test points | **Not required (confirmed by user, 2026-10-25):** none |
| Clock-gating test enable | **Not required (confirmed by user, 2026-10-25):** no clock gating |
| ATPG constraints and exclusions | **Not required (confirmed by user, 2026-10-25):** none beyond the rules above |
| DFT insertion architecture and generated test artifacts | **Not required (confirmed by user, 2026-10-25):** defined by the SoC DFT flow |

## 17. Physical design and timing integration

### 17.1 Timing constraints and budgets

The bridge owns the constraints of the crossings; they are those of `001_AsyncGrayFIFO` (REF-002 section 17.1) applied to each of the five FIFOs. The SoC owns the clock definitions and the interface delays. The text below describes the required content, not executable constraints.

#### 17.1.1 Clock and analysis scenarios

| Clock ID | Port / source object | Primary/generated and master | Period, waveform, phase / ratio | Latency / uncertainty / transition | Clock group / mode | Constraint source |
|---|---|---|---|---|---|---|
| CLK-SUB | i_clk_sub | Primary | Free (no restriction on frequency or ratio) | Set by the SoC | Asynchronous to CLK-MGR for functional paths, with the exceptions below | SoC SDC |
| CLK-MGR | i_clk_mgr | Primary | Free (no restriction on frequency or ratio) | Set by the SoC | Asynchronous to CLK-SUB | SoC SDC |

#### 17.1.2 Interface timing budgets

| Interface / port group | Direction | Reference clock | External min / max delay | Input transition / output load | IP timing budget | Mode / condition | Constraint source |
|---|---|---|---|---|---|---|---|
| Subordinate-side AW, W, AR inputs, B and R READY inputs | Input | CLK-SUB | Set by the SoC | Set by the SoC | VALID goes to the FIFO write request, payload to the FIFO write data (packing logic only) | All | SoC SDC |
| Subordinate-side READY outputs of AW, W, AR; VALID and payload outputs of B, R | Output | CLK-SUB | Set by the SoC | Set by the SoC | Flop output through at most the FIFO flag logic (REF-002: flags are combinational from registers) | All | SoC SDC |
| Manager-side AW, W, AR READY inputs; B and R inputs | Input | CLK-MGR | Set by the SoC | Set by the SoC | As above for the manager clock | All | SoC SDC |
| Manager-side outputs | Output | CLK-MGR | Set by the SoC | Set by the SoC | As above | All | SoC SDC |
| Resets | Input | Each own clock | Already synchronized | Not applicable | Not applicable | All | SoC SDC |

#### 17.1.3 Timing exception inventory

For each of the five FIFOs the exceptions EXC-001 (write Gray pointer to the synchronizer of the read side, `set_max_delay -datapath_only`, 0.9 x the source period), EXC-002 (read Gray pointer, 0.9 x the source period) and EXC-003 (storage to the output register, 1 x the destination period) of REF-002 apply with the same rationale. The software reset exceptions of REF-002 (EXC-005, EXC-006) apply to the idle crossings and may be kept. The threshold false path EXC-004 of REF-002 is not needed because the thresholds are tied to constants.

| Exception ID | Type / SDC command | From | Through | To | Value and setup/hold/min/max meaning | Mode / condition | Technical rationale |
|---|---|---|---|---|---|---|---|
| EXC-AXI-001 | `set_max_delay -datapath_only` (as REF-002 EXC-001) | Write Gray pointer registers of the five FIFOs | None | First synchronizer stage of the read side of the same FIFO | 0.9 x the period of the source clock of that channel | All | Same as REF-002 EXC-001: a pointer change completes before the next one is launched |
| EXC-AXI-002 | `set_max_delay -datapath_only` (as REF-002 EXC-002) | Read Gray pointer registers of the five FIFOs | None | First synchronizer stage of the write side | 0.9 x the period of the destination clock of that channel | All | Same as REF-002 EXC-002 |
| EXC-AXI-003 | `set_max_delay -datapath_only` (as REF-002 EXC-003) | Storage and storage output register path of the five FIFOs | None | Storage output register D pins | 1 x the period of the destination clock | All | Bundled data of REF-002 CDC-003 |

Do not use a whole-domain `set_false_path` or an unqualified `set_clock_groups -asynchronous` for the two clocks without covering the crossings above separately (REF-002 section 17.1.3).

### 17.2 Physical assumptions

| Topic | Requirement / assumption |
|---|---|
| Hard/memory macros and views | Only in the macro branch; the real macro views are supplied at integration |
| Floorplan, placement region, pin placement | The synchronizer stages of one bit should be placed adjacent to each other (REF-002 17.2). Pins of one channel should be grouped |
| Utilization/congestion target | Not specified; the wide configuration (DATA 1024) has many wires per channel |
| Power intent, clock/reset trees | Two clock trees and two reset nets, one per domain |
| High-fanout controls, physical-only cells | Not specified |
| ECO/spare cells | Decided by the integrator |
| Extraction and timing-analysis corners | Decided by the integrator |
| Delivery form: RTL/netlist/hardened layout | Soft RTL |

## 18. Security, safety, and reliability

| Topic | Requirement / rationale | Verification method / expected behavior |
|---|---|---|
| Security boundary and threat assumptions | **Not required (confirmed by user, 2026-10-25):** no security function; the protection attributes pass through unchanged | Not applicable |
| Access control / privilege | **Not required (confirmed by user, 2026-10-25):** the bridge makes no access decision | Not applicable |
| Secure clearing / zeroization | **Not required (confirmed by user, 2026-10-25):** the FIFO storage is not erased | Not applicable |
| Information leakage / side channels | **Not required (confirmed by user, 2026-10-25):** no secret-dependent behavior | Not applicable |
| ECC/parity and fault detection | **Not required (confirmed by user, 2026-10-25):** no data protection in this version | Not applicable |
| Safety goal / integrity level | **Not required (confirmed by user, 2026-10-25):** no safety goal is assigned | Not applicable |
| Diagnostics, fail-safe state, recovery | **Not required (confirmed by user, 2026-10-25):** the bridge has no diagnostics (DEC-016, DEC-019) | Not applicable |

## 19. Requirement-to-verification traceability

| Requirement ID | RTL module/location | Test/property | Verification method / analysis | Configuration |
|---|---|---|---|---|
| REQ-FUNC-001 | Channel modules, FIFOs | TEST-002, TEST-003, TEST-014, SVA-002 | Scoreboard simulation | All |
| REQ-FUNC-002 | Channel modules | TEST-002, TEST-003 | Simulation | All |
| REQ-FUNC-003 | Channel modules, FIFOs | TEST-002, SVA-001, SVA-002 | Simulation, assertion | All |
| REQ-FUNC-004 | Channel modules, FIFOs | TEST-004, SVA-003, SVA-004, SVA-005 | Simulation, assertion | All |
| REQ-FUNC-005 | Channel modules, top | TEST-012, SVA-010 | Structural check, assertion | All |
| REQ-FUNC-006 | Channel modules | TEST-002, TEST-005, COV-005 | Simulation | All |
| REQ-FUNC-007 | Channel modules | TEST-006, SVA-008, COV-004 | Simulation | CFG-USER |
| REQ-FUNC-008 | Channel modules, top | TEST-007, COV-004 | Simulation | CFG-AXI3 |
| REQ-FUNC-009 | m_vlsit_axi_async_w | TEST-007 | Simulation | CFG-AXI3 |
| REQ-FUNC-010 | m_vlsit_axi_async_aw, m_vlsit_axi_async_ar | TEST-008, SVA-008, COV-004 | Simulation | CFG-AXI4 |
| REQ-IF-001 | m_vlsit_axi_async_top | TEST-012 | Lint, review | All |
| REQ-IF-002 | Channel modules, top | TEST-008, TEST-012 | Simulation, lint | All |
| REQ-CLK-001 | All modules | TEST-002, TEST-013, COV-003 | Simulation with several ratios | All |
| REQ-CLK-002 | Channel modules, FIFOs | TEST-011, TEST-012 | CDC review, structural check | All |
| REQ-RESET-001 | m_vlsit_axi_async_top | TEST-001, TEST-010 | Simulation | All |
| REQ-RESET-002 | FIFOs | TEST-001, SVA-007 | Simulation, assertion | All |
| REQ-RESET-003 | FIFOs | TEST-010 | Simulation | All |
| REQ-PARAM-001 | m_vlsit_axi_async_top | TEST-009 | Elaboration | CFG-WIDE, CFG-MIN |
| REQ-PARAM-002 | Channel modules | TEST-003, TEST-014 | Simulation | All |
| REQ-PARAM-003 | m_vlsit_axi_async_top | TEST-009 | Elaboration | CFG-CELL |
| REQ-PERF-001 | FIFOs | TEST-013, COV-001, COV-002 | Throughput sweep | All |
| REQ-PERF-002 | FIFOs | TEST-013, SVA-009 | Latency measurement | All |
| REQ-PERF-003 | Channel modules, FIFOs | TEST-004, SVA-006, COV-001 | Simulation, assertion | All |
| REQ-RTL-001 | All modules | TEST-012 | Lint, rule check | All |
| REQ-RTL-002 | Channel modules | TEST-012 | Inspection, lint | All |
| REQ-RTL-003 | Channel modules | TEST-002 | Simulation of both branches | CFG-MACRO, CFG-CELL |
| REQ-VER-001 | Verification source set | TEST-015 | File check | All |
| REQ-VER-002 | Verification source set | TEST-014 | Regression | All |

## 20. Assumptions, dependencies, and decisions

### 20.1 Open items

| ID | Type | Assumption / dependency / unresolved decision | Technical impact / version / configuration | Resolution / status |
|---|---|---|---|---|
| OI-001 | Open item | Frequency, area and power targets, libraries and corners are not given | Section 13 goals and Section 17 budgets | Needs the integrator |
| OI-002 | Open item | Each FIFO of `001_AsyncGrayFIFO` carries software reset, threshold, overflow and underflow logic that the bridge does not use | Area overhead of five FIFOs | Accepted for this version; a reduced FIFO would need a change of 001 |
| OI-003 | Open item | The latency and the minimum depth for full rate were measured on a prototype for seven and five clock ratios and one phase per ratio | REQ-PERF-001, REQ-PERF-002 | Re-measure on the RTL (TEST-013) for the ratios of the product and several phases |
| OI-004 | Open item | AXI protocol statements come from a converted PDF whose conversion check reported 53 of 500 pages with a word count differing by more than 5% (tables and figures) | Citations of Sections 6.3 and 8 | The text of the cited sections was read in the converted file; re-check against the PDF at review |

### 20.2 Assumptions, dependencies and decisions

| ID | Type | Assumption / dependency / unresolved decision | Technical impact / version / configuration | Resolution / status |
|---|---|---|---|---|
| ASM-001 | Assumption | The two hardware resets are asserted together and released synchronously to their own clocks, outside the IP | Section 7.3 | Open; integration check |
| ASM-002 | Assumption | The external manager and subordinate follow the AXI protocol; the bridge does not check it | Section 6.3, DEC-019 | Open; integration check |
| ASM-003 | Assumption | The software reset of `001_AsyncGrayFIFO` is not used; `i_rst_n_sw` is tied to 1 | REQ-RTL-002 | Recorded as the answer of the designer to question 7 ("Software reset không dùng"); DEC-009 |
| DEC-001 | Decision | The naming rule is the default of the skill `vlsit-rtl-generator` (VLSIT_RTL_Design_Rule.md v2, sections 2 and 9) | Every name | Confirmed by the designer, 2026-10-25 (answer 1A) |
| DEC-002 | Decision | The IP is an asynchronous AXI bridge with the same protocol on both sides, five channels, one asynchronous FIFO per channel | Section 5 | Confirmed by the designer, 2026-10-25 (answer 3A) |
| DEC-003 | Decision | The two clocks are unrelated: any frequency and ratio | Section 7 | Confirmed by the designer, 2026-10-25 (answer 3A, note on clocks) |
| DEC-004 | Decision | The FIFO depth is selectable per channel; the bypass option (no FIFO) is dropped | Section 8 | Confirmed by the designer, 2026-10-25 (round 2: depth per stage selectable; round 3: "Bỏ ý định bypass") |
| DEC-005 | Decision | The user signals are optional, with an independent width per channel, default 0 | Section 8, REQ-FUNC-007 | Confirmed by the designer, 2026-10-25 (answers 4A, 4A) |
| DEC-006 | Decision | The AXI standard is Arm IHI 0022 issue H.c, downloaded from the Arm documentation service and converted to Markdown | REF-001 | Confirmed by the designer, 2026-10-25 (answers 1B, 9A) |
| DEC-007 | Decision | Address, data and ID widths are parameters; the full AXI4 field set is carried | Section 8, Section 9 | Confirmed by the designer, 2026-10-25 (answer 5A) |
| DEC-008 | Decision | AXI4 with an option for AXI3 (`PARA_AXI_AXI3_EN`) | REQ-FUNC-008 | Confirmed by the designer, 2026-10-25 (answers 6A, 12A) |
| DEC-009 | Decision | Two hardware resets; no software reset | Section 7.3, REQ-RTL-002 | Confirmed by the designer, 2026-10-25 (answer 7A and "Software reset không dùng") |
| DEC-010 | Decision | The domains are named `sub` (Subordinate) and `mgr` (Manager); the designer left the abbreviations to the author | `i_clk_sub`, `i_clk_mgr`, `i_rst_n_sub`, `i_rst_n_mgr` | The concepts confirmed by the designer, 2026-10-25 (answer 8B); the abbreviations `sub` and `mgr` are the author's choice |
| DEC-011 | Decision | Each channel reuses `001_AsyncGrayFIFO` (`m_vlsit_afifo_top`) as it is | Section 14.2 | Confirmed by the designer, 2026-10-25 (answer 3A) |
| DEC-012 | Decision | Default depths 4 (AW, AR, B) and 16 (W, R) | Section 8 | Confirmed by the designer, 2026-10-25 (answer 10A) |
| DEC-013 | Decision | One synchronizer cell parameter `PARA_AXI_CELL_TYPE` for the five FIFOs | Section 8 | Confirmed by the designer, 2026-10-25 (answer 11A) |
| DEC-014 | Decision | Subordinate and Manager are the names of the two roles (not Slave and Master) | All text | Confirmed by the designer, 2026-10-25 (answer 8B) |
| DEC-015 | Decision | QOS and REGION have enable parameters, default on in AXI4, off in AXI3 | REQ-FUNC-010 | Confirmed by the designer, 2026-10-25 (answer 13A) |
| DEC-016 | Decision | The threshold function of the FIFOs is not used; no status, overflow or underflow output | REQ-RTL-002 | Confirmed by the designer, 2026-10-25 (answer 14A, "Không dùng chức năng threshold") |
| DEC-017 | Decision | One parameter `PARA_AXI_MEM_USE_MACRO` for the five FIFOs | Section 8 | Confirmed by the designer, 2026-10-25 (answer 15A) |
| DEC-018 | Decision | The waveform plan is the proposed list of eleven waveforms | Section 10.3 | Confirmed by the designer, 2026-10-25 (answer 16A) |
| DEC-019 | Decision | The bridge only forwards: no protocol check, no validation, no response generation | REQ-FUNC-006 | Confirmed by the designer, 2026-10-25 (answer 17A) |
| DEC-020 | Decision | The two resets are asserted together and released synchronously outside the IP | REQ-RESET-001 | Confirmed by the designer, 2026-10-25 (answer 18A) |
| DEC-021 | Decision | Approved AXI4_BASE module names and PARA_AXI_* / LPARA_* naming | All names | Confirmed by the designer, 2026-10-25; see Section 23.3 |
| DEC-022 | Decision | Use three fixed interface profiles; absent optional fields have no ports, in accordance with PRT-03 | REQ-IF-001, Section 23.1 | Confirmed by the designer, 2026-10-25; supersedes placeholder-port text |
| DEC-023 | Decision | ID width minimum is 1 bit with no design-specific maximum | Section 8 | Confirmed by the designer, 2026-10-25; see Section 23.2 |
| DEC-024 | Decision | Channel-word fields are packed in Section 9 order, with the first field at the LSB | Section 9 | Confirmed in the approved RTL plan, 2026-10-25 |
| DEC-025 | Decision | Data widths are 8/16/32/64/128/256/512/1024; address width is 1 to 64 | Section 8 | Confirmed by the designer, 2026-10-25; see Section 23.2 |
| DEC-026 | Decision | FIFO full threshold is tied to depth, empty threshold to 0, and unused status outputs are left unconnected | REQ-RTL-002 | Confirmed in the approved RTL plan, 2026-10-25 |
| DEC-027 | Decision | Maximum latency remains S + 2 destination-clock periods | REQ-PERF-002 | Confirmed by the designer, 2026-10-25; see Section 23.2 |
| DEC-028 | Decision | AXI3 W beats and WID pass in accepted order without ID-based scheduling | Section 6.3 | Confirmed by the designer, 2026-10-25; see Section 23.2 |
| DEP-001 | Dependency | `001_AsyncGrayFIFO` (RTL and specification) and `000_Common` (cells, wrappers) | All configurations | Integration |
| DEP-002 | Dependency | Two clock sources and one reset controller per domain | REQ-CLK-001, REQ-RESET-001 | Integration |
| DEP-003 | Dependency | The prototype scripts of `waveforms/proto/` need iverilog, vvp, Python 3, and the skill script `vlsit_waveform_svg.py` | REQ-VER-001 | Tool setup |

## 21. Glossary

| Term / acronym | Definition |
|---|---|
| AXI | Advanced eXtensible Interface of the AMBA family (Arm IHI 0022) |
| Manager | The AXI component that issues transactions; on the bridge, the manager-side interface drives the external subordinate (the standard calls it Manager, older issues Master) |
| Subordinate | The AXI component that receives transactions; on the bridge, the subordinate-side interface is connected to the external manager (older issues: Slave) |
| Channel | One of the five AXI channels: AW (write address), W (write data), B (write response), AR (read address), R (read data) |
| VALID / READY | Handshake pair of a channel; a transfer happens at the clock edge at which both are 1 |
| Beat | One data transfer of a burst on the W or R channel |
| FIFO word | The concatenation of all fields of a channel, stored as one entry |
| Show-ahead | The FIFO output already shows the oldest word before it is read |
| S | Number of synchronizer stages of the selected synchronizer cell (2, 3 or 4) |
| CDC | Clock-domain crossing |
| User signals | The optional sideband signals AWUSER, WUSER, BUSER, ARUSER, RUSER |

## 22. References used to shape this template

1. `reference/md_doc/vlsit_axi_amba_axi_ihi0022h_c.md` of the skill `vlsit-asic-ip-microspec`: the AXI standard (Arm IHI 0022 issue H.c).
2. `VLSIT_RTL_Generator_AI_Model\common_rtl\001_AsyncGrayFIFO\AsyncGrayFIFO_Design_Specification.md`: the FIFO of every channel.
3. `VLSIT_RTL_Generator_AI_Model\spec_template\VLSIT_RTL_Design_Rule.md` v2: naming, hierarchy and coding rules.
4. `VLSIT_RTL_Generator_AI_Model\spec_template\VLSIT_ASIC_IP_Design_Specification_Template.md`: structure of this document.
5. `research/reference_ip_log.md`: reference-IP research of this design; no qualified public IP was found.
6. `waveforms/proto/`: the prototype and the scripts that produced the waveforms, the latency table and the throughput table.

## 23. Designer-confirmed RTL generation clarifications

This appendix records answers given by the designer on 2026-10-25. It supersedes conflicting single-top optional-port statements in Sections 6.2, 8, 14.1, 14.2 and 20 for this RTL generation. The original specification file remains unchanged.

### 23.1 Fixed interface profiles

The RTL shall provide three fixed port-list profiles to comply with REF-003 PRT-03:

| Profile | Protocol fields present | Protocol fields absent | USER parameters |
|---|---|---|---|
| AXI4_BASE | AXI4 fields, including QOS and REGION | All five USER fields; WID | No USER width parameters or USER ports |
| AXI4_USER | AXI4 fields, including QOS and REGION; all five USER fields | WID | Five independently overridable USER widths, each at least 1; default 1 |
| AXI3 | AXI3 fields, including WID | QOS, REGION and all USER fields | No USER width parameters or USER ports |

No module keeps a placeholder port for a field absent from its selected profile. Selecting a USER width of 0 means using AXI4_BASE; it does not create a 1-bit port. The `LPARA_*USER_W` values equal the matching `PARA_*USER_W` and exist only in AXI4_USER modules.

The profile selection replaces the single `PARA_AXI_AXI3_EN`, `PARA_AXI_QOS_EN` and `PARA_AXI_REGION_EN` interface configuration. QOS and REGION are present in both AXI4 profiles and absent from AXI3. The AXI4_USER profile carries all five USER fields; partial USER-field presence and QOS/REGION-disabled AXI4 profiles are outside this delivery.

### 23.2 Confirmed parameter limits and behavior

- `PARA_AXI_ID_W` has a minimum of 1 and no design-specific maximum. The practical limit is set by elaboration tools and the integration target.
- `PARA_AXI_DATA_W` is one of 8, 16, 32, 64, 128, 256, 512 or 1024. `PARA_AXI_ADDR_W` is 1 to 64.
- The latency limit in REQ-PERF-002 is retained: at most `S+2` destination-clock periods.
- AXI3 W beats and WID pass in accepted order without ID-based scheduling. For example, input WID sequence 1, 0, 1 is output in the same order; the bridge does not correlate AWID and WID.
- The FIFO field packing order remains the least-significant-first order specified in Section 9. FIFO threshold and unused-status connections remain as specified by REQ-RTL-002.

### 23.3 Module naming and output

The designer approved output under `003_AsyncAXI4Bridge/rtl` with 18 modules in three profile folders. AXI4_BASE modules are `m_vlsit_axi_async_top` and `m_vlsit_axi_async_aw/w/b/ar/r`; AXI4_USER modules are `m_vlsit_axi_user_async_top` and `m_vlsit_axi_user_async_aw/w/b/ar/r`; AXI3 modules are `m_vlsit_axi3_async_top` and `m_vlsit_axi3_async_aw/w/b/ar/r`. The approved instance name uses `u_` plus the complete module function after `m_`, for example `m_vlsit_axi_async_aw` is instantiated as `u_vlsit_axi_async_aw`.

