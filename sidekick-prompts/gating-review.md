Review the uncommitted changes in this repository. Begin by running `git diff HEAD` for all staged and unstaged changes to tracked files, and `git ls-files --others --exclude-standard` to list new untracked files. Read any new files in full. Review only these changes.

# Investigation methodology

Do not review the diff in isolation. Actively investigate the codebase to find real bugs:

1. **Trace call sites.** For every changed function/method, find all callers. Check if the change breaks any caller's assumptions (argument order, return type, nullability, error semantics).
2. **Follow data flow.** Trace changed variables from source to sink. Verify that transformations, validations, and bounds checks remain correct along the entire path.
3. **Check error paths.** For every new or modified operation that can fail, verify the error is handled. Look for swallowed errors, missing nil/null checks on return values, and uncaught exceptions.
4. **Verify contracts.** If the change modifies an interface, trait, protocol, or type signature, check all implementations and consumers for compatibility.
5. **Read surrounding code.** Before concluding something is safe, read the functions and types the change interacts with. Do not assume correctness from names alone.

Do not stop at the first qualifying finding. Continue until you have listed every qualifying finding in the change.

# Concern categories to check

Systematically evaluate the change for each of these. Not all will apply — skip categories irrelevant to the change, but do not skip relevant ones:

- Off-by-one errors and boundary conditions
- Nil/null/undefined dereference
- Unchecked or swallowed errors
- Race conditions and shared mutable state
- Resource leaks (file handles, connections, locks, memory)
- Type mismatches or unsafe casts
- Missing input validation at system boundaries (user input, API responses, file I/O)
- Integer overflow/underflow or arithmetic edge cases
- Incorrect boolean logic (flipped conditions, missing negation, short-circuit issues)
- Broken invariants (e.g., collection modified during iteration, stale cache)
- Security concerns (injection, path traversal, privilege escalation)

# Bug qualification criteria

Only flag an issue if ALL of the following hold:

1. It meaningfully impacts correctness, performance, security, or maintainability.
2. It is discrete and actionable — not a general codebase concern or a bundle of multiple issues.
3. It was introduced in this change — pre-existing bugs must not be flagged.
4. It is clearly not an intentional choice by the author.
5. Fixing it does not demand a level of rigor absent from the rest of the codebase.
6. It does not rely on unstated assumptions about the codebase or author's intent.
7. It is not speculative — you must identify the specific code paths that are provably affected. "This might break something" is not sufficient; cite the affected code.

If you are unsure whether something is a real bug, verify by reading the surrounding code before reporting it. If after investigation it remains ambiguous, do not flag it.

# Priority levels

Classify every finding with one of:

- **P1** — Must fix. Correctness bug, security flaw, data loss risk, or data integrity issue that should be addressed before merge.
- **P2** — Normal. Should be fixed eventually but does not block.
- **P3** — Low. Nice to have, minor improvement.

# Comment guidelines

For each finding:
- Be clear about *why* it is a bug and what scenarios trigger it.
- Communicate severity accurately — do not overstate impact.
- Keep the body to one paragraph maximum.
- Do not include code chunks longer than 3 lines.
- Tone should be matter-of-fact — not accusatory, not flattering.
- Include a concrete fix or suggestion for each finding.
- Do not flag pure style, naming, or formatting issues unless they introduce a bug.
- The author should immediately grasp the issue without close reading.

# Output format

Output valid JSON matching this schema exactly. Do not wrap in markdown fences or add prose outside the JSON.

{
  "findings": [
    {
      "title": "<≤ 80 chars, imperative, prefixed with priority e.g. [P1]>",
      "body": "<Markdown: why this is a problem, cite file:line, scenarios that trigger it>",
      "suggested_fix": "<concrete remediation>",
      "confidence_score": <float 0.0-1.0>,
      "priority": <int 1-3>,
      "location": {
        "file": "<file path>",
        "line_start": <int>,
        "line_end": <int>
      }
    }
  ],
  "overall_correctness": "patch is correct | patch is incorrect",
  "overall_explanation": "<1-3 sentences justifying the verdict>",
  "overall_confidence_score": <float 0.0-1.0>
}

Only findings with confidence_score >= 0.7 should be included. If there are no qualifying findings, output the full JSON structure with an empty findings array.
