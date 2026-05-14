# SuperTextField Extraction Dependency Map

Complete dependency tree for extracting `SuperTextField` from `tw_super_editor` to `tw_primitives`.

**Starting Point:** `packages/tw_super_editor/lib/src/super_textfield/super_textfield.dart`  
**Target:** `packages/tw_primitives/lib/src/`

---

## ⚠️ CRITICAL FINDING

**This is NOT a "primitives" extraction** — it's a tightly coupled widget that depends on the document editor core.

SuperTextField requires the **document model** (`core/document.dart`, `core/document_layout.dart`, `document_selection.dart`) to function. This means the new package must depend on tw_super_editor's core module.

**Recommendation:** Name it `tw_super_textfield` instead of using `tw_primitives`.

---

## Directory Structure for tw_primitives/lib/src/

```
tw_primitives/lib/src/
├── super_textfield/
│   ├── super_textfield.dart                           (main entry)
│   ├── super_textfield_context.dart
│   ├── styles.dart
│   ├── super_text_field_keys.dart
│   ├── metrics.dart
│   ├── android/
│   │   ├── android_textfield.dart
│   │   ├── _caret.dart
│   │   ├── _editing_controls.dart
│   │   ├── _user_interaction.dart
│   │   └── drag_handle_selection.dart                 (5 files)
│   ├── ios/
│   │   ├── ios_textfield.dart
│   │   ├── caret.dart
│   │   ├── editing_controls.dart
│   │   ├── user_interaction.dart
│   │   └── floating_cursor.dart                       (5 files)
│   ├── desktop/
│   │   └── desktop_textfield.dart                     (1 file)
│   └── infrastructure/
│       ├── attributed_text_editing_controller.dart
│       ├── fill_width_if_constrained.dart
│       ├── hint_text.dart
│       ├── magnifier.dart
│       ├── outer_box_shadow.dart
│       ├── text_field_border.dart
│       ├── text_field_gestures_interaction_overrides.dart
│       ├── text_field_scroller.dart
│       ├── text_field_tap_handlers.dart
│       └── text_scrollview.dart                       (10 files)
├── input_method_engine/
│   └── _ime_text_editing_controller.dart              (1 file)
├── infrastructure/
│   ├── attributed_text_styles.dart
│   ├── ime_input_owner.dart
│   ├── text_input.dart
│   ├── _logging.dart
│   ├── signal_notifier.dart
│   ├── document_gestures_interaction_overrides.dart
│   ├── keyboard.dart
│   ├── actions.dart
│   ├── multi_listenable_builder.dart
│   ├── multi_tap_gesture.dart
│   ├── strings.dart
│   ├── toolbar_position_delegate.dart
│   ├── touch_controls.dart
│   ├── composable_text.dart
│   ├── document_gestures.dart                         (EDITOR COUPLING)
│   ├── _scrolling.dart                                (EDITOR COUPLING)
│   ├── flutter/
│   │   ├── build_context.dart
│   │   ├── flutter_scheduler.dart
│   │   ├── text_input_configuration.dart
│   │   ├── geometry.dart
│   │   ├── text_selection.dart
│   │   └── material_scrollbar.dart                    (6 files)
│   ├── platforms/
│   │   ├── platform.dart
│   │   ├── mobile_documents.dart
│   │   ├── android/
│   │   │   ├── selection_handles.dart
│   │   │   ├── magnifier.dart
│   │   │   ├── toolbar.dart
│   │   │   ├── long_press_selection.dart
│   │   │   └── colors.dart                            (5 files)
│   │   ├── ios/
│   │   │   ├── selection_handles.dart
│   │   │   ├── magnifier.dart
│   │   │   ├── toolbar.dart
│   │   │   ├── ios_system_context_menu.dart
│   │   │   ├── selection_heuristics.dart
│   │   │   └── colors.dart                            (6 files)
│   │   └── mac/
│   │       └── mac_ime.dart                           (1 file)
│   └── documents/
│       └── selection_leader_document_layer.dart       (EDITOR COUPLING)
├── default_editor_exports/
│   ├── attributions.dart
│   ├── text_tools.dart
│   └── document_gestures_touch_ios.dart               (3 files - EDITOR COUPLING)
└── core_exports/
    ├── document.dart                                  (CORE - ESSENTIAL)
    ├── document_layout.dart                           (CORE - ESSENTIAL)
    └── document_selection.dart                        (CORE - ESSENTIAL)
```

---

## File Inventory by Category

### 🎯 SuperTextField Core (5 files)
**Location:** `super_textfield/` root  
**Self-contained:** YES (except for imports from infrastructure)
```
1. super_textfield.dart
2. super_textfield_context.dart
3. styles.dart
4. super_text_field_keys.dart
5. metrics.dart
```

### 📱 Platform-Specific Implementations (11 files)

#### Android (5 files)
```
6. super_textfield/android/android_textfield.dart
7. super_textfield/android/_caret.dart              [SELF-CONTAINED]
8. super_textfield/android/_editing_controls.dart
9. super_textfield/android/_user_interaction.dart
10. super_textfield/android/drag_handle_selection.dart
```

