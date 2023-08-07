#import "ImageUtils.h"

@implementation NSImage (Utils)
- (void)n_compositeToPoint:(NSPoint)point operation:(NSCompositingOperation)op {
  NSRect r;
  r.origin = NSZeroPoint;
  r.size = self.size;
  [self drawAtPoint:point fromRect:r operation:op fraction:1];
}

- (void)n_compositeToPoint:(NSPoint)point operation:(NSCompositingOperation)op fraction:(CGFloat)delta {
  NSRect r;
  r.origin = NSZeroPoint;
  r.size = self.size;
  [self drawAtPoint:point fromRect:r operation:op fraction:delta];
}

@end
