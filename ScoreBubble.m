//
//  ScoreBubble.m
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

#import "ScoreBubble.h"

// Open GL
//
#import "OpenGLSprite.h"
//

NSMutableDictionary *stringAttributes;

@implementation ScoreBubble

+(ScoreBubble *)scoreWithValue:(int)val At:(NSPoint)loc Duration:(int)count
{
    return [[[[self class] alloc] initWithValue:val At:loc Duration:count] autorelease];
}

-(id)initWithValue:(int)val At:(NSPoint)loc Duration:(int)count;
{
    NSString *str= [NSString stringWithFormat:@"%d", val];
    NSSize strsize;
    if (self=[super init]) {
	if (!stringAttributes) {
	    stringAttributes= [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"ArialNarrow-Bold" size:18],
		NSFontAttributeName, [NSColor blackColor], NSForegroundColorAttributeName, NULL];
	    [stringAttributes retain];
	}
	strsize= [str sizeWithAttributes:stringAttributes];
	strsize.width+= 3;
	strsize.height+=1;
	value= val;
	screenLocation= loc;
	screenLocation.x-=strsize.width/2;
	screenLocation.y-=strsize.height/2;
	animationCount= count;
	image= [[NSImage alloc] initWithSize:strsize];
	[image lockFocus];
	[stringAttributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];	
	[str drawAtPoint:NSMakePoint(2,0) withAttributes:stringAttributes];
	[stringAttributes setObject:[NSColor yellowColor] forKey:NSForegroundColorAttributeName];	
	[str drawAtPoint:NSMakePoint(1,1) withAttributes:stringAttributes];
	[image unlockFocus];

        // Open GL
        //
        sprite = [[OpenGLSprite alloc] initWithImage:image
                                       cropRectangle:NSMakeRect(0, 0, [image size].width, [image size].height)
                                                size:[image size]];
        //
    }
    return self;
}

- (void) dealloc
{
    [image release];
    [sprite release];
    
    [super dealloc];
}

-(void)drawImage
{
    float alpha= (float)animationCount/20;
    if (alpha>1) {
        alpha= 1;
    }
    [image compositeToPoint:screenLocation operation:NSCompositeSourceOver fraction:alpha];
}

-(void)drawSprite
{
    float alpha= (float)animationCount/20;
    if (alpha>1) {
        alpha= 1;
    }
    [sprite blitToX:screenLocation.x
                  Y:screenLocation.y
                  Z:SCOREBUBBLE_SPRITE_Z
              Alpha:alpha];
}

-(int)animate
{
    if (animationCount>0) {
	screenLocation.y++;
	animationCount--;
    }
    return animationCount;
}

-(int)animationCount
{
    return animationCount;
}
-(void)setAnimationCount:(int)count
{
    animationCount= count;
}

-(int)value
{
    return value;
}

-(NSImage *)image
{
    return image;
}

-(NSPoint)screenLocation
{
    return screenLocation;
}

@end
