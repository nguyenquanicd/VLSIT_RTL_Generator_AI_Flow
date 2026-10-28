# Simulated waveforms against the figures of the specification

Each scenario is simulated by `verification/vlsit_run_sim.py scenarios` on the delivered RTL (configuration CFG-BASE). The inputs of the bridge
are driven cycle by cycle from the input rows of the specification figure; the outputs of the figure are compared with the simulated ones
cycle by cycle (levels exactly, data labels decoded to values where the label has a value). Cycle 0 is the first cycle after the release of the reset.

| Waveform ID | Specification figure | Simulated waveform | Result | Note |
|---|---|---|---|---|
| WF-001 | figures/wf-001.svg | waveforms_sim/wf-001.svg | MATCH | Same values in all 14 compared cycles |
| WF-002 | figures/wf-002.svg | waveforms_sim/wf-002.svg | MATCH | Same values in all 6 compared cycles |
| WF-003 | figures/wf-003.svg | waveforms_sim/wf-003.svg | MATCH | Same values in all 9 compared cycles |
| WF-004 | figures/wf-004.svg | waveforms_sim/wf-004.svg | MATCH | Same values in all 10 compared cycles |
| WF-005 | figures/wf-005.svg | waveforms_sim/wf-005.svg | MATCH | Same values in all 9 compared cycles |
| WF-006 | figures/wf-006.svg | waveforms_sim/wf-006.svg | MATCH | Same values in all 11 compared cycles |
| WF-007 | figures/wf-007.svg | waveforms_sim/wf-007.svg | MATCH | Same values in all 6 compared cycles |
| WF-008 | figures/wf-008.svg | waveforms_sim/wf-008.svg | MATCH | Same values in all 9 compared cycles |
| WF-009 | figures/wf-009.svg | waveforms_sim/wf-009.svg | MATCH | Same values in all 12 compared cycles |
| WF-010 | figures/wf-010.svg | waveforms_sim/wf-010.svg | MATCH | Same values in all 7 compared cycles |
| WF-011 | figures/wf-011.svg | waveforms_sim/wf-011.svg | MATCH | Same values in all 9 compared cycles |
| WF-012 | figures/wf-012.svg | waveforms_sim/wf-012.svg | MATCH | Same values in all 9 compared cycles |
| WF-013 | figures/wf-013.svg | waveforms_sim/wf-013.svg | MATCH | Same values in all 10 compared cycles |
| WF-014 | figures/wf-014.svg | waveforms_sim/wf-014.svg | MATCH | Same values in all 9 compared cycles |
| WF-015 | figures/wf-015.svg | waveforms_sim/wf-015.svg | MATCH | Same values in all 10 compared cycles |
| WF-016 | figures/wf-016.svg | waveforms_sim/wf-016.svg | MATCH | Same values in all 12 compared cycles |
| WF-017 | figures/wf-017.svg | waveforms_sim/wf-017.svg | MATCH | Same values in all 8 compared cycles |
| WF-018 | figures/wf-018.svg | waveforms_sim/wf-018.svg | MATCH | Same values in all 8 compared cycles |
| WF-019 | figures/wf-019.svg | waveforms_sim/wf-019.svg | MATCH | Same values in all 10 compared cycles |
