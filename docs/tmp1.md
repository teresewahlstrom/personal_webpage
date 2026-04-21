# SOLVED
SOLVED

PERHAPS SOLVED (will verify after deployment)
* fix so that "t1grid.com" works, currently only "www.t1grid.com" works (I did some DNS changes in CloudFlare)

# SOON SOLVED


# NEXT
* do we have a PWS issue somehow that hinders the latest updates to carry through to the deployment? Or is it some other issue? Using a browser or device that I have not yet used gives me the latest version of the deployment and not the stale issue i have got with browsers/devices I have already used

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