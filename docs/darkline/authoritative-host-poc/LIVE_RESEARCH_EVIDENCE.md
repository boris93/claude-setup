# Curated Live-Run Research Evidence

**Status:** Historical, non-executable evidence; reverify against the current
Codex/App Server before relying on any version-sensitive observation
**Captured:** 2026-08-13

This document preserves the minimum inspectable evidence behind the live-run
discoveries in [`REVIEW_LEDGER.md`](REVIEW_LEDGER.md) without retaining the
abandoned PoC implementation.

The original ignored `poc/evidence/` tree contained 8,797 files and about 134
MiB of runtime output. Some records embedded old source files, role prompts,
worktree contents, and complete model inputs. Copying that tree would have
contradicted the decision to delete every old implementation artifact. The raw
tree, its SQLite databases, and the preserved runtime directories were
therefore deleted with the disposable worktree.

The records below are field projections made before deletion:

- every shown value is copied exactly from the named source record;
- omitted fields are not represented by invented values;
- `line` is the one-based JSONL source line where applicable;
- each source hash covers the complete original file, not this projection; and
- the original files can no longer be reconstructed from these excerpts or
  hashes.

Statements in the chronological ledger that raw evidence or a runtime “remain
untouched” describe the state at that historical checkpoint. This final archive
decision supersedes those operational retention statements.

## Runtime identity

All six live runs below recorded `codex-cli 0.147.0`. The shared `version.txt`
content had SHA-256
`47e8650c39eae3ea896e5873f03a97a65d183d81cd0d86616e8b83d7d87877ca`.

## LIVE-E7-01: stock resume shape included `excludeTurns`

Source: `poc/evidence/live-20260810-01/gateway.jsonl`, SHA-256
`87898622c1420ee8253e7e5c1bdb8082f4961490c28d0b453969f1a76537be85`.

```json
{"line":23,"direction":"from_tui","method":"thread/resume","excludeTurns":true,"cli_model":null,"requested_effort":"xhigh"}
{"line":24,"direction":"rejected","method":"thread/resume","error":"thread/resume contains unknown fields","reason":"downstream_authority_conflict"}
{"line":25,"direction":"to_tui","code":-32602,"error":"thread/resume contains unknown fields"}
```

The terminal prototype error was `stock CLI attach turn did not complete` in
`prototype-failure.json`, whose SHA-256 was
`4dcfe064acac002d67b00e5ce6e736a617f30aca96441b0a1bceab1086e024e5`.
This proves the observed 0.147 request and the old gateway rejection. It does
not establish that the same shape is current in a later Codex version.

## LIVE-E7-02: an empty started thread was not resumable

Source: `poc/evidence/live-20260810-02/app-server-raw.jsonl`, SHA-256
`4712305a1fc7e96babaabf50fcf90bfbffa80ccd0b1f6588f37330220f2d1351`.

```json
{"line":8,"direction":"from_app_server","response_id":"operation:mvp-primary-thread-start","thread":{"id":"019fea5e-43b3-7072-b57e-3add3dc6db5c","ephemeral":false,"historyMode":"legacy","turn_count":0,"path":"/tmp/darkline-mvp.live-20260810-02.2wfVkM/server-home/sessions/2026/08/10/rollout-2026-08-10T12-01-14-019fea5e-43b3-7072-b57e-3add3dc6db5c.jsonl"}}
{"line":15,"direction":"from_app_server","response_id":"controller:5","thread":{"id":"019fea5e-43b3-7072-b57e-3add3dc6db5c","turn_count":0,"preview":""}}
{"line":22,"direction":"to_app_server","method":"thread/resume","thread_id":"019fea5e-43b3-7072-b57e-3add3dc6db5c","excludeTurns":true}
{"line":23,"direction":"from_app_server","response_id":"operation:0d024a1f-3437-4589-892c-3c1a4eb49b57","code":-32600,"error":"no rollout found for thread id 019fea5e-43b3-7072-b57e-3add3dc6db5c"}
```