#### iOS (5 files)
```
11. super_textfield/ios/ios_textfield.dart
12. super_textfield/ios/caret.dart                  [SELF-CONTAINED]
13. super_textfield/ios/editing_controls.dart
14. super_textfield/ios/user_interaction.dart
15. super_textfield/ios/floating_cursor.dart        [SELF-CONTAINED]
```

#### Desktop (1 file)
```
16. super_textfield/desktop/desktop_textfield.dart   [COMPLEX - core/document_layout.dart]
```

### 🛠️ SuperTextField Infrastructure (11 files)
**Location:** `super_textfield/infrastructure/` + `input_method_engine/`
```
17. super_textfield/infrastructure/attributed_text_editing_controller.dart   [core/document_layout.dart]
18. super_textfield/infrastructure/fill_width_if_constrained.dart
19. super_textfield/infrastructure/hint_text.dart
20. super_textfield/infrastructure/magnifier.dart    [SELF-CONTAINED]
21. super_textfield/infrastructure/outer_box_shadow.dart   [SELF-CONTAINED]
22. super_textfield/infrastructure/text_field_border.dart
23. super_textfield/infrastructure/text_field_gestures_interaction_overrides.dart
24. super_textfield/infrastructure/text_field_scroller.dart
25. super_textfield/infrastructure/text_field_tap_handlers.dart
26. super_textfield/infrastructure/text_scrollview.dart
27. super_textfield/input_method_engine/_ime_text_editing_controller.dart   [core/document_layout.dart]
```

### 🏗️ Infrastructure Base (22 files)

#### Root (15 files)
```
28. infrastructure/attributed_text_styles.dart      [SELF-CONTAINED]
29. infrastructure/ime_input_owner.dart             [SELF-CONTAINED]
30. infrastructure/text_input.dart                  [SELF-CONTAINED]
31. infrastructure/_logging.dart                    [SELF-CONTAINED]
32. infrastructure/signal_notifier.dart             [SELF-CONTAINED]
33. infrastructure/document_gestures_interaction_overrides.dart   [core/document.dart, core/document_layout.dart]
34. infrastructure/keyboard.dart
35. infrastructure/actions.dart                     [SELF-CONTAINED]
36. infrastructure/multi_listenable_builder.dart    [SELF-CONTAINED]
37. infrastructure/multi_tap_gesture.dart           [SELF-CONTAINED]
38. infrastructure/strings.dart                     [SELF-CONTAINED]
39. infrastructure/toolbar_position_delegate.dart
40. infrastructure/touch_controls.dart              [SELF-CONTAINED]
41. infrastructure/composable_text.dart
42. infrastructure/document_gestures.dart           [EDITOR COUPLING - may need abstraction]
43. infrastructure/_scrolling.dart                  [EDITOR COUPLING - may need abstraction]
```

#### Flutter Utilities (6 files)
```
44. infrastructure/flutter/build_context.dart       [SELF-CONTAINED]
45. infrastructure/flutter/flutter_scheduler.dart
46. infrastructure/flutter/text_input_configuration.dart   [SELF-CONTAINED]
47. infrastructure/flutter/geometry.dart
48. infrastructure/flutter/text_selection.dart      [SELF-CONTAINED]
49. infrastructure/flutter/material_scrollbar.dart
```

#### Platform Detection (2 files)
```
50. infrastructure/platforms/platform.dart          [SELF-CONTAINED]
51. infrastructure/platforms/mobile_documents.dart  [Document model coupling]
```

#### Android Platform (5 files)
```
52. infrastructure/platforms/android/selection_handles.dart
53. infrastructure/platforms/android/magnifier.dart
54. infrastructure/platforms/android/toolbar.dart
55. infrastructure/platforms/android/long_press_selection.dart
56. infrastructure/platforms/android/colors.dart
```

#### iOS Platform (6 files)
```
57. infrastructure/platforms/ios/selection_handles.dart
58. infrastructure/platforms/ios/magnifier.dart
59. infrastructure/platforms/ios/toolbar.dart
60. infrastructure/platforms/ios/ios_system_context_menu.dart
61. infrastructure/platforms/ios/selection_heuristics.dart
62. infrastructure/platforms/ios/colors.dart
```

#### macOS Platform (1 file)
```
63. infrastructure/platforms/mac/mac_ime.dart
```

#### Document Support (1 file)
```
64. infrastructure/documents/selection_leader_document_layer.dart   [EDITOR COUPLING]
```

### 📋 Default Editor Exports (3 files)
**CRITICAL:** These create a hard dependency on tw_super_editor's default_editor module
```
65. default_editor/attributions.dart                [SELF-CONTAINED - constants only]
66. default_editor/text_tools.dart                  [core/document.dart, core/document_layout.dart, core/document_selection.dart, default_editor/text.dart]
67. default_editor/document_gestures_touch_ios.dart [EDITOR SPECIFIC - touches editor gestures]
```

