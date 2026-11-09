---
document_type: asic_ip_design_specification
document_id: "VLSIT-QSPI-SPEC"
title: "QSPI Controller and Target IP Design Specification"
ip_name: "QSPI Controller and Target IP"
version: "0.1"
status: "Draft"
language: "SystemVerilog IEEE 1800-2017"
rtl_rules: "VLSIT_RTL_Design_Rule.md"
csr_spec: "VLSIT_CSR_Specification_Template.xlsx"
---

# QSPI Controller and Target IP Design Specification

> **Purpose:** Normative design contract for architecture, RTL, verification, DFT, and physical integration of this IP.
>
> Replace every angle-bracket placeholder. Mark inapplicable sections **N/A** with a reason. Do not silently omit a required decision. Use **TBD** only with its technical impact and the decision needed recorded in [Assumptions, dependencies, and decisions](#20-assumptions-dependencies-and-decisions).
>
> Requirement terms: **shall** = mandatory and testable; **should** = recommended; **may** = optional. Give every mandatory requirement a stable REQ-<AREA>-<NNN> identifier and a verification method.

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

This IP provides a reconfigurable serial interface for an SoC to exchange data with external peripherals and flash devices. It shall support Standard SPI in both controller and target roles, and Dual-SPI and Quad-SPI in controller role only. Controller transaction formats shall include 1-1-2, 1-2-2, 1-1-4, 1-4-4 and QPI 4-4-4, selected by configuration registers. A single serial engine and pad interface shall be shared between the roles; only one role may be active at a time, and role changes are permitted only while the engine is idle. The SoC shall configure the IP through APB4 CSR and access the flash XIP window through an AXI4 subordinate (slave) interface. In XIP operation, the QSPI IP is the SPI controller toward the external flash.

The SoC-side interfaces are APB4 for control/status and indirect flash operations, plus AXI4 subordinate for memory-mapped XIP reads. XIP is read-only; flash program/erase uses the APB/FIFO path. The IP is flash-agnostic: indirect commands describe a serial command/data phase, and `done` means that phase has completed. Firmware owns write-enable setup, busy/status polling, retry policy, and device-specific QPI entry/exit. The XIP read profile and a few bus/FIFO details remain open in Section 20.

**Included:** Standard SPI controller and target roles; Dual-SPI and Quad-SPI controller operation, including the selected 1-1-2, 1-2-2, 1-1-4, 1-4-4 and QPI 4-4-4 formats; APB4 CSR and indirect flash program/erase through FIFO; read-only AXI4 subordinate XIP path; one shared engine/pad interface with mutually exclusive roles.

**Excluded:** Dual-SPI or Quad-SPI target operation; simultaneous controller and target transactions; DMA master interface; AXI writes to the XIP window; automatic flash write-enable, busy polling, retry, and vendor-specific recovery sequences. DDR/DTR behavior remains unselected. XIP is read-only. Firmware controls QPI entry/exit through indirect commands; the IP does not assume vendor-specific opcodes or flash status semantics.

### 1.2 Deployment assumptions

| Item | Specification |
|---|---|
| Target SoC / product class | ASIC-integrated SPI controller/target peripheral with APB4 CSR and AXI4 subordinate XIP connection; exact SoC TBD |
| Technology / library assumptions | Standard-cell implementation; process, library, voltage and corners TBD |
| Operating modes and workload | One shared engine; Standard SPI controller or target; Dual/Quad controller only; transaction type and target workload TBD |
| Security / privilege context | No security or privilege policy specified; register access policy TBD with the system bus choice |
| External dependencies | External SPI target device(s), system bus/CSR interface, clock/reset source, and SoC pad cells; exact device profile TBD |

### 1.3 Feature summary

| Feature ID | Feature | Required / optional | Configuration condition | Requirements |
|---|---|---|---|---|
| FEAT-001 | Standard SPI controller role | Required | Selected when the shared engine is idle; CPOL/CPHA modes 0–3; 4–32-bit words; MSB/LSB order | REQ-MODE-001, REQ-MODE-006, REQ-MODE-007 |
| FEAT-002 | Standard SPI target role | Required | Selected when the shared engine is idle; CPOL/CPHA modes 0–3; 4–32-bit words; MSB/LSB order | REQ-MODE-002, REQ-MODE-006, REQ-MODE-007 |
| FEAT-003 | Dual-SPI controller role | Required | Selected when the shared engine is idle | REQ-MODE-003 |
| FEAT-004 | Quad-SPI controller role, including QPI 4-4-4 | Required | Selected by configuration registers when the shared engine is idle | REQ-MODE-004, REQ-MODE-005 |
| FEAT-005 | Shared serial engine and pad interface | Required | Controller and target roles are mutually exclusive | REQ-ARCH-001, REQ-ARCH-002 |
| FEAT-006 | APB4 control/status register interface | Required | SoC software configures and monitors the IP | REQ-IF-001 |
| FEAT-007 | AXI4 subordinate memory-mapped XIP interface | Required | Parameterized bus widths; default 32-bit address/data, ID width 1, INCR reads up to 16 beats; writes return SLVERR without flash activity | REQ-IF-002 |
| FEAT-008 | Indirect flash program/erase path with FIFO | Required | Software configures/starts operations through APB4; FIFO data uses a custom APB window | REQ-IF-003 |

### 1.4 Real-world application and numeric need

The SoC starts from its internal Boot ROM. After boot, ROM or firmware configures the optional QSPI IP for the attached NOR flash; QSPI is therefore not a prerequisite for first-stage boot. The application is to support flash access and optional XIP across multiple NOR-device command profiles without requiring a different SoC image for each flash family. Six formats are confirmed: Standard `1-1-1`, Dual `1-1-2` and `1-2-2`, Quad `1-1-4` and `1-4-4`, and QPI `4-4-4`. Firmware-controlled indirect commands handle device-specific mode entry/exit, while configuration registers select controller framing. No maximum SCLK, bandwidth, flash capacity, or XIP latency target has been supplied; these remain open in DEC-005.

| Feature ID | Application | Need | Typical values / numeric target | Consequence if absent | Requirements | Source |
|---|---|---|---|---|---|---|
| FEAT-001 | Embedded SoC firmware controls a one-lane sensor, companion MCU, or serial NOR after ROM boot. | A standard controller mode is needed for widely compatible low-speed command/status traffic. | 1 lane; CPOL/CPHA modes 0–3; word lengths 4–32 bits; MSB/LSB. | Firmware cannot communicate with standard SPI peripherals through this IP. | REQ-MODE-001, REQ-MODE-006, REQ-MODE-007 | User-confirmed scope; REF-001 implementation profile. |
| FEAT-002 | A companion processor or test host controls the SoC as a one-lane SPI target. | The SoC must accept standard external-controller transactions without a second serial engine. | 1 lane; CPOL/CPHA modes 0–3; word lengths 4–32 bits. | The SoC cannot act as an SPI target through this IP. | REQ-MODE-002, REQ-MODE-006, REQ-MODE-007 | User-confirmed scope; REF-007 qualified target reference. |
| FEAT-003 | An embedded SoC accesses NOR flash supporting dual-I/O read/program commands, for example the device class illustrated by REF-011. | Two data lanes can reduce transfer clocks for payload phases while retaining serial command/address phases. | Formats 1-1-2 and 1-2-2; 2 data lanes. | Dual-I/O NOR features cannot be used; transfers must use another supported mode. | REQ-MODE-003, REQ-MODE-005 | User-confirmed format set; REF-001 and REF-011. |
| FEAT-004 | An embedded SoC accesses Quad-I/O NOR flash for image storage and optional post-ROM XIP. | Four data lanes support common Quad read/program profiles while preserving one-lane command phases. | Formats 1-1-4 and 1-4-4; 4 data lanes. | Quad-I/O flash profiles cannot be used, limiting image-read options. | REQ-MODE-004, REQ-MODE-005 | User-confirmed format set; REF-001 and REF-011. |
| FEAT-005 | A resource-constrained SoC shares one serial pin group between controller and target use cases. | Shared engine/pads avoid duplicating serial datapaths; role handoff is allowed only when idle. | 1 serial engine and 1 shared pad interface; at most 1 role active. | A design without sharing would need more area/pads, or could corrupt traffic if ownership overlaps. | REQ-ARCH-001, REQ-ARCH-002 | User-confirmed architecture. |
| FEAT-006 | Boot ROM and runtime firmware configure the controller for the attached flash and monitor program/erase completion. | APB4 provides a compact software control/status path. | APB4; one APB transaction at a time per APB protocol. | Firmware cannot select the flash profile or observe software-visible operation state. | REQ-IF-001 | User-confirmed SoC interface; REF-009. |
| FEAT-007 | After ROM boot, the CPU may read a memory-mapped external NOR image through the SoC fabric. | XIP allows optional direct CPU reads without copying the entire image into SRAM first. | AXI4 full subordinate; XIP reads only; numeric bandwidth/latency target TBD (DEC-005). | CPU cannot access flash through a memory-mapped path; software must use indirect transfers/copying. | REQ-IF-002, REQ-FUNC-001 | User-confirmed XIP role; REF-010. |
| FEAT-008 | Firmware updates or erases external NOR after ROM has configured the device. | APB-controlled, flash-agnostic indirect serial command/data phases and FIFO data move payload without making XIP writable. Firmware performs write-enable, busy polling, retry and device-specific state management. | Program/erase command and data phases through APB4/FIFO; 32-bit FIFO entries and parameterized depth (default 16). | The SoC has no software-controlled flash update/erase path through this IP. | REQ-IF-003, REQ-FUNC-002 | User-confirmed operation and flash-agnostic firmware responsibility. |

## 2. Normative references and precedence

### 2.1 Normative references

Record exact title, revision, document ID, controlled location/URL, and applicable clauses. Do not cite an unspecified “latest” revision. SPI is a de-facto interface rather than a single formal protocol standard; the supplied Synopsys databook is an implementation reference, not a vendor-neutral standard.

| Ref ID | Document and revision | Applicable clauses | Authority / notes |
|---|---|---|---|
| REF-001 | Synopsys IP DW_apb_ssi Databook, Version 4.05a, February 2025; user-provided document, converted copy at [`dw_apb_ssi_databook_v4_05a.md`](../legacy_qspi_dual_quad_ip_spec/reference/md_doc/dw_apb_ssi_databook_v4_05a.md) | §§2.8.4–2.8.5, 3.5, 4.2, 5.1.1, 5.1.27, Appendix B.2 | Proprietary implementation reference only; not a formal SPI standard; redistribution forbidden |
| REF-002 | User design request and confirmed scope, 2026-11-02 | Standard SPI controller + target with CPOL/CPHA modes 0–3, 4–32-bit configurable words, selectable MSB/LSB order; Dual/Quad controller-only; shared engine/pad interface with mutually exclusive roles; APB4 CSR/FIFO indirect program/erase; read-only CPU XIP through AXI4 subordinate; QPI 4-4-4 and 1-1-2, 1-2-2, 1-1-4, 1-4-4 selected; QSPI spelling confirmed | Product behavior; remaining interface/transfer details require user decisions |
| REF-006 | lowRISC OpenTitan `spi_host`, commit `41049e9deb40e0602cd5272c40398be380ae2637` | [`HWIP specification`](https://opentitan.org/book/hw/ip/spi_host/index.html), [`DV document`](https://opentitan.org/book/hw/ip/spi_host/dv/index.html), pinned source `hw/ip/spi_host/` | Qualified controller-side architecture/verification reference; Apache-2.0; upstream reports Earl Grey 1.0.0 tapeout |
| REF-007 | lowRISC OpenTitan `spi_device`, commit `41049e9deb40e0602cd5272c40398be380ae2637` | [`HWIP specification`](https://opentitan.org/book/hw/ip/spi_device/index.html), [`DV document`](https://opentitan.org/book/hw/ip/spi_device/dv/index.html), pinned source `hw/ip/spi_device/` | Qualified Standard target reference only; not full Dual/Quad-I/O target; Apache-2.0; upstream reports Earl Grey 1.0.0 tapeout |
| REF-008 | [`Reference-IP research log`](../legacy_qspi_dual_quad_ip_spec/research/vlsit_reference_ip_log.md) | Candidate evidence, exclusions, Chinese-language source review | Research record; not a protocol authority |
| REF-009 | AMBA APB Protocol Specification APB4 (Issue C, v2.0), included in Arm IHI 0024 Issue D, ID041221; converted source `reference/md_doc/vlsit_apb_amba_apb_ihi0024d.md` | §§2.1, 3.1–3.5, Appendix B.1 | Protocol authority for the selected APB4 CSR interface; APB5-only signals are excluded |
| REF-010 | AMBA AXI and ACE Protocol Specification, Arm IHI 0022 Issue H.c (ID012621); private local Markdown source `C:\HQuan\102_MyGithub\VLSIT_RTL_Generator_AI_Model\common_rtl\009_HyperRAM_Controller\reference\md_doc\vlsit_amba_axi_ihi0022hc.md` | Part A, Chapters A1–A6; Appendix G7 for revisions | Protocol authority for the selected full AXI4 subordinate interface. Local source license marks redistribution unconfirmed; source is referenced in place and is not copied into this package. |
| REF-011 | Macronix MX25U51245G/54 Serial NOR Flash datasheet, Rev. 1.2 (July 2020), public manufacturer document | §§7-2, 8, 10-15, 10-18 | Non-normative device example for distinction between 1-1-4 and QPI 4-4-4 and vendor-specific QPI entry/exit; not the selected target flash. [Manufacturer PDF](https://www.macronix.com/Lists/Datasheet/Attachments/8736/MX25U51245G%2054%2C%201.8V%2C%20512Mb%2C%20v1.2.pdf) |
| REF-003 | VLSIT RTL Design Rules v2, VLSIT_RTL_Design_Rule.md (same folder as this template) | All applicable rules | Mandatory RTL coding, hierarchy, reset, CDC, and naming baseline |
| REF-004 | IEEE 1800-2017 SystemVerilog | Synthesizable subset | Subject to REF-003 and selected frontend support |
| REF-005 | VLSIT CSR Specification Template workbook, VLSIT_CSR_Specification_Template.xlsx (same folder as this template) | Configuration and register definition sheets for this IP | Sole authority for the register interface, register map, fields, access types, and reset values (Section 11) |

### 2.2 Source-of-truth and conflict handling

1. The selected external protocol revision defines protocol behavior for the declared interface profile.
2. Approved product requirements and decisions define product-specific behavior.
3. This specification defines the IP contract and shall remain consistent with the selected protocol and the VLSIT RTL Design Rules v2.
4. REF-003 is the mandatory RTL coding, hierarchy, reset, CDC, and naming baseline. If a proposed requirement conflicts with it, revise the specification requirement or choose a compliant implementation; do not create a local RTL exception.
5. REF-005 is the only place where CSRs are specified. Do not declare registers, fields, offsets, access types, or reset values in this specification.
6. Record the exact protocol revision, role, and optional-signal configuration. Do not include protocol signals absent from the selected revision/profile.
7. Resolve conflicts through an explicit product decision; do not guess or weaken a requirement.
8. Reference IPs inform architecture and verification choices only; their feature sets do not silently expand or reduce the requirements in REF-002.

**Naming rule:** VLSIT default naming rule from `VLSIT_RTL_Design_Rule.md`, section 2, path `C:\Users\PC\.codex\skills\vlsit-asic-ip-microspec\reference\templates\VLSIT_RTL_Design_Rule.md`, version 2 (user confirmed 2026-11-01; rule R-026). Planned top module name: `m_qspi`.

### 2.3 Compliance declaration

| Standard | Revision / profile | Role implemented | Options | Deviations |
|---|---|---|---|---|
| Standard SPI | No single formal SPI revision; REF-001 is an implementation reference and the endpoint profile is product-defined | Controller and target | CPOL/CPHA modes 0–3; 4–32-bit words; selectable MSB/LSB order; one shared engine; target frame groups complete configured words | Peripheral-specific timing remains device-defined; target partial-word and TX-underflow behavior is specified in Sections 10.1 and 10.2 |
| Dual-SPI | Enhanced SPI in REF-001 | Controller only | 1-1-2 and 1-2-2 transaction formats; software selects mode through configuration registers | Opcode/phase support depends on selected flash profile |
| Quad-SPI | Enhanced SPI in REF-001 | Controller only | 1-1-4 and 1-4-4 transaction formats; software selects mode through configuration registers | Opcode/phase support depends on selected flash profile |
| QPI | Device-specific Quad Peripheral Interface defined by the selected flash datasheet; REF-001 is only an implementation reference for configurable multi-I/O instruction/address/data phases | Controller only | 4-4-4 command/address/data format; firmware issues device-specific entry/exit/reset commands through flash-agnostic indirect phases; software-visible configuration selects controller framing only | IP does not infer flash state or status; firmware selects commands from the target datasheet (DEC-008) |
| AMBA APB | APB4 Issue C, v2.0 within REF-009 | Subordinate (Completer) | Generated CSR bank is 32-bit data/16-bit byte address with four strobes; PPROT policy remains pending | APB5-only signals not used |
| AMBA AXI | AXI4 full, Arm IHI 0022 Issue H.c (REF-010) | Subordinate | XIP subordinate; parameterized address/data/ID widths; default 32-bit address/data, ID width 1; INCR read bursts 1–16 beats; one outstanding burst; writes return SLVERR | Not AXI4-Lite; FIXED/WRAP/unsupported-size reads return SLVERR; reads while disabled or in target mode return SLVERR; round-robin XIP/indirect arbitration; XIP writes never issue flash commands |

## 3. Requirements and traceability


| ID | Requirement using shall/should/may | Source | Applies to | Verification method |
|---|---|---|---|---|
| REQ-MODE-001 | The IP shall provide one-lane Standard SPI operation in controller role. | REF-002 §scope | CFG-STD-CTRL | Directed simulation with SPI target BFM; protocol assertions |
| REQ-MODE-002 | The IP shall provide one-lane Standard SPI operation in target role. | REF-002 §scope | CFG-STD-TGT | Directed simulation with SPI controller BFM; protocol assertions |
| REQ-MODE-003 | The IP shall provide two-lane Dual-SPI operation in controller role. | REF-002 §scope | CFG-DUAL-CTRL | Directed simulation with Dual-SPI target BFM; lane and phase checks |
| REQ-MODE-004 | The IP shall provide four-lane Quad-SPI operation in controller role. | REF-002 §scope | CFG-QUAD-CTRL | Directed simulation with Quad-SPI target BFM; lane and phase checks |
| REQ-MODE-005 | The IP shall provide configurable controller transactions in 1-1-2, 1-2-2, 1-1-4, 1-4-4 and QPI 4-4-4 formats, with the selected format controlled by software-visible configuration registers. | REF-002 §mode selection | CFG-DUAL-CTRL, CFG-QUAD-CTRL | Directed BFM tests for each phase/lane configuration; CSR mode-selection tests |
| REQ-MODE-006 | Standard SPI controller and target operation shall support all four CPOL/CPHA combinations, modes 0 through 3, selected by software-visible configuration fields. | REF-002 §SPI profile | CFG-STD-CTRL, CFG-STD-TGT | Controller/target BFM tests across all mode combinations and clock-edge assertions |
| REQ-MODE-007 | Standard SPI controller and target operation shall support software-configurable word lengths from 4 through 32 bits and selectable MSB-first or LSB-first bit order. | REF-002 §SPI profile | CFG-STD-CTRL, CFG-STD-TGT | Directed tests at minimum, maximum and representative word lengths in both bit orders |
| REQ-ARCH-001 | The IP shall use one serial engine and one pad interface shared by controller and target roles. | REF-002 §architecture | All configurations | RTL structure inspection; elaboration checks |
| REQ-ARCH-002 | Controller and target roles shall be mutually exclusive; role changes shall be accepted only when the shared engine is idle. | REF-002 §architecture | All configurations | Directed simulation of role switching while idle and while busy |
| REQ-ARCH-003 | XIP and indirect flash operations shall use the shared serial engine in controller role; the IP shall block new controller operations while target role is selected. | REF-002 §shared-engine architecture | Controller/target mode transitions | Directed concurrency tests for target selection, AXI XIP requests and indirect commands; blocked-request response remains a DEC-002 item |
| REQ-IF-001 | The IP shall expose an APB4 subordinate interface for software-visible control and status registers. | REF-002 §SoC interface | All configurations | APB protocol assertions; CSR read/write tests |
| REQ-IF-002 | The IP shall expose an AXI4 subordinate XIP interface; its default profile shall use 32-bit address/data, ID width 1, and INCR reads of 1–16 beats, with widths and maximum beats parameterized; it shall reject FIXED/WRAP reads and return flash data through AXI R. | REF-002 §SoC interface; user selection 2026-11-02 | XIP configuration | AXI protocol assertions; XIP read, burst-limit and unsupported-burst tests against a flash model |
| REQ-IF-003 | The IP shall provide a software-controlled indirect flash program/erase path through APB4 and a FIFO data path. | REF-002 §flash operations | Controller configurations | Directed program/erase tests against a flash model; FIFO boundary and error checks |
| REQ-IF-004 | AXI4 write transactions targeting the read-only XIP window shall complete with BRESP=SLVERR and shall cause no flash-side effect. | REF-002 §XIP read-only decision | XIP configuration | AXI write-channel assertions and flash-pin monitor prove SLVERR response and no serial program/erase command |
| REQ-FUNC-001 | The IP shall translate accepted AXI4 XIP reads into serial-flash read operations and return the corresponding bytes through AXI R responses. | REF-002 §XIP behavior | Controller/XIP configurations | Flash-model comparison of returned bytes; AXI protocol assertions |
| REQ-FUNC-002 | The IP shall execute software-started flash program and erase operations through the APB4/FIFO indirect path. | REF-002 §indirect operations | Controller configurations | Flash-model program/erase checks; operation completion and error checks |

## 4. Features and configurations

| Configuration ID | Enabled features | Disabled features | Interfaces / widths | Intended use | Verification target |
|---|---|---|---|---|---|
| CFG-STD-CTRL | Standard SPI; controller role; 1-1-1; modes 0–3; 4–32-bit words; MSB/LSB | Target role, Dual/Quad/QPI | APB4 CSR/FIFO and AXI4 XIP; widths TBD | Connect the SoC to a one-lane peripheral or flash | SPI modes/transactions and selected device profile |
| CFG-STD-TGT | Standard SPI; target role; 1-1-1; modes 0–3; 4–32-bit words; MSB/LSB | Controller role, Dual/Quad/QPI and XIP | APB4 CSR; AXI4 XIP disabled while target role is selected | Accept one-lane transactions from an external controller | External-clock sampling, CS framing, TX/RX response |
| CFG-DUAL-CTRL | Dual-SPI controller; 1-1-2 and 1-2-2 | Target role, Quad/QPI | APB4 CSR/FIFO and AXI4 XIP; widths TBD | Two-lane flash/peripheral transfers | Instruction/address/data phases, lane direction and timing |
| CFG-QUAD-CTRL | Quad-SPI controller; 1-1-4 and 1-4-4 | Target role, Dual/QPI | APB4 CSR/FIFO and AXI4 XIP; widths TBD | Four-lane flash/peripheral transfers with serial command | Instruction/address/data phases, lane direction and timing |
| CFG-QPI-CTRL | QPI controller; 4-4-4 | Target role, Standard/Dual/other Quad phase formats | APB4 CSR/FIFO and AXI4 XIP; firmware enters/exits flash QPI with indirect commands | Four-lane command, address and data transfers | Firmware command entry/exit, device-specific reset recovery, phase alignment and XIP reads |


## 5. Architecture

### 5.1 Overview and block responsibilities


| Block | Responsibility | Inputs / outputs | Clock/reset domain | State or storage |
|---|---|---|---|---|
| APB decode and custom FIFO window | Decodes APB addresses into generated CSRs or custom TX/RX FIFO data windows and returns one response. | APB4 pins; CSR and FIFO requests/responses | `i_clk_apb`; reset release synchronized to APB | Address decode and APB response state |
| Generated APB4 CSR and control | Holds software-selected role, CPOL/CPHA, frame, lane format, flash profile, indirect command, status and interrupt state; the CSR workbook is authoritative for fields. | APB4 CSR requests; control/status between APB and engine | `i_clk_apb`; control/status use CDC | Generated CSR state |
| AXI4 XIP subordinate | Accepts memory-mapped reads and converts them to flash-read work; returns ordered read data. XIP writes complete with SLVERR and no flash command. Defaults are 32-bit address/data, ID width 1, INCR bursts up to 16 beats; widths and limit are parameters. | Five AXI4 channels; request/completion to arbiter/engine | `i_clk_axi`; asynchronous to APB and serial engine | Address, ID, beat-count and response state |
| Indirect command controller | Executes software-programmed flash read/program/erase commands; TX data comes from the TX FIFO and received data can go to RX FIFO. | APB CSR/FIFO requests; engine request/completion | APB side in `i_clk_apb`; controller engine in `i_clk_serial` | Command/address/length and operation state |
| Request arbiter | Grants the single serial engine to XIP, indirect operation or target role. Priority among eligible controller requests remains open in DEC-002. | XIP, indirect and role requests; engine grant | `i_clk_serial`, with request/response CDC to AXI and APB | Owner/grant state |
| Shared serial engine | Executes one transfer at a time. Standard SPI supports controller/target; Dual/Quad/QPI are controller-only. Supports modes 0–3, 4–32-bit words, MSB/LSB, 1-1-2, 1-2-2, 1-1-4, 1-4-4 and 4-4-4. | Granted work, TX/RX data, selected serial clock and IO lanes | Controller `i_clk_serial` or target `i_spi_sclk_tgt`, selected only while idle; clock mux must switch glitch-free | Shared shift, phase and frame state |
| TX/RX FIFOs | Buffer software data and serial data across APB, controller and target timing domains. Depth and full/empty APB behavior remain open. | APB FIFO window and shared engine | Dual-clock domains as required; clocks are asynchronous | TX/RX queue pointers and storage |
| Serial pin mux | Drives/samples IO0–IO3, controller SCLK/CS and target signals according to role, phase and lane direction. | Shared engine controls and external serial pins | Selected serial timing domain | Output-enable and lane-direction state |
| Reset/CDC support | Synchronizes reset release and transfers commands, status and FIFO data across asynchronous domains. | APB, AXI, target SCLK and reset | Each destination clock domain | Synchronizers and asynchronous queues |

### 5.2 Block diagram

The SoC connects APB4 to an address decoder that selects generated CSRs or a custom TX/RX FIFO-data window. AXI4 XIP reads and APB indirect commands are serialized and use the shared serial engine; AXI4 XIP writes return SLVERR without flash-pin activity. The AXI XIP interface (`i_clk_axi`) and serial engine (`i_clk_serial`) are separate asynchronous clock domains. Target role uses external `i_spi_sclk_tgt`; the engine clock source switches only while idle through a glitch-free clock mux. APB, AXI, serial-engine and target-SCLK domains use explicit CDC. Controller CS count is parameterized; target mode has one external active-low CS input.

### 5.3 Transaction and dataflow

**XIP read:** The AXI4 subordinate accepts one outstanding INCR read burst, checks the configured profile and range, and translates each in-window beat to flash byte address `ARADDR - PARA_XIP_BASE_ADDR`. Default bus settings are 32-bit address/data, ID width 1 and at most 16 beats; widths and the burst limit are parameters. Byte, halfword and word reads are supported on a 32-bit data bus. FIXED/WRAP, unsupported size/profile, disabled XIP and out-of-window beats return RRESP=SLVERR for each rejected beat without issuing that beat's flash command. For accepted beats, the engine sends configured opcode, address, optional mode bits and dummy cycles, then samples data in the selected lane format. R data, ID, RRESP and RLAST obey AXI backpressure. Firmware configures the device-specific read profile; flash busy/status remains firmware-managed.

**Indirect command/data phase:** Firmware configures opcode, address length/value, lane format, dummy cycles, direction and transfer count through APB4 CSRs; it writes TX payload through the TX FIFO-data window and reads RX payload through the RX FIFO-data window. Proposed byte offsets are `0x1000` (TX push) and `0x1004` (RX pop). The serial engine executes only the requested command/data phase. `done` indicates completion of that phase, not completion of the flash's internal program/erase cycle. Firmware must separately issue write-enable, poll flash status/busy, perform retries and manage device-specific QPI entry/exit. The IP does not interpret vendor status bits or claim that a flash program/erase operation succeeded.

**Standard SPI target:** When software selects target role while the engine is idle, the engine clock selection changes to external `i_spi_sclk_tgt`; `i_spi_cs_n_tgt` frames the transaction. The IP samples/drives IO0/IO1 and transfers data through clock-domain-aware FIFOs. CS timing, word framing, response preloading and clock/reset details remain open. XIP and indirect controller operations are unavailable while target role owns the engine.

### 5.4 Invariants

1. The shared serial datapath and pin mux have a single owner at a time; controller and target roles cannot be active simultaneously.
2. Role changes are accepted only when the serial engine is idle (REQ-ARCH-002).
3. XIP accesses are served only when controller role is available; target-role access is rejected with an AXI read error whose encoding remains open.
4. AXI responses correspond to accepted requests; the default profile supports INCR bursts up to 16 beats and rejects FIXED/WRAP. Outstanding request depth remains open.
5. A serial data phase drives or samples only the lanes selected for that command phase; exact lane turnaround timing is specified after the flash profile is selected.

## 6. External interfaces and ports

### 6.1 Interface inventory

| Interface ID | Type and revision | Role | Direction at IP boundary | Clock domain | Required / optional | Configurations |
|---|---|---|---|---|---|---|
| IF-001 | AMBA APB4 (APB Issue C, v2.0; Arm IHI 0024D) | Subordinate (slave/Completer) | Receives CSR and custom FIFO-window accesses; returns read data/response | `i_clk_apb`; asynchronous to AXI and serial engine | Required | All |
| IF-002 | AMBA AXI4 full memory-mapped XIP (Arm IHI 0022H.c) | Subordinate (slave) | Accepts XIP reads and responds SLVERR to writes; default 32-bit address/data, ID width 1, INCR bursts up to 16 beats | `i_clk_axi`; separate asynchronous domain from serial engine | Required | XIP configurations |
| IF-003 | Standard/Dual/Quad SPI serial pin interface; de-facto profile | Controller or target, selected by mode | Shared bidirectional IO[3:0]; controller SCLK output or target external SCLK input; parameterized controller CS count and one target CS input | Controller engine clock `i_clk_serial`; target SCLK is an external asynchronous clock domain | Required | All, with Dual/Quad controller-only |

### 6.2 Complete port list


| Port | Direction | Width | Meaning (function) | Clock domain | Signal type | Reset / idle value | Timing / sampling | Configurations |
|---|---|---:|---|---|---|---|---|---|
| `i_clk_apb` | Input | 1 | APB4 and generated CSR clock | CLK-APB | clock | Stopped/unspecified during reset | Rising-edge APB sampling | All |
| `i_rst_n_apb` | Input | 1 | Active-low reset for APB decode, CSR and APB-side FIFO interface | CLK-APB reset domain | reset | Asserted LOW | Asynchronous assertion; synchronous release to `i_clk_apb` | All |
| `i_clk_axi` | Input | 1 | AXI4 XIP interface clock, separate from serial-engine clock | CLK-AXI | clock | Stopped/unspecified during reset | Rising-edge AXI sampling | XIP |
| `i_rst_n_axi` | Input | 1 | Active-low reset for AXI XIP adapter | CLK-AXI reset domain | reset | Asserted LOW | Asynchronous assertion; synchronous release to `i_clk_axi` | XIP |
| `i_clk_serial` | Input | 1 | Controller serial-engine reference clock | CLK-SERIAL | clock | Stopped/unspecified during reset | Rising-edge internal engine sampling | Controller modes |
| `i_rst_n_serial` | Input | 1 | Active-low reset for shared serial engine and serial-side CDC | CLK-SERIAL reset domain; also asynchronously asserts target reset synchronizer | reset | Asserted LOW | Asynchronous assertion; release synchronized to `i_clk_serial` and external target SCLK domain | All serial modes |
| `i_apb_psel` | Input | 1 | APB4 select | CLK-APB | level | 0 | Sample with PENABLE/PREADY at rising edge | All |
| `i_apb_penable` | Input | 1 | APB4 access phase | CLK-APB | level | 0 | Rising-edge APB handshake | All |
| `i_apb_paddr` | Input | `PARA_APB_ADDR_W` (16 default) | Byte address for CSR and FIFO windows | CLK-APB | data | 0 | Stable through ACCESS completion | All |
| `i_apb_pwrite` | Input | 1 | APB4 write direction | CLK-APB | level | 0 | Stable through ACCESS completion | All |
| `i_apb_pwdata` | Input | 32 | APB4 write data | CLK-APB | data | 0 | Sample on completed write | All |
| `i_apb_pstrb` | Input | 4 | APB4 byte write strobes | CLK-APB | data | 0 | CSR partial-strobe writes and FIFO writes without all four strobes return PSLVERR | All |
| `i_apb_pprot` | Input | 3 | APB4 protection attributes; not used for access control | CLK-APB | data | 0 | Ignored; CSR generator protection check is disabled (`i_protect_en=0`) | All |
| `o_apb_pready` | Output | 1 | APB4 transfer completion / wait-state control | CLK-APB | level | 0 | Asserted during ACCESS when selected target completes | All |
| `o_apb_prdata` | Output | 32 | APB4 read data for CSR or FIFO window | CLK-APB | data | 0 | Valid when PREADY completes a read | All |
| `o_apb_pslverr` | Output | 1 | APB4 error response | CLK-APB | level | 0 | Meaningful with PREADY in ACCESS | All |
| `i_axi_awaddr` | Input | `PARA_AXI_ADDR_W` (32 default) | AXI write address; writes to XIP are rejected | CLK-AXI | data | 0 | AXI AW handshake | XIP |
| `i_axi_awid` | Input | `PARA_AXI_ID_W` (1 default) | AXI write transaction ID | CLK-AXI | data | 0 | Captured on AW handshake | XIP |
| `i_axi_awlen` | Input | 8 | AXI write burst length, beats minus one | CLK-AXI | data | 0 | AXI4 fixed-width sideband | XIP |
| `i_axi_awsize` | Input | 3 | AXI write beat size | CLK-AXI | data | 0 | Captured on AW handshake | XIP |
| `i_axi_awburst` | Input | 2 | AXI write burst type | CLK-AXI | data | 0 | Captured on AW handshake | XIP |
| `i_axi_awlock` | Input | 1 | AXI write lock attribute | CLK-AXI | level | 0 | Captured on AW handshake | XIP |
| `i_axi_awcache` | Input | 4 | AXI write cache attributes | CLK-AXI | data | 0 | Captured on AW handshake | XIP |
| `i_axi_awprot` | Input | 3 | AXI write protection attributes | CLK-AXI | data | 0 | Captured on AW handshake | XIP |
| `i_axi_awqos` | Input | 4 | AXI write QoS attribute | CLK-AXI | data | 0 | Captured on AW handshake | XIP |
| `i_axi_awregion` | Input | 4 | AXI write region attribute | CLK-AXI | data | 0 | Captured on AW handshake | XIP |
| `i_axi_awvalid` | Input | 1 | AXI write-address valid | CLK-AXI | level | 0 | Held until AWREADY | XIP |
| `o_axi_awready` | Output | 1 | AXI write-address ready | CLK-AXI | level | 0 | Handshake when AWVALID and AWREADY are HIGH | XIP |
| `i_axi_wdata` | Input | `PARA_AXI_DATA_W` (32 default) | AXI write data; no flash side effect | CLK-AXI | data | 0 | Captured on W handshake | XIP |
| `i_axi_wstrb` | Input | `PARA_AXI_DATA_W/8` | AXI write byte strobes | CLK-AXI | data | 0 | Captured on W handshake | XIP |
| `i_axi_wlast` | Input | 1 | AXI final write-data beat marker | CLK-AXI | level | 0 | Captured on W handshake | XIP |
| `i_axi_wvalid` | Input | 1 | AXI write-data valid | CLK-AXI | level | 0 | Held until WREADY | XIP |
| `o_axi_wready` | Output | 1 | AXI write-data ready | CLK-AXI | level | 0 | Handshake when WVALID and WREADY are HIGH | XIP |
| `o_axi_bid` | Output | `PARA_AXI_ID_W` (1 default) | AXI write response ID | CLK-AXI | data | 0 | Stable while BVALID and not BREADY | XIP |
| `o_axi_bresp` | Output | 2 | AXI write response; SLVERR for any write to read-only XIP | CLK-AXI | data | 0 | Stable while BVALID and not BREADY | XIP |
| `o_axi_bvalid` | Output | 1 | AXI write response valid | CLK-AXI | level | 0 | Held until BREADY | XIP |
| `i_axi_bready` | Input | 1 | AXI write response ready | CLK-AXI | level | 0 | Sampled on rising edge | XIP |
| `i_axi_araddr` | Input | `PARA_AXI_ADDR_W` (32 default) | AXI read address into XIP window | CLK-AXI | data | 0 | AXI AR handshake | XIP |
| `i_axi_arid` | Input | `PARA_AXI_ID_W` (1 default) | AXI read transaction ID | CLK-AXI | data | 0 | Captured on AR handshake | XIP |
| `i_axi_arlen` | Input | 8 | AXI read burst length, beats minus one; default acceptance max is 16 beats | CLK-AXI | data | 0 | Captured on AR handshake | XIP |
| `i_axi_arsize` | Input | 3 | AXI read beat size | CLK-AXI | data | 0 | Captured on AR handshake | XIP |
| `i_axi_arburst` | Input | 2 | AXI read burst type; INCR supported by default profile | CLK-AXI | data | 0 | Captured on AR handshake | XIP |
| `i_axi_arlock` | Input | 1 | AXI read lock attribute | CLK-AXI | level | 0 | Captured on AR handshake | XIP |
| `i_axi_arcache` | Input | 4 | AXI read cache attributes | CLK-AXI | data | 0 | Captured on AR handshake | XIP |
| `i_axi_arprot` | Input | 3 | AXI read protection attributes | CLK-AXI | data | 0 | Captured on AR handshake | XIP |
| `i_axi_arqos` | Input | 4 | AXI read QoS attribute | CLK-AXI | data | 0 | Captured on AR handshake | XIP |
| `i_axi_arregion` | Input | 4 | AXI read region attribute | CLK-AXI | data | 0 | Captured on AR handshake | XIP |
| `i_axi_arvalid` | Input | 1 | AXI read-address valid | CLK-AXI | level | 0 | Held until ARREADY | XIP |
| `o_axi_arready` | Output | 1 | AXI read-address ready | CLK-AXI | level | 0 | Handshake when ARVALID and ARREADY are HIGH | XIP |
| `o_axi_rid` | Output | `PARA_AXI_ID_W` (1 default) | AXI read response ID | CLK-AXI | data | 0 | Stable while RVALID and not RREADY | XIP |
| `o_axi_rdata` | Output | `PARA_AXI_DATA_W` (32 default) | AXI XIP read data | CLK-AXI | data | 0 | Stable while RVALID and not RREADY | XIP |
| `o_axi_rresp` | Output | 2 | AXI read response; SLVERR for unsupported read profile or unavailable XIP | CLK-AXI | data | 0 | Stable with RVALID | XIP |
| `o_axi_rlast` | Output | 1 | AXI final read-beat marker | CLK-AXI | level | 0 | Asserted on final beat of accepted burst | XIP |
| `o_axi_rvalid` | Output | 1 | AXI read response valid | CLK-AXI | level | 0 | Held with payload until RREADY | XIP |
| `i_axi_rready` | Input | 1 | AXI read response ready | CLK-AXI | level | 0 | Sampled on rising edge | XIP |
| `o_spi_sclk_ctrl` | Output | 1 | Controller-generated serial clock | Divider from CLK-SERIAL; `f_sclk = f_ref / (2 x (divisor + 1))` | clock | CPOL-selected idle level; CPOL reset is 0 and divisor reset is `0xFFFF` | Divider-defined active edges | Controller modes |
| `i_spi_sclk_tgt` | Input | 1 | External controller clock in target role | CLK-TARGET | clock | External idle level follows CPOL | Captures target data at selected CPHA edge; asynchronous to APB, AXI and serial engine | Standard target |
| `i_spi_cs_n_tgt` | Input | 1 | Active-low external target select | Target SCLK domain | level | Inactive HIGH | Frame boundary; synchronize/capture per target implementation | Standard target |
| `i_spi_io_i` | Input | 4 | Samples external IO0–IO3 | Selected controller/target sampling domain | data | 0 | Lane/edge selected by transfer phase | All serial modes |
| `o_spi_io_o` | Output | 4 | Drives external IO0–IO3 | Selected controller/target domain | data | 0 | Valid with matching output enable | All serial modes |
| `o_spi_io_oe` | Output | 4 | Per-lane output enable; deassert to release flash-driven lanes | Selected controller/target domain | level | 0 (all lanes released) | Changes at defined phase/turnaround boundary | All serial modes |
| `o_spi_cs_n_ctrl` | Output | `PARA_NUM_CS` (default 1 proposed) | Active-low controller chip-select outputs | CLK-SERIAL | level | All HIGH | Setup/hold/high timing from programmed settings; exact minimums DEC-003 | Controller modes |
| `o_int_qspi` | Output | 1 | Combined QSPI interrupt output for enabled pending CSR event causes | `i_clk_apb` domain | level | 0 | Level asserted while any enabled sticky event is pending; sources and W1C clear behavior follow `qspi_irq_raw`, `qspi_irq_en`, and `qspi_irq_sts` in the CSR workbook | All |

### 6.3 Protocol behavior

**APB4 CSR and indirect path — REF-009, APB4 Issue C v2.0:** APB signals are sampled on the rising edge of `i_clk_apb`. A transfer has SETUP followed by ACCESS and completes on a rising edge when PSEL, PENABLE and PREADY are HIGH. The generated CSR interface is 32-bit data, 16-bit byte address and four PSTRB bits. Address decode selects CSRs or custom FIFO windows at byte offsets `0x1000` (TX push) and `0x1004` (RX pop). `PPROT` is ignored (`i_protect_en=0`); `i_slverr_en=1`. Misaligned/partial writes and FIFO accesses without all four strobes return PSLVERR. TX-full writes and RX-empty reads return PSLVERR without changing FIFO pointers. Aligned unmapped CSR reads return zero and writes are ignored, following the CSR generator. FIFO bytes are little-endian: TX sends `[7:0]`, `[15:8]`, `[23:16]`, `[31:24]` in that order; RX packs the first byte in `[7:0]`. CSR state is in the APB clock domain; crossings to engine/status domains use explicit CDC.

**AXI4 XIP subordinate — REF-010, Part A, Chapters A1–A6:** The interface uses independent AW, W, B, AR and R channels clocked by `i_clk_axi`. A transfer occurs when VALID and READY are HIGH at a rising edge; sources hold VALID and payload stable until handshake. Defaults are 32-bit address, 32-bit data, ID width 1 and maximum 16-beat INCR reads; widths and maximum beats are overridable parameters. Only one XIP burst may be outstanding. FIXED/WRAP/unsupported-size reads, and reads while XIP is disabled or target role is selected, return SLVERR on every beat without issuing a flash command. XIP and indirect requests use round-robin arbitration when the shared engine becomes idle. Every XIP write completes with BRESP=SLVERR and causes no flash-side effect. REF-010 also requires response VALID signals LOW during reset and prohibits combinational paths between interface inputs and outputs.

**SPI-family serial interface — REF-001 plus the selected endpoint datasheet:** Standard SPI supports CPOL/CPHA modes 0–3 and 4–32-bit words with selectable bit order. Controller formats are 1-1-1, 1-1-2, 1-2-2, 1-1-4, 1-4-4 and QPI 4-4-4. The CSR command fields select opcode, address-byte count, lane format, dummy cycles, direction and payload byte count. The IP executes only these configured phases; it does not perform implicit WREN, busy polling, retry or flash-status interpretation. Firmware controls QPI state through explicit indirect commands; the mode register controls controller framing only. Device electrical timing remains subject to the selected endpoint datasheet.

| Case | Legal behavior | Illegal / unsupported case | IP response | Requirement IDs |
|---|---|---|---|---|
| APB4 CSR access | APB4 SETUP/ACCESS handshake; complete when PREADY is HIGH in ACCESS | Misaligned, partial-strobe, protection-denied, or unmapped accesses | CSR generator behavior in Section 11; protection/partial-write profile pending DEC-009 | REQ-IF-001 |
| APB4 indirect flash data | Software configures operations and uses TX/RX FIFO windows at proposed byte offsets `0x1000`/`0x1004` | FIFO full/empty or access while operation is unavailable | Full/empty response and push/pop semantics remain open in DEC-010 | REQ-IF-003 |
| AXI4 XIP read | INCR read burst (default maximum 16 beats); flash data returned on R with backpressure | FIXED/WRAP burst, unsupported size, out-of-window read, or target role owns engine | Read error response encoding and address policy remain open in DEC-002 | REQ-IF-002, REQ-ARCH-003 |
| AXI4 write to XIP | No flash program/erase through AXI XIP path | Any write request to the XIP region | Complete the AXI write response with BRESP=SLVERR and no flash-side effect | REQ-IF-004 |
| Standard SPI transaction | Controller or target role, CPOL/CPHA mode 0–3, 4–32-bit word, selectable bit order | Controller/target overlap or reserved/invalid mode encoding | Active configuration is snapshotted at command acceptance; CSR writes while busy affect later work; a `start` written while busy is ignored and sets sticky `fl_err` | REQ-MODE-001, REQ-MODE-002, REQ-MODE-006, REQ-MODE-007 |
| Dual/Quad/QPI controller transaction | Mode register selects 1-1-2, 1-2-2, 1-1-4, 1-4-4 or 4-4-4; firmware enters/exits QPI through indirect commands | Dual/Quad/QPI target operation; invalid flash state for QPI | Invalid-mode and flash-state error reporting remains open in DEC-003/DEC-008 | REQ-MODE-003, REQ-MODE-004, REQ-MODE-005 |

### 6.4 Internal block-level connections

The following names define the logical wires used by the architecture diagram and planned RTL hierarchy. They are interface bundles only; CSR register and field details remain exclusively in the CSR workbook.

| Diagram interface | Source → destination | Signal names | Clock domain / CDC |
|---|---|---|---|
| APBC | APB decoder → generated CSR | `w_csr_psel`, `w_csr_penable`, `w_csr_paddr`, `w_csr_pwrite`, `w_csr_pwdata`, `w_csr_pstrb`, `w_csr_pprot`, `w_csr_pready`, `w_csr_prdata`, `w_csr_pslverr` | `i_clk_apb` |
| APBF | APB decoder → TX FIFO | `w_tx_fifo_push`, `w_tx_fifo_data`, `w_tx_fifo_strb`, `w_tx_fifo_full` | `i_clk_apb` to selected serial domain by dual-clock FIFO |
| APBR | RX FIFO → APB decoder | `w_rx_fifo_pop`, `w_rx_fifo_data`, `w_rx_fifo_empty` | Selected serial domain to `i_clk_apb` by dual-clock FIFO |
| CFG | Generated CSR → command/XIP control | `w_ctrl_cfg`, `w_xip_cfg`, `w_indirect_cfg`, `w_status`, `w_irq_pending` | APB to AXI/serial by CDC |
| XIPQ | AXI XIP adapter → CDC/arbiter | `w_xip_req_valid`, `w_xip_req_addr`, `w_xip_req_id`, `w_xip_req_len`, `w_xip_req_ready`, `w_xip_rsp_valid`, `w_xip_rsp_ready`, `w_xip_rsp_data`, `w_xip_rsp_id`, `w_xip_rsp_last`, `w_xip_rsp_resp` | `i_clk_axi` ↔ `i_clk_serial` |
| INDQ | Indirect command controller → CDC/arbiter | `w_ind_req_valid`, `w_ind_req_cmd`, `w_ind_req_addr`, `w_ind_req_len`, `w_ind_req_ready`, `w_ind_rsp_valid`, `w_ind_rsp_done`, `w_ind_rsp_error` | APB ↔ `i_clk_serial` |
| ARBR | CDC/request queue → arbiter | `w_ctrl_req_valid`, `w_ctrl_req_owner`, `w_ctrl_req_ready` | `i_clk_serial`; source requests cross CDC |
| GRNT | Arbiter → serial engine | `w_eng_start`, `w_eng_owner`, `w_eng_mode`, `w_eng_busy`, `w_eng_done`, `w_eng_error` | `i_clk_serial` or target SCLK selected while idle |
| TX | TX FIFO → serial engine | `w_tx_data`, `w_tx_valid`, `w_tx_ready` | Dual-clock FIFO between APB and selected engine domain |
| RX | Serial engine → RX FIFO | `w_rx_data`, `w_rx_valid`, `w_rx_ready` | Dual-clock FIFO between selected engine domain and APB |
| CLKS | Clock mux → serial engine | `w_clk_engine` | Controller `i_clk_serial` or target `i_spi_sclk_tgt` |
| PINS | Serial engine ↔ pin mux | `w_sclk_ctrl`, `w_spi_cs_n_ctrl`, `w_spi_io_i`, `w_spi_io_o`, `w_spi_io_oe` | Selected serial timing domain |
| IRQEV | CDC → CSR interrupt/status state | `w_irq_done`, `w_irq_tx_err`, `w_irq_rx_err`, `w_irq_flash_err` | Engine/target domain to `i_clk_apb` |

### 6.5 Interrupts and events

| Signal/event | Polarity | Assert condition | Clear/deassert condition | Mask/priority | Crossing | Reset state |
|---|---|---|---|---|---|---|
| `o_int_qspi` combined level | Active HIGH | `(|(qspi_irq_raw & qspi_irq_en))`; raw causes are sticky and W1C, and `qspi_irq_sts` reports enabled pending causes | Software writes one to the matching `qspi_irq_raw` bit to clear it | One combined level; no priority encoding; CSR provides `done`, `tx_err`, `rx_err`, and a `fl_err` field whose meaning is pending user confirmation | Event/status synchronizers into APB domain; output is APB-domain level | LOW after reset |

## 7. Clock, reset, and power

### 7.1 Clock domains

| Domain | Clock port | Edge | Frequency range | Source | Relationship to other clocks | Gating policy |
|---|---|---|---|---|---|---|
| CLK-APB | `i_clk_apb` | Rising | Supplied by SoC; no IP-specific numeric frequency target selected | SoC APB clock source | Asynchronous to `i_clk_axi` | Do not gate during APB access; SoC controls idle clock policy |
| CLK-AXI | `i_clk_axi` | Rising | Supplied by SoC; no IP-specific numeric frequency target selected | SoC AXI clock source | Asynchronous to APB and serial engine | Do not gate during accepted AXI transaction |
| CLK-SERIAL | `i_clk_serial` | Rising | Supplied by SoC; no IP-specific numeric frequency target selected | SoC serial-engine clock source | Asynchronous to APB and AXI; controller engine timing reference | Do not gate during controller transfer |
| CLK-TARGET | `i_spi_sclk_tgt` | Active CPOL/CPHA edges | Supplied by external controller; limit is endpoint/SoC timing input | External controller | Asynchronous to APB, AXI and serial engine; selected as engine timing source in target mode | Target clock may stop between frames; reset assertion cannot depend on this clock |
| CLK-SCLK-OUT | `o_spi_sclk_ctrl` | CPOL/CPHA-selected edges | `f_ref / (2 x (divisor + 1))`; SoC clock and flash limit determine legal range | Internal divider | Active only in controller mode; target mode uses `i_spi_sclk_tgt` | No divider/CS change during active transfer |

### 7.2 CDC and RDC


| Crossing ID | From → to | Signals | Structure | Reset handling | Constraints / verification |
|---|---|---|---|---|---|
| CDC-001 | APB to controller engine | Commands, configuration snapshots and completion/status | Request/acknowledge mailbox for atomic command/status bundles; dual-clock FIFOs for payload data | Reuse `m_vlsit_rst_sync` in each clock domain | CDC/RDC analysis and asynchronous-clock simulations |
| CDC-002 | Target SCLK to APB/AXI | Target RX/TX data, CS framing and events | Reuse `m_vlsit_afifo_top` for data; synchronize single-bit events; capture CS framing in target SCLK domain | Asynchronous assertion and target-clock-local synchronized release; stopped-clock case retains asserted reset | CDC/RDC analysis and target frequency-ratio tests |
| CDC-003 | AXI XIP to serial engine | XIP request/address, response/data and ownership | Request/response mailbox plus dual-clock request/response queues based on `m_vlsit_afifo_top`; one outstanding burst | Reuse `m_vlsit_rst_sync` in AXI and serial domains | CDC/RDC analysis and AXI ordering/backpressure assertions |
| CDC-004 | APB control/FIFO to serial engine | Configuration snapshots, indirect commands, completion/status and TX/RX FIFO data | Request/acknowledge mailbox plus `m_vlsit_afifo_top` dual-clock FIFOs; source dependencies listed in `filelist.f` | Reuse `m_vlsit_rst_sync` in APB and serial domains | CDC/RDC analysis, FIFO pointer checks and command ordering tests |

### 7.3 Reset domains and sequencing

| Reset ID | Port | Polarity / assertion | Sync or async | Scope | Deassertion | Reset value |
|---|---|---|---|---|---|---|
| RST-APB | `i_rst_n_apb` | Active-low | Asynchronous assertion; synchronous release to APB domain | APB decoder, generated CSR and APB-side FIFO logic | Synchronized to `i_clk_apb` | APB response inactive; CSR resets per workbook |
| RST-AXI | `i_rst_n_axi` | Active-low | Asynchronous assertion; synchronous release to AXI domain | AXI adapter and AXI-side request/response queues | Synchronized to `i_clk_axi` | AXI VALID outputs inactive; pending state follows the in-flight reset policy |
| RST-SERIAL/TARGET | `i_rst_n_serial` | Active-low | Asynchronous assertion; synchronous release separately to `i_clk_serial` and target SCLK; assertion works even when target SCLK stops | Shared engine, controller output state and target capture/shift state; serial-side FIFO pointers | Synchronized to each local clock | Engine idle; controller CS inactive; IO output enables disabled; target outputs released; FIFO contents invalid |


### 7.4 Power intent (if applicable)

No internal power-domain sequencing, retention, isolation, or power-state control is selected for this IP. SoC-level power intent is owned by the integrator. If the block or its pads can be powered down independently, isolation and reset sequencing must be specified in DEC-007 before RTL freeze.
## 8. Parameters and elaboration configurations

| Parameter | Purpose | Default | Legal values / range | Dependencies / invalid combinations | Effect |
|---|---|---|---|---|---|
| `PARA_APB_ADDR_W` | APB4 byte-address width | 16 (fixed by selected CSR generator) | 16 | Must cover CSR offsets and custom FIFO windows | APB4 address decode and ports |
| `PARA_AXI_ADDR_W` | AXI4 byte-address width | 32 (user-selected default) | 32–64 proposed; exact supported range validated at RTL elaboration | Must cover configured XIP window and selected flash address range | AXI AW/AR address ports and XIP translation |
| `PARA_AXI_DATA_W` | AXI4 data width | 32 (user-selected default) | 32, 64 or 128 proposed | Byte-aligned power-of-two width; beat size cannot exceed data width | AXI W/R data and strobes |
| `PARA_AXI_ID_W` | AXI4 transaction ID width | 1 (user-selected default) | 1–16 proposed | IDs are preserved; outstanding depth is implementation-bounded | AXI AW/AR and B/R ID ports |
| `PARA_AXI_MAX_BURST` | Maximum accepted XIP INCR read beats | 16 (user-selected default) | 1–16 | `ARLEN + 1` must not exceed this value; AXI LEN stays 8 bits | XIP buffering and serial burst segmentation |
| `PARA_XIP_BASE_ADDR` | Base address of the AXI XIP window | `0x00000000` | 32-bit byte address | Window must not wrap the supported 32-bit address space | AXI-to-flash address translation |
| `PARA_XIP_SIZE_BYTES` | Size of the AXI XIP window in bytes | `0x00000000` (disabled until overridden) | 0–`0xFFFFFFFF`; zero disables the window | `base + size` must be within the 32-bit XIP aperture; upper AXI address bits must be zero when `PARA_AXI_ADDR_W > 32` | Range checking and flash address translation |
| `PARA_NUM_CS` | Controller chip-select output count | 1 proposed | 1–16 proposed; CSR draft selection field is 4 bits | Target role has exactly one external target CS input; SoC pads constrain count | Width of `o_spi_cs_n_ctrl` |
| `PARA_FIFO_DEPTH` | Entries in each TX/RX/XIP asynchronous queue | 16 | Power of two, minimum 2; overridable parameter; practical maximum set by implementation memory budget | CDC and latency/burst tolerance (DEC-004/005/010) | Storage, backpressure and area |

| Configuration | Parameter overrides | Features/interfaces | Expected hierarchy | Elaboration/lint/synthesis target |
|---|---|---|---|---|
| CFG-BASE | Defaults from rows above; AXI widths/max burst and controller CS count may be overridden | APB4, AXI4 XIP, shared serial engine, TX/RX buffering | `m_qspi` and submodules in Section 14.2 | Elaborate Standard controller/target, Dual, Quad and QPI; validate each parameter set for address, data, FIFO and CDC constraints |


## 9. Data representation and arithmetic



| Quantity | Width | Encoding / range | Extension / truncation | Overflow / invalid behavior |
|---|---:|---|---|---|
| Standard SPI transfer word | 4–32 bits, selected by software | Unsigned serial bit vector; MSB-first or LSB-first selected by software | No arithmetic extension; word framing follows `qspi_frame.word_len_m1` | Encodings for 4–32 bits are legal; reserved encodings are rejected before a transfer and reported through command status |
| Dual-SPI data beat | 2 serial data lanes | Two bits transferred per SDR sampling edge when selected | Lane group follows selected format; detailed bit-to-lane ordering is an open serial-format decision | Transfers are byte-counted; unused tail bits are not sent beyond `qspi_len.byte_count` |
| Quad-SPI/QPI data beat | 4 serial data lanes | Four bits transferred per SDR sampling edge when selected | Lane group follows selected format; detailed bit-to-lane ordering is an open serial-format decision | Transfers are byte-counted; unused tail bits are not sent beyond `qspi_len.byte_count` |
| AXI XIP address/data | `PARA_AXI_ADDR_W` / `PARA_AXI_DATA_W`; defaults 32/32 | Byte-addressed XIP; flash address is `ARADDR - PARA_XIP_BASE_ADDR`; supported read sizes are byte, halfword and word on a 32-bit bus | `qspi_xip_cfg.addr_bytes` selects 3- or 4-byte flash addresses; each beat is checked against `PARA_XIP_BASE_ADDR` and `PARA_XIP_SIZE_BYTES`; out-of-window beats return SLVERR | FIXED/WRAP, sizes wider than the bus, or disabled/out-of-range accesses return SLVERR per DEC-002 |

## 10. Detailed functional behavior

### 10.1 Modes and state transitions

| Mode/state | Entry condition | Behavior | Exit condition | Outputs / side effects |
|---|---|---|---|---|
| RESET | Reset assertion in each domain | Clear local state and FIFO pointers; discard in-flight IP work; drive controller CS inactive, SCLK to reset CPOL level, IO output enables low, and AXI response VALID low | Reset deassertion synchronized locally by `m_vlsit_rst_sync`; SoC resets requesters with the IP so no accepted request waits for a response across reset | External flash state is not reset by the IP; firmware performs device-specific recovery if required |
| STD_CTRL | Software selects controller role while idle | Generate SCLK/CS and transfer one-lane words with modes 0–3, 4–32-bit word length and selected bit order; divider is `f_ref / (2 x (divisor + 1))` | Transfer complete or abort/error condition | `qspi_cs_cfg` selects CS and setup/hold/inactive delays; active-transfer FIFO error behavior remains to be confirmed |
| STD_TARGET | Software selects target role while idle | Group external CS frames into configured 4–32-bit words; each complete RX word enters a right-justified 32-bit entry; discard a partial tail and set sticky RX error; TX underflow transmits ones and sets sticky TX error because external SCLK cannot be stalled | External CS deassertion ends the frame | CPOL/CPHA modes 0–3 and selected bit order apply; target-SCLK domain crosses through asynchronous FIFOs |
| DUAL_CTRL | Software selects Dual-SPI controller format while idle | Execute 1-1-2 or 1-2-2 command/address/data phases | Serial command/data phase completion | Opcode, address length, dummy cycles and direction are software-configured |
| QUAD_CTRL | Software selects Quad-SPI controller format while idle | Execute 1-1-4 or 1-4-4 command/address/data phases | Serial command/data phase completion | Opcode, address length, dummy cycles and direction are software-configured |
| QPI_CTRL | Software selects QPI 4-4-4 while idle after firmware has placed the flash in QPI state using an indirect command | Send command, address and data over four lanes | Serial command/data phase completion | Firmware controls entry/exit; the IP does not infer or verify external flash QPI state |
| XIP_READ | AXI4 INCR read accepted while XIP is enabled and controller role is selected | CDC request to serial engine; serialize configured opcode/address/mode/dummy/data phases in the selected 1-1-1/dual/quad/QPI format; flash address is `ARADDR - PARA_XIP_BASE_ADDR`; one outstanding burst, default maximum 16 beats | AXI R response accepted; each unsupported or out-of-window beat returns SLVERR without issuing its flash command | Read sizes are byte/halfword/word on the default 32-bit bus; flash internal status is firmware-managed |
| INDIRECT_CMD | Software programs command/address/length/direction and starts through APB4/FIFO path | Execute exactly the configured serial phases, consume TX FIFO or produce RX FIFO bytes as selected; firmware sequences WREN/status/retry commands separately | `done` marks completion of this serial command/data phase | No device-specific busy polling; XIP and indirect arbitration is round-robin, burst is atomic after grant |

### 10.2 Operations


| Operation ID | Inputs / preconditions | Processing semantics | Result / completion | Latency / ordering |
|---|---|---|---|---|
| OP-001 | AXI4 XIP INCR read request while XIP is enabled and controller role is selected | Accept one burst up to `PARA_AXI_MAX_BURST` beats; translate each byte address by subtracting `PARA_XIP_BASE_ADDR`; cross request to `i_clk_serial`; issue configured read phases in the selected serial format and assemble bus-width beats | AXI R beats with matching ID and RLAST; stable under R backpressure; invalid profile or out-of-window beat responds SLVERR without a flash command | Latency depends on SoC clock, divider, opcode, dummy cycles and target flash; no numeric target selected |
| OP-002 | APB4 indirect command whose firmware-selected opcode writes data; TX data supplied through FIFO | Send configured opcode/address and consume the requested number of TX payload bytes; do not issue implicit WREN or poll status | `done` indicates serial data phase ended; this does not imply flash program completion | Firmware issues separate WREN/status/retry commands according to device datasheet |
| OP-003 | APB4 indirect command whose opcode performs an erase; address and opcode programmed in CSR | Send only configured opcode/address phases; do not wait for flash internal erase completion | `done` indicates command phase ended; firmware polls device status with a separate indirect read | Erase granularity, timeout and retry are firmware/device policy |
| OP-004 | Standard SPI controller transaction configured while engine idle | Snapshot role/format/timing/command settings at acceptance; shift the configured byte count over one data lane using selected CPOL/CPHA and bit order; TX/RX use 32-bit little-endian FIFO entries; `qspi_cs_cfg` controls CS select/setup/hold/inactive delays. CSR writes while busy stage values for later commands; `start` while busy is ignored and sets `fl_err`. | RX data and `done` at normal serial command/data phase completion; on TX underflow or RX overflow, finish the current byte, deassert CS after configured hold time, set the matching sticky error, and do not set `done` | First TX byte is `[7:0]`; first RX byte is placed in `[7:0]`; each byte uses the configured serial MSB/LSB order |
| OP-005 | Standard SPI target transaction selected while engine idle; external CS/SCLK received | Group sampled bits into configured words; write each complete RX word to a right-justified 32-bit FIFO entry; discard an incomplete final word with sticky RX error; on TX underflow, transmit ones and set sticky TX error | RX data / target frame completion | Target SCLK is asynchronous; output response cannot stall the external clock |
| OP-006 | Dual/Quad/QPI controller transaction selected while engine idle | Send configured command/address/dummy/data phases in 1-1-2, 1-2-2, 1-1-4, 1-4-4 or QPI 4-4-4 format | RX data / command-phase completion | Firmware configures device-specific opcodes and QPI state; detailed multi-lane bit ordering remains open |

### 10.3 Cycle-level behavior

**User-approved waveform plan (2026-11-02).** The approved 14-case set covers XIP, indirect command phases, Standard SPI controller/target, multi-lane formats, FIFO errors, arbitration, APB/AXI errors and reset. The referenced WaveJSON/SVG figures will be reconciled to the latest decisions before RTL generation. A figure is illustrative and does not approve any behavior explicitly marked pending below.

| Waveform ID | Function / operation | Scenario (success / error / corner) | Signals shown | Figure | Confirmed by user |
|---|---|---|---|---|---|
| WF-001 | AXI XIP read | Successful burst with R-channel backpressure | AR/R channels, XIP request/response CDC, serial phases | [`qspi_wf_001.svg`](../../figures/waveforms/qspi_wf_001.svg) | Yes; one outstanding burst |
| WF-002 | AXI XIP read | Unsupported profile/size; SLVERR and no flash command | AR/R channels, error response, serial pins idle | [`qspi_wf_002.svg`](../../figures/waveforms/qspi_wf_002.svg) | Yes; SLVERR on each rejected beat |
| WF-003 | Indirect command | APB setup and TX FIFO payload for a program-data phase | APB, TX FIFO, command engine, serial pins, `done` | [`qspi_wf_003.svg`](../../figures/waveforms/qspi_wf_003.svg) | Yes; `done` only ends serial phase |
| WF-004 | Indirect command | Erase command phase followed by a separate firmware status-read command | APB, serial commands, `done`, firmware-issued status poll | [`qspi_wf_004.svg`](../../figures/waveforms/qspi_wf_004.svg) | Yes; IP does not poll flash busy |
| WF-005 | Standard SPI controller | CPOL=0/CPHA=0, 8-bit MSB-first transfer | SCLK, CS, IO0/IO1, TX/RX word | [`qspi_wf_005.svg`](../../figures/waveforms/qspi_wf_005.svg) | Yes; illustrative bit profile |
| WF-006 | Configuration while active | Role/configuration write during an active frame | APB, engine busy, active role, CS/SCLK | [`qspi_wf_006.svg`](../../figures/waveforms/qspi_wf_006.svg) | Scenario approved; exact write handling pending |
| WF-007 | Standard SPI target | External-controller frame and asynchronous target SCLK | Target SCLK/CS, IO0/IO1, RX/TX FIFOs | [`qspi_wf_007.svg`](../../figures/waveforms/qspi_wf_007.svg) | Yes; target partial-word/underflow policy confirmed |
| WF-008 | Dual/Quad controller | 1-1-2, 1-2-2, 1-1-4 and 1-4-4 phase lane selection | SCLK, CS, IO[3:0], phase format | [`qspi_wf_008.svg`](../../figures/waveforms/qspi_wf_008.svg) | Yes; lane bit ordering still pending |
| WF-009 | QPI entry | Firmware issues indirect entry command before selecting 4-4-4 | APB command, serial lanes, mode selection | [`qspi_wf_009.svg`](../../figures/waveforms/qspi_wf_009.svg) | Yes; opcode is firmware/device-specific |
| WF-010 | QPI exit | Firmware issues indirect exit/reset command before selecting another format | APB command, serial lanes, mode selection | [`qspi_wf_010.svg`](../../figures/waveforms/qspi_wf_010.svg) | Yes; no automatic QPI state tracking |
| WF-011 | APB FIFO window | TX-full write and RX-empty read return PSLVERR without pointer movement | APB, FIFO full/empty, push/pop | [`qspi_wf_011.svg`](../../figures/waveforms/qspi_wf_011.svg) | Yes; APB byte policy pending |
| WF-012 | AXI write to XIP | BRESP=SLVERR; no flash-side write activity | AW/W/B channels, serial pins idle | [`qspi_wf_012.svg`](../../figures/waveforms/qspi_wf_012.svg) | Yes |
| WF-013 | Arbitration | Simultaneous XIP and indirect request, round-robin owner grant | Request/ack, arbiter, serial engine, responses | [`qspi_wf_013.svg`](../../figures/waveforms/qspi_wf_013.svg) | Yes; one granted XIP burst is atomic |
| WF-014 | Reset in flight | Reset during active serial transaction | Reset domains, CS/SCLK, AXI/APB pending responses | [`qspi_wf_014.svg`](../../figures/waveforms/qspi_wf_014.svg) | Scenario approved; reset recovery policy pending |
| WF-001 | OP-001: XIP flash read | Success with R-channel backpressure | ARVALID/ARREADY, ARADDR, RVALID/RREADY, RDATA, RRESP, RLAST, flash IO[3:0], SCLK, CS_n | [SVG](../../figures/waveforms/qspi_wf_001.svg) / [WaveJSON](../../figures/waveforms/qspi_wf_001.json) | Approved 2026-11-02 |
| WF-002 | OP-001: XIP flash read | Unsupported burst/size/address error | ARVALID/ARREADY, ARADDR, ARLEN, ARSIZE, RVALID/RREADY, RRESP, RLAST | [SVG](../../figures/waveforms/qspi_wf_002.svg) / [WaveJSON](../../figures/waveforms/qspi_wf_002.json) | Approved 2026-11-02 |
| WF-003 | OP-002: indirect flash program | Success, command/address/data phases | APB4 control, FIFO write, engine busy/done, flash IO[3:0], SCLK, CS_n | [SVG](../../figures/waveforms/qspi_wf_003.svg) / [WaveJSON](../../figures/waveforms/qspi_wf_003.json) | Approved 2026-11-02 |
| WF-004 | OP-003: indirect flash erase | Success and flash-busy completion | APB4 control/status, flash command/status phases, SCLK, CS_n, IRQ if selected | [SVG](../../figures/waveforms/qspi_wf_004.svg) / [WaveJSON](../../figures/waveforms/qspi_wf_004.json) | Approved 2026-11-02 |
| WF-005 | OP-004: Standard SPI controller | Success, CPOL/CPHA mode 0 and one representative word format | APB4 setup, SCLK, CS_n, IO0 input/output/enable, TX/RX data, done | [SVG](../../figures/waveforms/qspi_wf_005.svg) / [WaveJSON](../../figures/waveforms/qspi_wf_005.json) | Approved 2026-11-02 |
| WF-006 | OP-004: Standard SPI controller | Error or rejected reconfiguration while busy | APB4 control/status, busy, mode/role configuration, SCLK, CS_n | [SVG](../../figures/waveforms/qspi_wf_006.svg) / [WaveJSON](../../figures/waveforms/qspi_wf_006.json) | Approved 2026-11-02 |
| WF-007 | OP-005: Standard SPI target | Success with external controller and one CPOL/CPHA profile | External SCLK/CS_n, IO0 input/output/enable, target clock-domain signals, RX/TX status | [SVG](../../figures/waveforms/qspi_wf_007.svg) / [WaveJSON](../../figures/waveforms/qspi_wf_007.json) | Approved 2026-11-02 |
| WF-008 | OP-006: Dual/Quad controller formats | Success for 1-1-2, 1-2-2, 1-1-4 and 1-4-4 phase transitions | Command/address/data phase, IO[3:0], output enables, SCLK, CS_n | [SVG](../../figures/waveforms/qspi_wf_008.svg) / [WaveJSON](../../figures/waveforms/qspi_wf_008.json) | Approved 2026-11-02 |
| WF-009 | OP-006: QPI controller format | Firmware enters QPI through indirect command, then 4-4-4 transfer | APB4 command path, mode selection, IO[3:0], output enables, SCLK, CS_n | [SVG](../../figures/waveforms/qspi_wf_009.svg) / [WaveJSON](../../figures/waveforms/qspi_wf_009.json) | Approved 2026-11-02 |
| WF-010 | OP-006: QPI controller format | Firmware exits QPI and restores selected non-QPI format | APB4 command path, mode selection, IO[3:0], output enables, SCLK, CS_n | [SVG](../../figures/waveforms/qspi_wf_010.svg) / [WaveJSON](../../figures/waveforms/qspi_wf_010.json) | Approved 2026-11-02 |
| WF-011 | APB4 CSR/FIFO interface | Successful access and FIFO full/empty error | PSEL, PENABLE, PREADY, PADDR, PWRITE, PSTRB, PWDATA, PRDATA, PSLVERR, FIFO status | [SVG](../../figures/waveforms/qspi_wf_011.svg) / [WaveJSON](../../figures/waveforms/qspi_wf_011.json) | Approved 2026-11-02 |
| WF-012 | AXI4 write to read-only XIP region | Unsupported write response with no flash side effect | AWVALID/AWREADY, WVALID/WREADY, BVALID/BREADY, BRESP, flash SCLK/CS_n | [SVG](../../figures/waveforms/qspi_wf_012.svg) / [WaveJSON](../../figures/waveforms/qspi_wf_012.json) | Approved 2026-11-02 |
| WF-013 | Shared engine arbitration | Simultaneous XIP and indirect request; selected priority/serialization | AXI AR/R, APB command, engine request/owner, flash SCLK/CS_n | [SVG](../../figures/waveforms/qspi_wf_013.svg) / [WaveJSON](../../figures/waveforms/qspi_wf_013.json) | Approved 2026-11-02 |
| WF-014 | Reset and role safety | Reset during active transfer; pads enter safe idle; request/response reset behavior | reset inputs, APB/AXI valid/ready, busy, CS_n, SCLK, IO output enables | [SVG](../../figures/waveforms/qspi_wf_014.svg) / [WaveJSON](../../figures/waveforms/qspi_wf_014.json) | Approved 2026-11-02 |

Use timing diagrams/cycle tables where prose can be ambiguous; state active edge and when values are sampled/observed. A cycle-level narrative will be added for each approved waveform after the interface timing choices are resolved.

| Cycle / event | Input condition | State/action | Output condition |
|---|---|---|---|
| Per approved waveform | Defined by the user-approved waveform scenario and resolved interface profile | State/event sequence will be documented with the rendered waveform | Outputs are evaluated against the requirement and selected protocol profile |

### 10.4 Arbitration, buffering, and throughput

One serial engine performs only one serial transfer at a time. AXI XIP requests cross from `i_clk_axi` to `i_clk_serial`; APB indirect commands cross from `i_clk_apb`; the engine arbitrates XIP and indirect requests round-robin when idle, with one XIP burst outstanding and served atomically once granted. Firmware must avoid issuing XIP reads when the attached flash is internally busy or otherwise unavailable; the IP does not poll flash status or gate XIP based on vendor-specific busy state. Target role excludes controller operations while active. TX/RX FIFOs are dual-clock where needed; depth and APB byte-strobe behavior remain as recorded in DEC-010. No numeric throughput or latency target was supplied (DEC-005).

### 10.5 Memories and storage

| Storage ID | Kind | Depth × width | Ports | Read latency | Write mask | Reset/init | ECC/parity | Implementation |
|---|---|---|---|---|---|---|---|---|
| MEM-001 | APB/serial transmit FIFO | `PARA_FIFO_DEPTH` × 32 bits; default depth 16, power-of-two and minimum 2 | APB write and serial engine read; dual clock where required | Asynchronous FIFO read latency per `m_vlsit_afifo_top` | None; APB FIFO window accepts full-word writes | Reset FIFO pointers; payload contents invalid after reset | No ECC/parity requirement selected | Reuse `m_vlsit_afifo_top`; macro selection remains an implementation parameter |
| MEM-002 | APB/serial receive FIFO | `PARA_FIFO_DEPTH` × 32 bits; default depth 16, power-of-two and minimum 2 | Serial engine write and APB read; dual clock where required | Asynchronous FIFO read latency per `m_vlsit_afifo_top` | None | Reset FIFO pointers; payload contents invalid after reset | No ECC/parity requirement selected | Reuse `m_vlsit_afifo_top`; macro selection remains an implementation parameter |
| MEM-003 | AXI XIP request/response queues | Parameterized width/depth; one outstanding burst, up to `PARA_AXI_MAX_BURST` beats | AXI XIP adapter to/from serial engine across `i_clk_axi` and `i_clk_serial` | Asynchronous FIFO/mailbox latency; AXI backpressure holds response | No write mask; read-only response data | Reset clears queue pointers and discards in-flight work; requester reset coordination is required | No ECC/parity requirement selected | Reuse `m_vlsit_afifo_top` for queue crossings |

Define FIFO full/empty semantics, simultaneous push/pop behavior, data-valid rules, pointer reset, cross-clock implementation and storage inference/macro constraints after the application and clock profile are selected. No data contents are reset; only queue validity/pointers reset. The XIP response buffer's ordering and reset handling are open in DEC-002/DEC-004.

## 11. Register and programming model


### 11.1 CSR specification source


| Item | Specification |
|---|---|
| CSR workbook file | [`qspi_CSR_Specification_RTL.xlsx`](../../qspi_CSR_Specification_RTL.xlsx) beside this specification |
| Sheet used for this IP | `CSR` |
| Workbook revision / date | RTL working copy; `fl_err` description aligned to the user-confirmed flash-agnostic behavior |
| CSR generator | APB-CSR-Generator v1.2; repository: [APB-CSR-Generator](https://github.com/nguyenquanicd/APB-CSR-Generator) |
| CSR module name | `m_vlsit_csr_qspi` (planned generated CSR module) |
| Register prefix | `qspi`, selected by user |
| Asynchronous | `0`: generated CSR bank is synchronous to APB; bus-to-engine CDC is outside the generated CSR logic |
| APB clock and register clock | `i_clk_apb` clocks both APB4 and the generated CSR bank; the serial engine is a separate `i_clk_serial` domain |
| Source of `i_protect_en` and `i_slverr_en` | Constant tie-offs: `i_protect_en=0`, `i_slverr_en=1` |

Workbook requirements:

- Register names use the selected `qspi_` prefix and stay within the CSR-generator name limit. The workbook is authoritative for register/field definitions, reset values and access behavior.
- Generated CSRs are separate from custom FIFO data accesses because the generator does not implement FIFO enqueue/dequeue side effects.
- Custom APB byte offsets are TX FIFO push `0x1000` and RX FIFO pop `0x1004`; FIFO writes require all four PSTRB bits, TX-full writes and RX-empty reads return PSLVERR without moving pointers.
- FIFO byte order is little-endian: TX sends `[7:0]` first and RX stores the first byte in `[7:0]`; each byte's serial bit order follows the selected Standard SPI MSB/LSB setting.

### 11.2 Software sequences

Software uses the names from the CSR workbook. Startup loads the chosen flash profile before enabling XIP; indirect program/erase uses the FIFO windows and command controls; role changes are requested only when the shared engine is idle. Firmware enters/exits QPI through indirect commands before selecting 4-4-4 framing. Detailed command sequences depend on the selected flash part.

### 11.3 CSR connection to the design


| Workbook register.field group | Direction at the CSR | Design signal | Clock domain of the signal | Behavior notes |
|---|---|---|---|---|
| Controller/target configuration | CSR to engine | Role, CPOL/CPHA, word frame, lane format, divider and selected CS | APB to serial engine by CDC | Snapshot at operation acceptance; CSR writes while busy apply only to later operations; target/controller clock selection changes only while idle |
| XIP profile configuration | CSR to XIP adapter/engine | Enable, opcode, address-byte count, format, dummy cycles and optional mode value | APB to AXI/serial domains by CDC | Firmware configures before enabling XIP; field definitions are authoritative in workbook |
| Indirect command configuration | CSR to indirect sequencer | Opcode, format, address-byte count, dummy cycles, direction, start, address and byte count | APB to serial engine by CDC | Command executes only when controller role owns the engine |
| Status and interrupt state | Engine to CSR / CSR to interrupt output | Busy, FIFO state, completion/error causes, enable and W1C clear state | Engine/target to APB by CDC | `fl_err` means an IP-detected invalid command configuration or unsupported phase profile; it does not report flash-internal status |
| FIFO data window | APB to TX FIFO; RX FIFO to APB | TX push at `0x1000`; RX pop at `0x1004` | APB/serial crossings use dual-clock FIFO | FIFO windows are custom APB logic, not generated CSRs; 32-bit little-endian entries |


### 11.4 APB access behavior of the CSR


| Case | Behavior |
|---|---|
| Normal CSR read or write | Generated CSR baseline, synchronous to `i_clk_apb`; PREADY/PSLVERR behavior follows the generated workbook configuration |
| Write with PSTRB not all ones | Return PSLVERR; do not update CSR or enqueue FIFO data |
| Address not word aligned | Return PSLVERR |
| Aligned unmapped CSR offset in `0x0000–0x0FFF` | Read returns zero; write is ignored |
| Address outside CSR `0x0000–0x0FFF` and FIFO `0x1000`/`0x1004` windows | Return PSLVERR |
| `PPROT` attributes | Ignored; `i_protect_en=0` |
| FIFO TX push / RX pop | TX write enqueues one 32-bit word if not full; RX read dequeues one word if not empty; full/empty returns PSLVERR and does not move pointers |
| Reset | CSR reset values follow the workbook; local state/FIFO pointers clear and in-flight work is discarded; SoC resets requesters with the IP |

## 12. Error handling and recovery

| Error ID | Detection condition | Observable response/status | Interrupt | Clear/recovery | Reset behavior |
|---|---|---|---|---|---|
| ERR-001 | Unsupported or malformed APB CSR access | APB PSLVERR follows selected generated-CSR settings; confirm in DEC-009 | Candidate APB error cause; DEC-006 | Software corrects address/access and clears sticky cause | CSR state resets per workbook; FIFO contents invalid |
| ERR-002 | AXI write access to the read-only XIP region | Complete with BRESP=SLVERR and no flash-side effect | Candidate error cause; DEC-006 | No flash operation is launched | AXI-side pending state follows reset protocol and DEC-004 |
| ERR-003 | FIXED/WRAP burst, unsupported size, disabled XIP, or beat address outside `[PARA_XIP_BASE_ADDR, PARA_XIP_BASE_ADDR + PARA_XIP_SIZE_BYTES)` | Return RRESP=SLVERR for each rejected beat; do not issue a flash command for that beat | No dedicated interrupt cause; `fl_err` is reserved for locally detected command/configuration profile errors | Software/interconnect corrects the address/profile; the IP does not retry | Reset clears pending AXI state and discards in-flight work |
| ERR-004 | TX FIFO underflow or RX FIFO overflow during a controller operation; target FIFO loss; invalid FIFO-window access | Controller operation finishes its current byte, applies CS hold, deasserts CS and aborts without `done`; sticky `tx_err`/`rx_err` reports loss. Target TX underflow transmits ones; target partial RX word is discarded. APB full/empty accesses return PSLVERR without pointer movement. | Sticky TX/RX error events; level interrupt follows `qspi_irq_en` | Software checks status, refills/drains the FIFO, clears raw event with W1C, then restarts the command | Reset clears FIFO pointers and sticky causes; contents are invalid |
| ERR-005 | External flash reports busy, rejects an opcode, or fails a program/erase operation | Not detected or interpreted by this flash-agnostic IP; indirect `done` only reports completion of the serial command/data phase | No IP interrupt is generated for flash-internal status | Firmware reads the device status with an indirect command and applies device-specific timeout/retry/recovery policy | Flash state and recovery are firmware/device responsibilities |
| ERR-006 | `start` written while busy, or an invalid/reserved mode/format used at command acceptance | Busy operation continues from its latched configuration; new start is ignored. Invalid operation starts without asserting CS or toggling SCLK. Both set sticky `fl_err`; APB write completes without PSLVERR. | `fl_err` contributes to `o_int_qspi` when enabled | Software waits for idle, selects a legal configuration, then starts again; clear `fl_err` by W1C | Reset clears local busy/config snapshot state; external flash mode is unchanged |

## 13. Performance, power, and area


| Metric ID | Metric | Target / limit | Conditions | Measurement method | Hard / goal |
|---|---|---|---|---|---|
| PPA-001 | Maximum AXI/APB/core frequency and maximum generated SCLK | TBD; application and external flash profile required (DEC-005) | Process, voltage, temperature and configuration TBD | STA with named SDC constraints | TBD |
| PPA-002 | Standard-cell area | TBD; target library and FIFO sizes required (DEC-005, DEC-010) | Library, utilization and configuration TBD | Synthesis/placed cell area | TBD |
| PPA-003 | Dynamic and leakage power | TBD; activity, voltage and corner required (DEC-005) | Activity and corner TBD | Power analysis with documented vector/estimation method | TBD |
| PERF-001 | XIP first-beat latency, sustained read bandwidth, program/erase service and target-mode rate | TBD; application values required in Section 1.4/DEC-005 | AXI/flash traffic, SCLK and dummy cycles TBD | Simulation with flash model plus analytical lane-rate bound | TBD |


## 14. RTL implementation contract

### 14.1 Required coding baseline

The VLSIT RTL Design Rules v2 in VLSIT_RTL_Design_Rule.md (same folder as this template) is the mandatory RTL coding authority. Specifications and RTL deliverables shall comply with it; do not add project-local RTL exceptions.

At minimum: use one synthesizable module per .sv file with matching module/filename; keep each top a structural wrapper containing the interface, parameters, interconnect declarations, and named submodule instances only; use ANSI ports with input wire and output logic; end every active-low non-reset signal name in _n; use unsigned four-state logic vectors; and keep SVA/testbench/UVM code outside synthesis RTL. Use always_comb or continuous assignments for combinational logic, with defaults and explicit case defaults, and always_ff for state with one clock per process and separate next-state logic.

Declare overridable parameters as `parameter logic [31:0] PARA_PARAMETER_NAME` and derived values as `localparam logic [31:0] LPARA_DERIVED_NAME` after the overridable parameters, following REF-003. Use dedicated reset-synchronizer and CDC modules; reset release is synchronous to each receiving domain. Test reset override/mux logic belongs in a wrapper/reset controller, not a functional leaf. CDC source values are registered with no combinational logic before the first synchronizer stage or between stages.

Use statically bounded, zero-based generate loops and declare genvar in the generate-for header. Use named port and parameter connections. Prefer clock enables; any ICG must use an approved dedicated module with a scan test-enable. Do not use signed/two-state hardware types, packages/imports, interfaces, RTL macros, initial blocks, simulation delays, casex, plain always, latches, multiple drivers, positional/wildcard connections, or unsupported constructs. Each RTL file header shall identify the project, human RTL owner, AI flow, design page, date, and description. Indent with spaces only, do not use the default_nettype directive (lint/elaboration checking finds undeclared identifiers), comment each logic section, and keep RTL comment lines at or below 100 characters. REF-003 is the detailed authority.
### 14.2 RTL hierarchy

| Module | Responsibility | Parent / instance | Clock/reset domains | Interface |
|---|---|---|---|---|
| m_qspi | Structural top and protocol integration | Top | APB, AXI, serial-engine, target-SCLK and reset domains | APB4, AXI4, SPI pins, clocks/resets and IRQ |
| m_qspi_apb_decode | APB address decode, response mux and custom TX/RX FIFO data-window access | m_qspi/u_apb_decode | `i_clk_apb` / `i_rst_n_apb` | APB4, CSR/FIFO requests |
| m_vlsit_csr_qspi | Generated control/status CSR register set | m_qspi/u_csr | `i_clk_apb` / `i_rst_n_apb` | APB4 and generated field ports |
| m_qspi_axi_xip | AXI4 XIP subordinate, burst tracking and read-response assembly | m_qspi/u_axi_xip | `i_clk_axi` / `i_rst_n_axi` | AXI4 subordinate, async request/response CDC |
| m_qspi_indirect | APB-configured flash read/program/erase sequencer | m_qspi/u_indirect | APB control and `i_clk_serial` execution domains | CSR/FIFO commands, engine request/response |
| m_qspi_arbiter | Serial-engine request arbitration and ownership | m_qspi/u_arbiter | `i_clk_serial` / `i_rst_n_serial` | XIP/indirect requests, role grant |
| m_qspi_serial_engine | Shared controller/target shift datapath and phase control | m_qspi/u_serial_engine | `i_clk_serial` or target SCLK selected while idle | Work request/response and serial data lanes |
| m_qspi_clk_mux | Glitch-free selection between controller clock and external target SCLK | m_qspi/u_clk_mux | Clock-control cell; reset/selection changes while idle | `i_clk_serial`, target SCLK, engine clock |
| m_qspi_pin_mux | Role/phase-controlled SCLK, CS and IO lane direction | m_qspi/u_pin_mux | Selected serial timing domain | QSPI external pins and output enables |
| m_qspi_tx_fifo | Buffer APB program data for serial transmission | m_qspi/u_tx_fifo | APB and selected serial domains | APB FIFO window and serial engine |
| m_qspi_rx_fifo | Buffer serial receive data for APB software reads | m_qspi/u_rx_fifo | Selected serial domain and APB | Serial engine and APB FIFO window |
| m_qspi_cdc | Request/response and status crossings between APB, AXI, serial and target domains | m_qspi/u_cdc | Multiple asynchronous clock/reset domains | CDC handshakes and event/status synchronization |
| m_qspi_reset_sync | Reset-release synchronization for each receiving clock domain | m_qspi/u_reset_sync | APB, AXI, serial and target SCLK domains | Local reset outputs |

Identify structural top, state owners, and placement of protocol adapters, decode, arithmetic, and register logic. Keep functional logic in child modules.

### 14.3 Synthesis assumptions

| Item | Value / source |
|---|---|
| Top / source file list | Top module `m_qspi`; RTL source list not applicable to this design specification and will be defined for RTL generation |
| Frontend version and options | SystemVerilog IEEE 1800-2017; local Slang and Verilator used for syntax/lint evidence; SoC signoff frontend may differ |
| Parameters/configuration | AXI address/data/ID widths and maximum XIP burst are parameters with user-selected defaults; controller CS count is parameterized; legal values are checked at elaboration |
| Libraries/corners | No library-specific RTL constructs; target PDK/library/PVT/RC constraints are supplied by SoC integration |
| Memory flow | TX/RX FIFO uses `m_vlsit_afifo_top`; inferred versus macro storage is selected by its parameter and target synthesis flow |
| Lint rule configuration | VLSIT RTL Design Rules v2 (REF-003), `vlsit_rtl_check.py`; tool/version recorded with generated reports |

## 15. Verification specification

### 15.1 Scope and strategy

Verification shall use protocol-aware block simulation with APB4, AXI4, Standard SPI, Dual-SPI, Quad-SPI and NOR-flash BFMs. Directed tests cover each requirement and configuration; constrained-random traffic stresses channel independence, backpressure, command overlap and error recovery. Assertions check bus stability/handshakes and shared-engine exclusivity. Formal checks are planned for local handshake/state invariants. CDC/RDC, lint, elaboration and synthesis checks are required before integration; emulation and silicon validation depend on the SoC project. Seed/reproducibility policy and exact tool versions are TBD under DEC-007.


### 15.2 Requirement-based test plan

| Test ID | Requirements | Scenario / stimulus | Expected result | Test type | Configuration |
|---|---|---|---|---|---|
| TEST-001 | REQ-IF-002, REQ-FUNC-001 | Read XIP image through AXI4, including RREADY stalls | Correct flash bytes, stable R payload while stalled, ordered response and correct RLAST | Directed + protocol assertions | XIP configurations |
| TEST-002 | REQ-IF-002, REQ-FUNC-001 | Unsupported XIP burst/size/address and target-role access | Selected AXI error response; no spurious flash transaction | Directed + assertions | XIP configurations |
| TEST-003 | REQ-IF-003, REQ-FUNC-002 | Program flash through APB command and TX data path | Selected flash model stores requested payload and completion/error status is correct | Directed | Controller configurations |
| TEST-004 | REQ-IF-003, REQ-FUNC-002 | Erase selected flash sector/block through APB path | Flash model reflects erase and busy/completion handling matches selected profile | Directed | Controller configurations |
| TEST-005 | REQ-MODE-001, REQ-MODE-006, REQ-MODE-007 | Standard SPI controller across modes 0–3, 4–32-bit limits and both bit orders | Serial edges, word framing and captured/transmitted bit order match configuration | Directed + constrained random | CFG-STD-CTRL |
| TEST-006 | REQ-MODE-002, REQ-MODE-006, REQ-MODE-007 | Standard SPI target with external controller BFM | Correct target sampling/driving for modes 0–3, word sizes and both bit orders | Directed + constrained random | CFG-STD-TGT |
| TEST-007 | REQ-MODE-003, REQ-MODE-004, REQ-MODE-005 | Exercise 1-1-2, 1-2-2, 1-1-4, 1-4-4 and QPI 4-4-4 | Lane count, phase changes and output enables match selected format | Directed with flash BFM | CFG-DUAL-CTRL, CFG-QUAD-CTRL, CFG-QPI-CTRL |
| TEST-008 | REQ-ARCH-001, REQ-ARCH-002, REQ-MODE-005 | Role change while idle and busy; attempt controller/target overlap | One shared engine only; illegal role change does not corrupt an active operation | Directed + structural review | All configurations |
| TEST-009 | REQ-IF-001 | APB4 CSR normal, malformed, partial-strobe and unmapped transactions | PREADY/PSLVERR and state updates match selected generator profile | Directed + APB assertions | All configurations |
| TEST-010 | REQ-IF-003 | TX/RX FIFO boundary, empty/full, simultaneous transfer and reset | No data duplication/loss; flags and errors follow approved FIFO policy | Directed + constrained random | Controller/target configurations |
| TEST-011 | REQ-ARCH-003 | Concurrent AXI XIP and APB indirect requests; target role selected | Requests serialize per approved policy; no controller transfer occurs in target role | Directed + constrained random | All configurations |
| TEST-012 | REQ-IF-004 | AXI write to read-only XIP window | Completed BRESP=SLVERR; flash pins show no program/erase side effect | Directed + AXI assertions | XIP configurations |


### 15.3 Assertions and coverage


| Property / coverage ID | Intent | Requirements | Checker / source set | Acceptance criterion |
|---|---|---|---|---|
| SVA-001 | AXI VALID and payload remain stable until READY; no response without an accepted request | REQ-IF-002 | AXI protocol checker and local SVA | No assertion failures across directed/random AXI tests |
| SVA-002 | Controller and target never own the serial engine/pads simultaneously | REQ-ARCH-001, REQ-ARCH-002 | Serial-engine ownership assertions | Mutual-exclusion assertion holds in all configurations |
| SVA-003 | SPI output lane enables match the selected phase width; unused lanes are not driven | REQ-MODE-003, REQ-MODE-004, REQ-MODE-005 | Serial pin-mux assertions | All legal phase/mode crosses covered; no illegal drive |
| COV-001 | Cross role, lane format, CPOL/CPHA, word length and bit order | REQ-MODE-001 through REQ-MODE-007 | Functional coverage model | Every legal configured cross covered or excluded with rationale |
| COV-002 | AXI backpressure, APB errors, FIFO full/empty and overlapping requests | REQ-IF-001 through REQ-IF-003, REQ-ARCH-003 | Functional coverage model | Success/error and stall bins hit for each enabled interface |

### 15.4 Formal, CDC, and RDC

| Analysis | Scope | Assumptions / constraints | Evaluation method |
|---|---|---|---|
| Formal | AXI/APB handshakes, response ordering, engine ownership and FIFO pointer safety | Protocol-compliant requesters; implementation assumptions tied to selected bus profile | Property proof with bounded/unbounded methods selected by the SoC verification flow |
| CDC / RDC | Every APB/AXI/serial/target clock crossing and every reset release path | Clock/reset relationships from DEC-004; no unmodeled asynchronous crossing | CDC/RDC tool reports reviewed and waived only with documented structural evidence |

## 16. DFT and testability

DFT insertion, scan clocks, test controls and test-mode priority are owned by the SoC DFT flow; the IP exposes no dedicated test port in this baseline. Any test-enable or scan-control port requirement is TBD under DEC-007 before RTL freeze.

| Topic | Requirement / decision |
|---|---|
| Scan architecture and scan eligibility | TBD; SoC DFT owner selects scan methodology and eligible registers (DEC-007) |
| Scan/test clocks, controls, reset behavior | TBD; align with SoC test-clock and reset strategy (DEC-007) |
| Test-mode entry/exit and safe state | TBD; serial outputs must enter safe inactive state during test mode |
| MBIST, memory repair, LBIST | No memory macro, repair, or LBIST block is selected for the current RTL baseline; reassess if macros or a safety requirement is selected |
| Test access, wrappers, test points | TBD; SoC DFT flow owns wrapper and access mechanism |
| Clock-gating test enable | TBD; use approved SoC ICG cell only if clock gating is introduced |
| ATPG constraints and exclusions | TBD in the SoC DFT constraints package (DEC-007) |
| DFT insertion architecture and generated test artifacts | Owned by the SoC DFT flow; version and deliverables TBD (DEC-007) |


## 17. Physical design and timing integration

### 17.1 Timing constraints and budgets


#### 17.1.1 Clock and analysis scenarios


| Clock ID | Port / source object | Primary/generated and master | Period, waveform, phase / ratio | Latency / uncertainty / transition | Clock group / mode | Constraint source |
|---|---|---|---|---|---|---|
| CLK-APB | `i_clk_apb` | Primary; external SoC source | Period/duty cycle TBD (DEC-005) | Source latency, uncertainty and transition supplied by SoC | Asynchronous group to AXI/serial/target clocks | SoC SDC plus IP integration constraints |
| CLK-AXI | `i_clk_axi` | Primary; external SoC source | Period/duty cycle TBD (DEC-005) | Source latency, uncertainty and transition supplied by SoC | Separate asynchronous clock group from serial engine | SoC SDC plus CDC constraints |
| CLK-SERIAL | `i_clk_serial` | Primary; external SoC source | Period/duty cycle TBD (DEC-005) | Source latency, uncertainty and transition supplied by SoC | Separate asynchronous clock group from APB/AXI; selected against target SCLK only while idle | SoC SDC plus CDC constraints |
| CLK-TARGET | `i_spi_sclk_tgt` | External target-provided clock | Frequency/duty/phase bounds TBD (DEC-003/005) | External controller timing and IO delay constraints | Asynchronous clock group; external pin clock, active in target mode | SoC SDC plus target timing constraints |
| CLK-SCLK | `o_spi_sclk_ctrl`, generated by serial divider | Generated from `i_clk_serial` | Divider ratio, duty cycle and maximum rate TBD (DEC-003/005) | Output transition/load and flash timing from selected device | Inactive in target role; target role uses external SCLK | IP SDC and selected flash datasheet timing |

#### 17.1.2 Interface timing budgets


| Interface / port group | Direction | Reference clock | External min / max delay | Input transition / output load | IP timing budget | Mode / condition | Constraint source |
|---|---|---|---|---|---|---|---|
| APB4 pins | Input/output | `i_clk_apb` | SoC supplies min/max delay and input transition/output load | Budget partition TBD (DEC-007) | All APB transactions | SoC SDC |
| AXI4 XIP pins | Input/output | `i_clk_axi` | SoC supplies min/max delay and input transition/output load | Budget partition TBD (DEC-007) | XIP configuration | SoC SDC |
| Serial-engine control/CDC | Input/output | `i_clk_serial` and CDC source domains | CDC constraints and synchronizer MTBF targets supplied by integration | CDC paths reviewed per crossing inventory | Request/response crossings | SoC CDC/SDC package |
| SPI controller pins | Output/input | Generated SCLK plus selected sampling edge | External flash setup/hold and output load from selected flash datasheet | Budget derived from target device and package | Controller configurations | IP SDC plus flash datasheet |
| SPI target pins | Input/output | External SCLK/CS and selected CPOL/CPHA | External controller timing and input transition/output load TBD (DEC-003/007) | Target-mode capture budget TBD | CFG-STD-TGT | SoC integration SDC |


#### 17.1.3 Timing exception inventory


| Exception ID | Type / SDC command | From | Through | To | Value and setup/hold/min/max meaning | Mode / condition | Technical rationale |
|---|---|---|---|---|---|---|---|
| EXC-001 | No exception approved at architecture-spec stage | No endpoints selected | N/A: no through-point selected | No endpoints selected | TBD after clock/CDC topology and STA flow are known | Applicable mode TBD | Do not add broad exceptions; each exception needs CDC or cycle-level rationale and review (DEC-004/007) |




No executable SDC is issued by this architecture specification. SDC objects and numeric delays depend on final port names, clocks, the flash datasheet and SoC timing budgets; create them during implementation integration and review all exceptions against CDC/RDC analysis.

### 17.2 Physical assumptions

| Topic | Requirement / assumption |
|---|---|
| Hard/memory macros and views | FIFO macro versus standard-cell implementation TBD (DEC-007/010); no other hard macro is specified |
| Floorplan, placement region, pin placement | SoC integration owns floorplan and pad placement (DEC-007) |
| Utilization/congestion target | SoC implementation target TBD (DEC-007) |
| Power intent, clock/reset trees | SoC owns UPF/CPF and CTS; IP reset/clock contract follows DEC-004/007 |
| High-fanout controls, physical-only cells | Implementer handles buffering and physical-only cells per SoC flow |
| ECO/spare cells | SoC implementation flow decision TBD (DEC-007) |
| Extraction and timing-analysis corners | Target PVT/RC corners TBD (DEC-007) |
| Delivery form: RTL/netlist/hardened layout | Synthesizable RTL IP; netlist/layout delivery is outside this IP specification scope |


## 18. Security, safety, and reliability

| Topic | Requirement / rationale | Verification method / expected behavior |
|---|---|---|
| Security boundary and threat assumptions | TBD with SoC security owner (DEC-007); flash contents may include boot/runtime images | Threat-model review before RTL freeze |
| Access control / privilege | TBD; APB PPROT/security policy and XIP protection are not selected (DEC-009) | APB protection tests and XIP access-control tests after policy selection |
| Secure clearing / zeroization | No cryptographic key storage is specified; buffer clearing requirement TBD with product security | Verify no key material is retained; add clearing test if product requires it |
| Information leakage / side channels | Timing/traffic leakage requirements TBD with product security | Review command/address/data visibility and access timing against threat model |
| ECC/parity and fault detection | No ECC/parity requirement selected for FIFO storage; decision depends on macro and safety policy (DEC-007/010) | Fault-injection or memory-protection tests if required |
| Safety goal / integrity level | No safety integrity target supplied (DEC-007) | Safety analysis is not applicable until a target is assigned |
| Diagnostics, fail-safe state, recovery | Error/status and interrupt set TBD (DEC-006); reset should force serial pins inactive | Fault injection verifies safe pin state and selected status/recovery behavior |

## 19. Requirement-to-verification traceability

| Requirement ID | RTL module/location | Test/property | Verification method / analysis | Configuration |
|---|---|---|---|---|
| REQ-MODE-001 | m_qspi_serial_engine | TEST-005, WF-005 | SPI controller BFM; all CPOL/CPHA modes and representative word lengths | CFG-STD-CTRL |
| REQ-MODE-002 | m_qspi_serial_engine | TEST-006, WF-007 | SPI controller BFM drives external SCLK/CS; compare target sampling and response | CFG-STD-TGT |
| REQ-MODE-003 | m_qspi_serial_engine | TEST-007, WF-008 | Two-lane flash BFM checks 1-1-2 and 1-2-2 phase and lane ordering | CFG-DUAL-CTRL |
| REQ-MODE-004 | m_qspi_serial_engine | TEST-007, WF-008 | Four-lane flash BFM checks 1-1-4 and 1-4-4 phase and lane ordering | CFG-QUAD-CTRL |
| REQ-MODE-005 | m_qspi_serial_engine, m_vlsit_csr_qspi | TEST-007, TEST-008, WF-008, WF-009 | Mode field write/readback plus flash-BFM checks for all five selected formats | CFG-DUAL-CTRL, CFG-QUAD-CTRL, CFG-QPI-CTRL |
| REQ-MODE-006 | m_qspi_serial_engine, m_vlsit_csr_qspi | TEST-005, TEST-006 | BFM phase/edge checks for all four CPOL/CPHA combinations | CFG-STD-CTRL, CFG-STD-TGT |
| REQ-MODE-007 | m_qspi_serial_engine, m_vlsit_csr_qspi | TEST-005, TEST-006 | Directed minimum/maximum and representative word lengths in MSB/LSB order | CFG-STD-CTRL, CFG-STD-TGT |
| REQ-ARCH-001 | m_qspi | TEST-008 | RTL hierarchy review; elaboration proves one shared engine and pad mux | All configurations |
| REQ-ARCH-002 | m_qspi, m_qspi_serial_engine | TEST-008, WF-006 | Directed role-switch tests while idle and busy; configuration accepted only at idle | All configurations |
| REQ-ARCH-003 | m_qspi, m_qspi_axi_xip, m_qspi_indirect | TEST-011, WF-013 | Concurrent request tests verify serialization and no controller operation while target role owns engine | All configurations |
| REQ-IF-001 | APB4 interface wrapper, m_vlsit_csr_qspi | TEST-009, WF-011 | APB4 protocol assertions and CSR access tests | All configurations |
| REQ-IF-002 | m_qspi_axi_xip, m_qspi_cdc | TEST-001, TEST-002, WF-001, WF-002 | AXI4 protocol/CDC assertions; flash-model comparison; R backpressure and INCR burst-limit/unsupported type tests | XIP configurations |
| REQ-IF-003 | m_qspi_indirect, FIFO blocks | TEST-003, TEST-004, TEST-010, WF-003, WF-004, WF-011 | Flash-model program/erase checks; FIFO boundary and error tests | Controller configurations |
| REQ-IF-004 | m_qspi_axi_xip | TEST-012, WF-012 | AXI write-channel assertions and flash-pin monitor; BRESP is SLVERR with no serial write/program/erase command | XIP configurations |
| REQ-FUNC-001 | m_qspi_axi_xip, m_qspi_cdc, m_qspi_serial_engine | TEST-001, TEST-002 | Flash-model data comparison, CDC ordering, AXI response ordering and protocol assertions | XIP configurations |
| REQ-FUNC-002 | m_qspi_indirect, m_qspi_serial_engine | TEST-003, TEST-004 | Flash-model program/erase checks and completion/error-status checks | Controller configurations |

## 20. Assumptions, dependencies, and decisions

All unresolved values marked `TBD` in other sections are tracked by DEC-002 through DEC-010 or DEP-001; do not treat proposed defaults as approved until resolved.


| ID | Type | Assumption / dependency / unresolved decision | Technical impact / version / configuration | Resolution / status |
|---|---|---|---|---|
| ASM-001 | Confirmed terminology | The request term “Qual-SPI” means Quad-SPI (four data lanes); QPI is the separate 4-4-4 mode. | Distinguishes Quad I/O command formats from QPI operation. | Confirmed by user on 2026-11-02 when selecting 1-1-2, 1-2-2, 1-1-4, 1-4-4 and QPI 4-4-4. |
| DEC-001 | Resolved decision | SoC control and XIP interfaces. | APB4 CSR/FIFO subordinate plus full AXI4 subordinate XIP; AXI interface and serial engine use separate clocks. | User confirmed CPU XIP reads through AXI4 subordinate; APB controls operation; `i_clk_axi` and `i_clk_serial` are separate asynchronous domains. AXI widths/burst default are defined in DEC-002. |
| DEC-002 | Partially resolved | Define XIP opcode/dummy-cycle profile and accepted-read response handling. | Defines flash sequencing, serialization, bus response and multi-NOR compatibility. | User selected parameterized AXI defaults: 32-bit address/data, ID width 1, INCR bursts up to 16 beats, one outstanding burst. `PARA_XIP_BASE_ADDR` and `PARA_XIP_SIZE_BYTES` define the window; flash address is `ARADDR - BASE`; byte/halfword/word reads are supported on a 32-bit bus; out-of-window/unsupported reads return SLVERR per rejected beat. XIP and indirect requests use round-robin arbitration; an accepted burst is atomic after grant. AXI writes return BRESP=SLVERR with no flash side effect. Firmware configures the device-specific read profile. |
| DEC-003 | Partially resolved | Define Standard SPI device electrical timing and target RX-overflow behavior. | Affects controller/target timing, transfer framing and endpoint constraints. | User selected CPOL/CPHA modes 0–3 and 4–32-bit words with MSB/LSB order. Target CS frames are grouped into configured words; a partial RX tail is discarded with sticky RX error; target TX underflow transmits ones and sets sticky TX error. Controller CS setup/hold/high timing is controlled by `qspi_cs_cfg`. Controller TX underflow/RX overflow finishes the current byte, applies CS hold, deasserts CS and aborts without `done`, setting sticky error. CSR configuration is snapshotted at command acceptance; writes while busy stage later values; `start` while busy is ignored and sets sticky `fl_err`. Firmware submits individual flash phases; the IP performs no WREN, busy polling, retry or flash-status interpretation. |
| DEC-004 | Partially resolved | Define clock frequency constraints, target-mode CDC and physical clock-mux binding. | APB, AXI, serial engine and external target SCLK are separate asynchronous domains; the shared engine clock source changes only while idle. | User confirmed separate XIP and serial clocks and approved a clock-mux cell following the common_rtl cell format if needed. Existing `VLSIT_CELL_CKMUX2` is a functional model; SoC implementation must map it to an approved glitch-free clock-mux cell. User selected `m_vlsit_rst_sync` for APB, AXI, serial and target-SCLK domains. Reset clears local state/FIFO pointers and discards in-flight work; the SoC resets requesters with the IP. Numeric clock limits remain SoC/endpoint constraints. |
| DEC-005 | Unresolved decision | Set maximum SCLK, minimum core clock, throughput/latency, area and power targets. | Required for FIFO sizing, divider width, timing closure and PPA acceptance. | Open; no numeric targets supplied. |
| DEC-006 | Unresolved decision | Select DMA request/acknowledge, interrupts, error reporting and recovery behavior. | Changes ports, CSR fields, dataflow, backpressure and verification cases. | Open; not specified. |
| DEC-007 | Unresolved decision | Identify target SoC, process/library/corners, security/privilege policy and DFT/physical-design ownership. | Required for integration, protected register access, test ports, timing constraints and PPA limits. | Open; platform details not supplied. |
| DEC-008 | Resolved | Firmware controls flash QPI entry, exit, and reset using indirect commands. The QSPI mode register selects the controller's 4-4-4 framing only; it does not automatically change flash state. The IP is flash-agnostic: `done` marks the end of the serial command/data phase; firmware handles WREN, busy/status polling, retry, and device-specific recovery. | Flash command codes, status bits and reset state are device-specific; a controller/flash state mismatch can prevent XIP and command decoding. | User confirmed 2026-11-02: do not embed vendor-specific flash policy. Firmware owns write-enable setup, status polling, retries and QPI entry/exit. |
| DEC-009 | Resolved | APB4 CSR geometry and protection/error policy. | Generated CSR APB data width 32 bits, byte-address width 16 bits, four write strobes, word-aligned offsets; synchronous CSR (`async=0`). CSR aperture is `0x0000–0x0FFF`; TX/RX FIFO data windows are at `0x1000`/`0x1004`. | User selected VLSIT CSR generator; `i_protect_en=0` ignores PPROT and `i_slverr_en=1`; partial and misaligned accesses return PSLVERR; aligned unmapped offsets inside the CSR aperture read as zero and ignore writes; addresses outside CSR/FIFO windows return PSLVERR. |
| DEC-010 | Resolved | Separate generated CSR registers from FIFO data push/pop behavior and define queue sizing. | Generator produces CSR state only; custom APB FIFO-data window handles TX enqueue and RX dequeue at byte offsets `0x1000` and `0x1004`. | User approved `m_vlsit_afifo_top` for dual-clock TX/RX/XIP queues. TX/RX entries are 32-bit; `PARA_FIFO_DEPTH` is overridable, default 16, power of two and at least 2. TX-full writes and RX-empty reads return PSLVERR without moving pointers; FIFO-window writes require all four PSTRB bits. Bytes are little-endian; first TX byte is `[7:0]`, first RX byte is stored in `[7:0]`. |
| DEP-001 | Dependency | External SPI peripheral/flash and its datasheet; system clock/reset controller; SoC pad cells. | Exact command set, SCLK/CS timing, pin muxing and voltage/timing limits depend on the selected platform/device. | Endpoint and SoC not yet selected. |

## 21. Glossary

| Term / acronym | Definition |
|---|---|
| Controller | The SPI-side agent that supplies SCLK and chip select and initiates serial transactions. |
| Target | The SPI-side agent that receives SCLK and chip select from an external controller and responds to its transaction. |
| CPOL | Clock polarity; selects the idle level of SCLK for Standard SPI modes 0–3. |
| CPHA | Clock phase; selects which SCLK edge samples and changes data for Standard SPI modes 0–3. |
| XIP | Execute in place; CPU reads an external flash through a memory-mapped AXI4 subordinate interface. |
| 1-1-2 / 1-2-2 / 1-1-4 / 1-4-4 | Command/address/data phase lane counts, in that order. |
| QPI 4-4-4 | Device-specific Quad Peripheral Interface operation using four serial data lanes for command, address and data phases. |
| AXI4 subordinate | AXI endpoint that receives requests from a Manager and returns read/write responses; traditional term: AXI slave. |
| APB4 Completer | APB endpoint that accepts transfers from a Requester and provides response/data; traditional term: APB slave. |

## 22. References used to shape this template

These sources informed document organization and requirement traceability. Protocol sources and product behavior are listed in Section 2.1 and Section 20; this template does not replace the protocol specifications.

| Reference | Use in this specification |
|---|---|
| VLSIT ASIC IP Design Specification Template and VLSIT RTL Design Rule v2 | Section structure, requirement IDs, naming, signal typing, and RTL contract |
| VLSIT APB-CSR-Generator workbook and generator notes | APB CSR workbook structure and generated register behavior; FIFO side effects are not generated |
| AMBA APB4 and AMBA AXI4 protocol specifications (REF-009, REF-010) | Bus interface behavior and handshake/response requirements |
| Synopsys DW_apb_ssi databook (REF-001) | Non-normative enhanced SPI implementation patterns and test ideas; not copied into the specification |
| Macronix MX25U51245G/54 datasheet (REF-011) | Illustrates QPI 4-4-4 and vendor-specific QPI state transition; not selected as the target device |
| lowRISC OpenTitan SPI host and SPI device documentation (REF-006, REF-007) | Qualified controller/target architecture and verification references |

1. Arm, *Introducing the Arm architecture*: distinguishes architecture specifications, product-specific Technical Reference Manuals (TRMs), and Configuration/Integration Manuals (CIMs), with CIMs aimed at SoC integration.  
   [Source link](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/Learn%20the%20Architecture/Introducing%20the%20Arm%20architecture.pdf)
2. Arm, *CoreLink SIE-200 System IP for Embedded Technical Reference Manual*, DDI 0571: functional-description example includes function, port list, bus properties, and read/write timing.  
   [Source link](https://developer.arm.com/documentation/ddi0571/latest/functional-description/ahb5-to-internal-sram-interface-module)
 3. Synopsys, *DesignWare DW_axi IP Directory*: background only; the QSPI design does not depend on a DesignWare AXI implementation. [Product directory](https://www.synopsys.com/dw/ipdir.php?c=DW_axi)
4. Synopsys, *Using DW_ahb_dmac in an AXI Subsystem*: references Databook functional-description and integration-considerations chapters; discusses configuration, interface propagation, subsystem connections, clock assumptions, performance/area trade-offs, and integration.  
   [Source link](https://www.synopsys.com/dw/dwtb/ahb_dmac/ahb_dmac.html)
5. Synopsys, *What Is Static Timing Analysis?*: overview of static timing analysis and definitions of false-path and multicycle-path concepts.  
   [Source link](https://www.synopsys.com/glossary/what-is-static-timing-analysis.html)

