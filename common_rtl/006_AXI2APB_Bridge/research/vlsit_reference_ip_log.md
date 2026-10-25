# Reference IP research log

## Qualification rule

A reference design is used as a design reference only when public evidence supports all three criteria: silicon tapeout or FPGA validation, an available testbench, and an identifiable license. No candidate below met all criteria for the selected full AXI4-to-APB4 profile. No source code or proprietary text was copied into the specification.

## Candidates

| Candidate | Public evidence reviewed | Profile and evidence | Disposition |
|---|---|---|---|
| PULP Platform AXI | [Repository](https://github.com/pulp-platform/axi), [changelog](https://github.com/pulp-platform/axi/blob/master/CHANGELOG.md), [license](https://github.com/pulp-platform/axi/blob/master/LICENSE), [core file](https://github.com/pulp-platform/axi/blob/master/axi.core) | Contains an AXI4-to-APB adapter and test target; Solderpad Hardware License v0.51. No public proof found for FPGA/tapeout validation of this exact bridge. | Excluded by evidence rule; useful only to confirm the adapter is a known architecture. |
| CAST AXI2APB | [Product page](https://www.cast-inc.com/peripherals/subsystems/axi2apb) | Full AXI4/APB4 and vendor claims production use and verification; public license terms were not identified. | Excluded: license cannot be checked. |
| Lattice AXI4-to-APB bridge | [Product page](https://www.latticesemi.com/products/designsoftwareandip/intellectualproperty/ipcore/ipcores05/axi4-to-apb-bridge-module) | AXI4 to APB3; public page did not establish all validation, testbench and license criteria. | Excluded: profile mismatch and evidence incomplete. |
| AMD AXI APB Bridge PG073 | [Product guide](https://docs.amd.com/r/en-US/pg073-axi-apb-bridge/Product-Specification) | AXI4-Lite to APB3/APB4, fixed-width product IP; not full AXI4. | Excluded: profile mismatch. |
| Anlogic AXI-Lite2APB manual | [Chinese PDF](https://anlogic.oss-cn-shanghai.aliyuncs.com/web_doc/IP%E5%92%8C%E5%8F%82%E8%80%83%E8%AE%BE%E8%AE%A1/IP/%E9%80%9A%E7%94%A8%E6%8E%A5%E5%8F%A3/IPUG167_AXI-lite2APB%E7%94%A8%E6%88%B7%E6%89%8B%E5%86%8C.pdf) | AXI4-Lite to APB3/4; describes 1:1 clock, optional multi-port decode and timeout; includes example FPGA metrics but no located testbench/license evidence. | Excluded: profile mismatch and evidence incomplete. |
| Technical overview article | [Bridge design article](https://geek-doc.cn/chip-design/intermediate/peripheral-bus-bridge-apb-ahb) | Discusses serialization, wait states, burst splitting, strobes and errors. Its PPROT mapping conflicts with Arm IHI 0024D. | Low-confidence background only; protocol standard takes precedence. |

## Chinese-language source summary

The Anlogic Chinese manual describes a lightweight AXI-Lite-to-APB bridge with shared-clock operation, optional address decoding and selectable timeout behavior. Its FPGA resource and frequency figures are examples for the named device, not ASIC estimates and not comparable to this full AXI4 design. Confidence: medium for the manual's product description, low for transfer to this design. The linked Chinese overview supports general bridge concepts but contains a protection mapping inconsistent with the APB standard; confidence: low and not used for normative behavior.

## Decision

No candidate is a qualified proven reference under the skill evidence filter for this product profile. The architecture and protocol behavior are derived from the selected Arm standards and user decisions, not copied from candidate RTL. The licensed AXI/APB standards remain outside this deliverable folder.
