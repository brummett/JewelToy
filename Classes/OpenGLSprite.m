//
//  OpenGLSprite.m
//  GL_BotChallenge
//
//  Created by Giles Williams on Fri Jun 21 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "OpenGLSprite.h"


@implementation OpenGLSprite {

    NSData*	textureData;
    GLuint	texName;

    NSRect	textureCropRect;
    NSSize	textureSize;
    NSSize	size;
}


- (id) init
{
    self = [super init];
    return self;
}

- (id) initWithImage:(NSImage *)textureImage cropRectangle:(NSRect)cropRect size:(NSSize) spriteSize
{
    self = [super init];
    [self makeTextureFromImage:textureImage cropRectangle:cropRect size:spriteSize];
    return self;

}

- (void) dealloc
{
  if (texName != 0) {
    GLuint	delTextures[1] = { texName };
    glDeleteTextures(1, delTextures);	// clean up the texture from the 3d card's memory
  }
  if (textureData) {
    [textureData release];
    textureData = nil;
  }
  [super dealloc];
}

- (void)blitToX:(float)x Y:(float)y Z:(float)z
{
    glEnable(GL_TEXTURE_2D);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    glBindTexture(GL_TEXTURE_2D, texName);
    glBegin(GL_QUADS);

    glTexCoord2f(0.0, 1.0-textureCropRect.size.height);
    glVertex3f(x, y+size.height, z);

    glTexCoord2f(0.0, 1.0);
    glVertex3f(x, y, z);

    glTexCoord2f(textureCropRect.size.width, 1.0);
    glVertex3f(x+size.width, y, z);

    glTexCoord2f(textureCropRect.size.width, 1.0-textureCropRect.size.height);
    glVertex3f(x+size.width, y+size.height, z);

    glEnd();
    glDisable(GL_TEXTURE_2D);
}

- (void)blitToX:(float)x Y:(float)y Z:(float)z Alpha:(float)a
{
    if (a < 0.0)
        a = 0.0;	// clamp the alpha value
    if (a > 1.0)
        a = 1.0;	// clamp the alpha value
    glEnable(GL_TEXTURE_2D);
    glColor4f(1.0, 1.0, 1.0, a);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    glBindTexture(GL_TEXTURE_2D, texName);
    glBegin(GL_QUADS);

    glTexCoord2f(0.0, 1.0-textureCropRect.size.height);
    glVertex3f(x, y+size.height, z);

    glTexCoord2f(0.0, 1.0);
    glVertex3f(x, y, z);

    glTexCoord2f(textureCropRect.size.width, 1.0);
    glVertex3f(x+size.width, y, z);

    glTexCoord2f(textureCropRect.size.width, 1.0-textureCropRect.size.height);
    glVertex3f(x+size.width, y+size.height, z);

    glEnd();
    glDisable(GL_TEXTURE_2D);
}

- (void)makeTextureFromImage:(NSImage *)texImage cropRectangle:(NSRect)cropRect size:(NSSize)spriteSize
{
    NSBitmapImageRep*	bitmapImageRep;
    NSRect		textureRect = NSMakeRect(0.0,0.0,OPEN_GL_SPRITE_MIN_WIDTH,OPEN_GL_SPRITE_MIN_HEIGHT);
    NSImage*		image;

    if (!texImage)
        return;

    size = spriteSize;
    textureCropRect = cropRect;

    //NSLog(@"texImage size is %f %f - textureRect.size is %f %f", [texImage size].width, [texImage size].height, textureRect.size.width, textureRect.size.height);

    // correct size for texture to a power of two
/**
    while (textureRect.size.width < [texImage size].width)
        textureRect.size.width *= 2;
    while (textureRect.size.height < [texImage size].height)
        textureRect.size.height *= 2;
**/
    while (textureRect.size.width < cropRect.size.width)
        textureRect.size.width *= 2;
    while (textureRect.size.height < cropRect.size.height)
        textureRect.size.height *= 2;
    
    textureRect.origin= NSMakePoint(0,0);
    textureCropRect.origin= NSMakePoint(0,0);

    textureSize = textureRect.size;

    image = [[NSImage alloc] initWithSize:textureRect.size];

    [image lockFocus];
    [[NSColor clearColor] set];
    NSRectFill(textureRect);
    [texImage drawInRect:textureCropRect fromRect:cropRect operation:NSCompositingOperationSourceOver fraction:1.0];
    bitmapImageRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:textureRect];
    [image unlockFocus];

    [image release];
    // normalise textureCropRect size to 0.0 -> 1.0
    textureCropRect.size.width /= textureRect.size.width;
    textureCropRect.size.height /= textureRect.size.height;

    //NSLog(@"Texture has :\n%d bitsPerPixel\n%d bytesPerPlane\n%d bytesPerRow",[bitmapImageRep bitsPerPixel],[bitmapImageRep bytesPerPlane],[bitmapImageRep bytesPerRow]);
    //NSLog(@"Texture is :\n%f x %f pixels, using %f x %f",textureRect.size.width,textureRect.size.height,textureCropRect.size.width,textureCropRect.size.height);

    if (textureData)
        [textureData autorelease];
    textureData = [[NSData dataWithBytes:[bitmapImageRep bitmapData] length:textureRect.size.width*textureRect.size.height*4] retain];
    [bitmapImageRep release];

    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glGenTextures(1, &texName);			// get a new unique texture name
    glBindTexture(GL_TEXTURE_2D, texName);	// initialise it

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureRect.size.width, textureRect.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, [textureData bytes]);

}

