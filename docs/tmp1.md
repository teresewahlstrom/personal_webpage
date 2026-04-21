# SOLVED
SOLVED
* subtle grid with small unit size was introduced behind the chat list.
* removed H4-H6
* increased weight of H3
* List spacing to headers made more similiar to distance between regular text and headers
* remade with additive to the regular paragraph rather than stand-alone: list (nested and top-level) spacings, header spacings, blockquote, 
* made list marker spacing multiplier-based instead of fixed px so they scale more naturally with typography 

PERHAPS SOLVED (will verify after deployment)
* The nice format of copied material from tw_chat that we introduced works on Chrome using a computer, but not using Chrome on a phone, why? can it be solved?
* Bug in tw_chat when using Chrome on phone/touchdevice
I can select the text in the text input, but i do not get the chrome in-situ copy/paste-menu


# SOON SOLVED


# NEXT












# tw_chat scrollbar
- Scroll thumbbar should go up to end of chat list, I know I have instructed otherwise in the past and there are likely some uggly solution somewhere that hinders it to go beyond that top shadow
- scroll thumbbar in text input does not go entire way down, but it does so on chrome


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
