Read [](file:///d%3A/flutter/personal_webpage/packages/tw_chat/lib/src/config/skin_light.dart)

**Light singletons** (inline, not using a named const):

| field | value |
|---|---|
| `transparent` | `0x00000000` |
| `bubbleText` | `0xFF000000` |
| `shellBackground` | `0xFFEEEEEE` |
| `shellOuterShadow` | `0x14000000` |
| `shellDivider` | **`0xFFFFFFFF`** |
| `bubbleShadow` | `0x10000000` |
| `bubbleFadeMaskOpaque` | **`0xFFFFFFFF`** |
| `bubbleFadeMaskSoft` | **`0x00000000`** |
| `scrollbarThumbInactive` | **`0xFFFFFFFF`** |
| `scrollbarTrack` | `0x00F8F9F7` |

Three matches:
- `shellDivider`, `bubbleFadeMaskOpaque`, `scrollbarThumbInactive` are all identical `0xFFFFFFFF`
- `transparent` and `bubbleFadeMaskSoft` are both `0x00000000`

---

**Dark singletons:**

| field | value |
|---|---|
| `transparent` | `0x00000000` |
| `bubbleText` | `0xD6DCF6F8` |
| `shellBackground` | `0xFF212835` |
| `shellOuterShadow` | `0x8A000000` |
| `shellDivider` | `0xFF2B364A` |
| `bubbleShadow` | `0x47000000` |
| `bubbleFadeMaskOpaque` | `0xFFFFFFFF` |
| `bubbleFadeMaskSoft` | `0x50FFFFFF` |
| `scrollbarThumbInactive` | `0xFF283143` |
| `scrollbarTrack` | `0x004EF0FF` |

No exact matches, but `scrollbarThumbInactive` (`0xFF283143`) and `shellBackground` (`0xFF212835`) are close neighbours — same dark navy-blue family, just a notch lighter. Whether they're intentionally distinct is a design call.