# Source of the AXI3 write data interleaving rules (ASM-008, rule R-006)

Date read: 2026-10-28. The rules are not in the local copy of the standard used by the specification skill (`vlsit_axi_amba_axi_ihi0022h_c.md`, issue H.c), which only states in A5.2.2 that AXI3 permitted the interleaving of write data with different IDs and that it is deprecated in AXI4.

| Item | Value |
|---|---|
| Document | Arm, AMBA AXI Protocol Specification, v1.0, ARM IHI 0022B, copyright 2003, 2004 (108 pages) |
| Where it was found | Arm documentation site, `https://documentation-service.arm.com/static/5f915920f86e16515cdc3342`, found by a web search for the AXI3 interleave rules |
| Licence | Arm proprietary documentation; no redistribution. The PDF is kept in `research/source_docs/` (ignored by git). It was converted on 2026-10-28 into `reference/md_doc/vlsit_axi_amba_axi_ihi0022b_v1_0.md` of the specification skill (source repository, mirror and both installed copies; ignored by git, rule R-008); the converter check lists two pages with word differences (25 and 88), outside chapter 8 |
| Local copy of the downloaded file | `research/source_docs/Arm_AMBA_AXI_Protocol_Specification_v1.0_IHI0022B.pdf` in this folder (757853 bytes, SHA-256 742037ee73eda65c1705de1a475c3632c2b736847da94a6151b5030022b90b19). The web fetch tool saved it while the page was read; at the request of the user it was moved here and is ignored by git through `research/source_docs/.gitignore`, so it is never committed (rule R-008) |
| Sections read | 8.4 Normal write ordering (page 8-5), 8.5 Write data interleaving (pages 8-6 and 8-7) |
| Not read | The later issues (AMBA AXI and ACE Protocol Specification issue F); the user confirmed on 2026-10-28 that v1.0 is enough |

## Rules taken (paraphrased, none copied)

1. A slave interface declares a write data interleaving depth. It is statically configured and is 1 by default (no interleaving).
2. The data of different transactions with the same AWID shall not be interleaved.
3. The depth is the number of different pending addresses for which write data can be supplied; with depth 2 and four pending addresses, data can be supplied for either of the first two.
4. The first data item of each transaction arrives in the order of the addresses.
5. A slave with a depth above 1 shall accept interleaved write data continuously and shall never stall acceptance in order to change the order (deadlock avoidance).
6. When two writes with different AWID access overlapping addresses, the processing order is not defined.
7. If a slave does not support interleaving, the master issues the data in address order (8.4).

Use in the specification: ASM-003, ASM-008, REQ-FUNC-018, REQ-PARAM-005, ERR-006, DEP-004; the checks of the model use one 4KB page per transaction because of rule 6.
