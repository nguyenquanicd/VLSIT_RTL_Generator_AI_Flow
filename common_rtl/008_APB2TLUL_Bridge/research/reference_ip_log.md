# Reference IP research log - APB4 to TL-UL bridge

Date: 2026-10-18. Tool: `ip_search.py search ... --source both` (GitHub and Gitee). Rules R-010 (evidence filter), R-011 (Chinese sources), R-012 (no copying of reference code).

## Queries and sources

| Query | Source | Candidates |
|---|---|---|
| apb tilelink uh bridge | GitHub + Gitee | 0 |
| apb tlul bridge | GitHub + Gitee | 0 |
| apb to tilelink | GitHub + Gitee | 2 |
| tl-ul apb / tlul apb | GitHub + Gitee | 2 |
| tilelink apb | GitHub + Gitee | 3 |
| APB TileLink 桥接 (Chinese) | GitHub + Gitee | 0 |
| apb2tl | GitHub + Gitee | 0 |

## Candidates

| Candidate | Direction | Evidence found | Licence | Decision |
|---|---|---|---|---|
| https://github.com/vyges/tlul-apb-adapter | TL-UL host to APB (opposite direction of this IP) | FPGA, verification, ASIC-flow keywords (score 4) | NOASSERTION (none stated) | EXCLUDED: no licence, no tapeout/silicon evidence, opposite direction |
| https://github.com/vyges-ip/tlul-apb-adapter | same as above (mirror/org copy) | same | NOASSERTION | EXCLUDED: same reasons |
| https://github.com/merledu/common_peripheral_ips | peripheral collection, not a bridge | none | Apache-2.0 | EXCLUDED: no tapeout/FPGA evidence, no verification evidence, not a bridge |

## Accepted references

None. No candidate is QUALIFIED under R-010, so none is used and no code was downloaded or read.

## Findings that shaped the specification

None from reference IP. The design relies on the protocol documents in `../../../VLSIT_CODEX_CLAUDE_SKILLS/.claude/skills/vlsit-asic-ip-microspec/reference/md_doc/` (TL-UL from OpenTitan, APB from Arm IHI 0024 Issue D) and on decisions agreed with the user.

## What was not done

- No repository was cloned or downloaded.
- Silicon or FPGA proof of an APB-to-TL-UL bridge could not be confirmed from public sources found by the tool; the bridge is verified only by the verification plan of this specification.
- The OpenTitan repository itself contains TL-UL adapters and bridges, but they were not searched by `ip_search.py` and are not claimed here as evidence.