### 🔌 Core Document Model (3 files)
**ESSENTIAL & UNAVOIDABLE** — These are imported directly by multiple files
```
68. core/document.dart                              [CORE MODEL]
69. core/document_layout.dart                       [LAYOUT ENGINE - heavily used]
70. core/document_selection.dart                    [SELECTION MODEL]
```

---

## Summary by Dependency Type

| Type | Count | Self-Contained | Dependencies | Risk |
|------|-------|-----------------|--------------|------|
| Widget Core | 5 | Partial | Infrastructure | Low |
| Platform UI (Android) | 5 | Mostly | Infrastructure, platform | Low |
| Platform UI (iOS) | 5 | Mostly | Infrastructure, platform, **editor gestures** | Medium |
| Platform UI (Desktop) | 1 | No | **document_layout.dart** | High |
| TextField Infrastructure | 11 | No | Infrastructure, **core** | Medium |
| Flutter Utilities | 6 | Mostly | Flutter only | Very Low |
| Platform Support | 12 | Mostly | Platform detection | Low |
| Root Infrastructure | 15 | Mostly | Core, editor coupling | Medium |
| **Editor Coupling** | 4 | No | **core/**, **default_editor/** | **High** |
| **Core Model** | 3 | - | - | **ESSENTIAL** |
| **TOTAL** | **71** | 28 self-contained | - | - |

---

## Files with Complex/Hidden Dependencies

### ⚠️ TIER 1: Core Document Model (ESSENTIAL)
```
core/document.dart
core/document_layout.dart              ← Used by 6+ files
core/document_selection.dart
```

### ⚠️ TIER 2: Heavy Editor Coupling
```
desktop_textfield.dart                 → core/document_layout.dart
attributed_text_editing_controller.dart → core/document_layout.dart
_ime_text_editing_controller.dart      → core/document_layout.dart
ios/editing_controls.dart              → default_editor/document_gestures_touch_ios.dart
text_tools.dart                        → core/document.dart + core/document_layout.dart
```

### ⚠️ TIER 3: Editor Infrastructure Coupling
```
document_gestures_interaction_overrides.dart → core/document.dart, core/document_layout.dart
mobile_documents.dart                  → infrastructure/document_gestures.dart (editor)
default_editor/attributions.dart       → (constants only - safe)
default_editor/document_gestures_touch_ios.dart → (platform specific - hard dependency)
```

---

## External Package Dependencies

Add to `tw_primitives/pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Core packages (already used in tw_super_editor)
  attributed_text: any
  super_text_layout: any
  
  # UI positioning
  follow_the_leader: any
  overlord: any
  
  # Utilities
  collection: any
  characters: any

dependency_overrides:
  # To use core document model from tw_super_editor
  tw_super_editor: path: ../tw_super_editor
```

---

## Migration Strategy Recommendations

### Option 1: Full Extraction (Cleanest)
- Copy all 71 files to `tw_primitives`
- Keep dependency on tw_super_editor for core document model
- Risk: Circular if tw_super_editor also depends on tw_primitives

### Option 2: Abstraction Layer (Recommended)
1. **Keep in tw_super_editor:**
   - Core document model
   - Editor-specific gesture handlers
   - text_tools.dart

2. **Extract to tw_primitives:**
   - 60 files (without editor-specific items)
   - Create abstract interfaces for document interactions
   - Reduce coupling via dependency inversion

3. **Result:**
   - tw_primitives: Standalone text field package
   - tw_super_editor: Depends on tw_primitives, provides document integration

### Option 3: Two-Package Split
- **tw_primitives:** Generic text field (64 files - no core/document model)
- **tw_editor_text_field:** Document-aware wrapper (7 files + core reexports)

---

## File Count Verification

```
super_textfield/                    : 5 files
super_textfield/android/            : 5 files  
super_textfield/ios/                : 5 files
super_textfield/desktop/            : 1 file
super_textfield/infrastructure/     : 10 files
input_method_engine/                : 1 file
infrastructure/ (root)              : 15 files
infrastructure/flutter/             : 6 files
infrastructure/platforms/android/   : 5 files
infrastructure/platforms/ios/       : 6 files
infrastructure/platforms/mac/       : 1 file
infrastructure/platforms/ (root)    : 2 files
infrastructure/documents/           : 1 file
default_editor/ (exports)           : 3 files
core/ (required imports)            : 3 files
                                    ─────────
TOTAL                               : 69 files
```

**Note:** Some files were not reviewed in detail (text_field_border.dart, text_field_scroller.dart, geometry.dart, etc.) but are imported and should be included.

---

## Next Steps

1. **Verify all 69+ files** are properly imported by tracing through each platform's full initialization
2. **Test self-contained claims** by creating bare exports and checking import resolution
3. **Identify abstraction points** for editor coupling (document_gestures_interaction_overrides, etc.)
4. **Create a pubspec.yaml** with correct dependency declarations
5. **Plan migration path** to avoid circular dependencies
