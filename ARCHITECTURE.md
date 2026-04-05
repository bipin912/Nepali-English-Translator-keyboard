# Nepali Romanized → English Translator App — Architecture Plan

## What the app does
User types Nepali in Roman script (e.g. `k xa khabar?`) → App translates it to
natural English (`How are you?`) using an AI backend.

---

## App Architecture: Clean Architecture + BLoC

```
lib/
├── main.dart
├── core/
│   ├── constants.dart          # API keys, debounce durations
│   └── theme.dart              # App theme
├── features/
│   └── translator/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── translation_remote_datasource.dart   # Calls Claude API
│       │   └── repositories/
│       │       └── translation_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── translation.dart                     # Pure data model
│       │   ├── repositories/
│       │   │   └── translation_repository.dart          # Abstract contract
│       │   └── usecases/
│       │       └── translate_text.dart                  # Business logic
│       └── presentation/
│           ├── bloc/
│           │   ├── translator_bloc.dart
│           │   ├── translator_event.dart
│           │   └── translator_state.dart
│           └── pages/
│               └── translator_page.dart
└── injection_container.dart    # Dependency injection (get_it)
```

---

## Data Flow

```
User types
    │
    ▼
TextField (debounced 800ms auto) OR Translate Button (manual)
    │
    ▼
TranslatorBloc  ──► TranslateTextUseCase
    │                       │
    │               TranslationRepository (abstract)
    │                       │
    │               TranslationRepositoryImpl
    │                       │
    │               TranslationRemoteDatasource
    │                       │
    │               Claude API (v1/messages)
    │                       │
    ◄───────────────────────┘
    │
    ▼
UI updates (loading → result)
```

---

## Translation Prompt Strategy

The Claude API is called with a carefully crafted system prompt:

```
System: You are a Nepali-to-English translator. 
The user types Nepali sentences written in Roman/English script 
(called "Romanized Nepali" or "Romanized Transliteration"). 
Your job is to translate these into natural, fluent English sentences.

Rules:
- Never explain, never add notes.
- Output ONLY the English translation.
- Preserve the tone (question stays question, casual stays casual).
- Examples:
    k xa khabar? → How are you?
    ma school jaadai chu → I am going to school.
    tapai kahaa basnu huncha? → Where do you live?
```

---

## Key Packages

| Package | Purpose |
|---|---|
| `flutter_bloc` | State management |
| `get_it` | Dependency injection |
| `http` | HTTP calls to Claude API |
| `rxdart` | Debounce on text stream |
| `flutter_dotenv` | Secure API key storage |
| `google_fonts` | Typography |

---

## Trigger Logic

- **Auto**: `TextField` listener → debounce 800ms → fire BLoC event (only if input ≥ 3 chars)
- **Manual**: Translate button → fire BLoC event immediately
- Both feed into the same `TranslateText` use case — no duplication

---

## Security Note
Never hardcode the API key. Store in `.env` file (excluded from git via `.gitignore`)
and load with `flutter_dotenv`.
