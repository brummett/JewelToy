6/26/2017

picking a different clear color worked.

10/12/2019

Removed deprecated calls.

Could not get this to code sign (This Mac appears not to have a device ID), so turned signing off by setting the code signing identity to empty.

Created a new development profile for this Mac Mini. Now this project code signs.
Added Entitlements file.
Replaced .nibs by .xibs


7/07/2023
• bumped up min SDK from 10.10 to 10.13.
• added check for tink and sploink to not play if already playing.
• discovered that the gem's image ivar isn't used in normal use, but can be with alternate graphics, which I did not test.
• ScoreBubble sprites weren't being initialized correctly because when the app used OpenGL to request a texture number the wrong OpenGLGraphicContext was current. Fixed.

7/20/2023
• Mystery: the app works correctly on my M1 Mac Mini, but none of the OpenGL sprites draw on when the same code is compiled and run on other M1 Macs. Why?
• The non-English localizations were broken. Fixed for French, German, Japanese.

