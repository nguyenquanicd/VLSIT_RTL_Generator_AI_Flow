# User Decision Prompt Standard

## Purpose

Use this standard whenever a workflow asks the user to choose an option, supply missing information, approve a gate, review generated content, or decide whether to overwrite, skip, retry, or stop.

## Before asking

Review the available project files and current state first. Do not ask for information the project already provides, and do not make the user repeat a choice already given in the conversation.

For each question, give the user enough context to make an informed decision:

1. **Analysis:** State what was found, what is still unknown, and why the decision affects the next step. Keep it concise and specific to the current design or artifact.
2. **Terminology:** Define technical terms and abbreviations that are not likely to be familiar. Explain the practical effect, not only the expansion of an acronym.
3. **Options:** List the valid choices. For each, state what it means, what the workflow will do, and the main benefit or trade-off.
4. **Example:** Include a concrete example of a valid answer or how one option applies. For technical values, use values allowed by the approved specification; label illustrative values as examples.
5. **Recommendation:** Mark the best-supported option and explain why it fits the known requirements. Mention its material trade-off. If there is no safe recommendation because a product requirement is missing, say that plainly and do not invent a default.
6. **Response format:** Tell the user exactly how to answer and what happens after each choice.

Keep the analysis short: one or two sentences is usually enough. Use a small table for several comparable options. Prefer two to four options; do not create artificial choices when a direct input is required.

## Question types

### Missing technical information

Explain why the information is needed and give a representative answer format. Offer supported choices only when the specification or context establishes them. If the value is design-specific and cannot be inferred, explain why no default is safe.

Example:

> The reset polarity is not stated, and it affects the port contract and reset checks. Active-low means reset is asserted at 0; active-high means it is asserted at 1. Example answer: “active-low, asynchronous.” There is no safe default from the current specification. Which polarity and reset style should the design use?

### Selecting modes, configurations, or test cases

Describe what each option includes and excludes. For configuration choices, show the current/default value, legal range, dependent features, and effects on area, timing, throughput, or compatibility when those effects are supported by the specification. For test selection, explain what each group verifies and what remains uncovered.

Example:

> “All applicable tests” selects every test whose required feature is enabled. “Selected tests” runs only the IDs you name and may leave requirements uncovered. Recommended: all applicable tests for sign-off because that maximizes planned requirement coverage. Example: TC-001,TC-003 selects only reset and arithmetic tests.

### Review or approval gates

Show the artifact or decision being approved, its revision/status, unresolved items, validation results, and what approval unlocks. Define each response:

- **Approve:** accept the displayed artifact and proceed.
- **Revise:** keep the gate open and identify changes to make.
- **Reject/stop:** do not use the artifact for the next phase.

Recommend approval only when the required checks pass and no unresolved decision blocks the gate. The user remains the signer.

### Failure recovery

Explain the failure evidence and the effect of recovery choices. Define options such as retry, skip, continue, and abort. Explicitly state when skipping leaves a test failed or coverage incomplete. Recommend fixing or stopping when proceeding could misrepresent a failed check as passing.

### Overwrite or replacement

Identify the exact file, summarize whether it exists and whether it contains user edits, and explain what replacement would discard. Offer compare/review, overwrite, and keep/stop choices as appropriate. Recommend comparing or preserving the existing content when its provenance is uncertain.

## Required prompt shape

Use this structure when presenting a meaningful choice:

~~~text
Analysis: <current evidence and why a decision is needed>
Terms: <brief definitions, if needed>
Options:
- A — <meaning, consequence, and trade-off>
- B — <meaning, consequence, and trade-off>
Example: <valid sample answer or scenario>
Recommended: <option> — <reason based on current evidence>; <main trade-off>.
Choose: <exact accepted response format>.
~~~

For a simple approval, compress the structure but still state what is being approved, what yes/no does, and why approval is or is not recommended. Do not emit a bare “yes/no,” “choose A/B,” or “continue/stop” prompt.

## Language and judgment

Use the user's language for the question. Preserve standard technical terms where translation could obscure meaning, and define them on first use. Separate facts from assumptions. Do not overstate a recommendation: make clear when it depends on a design goal such as lower area, higher throughput, or compatibility.

