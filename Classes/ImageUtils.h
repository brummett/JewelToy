#import <Cocoa/Cocoa.h>

@interface NSImage (Utils)
- (void)n_compositeToPoint:(NSPoint)point operation:(NSCompositingOperation)op;
- (void)n_compositeToPoint:(NSPoint)point operation:(NSCompositingOperation)op fraction:(CGFloat)delta;
@end
