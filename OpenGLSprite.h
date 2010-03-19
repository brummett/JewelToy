//
//  OpenGLSprite.h
//  GL_BotChallenge
//
//  Created by Giles Williams on Fri Jun 21 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <OpenGL/gl.h>
//#import <OpenGL/glu.h>

#define	OPEN_GL_SPRITE_MIN_WIDTH	64.0
#define	OPEN_GL_SPRITE_MIN_HEIGHT	64.0

@interface OpenGLSprite : NSObject {

    NSData*	textureData;
    GLuint	texName;

    NSRect	textureCropRect;
    NSSize	textureSize;
    NSSize	size;
}



- (id) init;
- (id) initWithImage:(NSImage *)textureImage cropRectangle:(NSRect)cropRect size:(NSSize) spriteSize;
- (void) dealloc;

- (void)blitToX:(float)x Y:(float)y Z:(float)z;
- (void)blitToX:(float)x Y:(float)y Z:(float)z Alpha:(float)a;

- (void)makeTextureFromImage:(NSImage *)texImage cropRectangle:(NSRect)cropRect size:(NSSize)spriteSize;

- (void)replaceTextureFromImage:(NSImage *)texImage cropRectangle:(NSRect)cropRect;
- (void)substituteTextureFromImage:(NSImage *)texImage;

@end
