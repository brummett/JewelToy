/* ----====----====----====----====----====----====----====----====----====----
Gem.m (jeweltoy)

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


#import "Gem.h"

// Open GL
#import "OpenGLSprite.h"
//

@implementation Gem

- (id)	init
{
    self = [super init];
    [self setSoundsTink:[NSSound soundNamed:@"tink"] Sploink:[NSSound soundNamed:@"sploink"]];
    // MW...
    waitForFall= 0;
    //
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

+ (Gem *) gemWithNumber:(int) d andImage:(NSImage *)img
{
    Gem	*result = [[[Gem alloc] init] autorelease];
    [result setGemType:d];
    [result setImage:img];
    [result setSoundsTink:[NSSound soundNamed:@"tink"] Sploink:[NSSound soundNamed:@"sploink"]];
    return result;
}

+ (Gem *) gemWithNumber:(int) d andSprite:(OpenGLSprite *)aSprite
{
    Gem	*result = [[[Gem alloc] init] autorelease];
    [result setGemType:d];
    [result setSprite:aSprite];
    [result setSoundsTink:[NSSound soundNamed:@"tink"] Sploink:[NSSound soundNamed:@"sploink"]];
    return result;
}

- (int) animate
{
    if (state == GEMSTATE_RESTING)
    {
        [self setPositionOnScreen:positionOnBoard.x*48:positionOnBoard.y*48];
        animationCounter = 0;
    }
    if (state == GEMSTATE_FADING)
    {
        [self setPositionOnScreen:positionOnBoard.x*48:positionOnBoard.y*48];
        if (animationCounter > 0)	animationCounter--;
    }
    // MW...
    if (state== GEMSTATE_SHIVERING) {
        positionOnScreen.x= positionOnBoard.x*48+(rand()%3)-1;
        positionOnScreen.y= positionOnBoard.y*48;
    }
    //
    if (state == GEMSTATE_FALLING)
    {
        if (animationCounter<waitForFall) {
            positionOnScreen.x= positionOnBoard.x*48;
            //positionOnScreen.y= positionOnBoard.y*48;
            animationCounter++;
        }
        else if (positionOnScreen.y > (positionOnBoard.y*48))
        {
            positionOnScreen.y += vy;
            positionOnScreen.x = positionOnBoard.x*48;
            vy -= GRAVITY;
            animationCounter++;
        }
        else
        {
			[tink play];
            positionOnScreen.y = positionOnBoard.y * 48;
            state = GEMSTATE_RESTING;
        }
    }
    if (state == GEMSTATE_SHAKING)
    {
        positionOnScreen.x = positionOnBoard.x*48+(rand()%5)-2;
        positionOnScreen.y = positionOnBoard.y*48+(rand()%5)-2;
        if (animationCounter > 1) animationCounter--;
        else state = GEMSTATE_RESTING;
    }
    if (state == GEMSTATE_ERUPTING)
    {
        if (positionOnScreen.y > -48)
        {
            if (animationCounter < GEM_ERUPT_DELAY)
            {
                positionOnScreen.x = positionOnBoard.x*48+(rand()%5)-2;
                positionOnScreen.y = positionOnBoard.y*48+(rand()%5)-2;
            }
            else
            {
                positionOnScreen.y += vy;
                positionOnScreen.x += vx;
                vy -= GRAVITY;
            }
            animationCounter++;
        }
        else
        {
            animationCounter = 0;
        }
    }
    if (state == GEMSTATE_MOVING)
    {
        if (animationCounter > 0)
        {
            positionOnScreen.y += vy;
            positionOnScreen.x += vx;
            animationCounter--;
        }
        else	state = GEMSTATE_RESTING;
    }
    return animationCounter;
}

- (void) fade
{
    [sploink play];
    state = GEMSTATE_FADING;
    animationCounter = FADE_STEPS;
}
- (void) fall
{
    state = GEMSTATE_FALLING;
    // MW...
    waitForFall= rand()%6;
    //
    vx = 0;
    vy = 0;
    animationCounter = 1;
}
// MW...
- (void) shiver
{
    state= GEMSTATE_SHIVERING;
    animationCounter= 0;
}
//
- (void) shake
{
    state = GEMSTATE_SHAKING;
    animationCounter = 25;
}
- (void) erupt
{
    [self setVelocity:(rand()%5)-2:(rand()%7)-2:1];
    state = GEMSTATE_ERUPTING;
    animationCounter = GEM_ERUPT_DELAY;
}

- (int) gemType
{
    return gemType;
}
- (void) setGemType:(int) d
{
    gemType = d;
}

- (NSImage *) image
{
    return image;
}
- (void) setImage:(NSImage *) value
{
    image = value;
}
- (void) drawImage
{
    if (state == GEMSTATE_FADING)
        [[self image] compositeToPoint:[self positionOnScreen] operation:NSCompositeSourceOver fraction:(animationCounter / FADE_STEPS)];
    else
        [[self image] compositeToPoint:[self positionOnScreen] operation:NSCompositeSourceOver];
}

- (OpenGLSprite *) sprite
{
    return sprite;
}
- (void) setSprite:(OpenGLSprite *) value
{
    sprite = value;
}
- (void) drawSprite
{
    if (state == GEMSTATE_FADING)
        [[self sprite] blitToX:positionOnScreen.x
                             Y:positionOnScreen.y
                             Z:GEM_SPRITE_Z
                         Alpha:(animationCounter / FADE_STEPS)];
    else
        [[self sprite] blitToX:positionOnScreen.x
                             Y:positionOnScreen.y
                             Z:GEM_SPRITE_Z
                         Alpha:1.0];
}

- (int) state
{
    return state;
}
- (void) setState:(int) value
{
    state = value;
}

- (int) animationCounter
{
    return animationCounter;
}
- (void) setAnimationCounter:(int) value
{
    animationCounter = value;
}

- (NSPoint) positionOnScreen
{
    return positionOnScreen;
}
- (void) setPositionOnScreen:(int) valx :(int) valy
{
    positionOnScreen.x = valx;
    positionOnScreen.y = valy;
}
- (void) setVelocity:(int) valx :(int) valy :(int) steps
{
    vx = valx;
    vy = valy;
    animationCounter = steps;
    state = GEMSTATE_MOVING;
}

- (NSPoint) positionOnBoard
{
    return positionOnBoard;
}
- (void) setPositionOnBoard:(int) valx :(int) valy
{
    positionOnBoard.x = valx;
    positionOnBoard.y = valy;
}

- (void) setSoundsTink:(NSSound *) tinkSound Sploink:(NSSound *) sploinkSound
{
    tink = tinkSound;
    sploink = sploinkSound;
}

@end
