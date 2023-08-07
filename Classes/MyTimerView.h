/* ----====----====----====----====----====----====----====----====----====----
MyTimerView.h (jeweltoy)

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

@interface MyTimerView : NSView
{
    float meter;
    float decrement;
    id	target;
    SEL	runOutSelector;
    SEL runOverSelector;
    NSTimer	*timer;
    BOOL	isRunning;
    
    NSColor	*color1;
    NSColor	*color2;
    NSColor	*colorOK;
    NSColor	*backColor;
}
// Standard view create/free methods
- (id)initWithFrame:(NSRect)frame;
- (void)dealloc;

// Drawing
- (void)drawRect:(NSRect)rect;
- (BOOL)isOpaque;

// Utility
- (void) setPaused:(BOOL) value;
- (void) incrementMeter:(float) value;
- (void) setDecrement:(float) value;
- (void) decrementMeter:(float) value;
- (void) setTimerRunningEvery:(NSTimeInterval) timeInterval
                    decrement:(float) value
                   withTarget:(id) targ
                   whenRunOut:(SEL) runOutSel
                  whenRunOver:(SEL) runOverSel;
- (void) runTimer;
- (void) setTimer:(float)value;
- (float) meter;


@end
