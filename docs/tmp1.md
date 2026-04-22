# SOLVED
SOLVED


PERHAPS SOLVED (will verify after deployment)


---
# SOON SOLVED



---
# PROPOSED NEXT


Make the header collapse similar to Facebook 


Write "a data-driven resume creator"
 make the title into correct font and size and position.

Make projects boxes:
* Data-driven twin

* Formatted copy from my phone still does not work
* At the bottom of a truncated message, I want a gradient shadow with the same color like that of the chat grid. But always with a transparency




---
# LATER

## Fix colors/theme across main app and tw_chat
* Light theme is not on brand
* Dark theme:
    * make link colors nicer
    * make scroll thumb active color nicer
    * make bot bubble bgd color less dull

## BUGS: phone / touch
    * copy issue formatting not resolved on phone
    * paste/copy issue not resolved on phone
    * scrollbar issue in text input fiels on phone not resolved

## Keywords impr:
    * Make placement logic better
    * Make the logic of co-locating words better and more logic
    * use the colors from the ref pictures as i think they were nicer
    * Make color mean something Right now color seems mostly aesthetic. 
        Better if it encodes category:
        magenta = commercial / strategic / leverage
        cyan = systems / integration / collaboration
        charcoal = engineering / technical coreThen the composition becomes legible, not just attractive.



---
# MUCH LATER

## Terese Content Development:
    * Keywords:
        * Lägga till context engineering 
        * Mechanical engineering är menat ihop på två rader
        * inventering av kunskap

    * Hero text?
    * The keywords should be placed based on embeddings?


    * twin-data
    * Do a proper inventory of skills
    * Make the keywords clickable with real examples or other info supporting it - this will replace the section "Explore my skills"

    * Perhaps remove contact details from chat and / or refer to webpage and / or say that the message will get sent to the stated email.
    * Need a picture and a hero text

    * Explore My Skills
        Identify -> Clarify -> Cut waste -> Coach for Change
        Education
        Advanced Data Analysis
        Automating work and everything 
        Creating joyful work processes & UI
        Design & 3D-modeling
        3D-printing

## DRY-ify
Göra ett shared paket:
    - återanvända tw_chat scrollbar i main app från tw_chat?
    - återanvända arrow-key-scroll i tw_chat från main app?
    - gemensam färg-config mellan tw_chat och main app?
    - annat som kan ingå i detta?
    - Make the selection/deselction logic centralised into a wrapper? Create internal package tw_flutter_basics that can be shared with other internal packages as well as Main app. Move the scrollable behavior in there as well?







I’ve got enough context from the current app_ui_config.dart and the `tw_chat` skin split. I’ll answer this as a design recommendation rather than editing code, because the main question is whether the structure should change.Yes, but only for theme tokens and theme-owned styling, not for the whole app.

Right now app_ui_config.dart is starting to do the same job that `tw_chat` split across skin.dart, skin_light.dart, skin_dark.dart, and skin_shared.dart. That pattern is good when:
- the number of light/dark overrides keeps growing
- you want one place to reason about each mode
- you want token naming to become more semantic than “header/footer/grid/etc”

I would not split the whole app by theme. I would split only the visual token layer. Concretely, the clean version would look like this:

1. `app_theme_shared.dart`
   Contains typed theme contracts like `AppLineThemeData`, `AppSurfaceThemeData`, `AppAccentThemeData`, spacing, radii, and shared resolvers.

2. `app_theme_light.dart`
   Exports one `appLightThemeData` constant.

3. `app_theme_dark.dart`
   Exports one `appDarkThemeData` constant.

4. `app_theme.dart`
   Small facade with `AppThemeData forBrightness(Brightness brightness)`.

That would be closer to `tw_chat`, but with one important improvement: prefer returning a theme object from brightness rather than mutating a global mode like `ChatSkin.setMode(...)`. For the main app, scoped lookup is cleaner and safer than a global singleton.

So the short answer is:
- yes, a similar split is a good idea
- no, do not split widgets/pages into separate dark/light files
- split the token/config layer only

Given where this app is now, I think that is the right next structural move before app_ui_config.dart becomes a long mixed bag of unrelated tokens. If you want, I can do that refactor next and migrate the current line/surface/button tokens into a shared `AppThemeData` shape.