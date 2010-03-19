/* ----====----====----====----====----====----====----====----====----====----
GameView.h (jeweltoy)

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
#import <OpenGL/gl.h>

@class Game, GameController, OpenGLSprite;

@interface GameView : NSOpenGLView
{
    IBOutlet GameController	*gameController;
    
    BOOL			m_glContextInitialized;

    NSColor			*backgroundColor;
    NSMutableArray		*gemImageArray;
    NSImage			*backgroundImage;
    NSImage			*crosshairImage;
    NSImage			*movehintImage;

    //OpenGLSprites!
    OpenGLSprite		*backgroundSprite, *crosshairSprite, *movehintSprite;
    NSMutableArray		*gemSpriteArray;

    //backgrounds
    NSMutableArray		*backgroundImagePathArray;
    
    id				legend;
    NSAttributedString		*hiScoreLegend;

    NSImage			*legendImage;
    OpenGLSprite		*legendSprite;
    
    NSArray			*hiScoreNumbers, *hiScoreNames;
    int				ticsSinceLastMove, scoreScroll;
    
    NSPoint			dragStartPoint;
    
    Game			*game;
        
    NSDictionary		*docTypeDictionary;
    
    BOOL			animating, showHighScores, paused, muted, animationStatus, showHint;
}

- (void) graphicSetUp;
- (void) loadImageArray;

// ANIMATE
- (void) setMuted:(BOOL)value;
- (void) setShowHint:(BOOL)value;
- (void) setPaused:(BOOL)value;
- (void) setAnimating:(BOOL)value;
- (BOOL) isAnimating;
- (void) animate;

- (void) setGame:(Game *) agame;
- (Game *) game;
- (NSArray *) imageArray;
- (NSArray *) spriteArray;
- (void) newBackground;
- (void) setLegend:(id)value;
- (void) setHTMLLegend:(NSString *)value;
- (void) setHiScoreLegend:(NSAttributedString *)value;
- (void) setHTMLHiScoreLegend:(NSString *)value;
- (void) setLastMoveDate;

- (void) showHighScores:(NSArray *)scores andNames:(NSArray *)names;

// Standard view create/free methods
- (id)initWithFrame:(NSRect)frame;
- (void)dealloc;

// Drawing
- (void)drawRect:(NSRect)rect;
- (void) showScores;
- (BOOL)isOpaque;

// Event handling
- (void)mouseDown:(NSEvent *)event;
- (void)mouseDragged:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;

@end