The gateway projection of the same failure had SHA-256
`3fcb416dfbd6462d5ff4d5372fcd2d8ba746ad95034c7f191d79cfc495330bf0`.
The excerpt proves the exact start/read/resume response sequence. The deleted
runtime was also inspected at the time and contained no `sessions` directory;
that negative filesystem observation survives only as a recorded observation
in the ledger, not as independently reinspectable raw state.

## LIVE-E7-03: controller-created primary effort was null

Source: `poc/evidence/live-20260810-03/gateway.jsonl`, SHA-256
`26047adae96bb399995b5c7da5a6d45c3e69ccaa3b0239e4730bb19a49c81e03`.

```json
{"line":41,"direction":"to_tui","kind":"upstream_response","response_id":6,"model":"gpt-5.6-sol","reasoningEffort":null,"thread_id":"019fea81-0bf5-7433-b4cc-a4d55263a333"}
{"line":55,"direction":"from_tui","method":"turn/start","model":"gpt-5.6-sol","effort":null,"collaboration_model":"gpt-5.6-sol","collaboration_effort":null}
{"line":56,"direction":"rejected","method":"turn/start","error":"turn/start model or effort conflicts with controller policy","reason":"downstream_authority_conflict"}
{"line":57,"direction":"to_tui","code":-32602,"error":"turn/start model or effort conflicts with controller policy"}
```

This proves the null effective effort and downstream null turn shape in that
run. It does not prove why App Server chose the value or how current versions
persist effort.

## LIVE-E7-04 and LIVE-E7-05: presentation mismatch and human-wait timeout

LIVE-E7-04 was a product-presentation finding: the prompt advertised a freely
chosen low-stakes coding outcome while the harness could execute only its fixed
normalization fixture. The user then supplied a real Piccolod task. The exact
discussion and disposition are preserved in the ledger; this was not a claim
about an App Server protocol response.

LIVE-E7-05 has direct runtime evidence. The successful readiness sequence came
from `poc/evidence/live-20260810-04/gateway.jsonl`, SHA-256
`51c255e6e0a3506cc9737c3171c11ff0b778ecbc6e59a7c831cc1c63939bbda5`.

```json
{"line":55,"direction":"from_tui","method":"turn/start","model":"gpt-5.6-sol","effort":"xhigh","thread_id":"019fea93-8e32-7bd3-a052-510be6b27e35"}
{"line":56,"direction":"canonicalized","method":"turn/start","effective_model":"gpt-5.6-sol","effective_effort":"xhigh","thread_id":"019fea93-8e32-7bd3-a052-510be6b27e35"}
{"line":73,"direction":"to_tui","kind":"notification","method":"turn/completed","thread_id":"019fea93-8e32-7bd3-a052-510be6b27e35","turn_id":"019fea93-b15d-7f92-9eb4-600a3510b25f","status":"completed","output_types":["agentMessage"]}
```

The presentation lifecycle came from
`poc/evidence/live-20260810-04/controller.jsonl`, SHA-256
`7c9896a74c3baf42e8dc82d14be2e9124f6f1f3b40f84e5304604c73872cfe20`.

```json
{"line":8,"event":"presentation_attached","presentation_generation":1,"monotonic_ns":2770939520101435,"wall_time_ns":1786346971525102323}
{"line":11,"event":"presentation_detached","presentation_generation":1,"monotonic_ns":2771846091618770,"wall_time_ns":1786347878096619778}
```

The interval was about 906.57 seconds. The terminal error was
`timed out waiting for primary user input` in `prototype-failure.json`, whose
SHA-256 was
`2ed70c984cd1d276785483289b470ab6330fab9fcbd4f2601b3669346b77c3aa`.
Together these records establish that the presentation became ready and the
run later failed at the human-input wait. They do not prove that every elapsed
second was caused solely by the configured 900-second timeout.

## LIVE-E7-06: provider rejected an open nested output schema

Source: `poc/evidence/live-20260810-05/app-server-raw.jsonl`, SHA-256
`93e3aa53afcf4dc4d0e6ee18e367154c32e3269c02444ffe58777c5cc6742f41`.

