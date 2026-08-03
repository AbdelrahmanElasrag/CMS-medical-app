# cms

## Health assistant (symptom check)

The **Symptom check** tab uses a **rule-based chat questionnaire** shipped in [`assets/rule_based_triage.json`](assets/rule_based_triage.json) (English) and [`assets/rule_based_triage_ar.json`](assets/rule_based_triage_ar.json) (Arabic). The app loads one file based on the active UI locale (`ar` vs `en`). `pubspec.yaml` registers the whole `assets/` tree so every file there is packaged; after adding or renaming triage JSON, run **`flutter clean`** then **`flutter pub get`** and do a **full restart** (hot reload does not refresh the asset manifest).

**Keep both JSON files in lockstep**: same `version`, `startId`, node ids, option `id` values, `nextId`, tags, and terminal metadata; translate only user-facing strings (`assistantText`, option `label`, terminal `careSummary` / `hintBullets`). Any graph or safety change must be applied to **both** assets until you automate extraction.

If the user **changes language** while using the health assistant, the flow **resets to the disclaimer** and reloads the questionnaire for the new locale (avoids a mixed-language transcript).

There is **no** EndlessMedical call and **no** LLM in that flow; answers are turned into a triage bucket with **deterministic** logic in [`lib/services/rule_triage_engine.dart`](lib/services/rule_triage_engine.dart).

The chat shows **one** assistant prompt per step (`assistantText` only). [`assets/symptoms_dictionary.json`](assets/symptoms_dictionary.json) may still be used elsewhere in the app; it is not inlined into triage bubbles so wording stays simple and on‑topic.

### How the questionnaire is structured (non-clinical synthesis)

The JSON flow is **not** a copy of NHS 111, CDC Clara, or any proprietary algorithm. It is informed by common themes in the literature and public descriptions of digital triage: **early red-flag / danger questions**, **chief-complaint branches**, **duration and severity chips**, **risk-averse** routing toward higher acuity when patterns overlap serious conditions, and **safety-net** reminders in copy. Useful background reading (for your clinical team, not as endorsement of this draft):

- [Digital and online symptom checkers for urgent problems — systematic review (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6688675/)
- [Evaluating red-flag coverage in online symptom checkers (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12486864/)
- [How NHS 111 online describes its algorithm-led questioning (NHS UK)](https://www.nhs.uk/nhs-services/urgent-and-emergency-care-services/when-to-use-111/how-nhs-111-online-works/)
- [NHS 111 online as a regulated device — governance note (NHS England Digital)](https://digital.nhs.uk/services/nhs-111-online/nhs-111-online-is-a-class-1-medical-device)

**Crisis line:** the shipped mental-health branch mentions **988** for the U.S.; adjust copy in JSON for other regions if you ship internationally.

### Clinical sign-off (required for “real” medical claims)

Before marketing this questionnaire as medically validated for your jurisdiction, a **licensed clinician** should review and approve the JSON tree, red-flag wording, and bucket mapping. The shipped content is a **strong draft**, not a certified clinical protocol.

### Optional server-side triage (legacy / experiments)

The CMS backend still exposes EndlessMedical proxy and optional Gemini triage for other clients; the Flutter health tab **does not** use them by default. See `cms-backend/docs/SYMPTOM_TRIAGE_CONTRACT.md` if you re-enable those integrations elsewhere.

### Localization (English / Arabic)

- App locale is persisted (`LocaleController` + `shared_preferences`) and wired on `MaterialApp` in [`lib/main.dart`](lib/main.dart) and [`lib/main_staff.dart`](lib/main_staff.dart).
- Health assistant chrome strings live in [`lib/l10n/app_en.arb`](lib/l10n/app_en.arb) / [`lib/l10n/app_ar.arb`](lib/l10n/app_ar.arb); generated Dart lives under [`lib/l10n/`](lib/l10n/) (run `flutter gen-l10n` after editing ARBs if you use codegen instead of the checked-in files).
- Smoke coverage: [`test/app_localizations_smoke_test.dart`](test/app_localizations_smoke_test.dart) (`flutter test test/app_localizations_smoke_test.dart`).

