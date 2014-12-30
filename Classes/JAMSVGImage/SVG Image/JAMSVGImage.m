/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "JAMSVGImage.h"
#import "JAMSVGParser.h"
#import "JAMStyledBezierPath.h"
#import "JAMStyledText.h"

@interface JAMSVGImage ()
@property (nonatomic) NSArray *styledPaths;
@property (nonatomic) NSArray *styledTexts;
@property (nonatomic) CGRect viewBox;
@end

@implementation JAMSVGImage

+ (JAMSVGImage *)imageNamed:(NSString *)name;
{
    NSBundle *bundle;
#if !TARGET_INTERFACE_BUILDER
    bundle = NSBundle.mainBundle;
#else
    bundle = [NSBundle bundleForClass:self.class];
#endif
    NSString *fileName = [bundle pathForResource:name ofType:@"svg"];
    if (!fileName) {
        fileName = [bundle pathForResource:name ofType:@"svgz"];
    }
    return [JAMSVGImage imageWithContentsOfFile:fileName];
}

+ (JAMSVGImage *)imageWithContentsOfFile:(NSString *)path;
{
    JAMSVGImage *image = JAMSVGImage.new;
    JAMSVGParser *parser = [JAMSVGParser.alloc initWithSVGDocument:path];
    if (!parser) return nil;
    
    [parser parseSVGDocument];
    image.styledPaths = parser.paths;
    image.styledTexts = parser.texts;
    image.viewBox = parser.viewBox;
    image.scale = 1;
    return image;
}

+ (JAMSVGImage *)imageWithSVGData:(NSData *)svgData;
{
    JAMSVGImage *image = JAMSVGImage.new;
    JAMSVGParser *parser = [JAMSVGParser.alloc initWithSVGData:svgData];
    if (!parser) return nil;
    
    [parser parseSVGDocument];
    image.styledPaths = parser.paths;
    image.styledTexts = parser.texts;
    image.viewBox = parser.viewBox;
    image.scale = 1;
    return image;
}

- (UIImage *)image;
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width * self.scale,
                                                      self.size.height * self.scale), NO, 0.f);
    [self drawInCurrentContext];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (CGSize)size;
{
    return self.viewBox.size;
}

- (CGImageRef)CGImage;
{
    return self.image.CGImage;
}

- (void)drawInCurrentContext;
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, -self.viewBox.origin.x, -self.viewBox.origin.y);
    CGContextScaleCTM(context, self.scale, self.scale);
    for (JAMStyledBezierPath *styledPath in self.styledPaths) {
        [styledPath drawStyledPath];
    }
    for (JAMStyledText *styledText in self.styledTexts) {
        [styledText drawStyledText];
    }
    CGContextRestoreGState(context);
}

- (void)drawAtPoint:(CGPoint)point
{
    [self drawInRect:CGRectMake(point.x, point.y, self.size.width, self.size.height)];
}

- (void)drawInRect:(CGRect)rect;
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    CGContextScaleCTM(context, rect.size.width / self.size.width, rect.size.height / self.size.height);

    [self drawInCurrentContext];
    CGContextRestoreGState(context);
}

- (BOOL)containsPoint:(CGPoint)point;
{
    point.x += self.viewBox.origin.x;
    point.y += self.viewBox.origin.y;
    
    for (JAMStyledBezierPath *styledPath in self.styledPaths) {
        if ([styledPath containsPoint:point]) {
            return YES;
        }
    }
    return NO;
}

- (UIImage *)imageAtSize:(CGSize)size;
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.f);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