```json
{"line":785,"direction":"from_app_server","method":"error","thread_id":"019fec40-d61d-7142-8517-22fabc57323b","turn_id":"019fec41-1068-7ac0-9e1d-0dddbcfa56eb","willRetry":false,"provider_code":"invalid_json_schema","provider_status":400,"provider_message":"Invalid schema for response_format 'codex_output_schema': In context=('properties', 'ask', 'type', '0'), 'additionalProperties' is required to be supplied and to be false."}
{"line":786,"direction":"from_app_server","method":"turn/completed","thread_id":"019fec40-d61d-7142-8517-22fabc57323b","turn_id":"019fec41-1068-7ac0-9e1d-0dddbcfa56eb","status":"failed","item_count":0}
```

The first record projects the nested JSON error string into its exact code,
status, and message fields; no wording was paraphrased. The terminal prototype
error was `attempt_1_planner model call failed` in `prototype-failure.json`,
whose SHA-256 was
`f8dac0c4857e4c46856a220ad561edc872080b8dfd237daee96c51f2304b1c4f`.

## LIVE-E7-07: notifications and `thread/read` exposed different item sets

Source: `poc/evidence/live-20260811-01/app-server-raw.jsonl`, SHA-256
`ad08a0aa1bb71c9f1290c54e73349f12a132d259a4cd55bb44d948bb3b090c41`.
The selected turn was `019fee35-f7a9-7742-88ff-a8803bb444ea`.

The ordered notifications included the command action:

```json
{"line":807,"direction":"from_app_server","method":"item/started","thread_id":"019fee35-d4ff-7f62-9b91-86ab11aa8285","turn_id":"019fee35-f7a9-7742-88ff-a8803bb444ea","item":{"id":"exec-d0e951e8-08d4-4c6f-a731-711773cbc95e","type":"commandExecution","status":"inProgress"}}
{"line":808,"direction":"from_app_server","method":"item/completed","thread_id":"019fee35-d4ff-7f62-9b91-86ab11aa8285","turn_id":"019fee35-f7a9-7742-88ff-a8803bb444ea","item":{"id":"exec-d0e951e8-08d4-4c6f-a731-711773cbc95e","type":"commandExecution","status":"completed"}}
```

Two later exact reads returned the completed turn without that action:

```json
{"line":977,"direction":"from_app_server","response_id":"controller:22","turn":{"id":"019fee35-f7a9-7742-88ff-a8803bb444ea","status":"completed","items":[{"id":"item-1","type":"userMessage"},{"id":"item-2","type":"agentMessage"}]}}
{"line":981,"direction":"from_app_server","response_id":"role-turn:model-010:closure-read","turn":{"id":"019fee35-f7a9-7742-88ff-a8803bb444ea","status":"completed","items":[{"id":"item-1","type":"userMessage"},{"id":"item-2","type":"agentMessage"}]}}
```

The deleted SQLite database
`poc/evidence/live-20260811-01/journal.sqlite`, SHA-256
`a512a58190700340d39f4fbe446cc24d44fcf351c1ed7e3f4c95e6f0122e2212`,
contained this canonical row projection from `role_turn_actions`:

```json
{"role_turn_id":"role-turn:model-010","action_id":"exec-d0e951e8-08d4-4c6f-a731-711773cbc95e","item_type":"commandExecution","ordinal":1,"state":"completed","started_ns":1786407951306387291,"terminal_ns":1786407951317603289}
```

The associated `role_turns` row was:

```json
{"role_turn_id":"role-turn:model-010","run_id":"run-001-planner","turn_id":"019fee35-f7a9-7742-88ff-a8803bb444ea","state":"fenced","turn_status":null,"logical_outcome":"failed","action_admission_open":0,"action_frontier_count":null}
```

This is direct evidence that the notification stream reported and the durable
store recorded the completed action while both exact reads omitted it. The
excerpt does not establish a universal App Server guarantee; it establishes one
observed 0.147 projection difference that a future design must reverify.

## What this evidence can and cannot support

This file is sufficient to avoid rediscovering what was actually observed and
why the old design changed. It is not a retained qualification packet, a replay
corpus, or proof about current Codex behavior. Any fresh PoC must create its own
bounded evidence from its current version and must not treat these historical
records as inherited protocol contracts.
