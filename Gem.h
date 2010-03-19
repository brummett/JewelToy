/* ----====----====----====----====----====----====----====----====----====----
Gem.h (jeweltoy)

JewelToy is a simple game played against the clock.
Copyright (C) 2001  Giles Williams

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
----====----====----====----====----====----====----====----====----====---- */

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#define GEMSTATE_RESTING	1
#define GEMSTATE_FADING		2
#define GEMSTATE_FALLING	3
#define GEMSTATE_SHAKING	4
#define GEMSTATE_ERUPTING	5
#define GEMSTATE_MOVING		6
//
// MW...
//
#define GEMSTATE_SHIVERING	7
//

#define FADE_STEPS		8.0
#define GRAVITY			1.46
#define GEM_ERUPT_DELAY		45

//
// Open GL Z value for gems
//
#define GEM_SPRITE_Z		-0.25
//

@class	OpenGLSprite;

@interface Gem : NSObject
{
    int		gemType;
    NSImage	*image;

    // Open GL
    OpenGLSprite	*sprite;
    //
    
    NSSound	*tink;
    NSSound	*sploink;
    
    // MW
    int		waitForFall;
    //
    
    int		state;
    int		animationCounter;
    double	vx, vy;
    NSPoint	positionOnScreen, positionOnBoard;
}

- (id)	init;
- (void) dealloc;

+ (Gem *) gemWithNumber:(int) d andImage:(NSImage *)img;
+ (Gem *) gemWithNumber:(int) d andSprite:(OpenGLSprite *)aSprite;

- (int) animate;
- (void) fade;
- (void) fall;
- (void) shake;
- (void) erupt;
// MW...
- (void) shiver;
//

- (int) gemType;
- (void) setGemType:(int) d;

- (NSImage *) image;
- (void) setImage:(NSImage *) value;
- (void) drawImage;

- (OpenGLSprite *) sprite;
- (void) setSprite:(OpenGLSprite *) value;
- (void) drawSprite;

- (int) state;
- (void) setState:(int) value;

- (int) animationCounter;
- (void) setAnimationCounter:(int) value;

- (NSPoint) positionOnScreen;
- (void) setPositionOnScreen:(int) valx :(int) valy;
- (void) setVelocity:(int) valx :(int) valy :(int) steps;

- (NSPoint) positionOnBoard;
- (void) setPositionOnBoard:(int) valx :(int) valy;

- (void) setSoundsTink:(NSSound *) tinkSound Sploink:(NSSound *) sploinkSound;

@end
