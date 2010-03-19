/* ----====----====----====----====----====----====----====----====----====----
GameView.m (jeweltoy)

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

#include <math.h>
//#import <OpenGL/gl.h>
//#import <OpenGL/glu.h>

#import "GameView.h"
#import "GameController.h"
#import "Game.h"
#import "Gem.h"
//
// MW...
//
#import "ScoreBubble.h"
//
// OpenGLSprites
//
#import "OpenGLSprite.h"


@implementation GameView

- (id)initWithFrame:(NSRect)frame {

    //NSData	*tiffData;

    NSOpenGLPixelFormatAttribute attrs[] = {
        NSOpenGLPFADepthSize, 1,
        NSOpenGLPFAAccelerated,
        0};
    NSOpenGLPixelFormat *pixFmt;

    pixFmt = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    self = [super initWithFrame:frame pixelFormat:pixFmt];

    m_glContextInitialized = NO;

    animating = NO;
    showHighScores = NO;
    showHint = YES;
    ticsSinceLastMove = 0;
    
    docTypeDictionary = [NSDictionary dictionary];
    
    return self;
}

- (void) dealloc
{
    if (backgroundColor)
        [backgroundColor release];
    if (gemImageArray)
        [gemImageArray release];
    if (gemSpriteArray)
        [gemImageArray release];
    if (backgroundImagePathArray)
        [backgroundImagePathArray release];
    [super dealloc];
}

- (void) graphicSetUp
{
    int		i;
    NSData	*tiffData;

    backgroundColor = [[NSColor purpleColor] retain];

    [self loadImageArray];

        tiffData = [[NSUserDefaults standardUserDefaults]	dataForKey:@"backgroundTiffData"];
    if (tiffData)
        backgroundImage = [[NSImage alloc] initWithData:tiffData];
    else
        backgroundImage = [NSImage imageNamed:@"background"];

    crosshairImage = [NSImage imageNamed:@"cross"];
    movehintImage = [NSImage imageNamed:@"movehint"];

    //////
    //
    // Make the Open GL Sprites!
    //
    backgroundSprite = [[OpenGLSprite alloc] initWithImage:backgroundImage
                                             cropRectangle:NSMakeRect(0.0, 0.0, [backgroundImage size].width, [backgroundImage size].height)
                                                      size:NSMakeSize(384.0,384.0)];

    crosshairSprite = [[OpenGLSprite alloc] initWithImage:crosshairImage
                                            cropRectangle:NSMakeRect(0.0, 0.0, [crosshairImage size].width, [crosshairImage size].height)
                                                     size:NSMakeSize(48.0,48.0)];
    movehintSprite = [[OpenGLSprite alloc] initWithImage:movehintImage
                                           cropRectangle:NSMakeRect(0.0, 0.0, [movehintImage size].width, [movehintImage size].height)
                                                    size:NSMakeSize(48.0,48.0)];
    if (gemSpriteArray)
        [gemSpriteArray release];
    gemSpriteArray = [[NSMutableArray arrayWithCapacity:0] retain];
    for (i = 0; i < 7; i++)
    {
        NSImage	*image = [gemImageArray objectAtIndex:i];
        OpenGLSprite *sprite = [[OpenGLSprite alloc] initWithImage:image
                                                     cropRectangle:NSMakeRect(0.0, 0.0, [image size].width, [image size].height)
                                                              size:NSMakeSize(48.0,48.0)];
        
        [gemSpriteArray addObject:sprite];
        [sprite release];
    }

    if (!legendImage)
    {
        legendImage = [[NSImage alloc] initWithSize:NSMakeSize(384,384)];
        [legendImage lockFocus];
        [[NSColor clearColor] set];
        NSRectFill(NSMakeRect(0,0,384,384));
        [legendImage unlockFocus];
        legendSprite = [[OpenGLSprite alloc] initWithImage:legendImage
                                            cropRectangle:NSMakeRect(0.0, 0.0, [legendImage size].width, [legendImage size].height)
                                                    size:[legendImage size]];
        
        [self setLegend:[NSImage imageNamed:@"title"]];
    }
    //
    //
    //////

    // if custom backgrounds are to be used initialise the array of paths to images
    //
    if ([[NSUserDefaults standardUserDefaults]	boolForKey:@"useCustomBackgrounds"])
    {
        NSString *customBackgroundFolderPath = [[[NSUserDefaults standardUserDefaults] stringForKey:@"customBackgroundFolderPath"] stringByResolvingSymlinksInPath];

        //NSLog(@"customBackgroundFolderPath = ",customBackgroundFolderPath);
        
        if (customBackgroundFolderPath)
        {
            // borrowed code here
            NSDirectoryEnumerator *picturesFolderEnum;
            NSString *relativeFilePath,*fullPath;
            // grab all picture formats NSImage knows about - we'll assume that if we can read them,
            // we can set them to be the desktop picture
            NSArray *imageFormats=[NSImage imageFileTypes];

            if (backgroundImagePathArray)
                [backgroundImagePathArray autorelease];
            backgroundImagePathArray = [[NSMutableArray arrayWithCapacity:0] retain];
            // build the array

            // borrowed code here
            // now we need to go scan the folder chosen, enumerating through to find all picture files
            picturesFolderEnum=[[NSFileManager defaultManager] enumeratorAtPath:customBackgroundFolderPath];

            relativeFilePath=[picturesFolderEnum nextObject];
            while (relativeFilePath)
            {
                fullPath=[NSString stringWithFormat:@"%@/%@",customBackgroundFolderPath,relativeFilePath];

                // If the file's extension or type matches a format that NSImage understands,
                // then we're good to go, and we add a new menu item, using the display name
                // (which may have a hidden extension) for the menu item's title and passing
                // the full path to the picture to store with the menu item
                if ([imageFormats containsObject:[relativeFilePath pathExtension]] ||
                    [imageFormats containsObject:NSHFSTypeOfFile(fullPath)])
                {
                    [backgroundImagePathArray addObject:fullPath];
                }
                relativeFilePath=[picturesFolderEnum nextObject];
            }

            //NSLog(@"[backgroundImagePathArray count]= %d",[backgroundImagePathArray count]);
            
            //
        }

    }

    [self newBackground];
    
    
}

- (void) loadImageArray
{
    BOOL	useAlternateGraphics, useImportedGraphics;
    useAlternateGraphics = [[NSUserDefaults standardUserDefaults]
                                        boolForKey:@"useAlternateGraphics"];
    useImportedGraphics = [[NSUserDefaults standardUserDefaults]
                                        boolForKey:@"useImportedGraphics"];
    if (gemImageArray)
        [gemImageArray release];
    gemImageArray = [[NSMutableArray arrayWithCapacity:0] retain];
    if (!useAlternateGraphics)
    {
        //NSLog(@"Loading regular graphics");
        [gemImageArray addObject:[NSImage imageNamed:@"1gem"]];
        [gemImageArray addObject:[NSImage imageNamed:@"2gem"]];
        [gemImageArray addObject:[NSImage imageNamed:@"3gem"]];
        [gemImageArray addObject:[NSImage imageNamed:@"4gem"]];
        [gemImageArray addObject:[NSImage imageNamed:@"5gem"]];
        [gemImageArray addObject:[NSImage imageNamed:@"6gem"]];
        [gemImageArray addObject:[NSImage imageNamed:@"7gem"]];
    }
    else
    {
        //NSData	*tiffData = [[[NSUserDefaults standardUserDefaults]
        //                                dataForKey:@"tiffData"] retain];
        if (!useImportedGraphics)
        {
            //NSLog(@"Loading alternate graphics");
            [gemImageArray addObject:[NSImage imageNamed:@"1gemA"]];
            [gemImageArray addObject:[NSImage imageNamed:@"2gemA"]];
            [gemImageArray addObject:[NSImage imageNamed:@"3gemA"]];
            [gemImageArray addObject:[NSImage imageNamed:@"4gemA"]];
            [gemImageArray addObject:[NSImage imageNamed:@"5gemA"]];
            [gemImageArray addObject:[NSImage imageNamed:@"6gemA"]];
            [gemImageArray addObject:[NSImage imageNamed:@"7gemA"]];
        }
        else
        {
            int i = 0;
            //NSLog(@"Loading custom graphics");
            for (i = 0; i < 7; i++)
            {
                NSString *key = [NSString stringWithFormat:@"tiffGemImage%d", i];
                NSData	*tiffData = [[NSUserDefaults standardUserDefaults]
                                        dataForKey:key];
                NSImage	*gemImage = [[NSImage alloc] initWithData:tiffData];
                [gemImageArray addObject:gemImage];
                [gemImage release];
            }
            
        }
    }
}

- (void) setMuted:(BOOL)value
{
    muted = value;
}

- (void) setShowHint:(BOOL)value
{
    showHint = value;
}

- (void) setPaused:(BOOL)value
{
    paused = value;
    if (paused)
    {
        animationStatus = animating;
        animating = NO;
    }
    else
        animating = animationStatus;
}

- (void) setAnimating:(BOOL)value
{
    animating = value;
}

- (BOOL) isAnimating
{
    return animating;
}

// ANIMATE called by the Timer
- (void) animate
{
    if (!paused)
    {
        //
        // MIKE WESSLER'S Scorebubbles
        //
        int b;
        //
        // needsUpdate added so setNeedsDisplay gets called once at most
        //
        BOOL needsUpdate = FALSE;
        //
        // animate bubbles, if any
        for (b=0; b<[[game scoreBubbles] count]; b++) {
            ScoreBubble *sb= [[game scoreBubbles] objectAtIndex:b];
            int more= [sb animate];
            needsUpdate = TRUE;
            if (!more) {
                [[game scoreBubbles] removeObjectAtIndex:b];
                b--;
            }
        }
        //
        ////
        
        if (animating)
        {
            //NSLog(@"GameView.animate");
            if (game)
            {
                int i,j,c;	// animate each gem in the grid
                c = 0;		// animation accumulator
                for (i = 0; i < 8; i++)
                    for (j = 0; j < 8; j++)
                        if ([game gemAt:i:j])	c += [[game gemAt:i:j] animate];
                if (c == 0)
                    [gameController animationEnded];
            }
            needsUpdate = TRUE;
        }
        else
        {
            ticsSinceLastMove++;
            if (ticsSinceLastMove > 500)
            {
                needsUpdate = TRUE;
            }
        }
	if (needsUpdate)
	    [self setNeedsDisplay:YES];
    }
}

- (void) setGame:(Game *) agame
{
    game = agame;
}
- (Game *) game
{
    return game;
}
- (NSArray *) imageArray
{
    return gemImageArray;
}
- (NSArray *) spriteArray
{
    return gemSpriteArray;
}

- (void) newBackground
{
    if (([gameController useCustomBackgrounds])&&(backgroundImagePathArray)&&([backgroundImagePathArray count] > 0))
    {
        NSString *imagePath = [backgroundImagePathArray objectAtIndex:0];
        [backgroundImagePathArray addObject:imagePath];
        [backgroundImagePathArray removeObjectAtIndex:0];
        //NSLog(@"Taking image from path: %@",imagePath);
        
        backgroundImage = [[NSImage alloc] initWithContentsOfFile:imagePath];
        
        //NSLog(@"Image size is %f x %f",[backgroundImage size].width, [backgroundImage size].height);

        [backgroundSprite substituteTextureFromImage:backgroundImage];
        //backgroundSprite = [[OpenGLSprite alloc] initWithImage:backgroundImage
        //                                         cropRectangle:NSMakeRect(0.0, 0.0, [backgroundImage size].width, [backgroundImage size].height)
        //                                                 size:NSMakeSize(384.0,384.0)];
    }
    else
    {
        NSData *tiffData = [[NSUserDefaults standardUserDefaults]	dataForKey:@"backgroundTiffData"];
        if (tiffData)
            backgroundImage = [[NSImage alloc] initWithData:tiffData];
        else
            backgroundImage = [NSImage imageNamed:@"background"];
        backgroundSprite = [[OpenGLSprite alloc] initWithImage:backgroundImage
                                                 cropRectangle:NSMakeRect(0.0, 0.0, [backgroundImage size].width, [backgroundImage size].height)
                                                          size:NSMakeSize(384.0,384.0)];
    }    
}

- (void) setLegend:(id)value
{
    // NEED TO DRAW LEGEND INTO LEGENDIMAGE THEN REPLACE THE TEXTURE IN LEGENDSPRITE

    if (!value)		// is null
    {
        //NSLog(@"Legend cleared");
        legend = value;
        [self setNeedsDisplay:YES];
        return;
    }

    //
    //
    [legendImage lockFocus];
    [[NSColor clearColor] set];
    NSRectFill(NSMakeRect(0,0,384,384));
    if ([value isKindOfClass:[NSAttributedString class]])
    {
        NSPoint legendPoint = NSMakePoint((384 - [value size].width)/2,(384 - [value size].height)/2);
        [(NSAttributedString *)value drawAtPoint:legendPoint];
    }
    if ([value isKindOfClass:[NSImage class]])
    {
        NSPoint legendPoint = NSMakePoint((384 - [value size].width)/2,(384 - [value size].height)/2);
        [(NSImage *)value compositeToPoint:legendPoint operation:NSCompositeSourceOver];
    }
    [legendImage unlockFocus];
    [legendSprite replaceTextureFromImage:legendImage
                            cropRectangle:NSMakeRect(0.0, 0.0, [legendImage size].width, [legendImage size].height)];

    legend = legendSprite;
    ticsSinceLastMove = 0;
    showHighScores = NO;
    animating = NO;

    [self setNeedsDisplay:YES];
    
    //
    //
}

- (void) setHTMLLegend:(NSString *)value
{
    NSData		*htmlData = [NSData dataWithBytes:[value cString] length:[value length]];
    [self setLegend:[[NSAttributedString alloc] initWithHTML:htmlData documentAttributes:NULL]];
}

- (void) setHiScoreLegend:(NSAttributedString *)value
{
    hiScoreLegend = value;
}

- (void) setHTMLHiScoreLegend:(NSString *)value
{
    NSData *htmlData = [NSData dataWithBytes:[value cString] length:[value length]];
    [self setHiScoreLegend:[[NSAttributedString alloc] initWithHTML:htmlData documentAttributes:NULL]];
}

- (void) setLastMoveDate
{
    ticsSinceLastMove = 0;
}

- (void) showHighScores:(NSArray *)scores andNames:(NSArray *)names
{
    hiScoreNumbers = scores;
    hiScoreNames = names;
    showHighScores = YES;
    animating = NO;
    scoreScroll = 0;
    [self setNeedsDisplay:YES];
}


// drawRect: should be overridden in subclassers of NSView to do necessary
// drawing in order to recreate the the look of the view. It will be called
// to draw the whole view or parts of it (pay attention the rect argument);
// it will also be called during printing if your app is set up to print.

- (void)drawRect:(NSRect)rect {
    int i,j;

    // Open GL
    float	size = 384.0/2.0;	// screenSize/2;
    float	clearDepth = 1.0;

    // try to fix image loading problem
    if (!legendImage)
        [self graphicSetUp];

    //////////

    if (!m_glContextInitialized)
    {
        glShadeModel(GL_FLAT);

        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();	// reset matrix

        glFrustum(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0);	// set projection matrix
        glMatrixMode(GL_MODELVIEW);

        //glEnable(GL_DEPTH_TEST);		// depth buffer

        glEnable(GL_BLEND);			// alpha blending
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);		// alpha blending
        m_glContextInitialized = YES;
    }

    glClearColor(0.3, 0.3, 0.3, 0.0);
    glClearDepth(clearDepth);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glLoadIdentity();	// allows me to resize the window but keep position OK

    glTranslatef(-1.0,-1.0,0.0);
    glScalef(1/size,1/size,1.0);// scale to screen size and width

    if (backgroundSprite)
    {
        [backgroundSprite blitToX:0.0
                                Y:0.0
                                Z:0.0];
    }
    if ((game)&&(!paused))
    {
        for (i = 0; i < 8; i++)
            for (j = 0; j < 8; j++)
                [[game gemAt:i :j] drawSprite];
        //
        // MW - Scorebubbles
        //
        for (i=0; i<[[game scoreBubbles] count]; i++) {
            ScoreBubble *sb= [[game scoreBubbles] objectAtIndex:i];
            [sb drawSprite];
        }
        //
        ////
    }

    if ([gameController gameState] == GAMESTATE_AWAITINGSECONDCLICK)
    {
        [crosshairSprite blitToX:[gameController crossHair1Position].x
                               Y:[gameController crossHair1Position].y
                               Z:-0.5];
    }
    if (showHighScores)
    {
        [self showScores];	// draws the HighScores in the current focused view (Quartz)
        //return;		// now legendSprite contains the drawing...
    }
    if (!legend)
    {
        if ((ticsSinceLastMove > 500)&&(showHint))
        {
            [movehintSprite blitToX:[game hintPoint].x
                                   Y:[game hintPoint].y
                                   Z:-0.4
                              Alpha:(sin((ticsSinceLastMove-497.0)/4.0)+1.0)/2.0];
        }
    }
    else
    {
        if (ticsSinceLastMove > 500)
            [self setLegend:[NSImage imageNamed:@"title"]];	// show Logo
        if ([legend isKindOfClass:[OpenGLSprite class]])
        {
            //NSLog(@"Blitting legend");
            [legend blitToX:0.0 Y:0.0 Z:-0.75];
        }
    }
    glFlush();
    
}

- (void) showScores
{
    int i;
    NSPoint legendPoint;
    NSRect panelRect;
    NSMutableDictionary	*attr = [NSMutableDictionary dictionaryWithCapacity:0];

    [attr setObject:[NSColor yellowColor] forKey:NSForegroundColorAttributeName];

    [legendImage lockFocus];
    [[NSColor clearColor] set];
    NSRectFill(NSMakeRect(0,0,384,384));

    [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.5] set];
    panelRect = NSMakeRect(32, 16, 384-64, 384-32);
    NSRectFill(panelRect);
    
    
    legendPoint = NSMakePoint((384 - [hiScoreLegend size].width)/2,384 - [hiScoreLegend size].height*1.5 + scoreScroll);

    [hiScoreLegend drawAtPoint:legendPoint];
    
    for (i = 0; i< 10; i++)
    {
        NSString *s1 = [NSString stringWithFormat:@"%d",[[hiScoreNumbers objectAtIndex:i] intValue]];
        NSString *s2 = [hiScoreNames objectAtIndex:i];
        NSPoint	q1 = NSMakePoint( 192+20+1, 384 - 84 - i*30 + scoreScroll - 1); 
        NSPoint	q2 = NSMakePoint( 192-20-[s2 sizeWithAttributes:attr].width+1, 384 - 84 - i*30 + scoreScroll - 1); 
        NSPoint	p1 = NSMakePoint( 192+20, 384 - 84 - i*30 + scoreScroll); 
        NSPoint	p2 = NSMakePoint( 192-20-[s2 sizeWithAttributes:attr].width, 384 - 84 - i*30 + scoreScroll); 

        [attr setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];

        [s1 drawAtPoint:q1 withAttributes:attr];
        [s2 drawAtPoint:q2 withAttributes:attr];
        
        [attr setObject:[NSColor yellowColor] forKey:NSForegroundColorAttributeName];

        [s1 drawAtPoint:p1 withAttributes:attr];
        [s2 drawAtPoint:p2 withAttributes:attr];
    }
    [legendImage unlockFocus];
    [legendSprite replaceTextureFromImage:legendImage
                            cropRectangle:NSMakeRect(0.0, 0.0, [legendImage size].width, [legendImage size].height)];

    legend = legendSprite;
    
    showHighScores = NO;
}

// Views which totally redraw their whole bounds without needing any of the
// views behind it should override isOpaque to return YES. This is a performance
// optimization hint for the display subsystem. This applies to DotView, whose
// drawRect: does fill the whole rect its given with a solid, opaque color.

- (BOOL)isOpaque {
    return YES;
}

// Recommended way to handle events is to override NSResponder (superclass
// of NSView) methods in the NSView subclass. One such method is mouseUp:.
// These methods get the event as the argument. The event has the mouse
// location in window coordinates; use convertPoint:fromView: (with "nil"
// as the view argument) to convert this point to local view coordinates.
//
// Note that once we get the new center, we call setNeedsDisplay:YES to 
// mark that the view needs to be redisplayed (which is done automatically
// by the AppKit).

//
// I want to add a new behaviour here, the click-drag for a square
// I'm prolly going to have to fake this by sending gameController two clicks
// I might have to change the shape of the mouse cursor too!
//
- (void)mouseDown:(NSEvent *)event {
    NSPoint eventLocation = [event locationInWindow];
    NSPoint center = [self convertPoint:eventLocation fromView:nil];
    dragStartPoint = center;
}

- (void)mouseDragged:(NSEvent *)event {
    // do nothing for now
}

- (void)mouseUp:(NSEvent *)event {
    NSPoint eventLocation = [event locationInWindow];
    NSPoint center = [self convertPoint:eventLocation fromView:nil];
    
    // check situation - is this a first or second mouseUp
    if ([gameController gameState] == GAMESTATE_AWAITINGSECONDCLICK)
    {
    	//NSLog(@"click at :%f,%f",center.x,center.y);
        [gameController receiveClickAt:center.x:center.y];
    }
    else if ([gameController gameState] == GAMESTATE_AWAITINGFIRSTCLICK)
    {
        int chx1 = floor(dragStartPoint.x / 48);
        int chy1 = floor(dragStartPoint.y / 48);
        int chx2 = floor(center.x / 48);
        int chy2 = floor(center.y / 48);
        if ((chx2 != chx1)^(chy2 != chy1))	// xor checks if a valid shove's occurred!
        {
            [gameController receiveClickAt:dragStartPoint.x:dragStartPoint.y];
            [gameController receiveClickAt:center.x:center.y];
        }
        else
        {
            [gameController receiveClickAt:center.x:center.y];
        }
    }
        
}


@end
