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

7/21/2023
• Created git branch classic_opengl with the most recent version of the app that worked on old machines but not on M1 Air.
• Created git branch appkit that removes OpenGL and just draws using AppKit == Cocoa
• Set git Master to point to appkit.

7/27/2023
Also fixed slow running code searching folders for background images. It was so slow,  you'd think the program had crashed.
If you do a:

git pull

git checkout master ;# gives you the Appkit version
git checkout classic_opengl  ;# gives you the OpenGL version

The Appkit branch should work on your Mac. I've had reports that the openGL branch just draws
a gray square on some Macs. I'm trying to track down why it works on some Macs and not others.


