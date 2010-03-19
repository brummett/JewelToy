/* ----====----====----====----====----====----====----====----====----====----
MyTimerView.m (jeweltoy)

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

#import "MyTimerView.h"

@implementation MyTimerView

- (id)initWithFrame:(NSRect)frame {
    [super initWithFrame:frame];
    
    meter	= 0.5;
    color1	= [[NSColor redColor] retain];
    color2	= [[NSColor yellowColor] retain];
    colorOK	= [[NSColor greenColor] retain];
    backColor	= [[NSColor blackColor] retain];
    isRunning	= NO;
    
    return self;
}

// dealloc is the method called when objects are being freed. (Note that "release"
// is called to release objects; when the number of release calls reduce the
// total reference count on an object to zero, dealloc is called to free
// the object.  dealloc should free any memory allocated by the subclass
// and then call super to get the superclass to do additional cleanup.

- (void)dealloc {
    [color1 release];
    [color2 release];
    [colorOK release];
    [backColor release];
    [super dealloc];
}

// drawRect: should be overridden in subclassers of NSView to do necessary
// drawing in order to recreate the the look of the view. It will be called
// to draw the whole view or parts of it (pay attention the rect argument);

- (void)drawRect:(NSRect)rect {
    NSRect dotRect;

    [backColor set];
    NSRectFill([self bounds]);   // Equiv to [[NSBezierPath bezierPathWithRect:[self bounds]] fill]

    dotRect.origin.x = 4;
    dotRect.origin.y = 4;
    dotRect.size.width  = meter * ([self bounds].size.width - 8);
    dotRect.size.height = [self bounds].size.height - 8;
    
    [colorOK set];
    //
    // another MW change...
    //
    if (decrement!=0)
    {
        if (meter < 0.3) [color2 set];
        if (meter < 0.1) [color1 set];
    }

    NSRectFill(dotRect);   // Equiv to [[NSBezierPath bezierPathWithRect:dotRect] fill]
}

- (BOOL)isOpaque {
    return YES;
}

// Utility
- (void) setPaused:(BOOL) value
{
    isRunning = !value;
}

- (void) incrementMeter:(float) value
{
    meter += value;
    if (meter > 1) meter = 1;
    [self setNeedsDisplay:YES];
}

- (void) setDecrement:(float) value
{
    decrement = value;
}

- (void) decrementMeter:(float) value
{
    meter -= value;
    if (meter < 0) meter = 0;
    [self setNeedsDisplay:YES];
}

- (void) setTimerRunningEvery:(NSTimeInterval) timeInterval
            decrement:(float) value
            withTarget:(id) targ
            whenRunOut:(SEL) runOutSel
            whenRunOver:(SEL) runOverSel
{
    decrement = value;
    target = targ;
    runOutSelector = runOutSel;
    runOverSelector = runOverSel;
    if (timer)
    {
        [timer invalidate];
    }
    timer = [NSTimer	scheduledTimerWithTimeInterval:timeInterval
                target:self
                selector:@selector(runTimer)
                userInfo:self
                repeats:YES];
    isRunning = YES;
}

- (void) runTimer
{
    if (isRunning)
    {
        if (meter == 1)
        {
            isRunning = NO;
            [target performSelector:runOverSelector];
            return;
        }
        [self decrementMeter:decrement];
        if (meter == 0 && decrement!=0)	// MW change added '&& decrement'
        {
            isRunning = NO;
            [target performSelector:runOutSelector];
            return;
        }
    }
}

- (void) setTimer:(float)value
{
    isRunning = NO;
    meter = value;
    [self setNeedsDisplay:YES];
}

- (float) meter
{
    return meter;
}


@end
