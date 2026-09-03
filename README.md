# Digi-Tribute 2.0

> Native Swift memorial tribute collection, dynamic relationship question bank, and unified keepsake presentation compiler backed by Supabase.

---

## 🕊️ Overview

**Digi-Tribute 2.0** replaces legacy, single-admin memorial software with a modern, multi-tenant platform for funeral homes and families:
- **Relationship-Specific Dynamic Question Bank:** 78 curated prompts across 13 relationship categories (Father, Mother, Spouse, Children, Friends, etc.) that randomly surface 4–6 warm questions.
- **Multi-Format Memorial Gathering:** High-res photos, audio recordings, video tributes, and written memories.
- **Unified Family Keepsake & Presentation Compiler:** Assembles approved tributes into a high-res printable PDF keepsake booklet with scan-to-stream QR codes for audio/video playback.
- **Permanent Master Archival & 90-Day Raw Purge:** Permanent storage for final compiled memorial presentations with automated serverless purging for raw footage 90 days post-publish.
- **Phase 2 Privacy-Gated Event Invites:** 4-digit PIN gate and magic-link contributor verification for guests.

---

## 📂 Project Structure

```text
├── DigiTributeCore/                  # Core Swift Framework
│   ├── Models/                       # Entities matching Supabase schema (Subject, Tribute, etc.)
│   ├── Services/                     # QuestionBankService, SupabaseClient, Storage, PDFExport, MemorialDoc
│   └── Views/                        # SwiftUI Views (Prompt Picker, Admin Dashboard, Keepsake Viewer)
├── Sources/
│   ├── DigiTributeApp/               # Native macOS / iOS Application Entry Point
│   └── DigiTributeTestRunner/        # CLI Test Suite Runner
├── supabase/
│   ├── migrations/                   # PostgreSQL DDL, RLS policies, Question Bank seeds (001 - 005)
│   └── functions/purge-raw-footage/  # Serverless Edge Function for 90-day storage cleanup
└── preview/
    └── index.html                    # Interactive Browser Preview
```

---

## 🚀 Quick Start

### 1. Run the Native App (macOS / iOS)
```bash
# Run on macOS
swift run DigiTributeApp

# Or open in Xcode
open Package.swift
```

### 2. Run the Test Suite
```bash
swift run DigiTributeTestRunner
```

### 3. Deploy to Supabase
```bash
# Link your project
npx supabase link --project-ref <your-supabase-project-id>

# Push database schema & 78-question seed data
npx supabase db push

# Deploy retention purge Edge Function
npx supabase functions deploy purge-raw-footage
```

---

## 📜 License
Private & Proprietary · Digi-Tribute
