//
//  ScoreBubble.h
//  jeweltoy
//
//  Created by Mike Wessler on Sat Jun 15 2002.
//
/*
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

// Open GL Z value for scorebubbles
//
#define SCOREBUBBLE_SPRITE_Z	-0.30
//

@class NSOpenGLContext;
@class	Sprite;

@interface ScoreBubble : NSObject
+(ScoreBubble *)scoreWithValue:(int)value At:(NSPoint)loc Duration:(int)count;

-(void)drawImage;
-(void)drawSprite;

-(id)initWithValue:(int)value At:(NSPoint)loc Duration:(int)count;
-(int)animate;

-(int)animationCount;
-(void)setAnimationCount:(int)count;

-(int)value;

-(NSImage *)image;

-(NSPoint)screenLocation;
@end
