//  Sprite.h
//
//  Created by Giles Williams on Fri Jun 21 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface Sprite : NSObject

- (id) init;
- (id) initWithImage:(NSImage *)textureImage cropRectangle:(NSRect)cropRect size:(NSSize) spriteSize;
- (void) dealloc;

- (void)blitToX:(float)x Y:(float)y Z:(float)z;
- (void)blitToX:(float)x Y:(float)y Z:(float)z Alpha:(float)a;

- (void)replaceTextureFromImage:(NSImage *)texImage cropRectangle:(NSRect)cropRect;
- (void)substituteTextureFromImage:(NSImage *)texImage;

@end
