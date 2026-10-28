# Reference IP research log: AXI2TLUL Bridge

Date: 2026-10-26. Skill: `vlsit-asic-ip-microspec`, step 6 (rules R-010, R-011, R-012). Tool: `vlsit_ip_search.py`.

## Searches

| Source | Query | Result |
|---|---|---|
| GitHub | `axi tlul bridge`, `axi2tlul`, `tlul axi4`, `axi tlul` | 3 repositories found, all EXCLUDED: `vyges-ip/coralnpu-axi2tlul`, `vyges-ip/coralnpu-tlul2axi`, `vyges-ip/opentitan-tlul` (score 0: no licence, no tapeout or FPGA evidence, no verification evidence) |
| GitHub | `tilelink uncached lightweight axi bridge`, `opentitan axi tl-ul adapter` | 0 candidates |
| Gitee | `axi tilelink bridge`, `axi tl-ul`, `tlul` | 0 candidates; no Chinese-language source was available to read (rule R-011) |
| GitHub (evaluate) | `lowRISC/opentitan` | The script scores 0 (no evidence recognised on the page). OpenTitan is the source of the TL-UL specification; the repository is used only as the protocol authority (Apache-2.0), not as design reference |
| GitHub (evaluate) | `pulp-platform/axi` | QUALIFIED (score 3: FPGA and verification evidence). It contains AXI utilities (burst handling, ID remapping). **No idea was borrowed and no code was read for this specification**; it is listed for the RTL design phase only |

Conclusion: no qualified public AXI4-to-TL-UL bridge exists, so this specification is derived from the two protocol specifications (REF-001, REF-002) and the user's decisions (Section 20). No text or code of any reference IP is copied into the specification (rule R-012).

## OpenTitan source files downloaded with the user's approval (2026-10-26)

Source: `https://raw.githubusercontent.com/lowRISC/opentitan/master/hw/...` (branch `master` on the download date; the commit hash was not recorded). Licence: Apache-2.0. Stored unchanged in `opentitan_ref/`; used only to read the `a_user` layout, the mubi4 encoding and the integrity-generation interface. They are source files, not converted standards, so they are cited as REF-006 and not stored in `reference/md_doc/`.

| File | Path in the repository | Bytes | SHA-256 |
|---|---|---:|---|
| `tlul_pkg.sv` | `hw/ip/tlul/rtl/tlul_pkg.sv` | 8080 | `a26274dd17824645eedac5160e01ed2ab422e04daefcde2306b167ee65c9833c` |
| `prim_mubi_pkg.sv` | `hw/ip/prim/rtl/prim_mubi_pkg.sv` | 40926 | `11a2f1a16ddaf750d859c95e07fc48c54743fe6ad3b5c5eabe2e14a51d9fb1af` |
| `tlul_cmd_intg_gen.sv` | `hw/ip/tlul/rtl/tlul_cmd_intg_gen.sv` | 1483 | `1b212e8f085ccc89d16b38e4731762165c11bad51cc275c356bd08f097e42518` |
| `tlul_cmd_intg_chk.sv` | `hw/ip/tlul/rtl/tlul_cmd_intg_chk.sv` | 1559 | `1b56b9fca7e0b8643110622f6e9d5e6d8bb263bec923a5836748ba3b6f7f76ad` |
| `tlul_rsp_intg_chk.sv` | `hw/ip/tlul/rtl/tlul_rsp_intg_chk.sv` | 1519 | `2159ecd5b1c89222c8dd6b7e807ed5e05d2e052fa5c4b7feb5747180f39064b6` |

Facts taken from these files (all cited in the specification as REF-006):

- `tl_a_user_t` is a packed struct, most significant first: `rsvd` (`TL_AUW - 4 - 7 - 7` bits), `instr_type` (mubi4, 4 bits), `cmd_intg` (7 bits), `data_intg` (7 bits).
- `prim_mubi_pkg`: `MuBi4True = 4'h6`, `MuBi4False = 4'h9`.
- `TL_A_USER_DEFAULT` = `rsvd` 0, `instr_type` False, `cmd_intg` and `data_intg` all ones. `BlankedAData` (a_data of a request that carries no data) is all ones.
- `tl_d_user_t` = `rsp_intg` (7 bits), `data_intg` (7 bits).
- `tlul_cmd_intg_gen` takes a request struct and overwrites `a_user.cmd_intg` (computed from `instr_type`, address, opcode and mask) and `a_user.data_intg` (computed from `a_data`). `tlul_cmd_intg_chk` and `tlul_rsp_intg_chk` only produce an error output; the reaction is left to the module that instantiates them.

Not verified: how each OpenTitan device reacts to a request with an invalid integrity code (the device files were not read). The specification records this as DEP-004.
