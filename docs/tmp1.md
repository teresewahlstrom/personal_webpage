# SOLVED
SOLVED
* nudge underline of text + links slightly downwards
* make the strike through line same width as the underline with same hack as underline?

PERHAPS SOLVED (will verify after deployment)
* I get double selection markers handles (you know those that looks like teardrops) on touch devices in text input field.... The magenta version currently seems to work with copy/paste, but not the blue. 

* tw_chat scrollbar within the text input field issue:
    - thumbbar does not go as far down on phone using Chrome as it does on computer using Chrome
    - If you still see a slight offset on phone after deployment, next step is to tune crossAxisMargin and possibly disable interactive for the composer scrollbar on touch web in the same file, which can further reduce mobile-web scrollbar quirks.

# SOON SOLVED


# NEXT
* do we have a PWS issue somehow that hinders the latest updates to carry through to the deployment? Or is it some other issue? Using a browser or device that I have not yet used gives me the latest version of the deployment and not the stale issue i have got with browsers/devices I have already used










# Keywords förb:
    * Lägga till context engineering 
    * Mechanical engineering är menat ihop på två rader

    Make color mean something Right now color seems mostly aesthetic. 
    Better if it encodes category:
    magenta = commercial / strategic / leverage
    cyan = systems / integration / collaboration
    charcoal = engineering / technical coreThen the composition becomes legible, not just attractive.

# DRY-ify
Göra ett shared paket:
- återanvända tw_chat scrollbar i main app från tw_chat?
- återanvända arrow-key-scroll i tw_chat från main app?
- gemensam färg-config mellan tw_chat och main app?





* fix so that "t1grid.com" works, currently only "www.t1grid.com" works





















Yes, this matches a **PWA/service-worker cache issue** (you wrote “PWS”), not a missing deployment.

New browsers/devices have no old service worker cache, so they fetch latest immediately. Existing browsers can stay on stale cached app shell/assets until the worker updates.

I added a deploy-side fix:

1. [cloudflare-pages-build.sh](D:/projects/flutter/personal_webpage_2/cloudflare-pages-build.sh)  
Copies Cloudflare Pages files like `_headers` into the built output.

2. [web/_headers](D:/projects/flutter/personal_webpage_2/web/_headers)  
Sets `no-cache/no-store` for Flutter entry files (`/index.html`, `/main.dart.js`, `/flutter_bootstrap.js`, `/flutter_service_worker.js`) and long cache for static asset folders.

After redeploy, old browsers may still need a one-time reset:
1. Hard refresh (`Ctrl+Shift+R`).
2. If still stale: DevTools -> Application -> Service Workers -> Unregister, then clear site data and reload.

I could not run a full local Flutter build here because `flutter` commands timed out in this environment, so the final validation should happen in your deploy run.