- (void)replaceTextureFromImage:(NSImage *)texImage cropRectangle:(NSRect)cropRect
{
    NSBitmapImageRep*	bitmapImageRep;
    NSRect		textureRect = NSMakeRect(0.0,0.0,OPEN_GL_SPRITE_MIN_WIDTH,OPEN_GL_SPRITE_MIN_HEIGHT);
    NSImage*		image;

    if (!texImage)
        return;

    textureCropRect = cropRect;

    //NSLog(@"texImage size is %f %f - textureRect.size is %f %f", [texImage size].width, [texImage size].height, textureRect.size.width, textureRect.size.height);

    // correct size for texture to a power of two
    while (textureRect.size.width < cropRect.size.width)
        textureRect.size.width *= 2;
    while (textureRect.size.height < cropRect.size.height)
        textureRect.size.height *= 2;

    if ((textureRect.size.width != textureSize.width)||(textureRect.size.height != textureSize.height))
    {
        NSLog(@"ERROR! replacement texture isn't the same size as original texture");
        NSLog(@"cropRect %f x %f textureSize %f x %f",textureRect.size.width, textureRect.size.height, textureSize.width, textureSize.height);
        return;
    }

    textureRect.origin= NSMakePoint(0,0);
    //textureRect.size = textureSize;
    textureCropRect.origin= NSMakePoint(0,0);

    image = [[NSImage alloc] initWithSize:textureRect.size];

    [image lockFocus];
    [[NSColor clearColor] set];
    NSRectFill(textureRect);
    [texImage drawInRect:textureCropRect fromRect:cropRect operation:NSCompositingOperationSourceOver fraction:1.0];
    bitmapImageRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:textureRect];
    [image unlockFocus];

    [image release];
    // normalise textureCropRect size to 0.0 -> 1.0
    textureCropRect.size.width /= textureRect.size.width;
    textureCropRect.size.height /= textureRect.size.height;

    //NSLog(@"Texture has :\n%d bitsPerPixel\n%d bytesPerPlane\n%d bytesPerRow",[bitmapImageRep bitsPerPixel],[bitmapImageRep bytesPerPlane],[bitmapImageRep bytesPerRow]);
    //NSLog(@"Texture is :\n%f x %f pixels, using %f x %f",textureRect.size.width,textureRect.size.height,textureCropRect.size.width,textureCropRect.size.height);

    if (textureData)
        [textureData autorelease];
    textureData = [[NSData dataWithBytes:[bitmapImageRep bitmapData] length:textureSize.width*textureSize.height*4] retain];
    [bitmapImageRep release];

    glBindTexture(GL_TEXTURE_2D, texName);

    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, textureSize.width, textureSize.height, GL_RGBA, GL_UNSIGNED_BYTE, [textureData bytes]);

}

- (void)substituteTextureFromImage:(NSImage *)texImage
{
    NSBitmapImageRep*	bitmapImageRep;
    NSRect		cropRect = NSMakeRect(0.0,0.0,[texImage size].width,[texImage size].height);
    NSRect		textureRect = NSMakeRect(0.0,0.0,textureSize.width,textureSize.height);
    NSImage*		image;

    if (!texImage)
        return;

    image = [[NSImage alloc] initWithSize:textureSize];

    [image lockFocus];
    [[NSColor clearColor] set];
    NSRectFill(textureRect);
    [texImage drawInRect:textureRect fromRect:cropRect operation:NSCompositingOperationSourceOver fraction:1.0];
    bitmapImageRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:textureRect];
    [image unlockFocus];

    [image release];
    // normalise textureCropRect size to 0.0 -> 1.0
    textureCropRect = NSMakeRect(0.0,0.0,1.0,1.0);

    //NSLog(@"Texture has :\n%d bitsPerPixel\n%d bytesPerPlane\n%d bytesPerRow",[bitmapImageRep bitsPerPixel],[bitmapImageRep bytesPerPlane],[bitmapImageRep bytesPerRow]);
    //NSLog(@"Texture is :\n%f x %f pixels, using %f x %f",textureRect.size.width,textureRect.size.height,textureCropRect.size.width,textureCropRect.size.height);

    if ([bitmapImageRep bitsPerPixel]==32)
    {
        if (textureData)
            [textureData autorelease];
        textureData = [[NSData dataWithBytes:[bitmapImageRep bitmapData] length:textureSize.width*textureSize.height*4] retain];

        glBindTexture(GL_TEXTURE_2D, texName);

        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, textureSize.width, textureSize.height, GL_RGBA, GL_UNSIGNED_BYTE, [textureData bytes]);
    }
    else if ([bitmapImageRep bitsPerPixel]==24)
    {
        if (textureData)
            [textureData autorelease];
        textureData = [[NSData dataWithBytes:[bitmapImageRep bitmapData] length:textureSize.width*textureSize.height*3] retain];

        glBindTexture(GL_TEXTURE_2D, texName);

        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, textureSize.width, textureSize.height, GL_RGB, GL_UNSIGNED_BYTE, [textureData bytes]);
    }
    [bitmapImageRep release];
}

@end
