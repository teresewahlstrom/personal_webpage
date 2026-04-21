# SOLVED
SOLVED
* Landing page updates
    * removed old skills section
    * added about me section with new text and format
    * moved two classes to the landing page config from the landing page

* Scaffold updates 
    * Add a header to the page_scaffold.dart and move the logo there
    * create a dark/light button in header instead and make it into a moon/sunlight (remove the button from the footer)
    * I no longer want the footer to always take up space on the visible window, i simply want it at the very bottom of the page

* arrow scroll widget updates
    * focus bug where scrolling in main app caused scrolling in chat app
    * Clicking elsewhere does not deselect text on phone in main page (but works in tw_chat, anything we should centralise to a shared package?)


PERHAPS SOLVED (will verify after deployment)
* fix icon for chat circle on mobile devices

---
# SOON SOLVED



---
# NEXT

* tw_chat updates
    * When one is not on the bottom of the chat, perhaps there should be a down-arrow in a button-circle that take one down to the bottom, somehow shared with the button "new message", perhaps reusing the same container?
    * The "new message" button should only display if the bottom is not currently visible

* dark/light theme update
    * Do a dark/light theme for main page as well, use some of the same color as for the dark chat for the dark theme of the main app?

* landing page update
    * Title + bgd + outline for the keyword graphic. 






---
# LATER

* Make truncation shadow same color as outline of bubble in bottom


## Fix colors/theme across main app and tw_chat
* fix tw_chat colors
    - light theme is not on brand
* Fix dark link colors
* Fix dark scroll thumb active color
* Make dark bot bubble bgd color less dull


## BUGS: phone / touch
    * copy issue formatting not resolved on phone
    * paste/copy issue not resolved on phone
    * scrollbar issue in text input fiels on phone not resolved


## Keywords impr:
    * Make color mean something Right now color seems mostly aesthetic. 
        Better if it encodes category:
        magenta = commercial / strategic / leverage
        cyan = systems / integration / collaboration
        charcoal = engineering / technical coreThen the composition becomes legible, not just attractive.

    * Make placement logic better

    * Make the logic of co-locating words better and more logic

    * use the colors from the ref pictures as i think they were nicer


## DRY-ify
Göra ett shared paket:
    - återanvända tw_chat scrollbar i main app från tw_chat?
    - återanvända arrow-key-scroll i tw_chat från main app?
    - gemensam färg-config mellan tw_chat och main app?
    - annat som kan ingå i detta?
    - Make the selection/deselction logic centralised into a wrapper? Create internal package tw_flutter_basics that can be shared with other internal packages as well as Main app. Move the scrollable behavior in there as well?


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