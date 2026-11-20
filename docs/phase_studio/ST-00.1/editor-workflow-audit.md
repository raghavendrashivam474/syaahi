# ST-00.1: Existing Editor Workflow Audit

**Sprint ID:** ST-00.1  
**Phase:** `phase_studio`  
**Status:** Completed  
**Audit Target:** End-to-End Poem Creation and Editing Workflow in `syaahi-app`  

---

## 1. End-to-End Flow Trace

The current creation flow follows this exact sequence:

```text
User Action (Tap '+' floating action button on feed or navigation action)
└─> GoRouter navigates to /write (pushed over root navigator key)
└─> UI: WriterScreen (ConsumerStatefulWidget)
├─> Local Controllers: _titleCtrl, _contentCtrl, _themeCtrl
├─> Local State: _language (PoemLanguage), _emotion (PoemEmotion?)
└─> Tap "Publish" button in AppBar
└─> WriterScreen._publish()
├─> Check _contentCtrl.text.trim().isEmpty -> Show Warning SnackBar if empty
└─> ref.read(writerProvider.notifier).publish(...)
└─> WriterNotifier.publish()
├─> state = state.copyWith(isPublishing: true)
└─> PoemsRepository.createPoem(...)
└─> Dio.post('/poems', body)
└─> Backend: POST /api/v1/poems
├─> createPoemSchema.parse(body)
├─> prisma.poem.create(isPublished: true)
├─> createPublicationNotifications(...)
└─> Returns 201 Created with JSON poem payload
└─> WriterNotifier updates state: isPublishing = false, refreshes feedProvider
└─> WriterScreen shows Success SnackBar, sets _dismissed = true, calls context.pop()
```

---

## 2. Component-Level Analysis

### UI Layer (`syaahi-app/lib/features/poems/presentation/writer_screen.dart`)
- **Inputs:** Standard Flutter `TextField` widgets.
  - `_titleCtrl` (lines 198–218): Single/multi-line header input using `GoogleFonts.cormorantGaramond` (size 30, gold color).
  - `_contentCtrl` (lines 225–248): Multiline canvas input (`maxLines: null`, `minLines: 10`), using `GoogleFonts.cormorantGaramond` (size 20, height 1.7 line height). Standard Dart string, preserves `\n` line breaks.
  - `_themeCtrl` (lines 316–326): Optional single-line text field for theme tags.
  - `_emotion` (lines 253–281): `ChoiceChip` selection mapping to `PoemEmotion` enum.
  - `_language` (lines 283–311): `ChoiceChip` selection mapping to `PoemLanguage` enum (defaults to English).
- **Line Break & Stanza Preservation:** Plain text `TextField` handles native newline characters (`\n`). Multi-line paragraphs and stanza spacing are preserved directly in raw Dart `String`.
- **Formatting Support:** **None.** No bold, italic, underline, stanza indentation, or rich text attributes exist in the current text field.
- **Unsaved Changes & Navigation Guard (UX-03):**
  - Uses `PopScope` (lines 130–135) checking `_hasUnsavedContent`.
  - `_hasUnsavedContent` returns true if `_titleCtrl`, `_contentCtrl`, or `_themeCtrl` are non-empty and `_dismissed` is false.
  - If true on back/close press, triggers `_confirmDiscard()` showing an `AlertDialog` warning that words will be lost (lines 78–124).
  - If user selects "Discard", sets `_dismissed = true` and pops route.

### State Layer (`syaahi-app/lib/features/poems/state/poems_providers.dart`)
- **Provider:** `writerProvider` (`StateNotifierProvider<WriterNotifier, WriterState>`).
- **State Model (`WriterState`):**
  - `isPublishing` (`bool`, default `false`)
  - `error` (`String?`, default `null`)
- **Limitations in Current State Model:**
  - **No text content in Riverpod state:** `_titleCtrl`, `_contentCtrl`, and `_themeCtrl` state lives entirely inside `StatefulWidget` state (`_WriterScreenState`). If the screen is disposed or unmounted by OS, draft text is wiped out.
  - **No auto-save:** Editing does not trigger background state persistence or local storage writes.
  - **No draft loading:** `WriterNotifier` cannot load existing draft poems or edit existing published poems.

---

## 3. Key Operational Deficiencies Identified

1. **Ephemeral Text Storage:** Written content is strictly in-memory within Flutter controller instances. Navigating away without publishing (or receiving an incoming phone call that causes OS process kill) destroys the text.
2. **No Edit Mode:** Flutter app has no screen or controller mechanism to load an existing poem into the editor for updating (`PATCH`), even though backend supports updating.
3. **No Rich Formatting / Analysis Tools:** Plain string field cannot support rhyming suggestions, synonym inspection, repeat phrase highlighting, or reusable writing fragments.
