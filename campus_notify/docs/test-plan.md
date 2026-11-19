# Test plan - Week 12

Feature under test: login and announcements (list, search, detail), plus the token refresh and the assistant error handling behind them.

## Scenarios

| # | Scenario | Kind | Type | Test file |
|---|---|---|---|---|
| 1 | Valid login: email is trimmed and lowercased | success | unit + widget | `login_user_test.dart`, `login_page_test.dart` |
| 2 | Invalid email or short password is rejected, repository not called | edge | unit + widget | `login_user_test.dart`, `login_page_test.dart` |
| 3 | Wrong credentials give an `AuthFailure`, nothing is stored | failure | unit (fake) | `auth_repository_impl_test.dart` |
| 4 | Search ignores case, trims, blank shows all, no match is empty | edge | unit + widget | `search_filter_test.dart`, `home_widgets_test.dart` |
| 5 | List shows titles and dates, tap reports the id | success | widget | `announcement_widgets_test.dart` |
| 6 | Loading, error with Retry, and Retry reloads | failure | widget | `announcement_widgets_test.dart` |
| 7 | Cache: repeat calls, expiry, shared request, stale on error | edge + failure | unit (fake) | `announcement_cache_test.dart` |
| 8 | A 401 refreshes once and retries; failed refresh clears the session; no second refresh | failure | unit (fake adapter) | `api_client_test.dart` |
| 9 | Assistant errors map to the right failure (no key, 403, 429, 5xx, bad response) | failure | unit (fake) | `assistant_repository_impl_test.dart` |
| 10 | Chat state: success, history, failure, blank question, redacted numbers | success + failure | unit (provider) | `chat_notifier_test.dart` |
| 11 | Main flow: login, search, open detail, back; invalid login stays put | flow | integration | `integration_test/app_test.dart` |

## Fakes used
- `FakeRemote`, `MemoryTokenStore` (auth)
- `CountingSource` (announcement cache)
- `ScriptedAdapter` (Dio, scripted status codes)
- `FakeGemini`, `FakeAssistantRepo` (assistant)
- `RecordingAuthRepo`, provider overrides (widgets)

## Not tested (on purpose)
- `PushService` and `FcmTokenLabel`: they need Firebase platform channels. Covered by manual FCM tests from Week 6.
- Real Gemini API: needs a key and network, which makes tests slow and unstable.
