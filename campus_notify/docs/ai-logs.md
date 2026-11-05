# AI log - Week 10 (AI feature: campus assistant chat)

## Tool used
Claude (chat assistant). Model/version: <fill in>

## Feature
Chat assistant that answers questions about campus announcements, using the Gemini `generateContent` REST API.

## System prompt
```
You are the Campus Notify assistant. Answer in the same language as the user,
in at most 3 sentences. Only help with campus announcements, schedules and
study questions. Never ask for or repeat personal data (ID numbers, phone
numbers, passwords). If you are not sure, say so.
```

## User prompt (example) and context
- User prompt: "When is the midterm?"
- Context sent: earlier chat turns only. No tokens, no campus Bearer token, no user profile.
- Not sent: IDs, phone numbers, emails (redacted in the domain use case).

## Initial AI output
<paste the raw answer you got before changing anything>

## Real results of the checks (fill in)

### Model name and API shape
The codelab uses `gemini-pro` and puts the key in the URL (`?key=`). I checked what the API really accepts:
```
<paste output of the models list command>
```
- Model I used: <name> (found in the list: yes / no)
- Key sent in the `x-goog-api-key` header, not in the URL, so it does not show in logs.

### Verification
- [ ] Every line read, unclear parts marked: <list>
- [ ] APIs exist (autocomplete + docs): <result>
- [ ] `grep` for framework imports in domain: ZERO hits
- [ ] `grep` for secrets in source: ZERO hits
- [ ] `flutter analyze` clean
- [ ] `flutter test` green
- [ ] Manual: no key, wrong key, offline, normal question, long input

## Problem found (write only what really happened)
- What was wrong or risky: <describe>
- Proof: <command + output, or failing test>
- Fix: <what I changed>

## Accept / reject table

| Part | Proposal | Decision | Evidence | Reason |
|---|---|---|---|---|
| Key in secure storage | flutter_secure_storage | accept | grep shows no key in source | codelab rule |
| Key in URL query | `?key=$apiKey` (codelab) | reject | | URLs end up in logs and proxies; header is safer |
| Reuse campus Dio | | reject | | would send the campus Bearer token to a third party |
| Redaction in use case | | accept | test output | privacy rule lives in domain and is testable |
| Session question limit | | accept | test output | simple cost control |
| Streaming responses | | defer | | not needed for 3-sentence answers |
| `http` + `riverpod` packages (codelab) | | reject | `pubspec.yaml` | project already uses dio + flutter_riverpod |

## Final evidence
```
flutter analyze  ->  <paste>
dart format --set-exit-if-changed .  ->  <paste>
flutter test     ->  <paste>
```
