/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "JAMSvgImageView.h"

#define DOUBLE_TAP_DELAY 0.35

CGPoint midpointBetweenPoints(CGPoint a, CGPoint b);


@implementation JAMSVGImageView
@synthesize delegate;

- (instancetype)initWithSVGImage:(JAMSVGImage *)svgImage;
{
    if (!(self = [super initWithFrame:CGRectMake(0, 0, svgImage.size.width, svgImage.size.height)])) return nil;
    
    self.svgImage = svgImage;
    self.backgroundColor = UIColor.clearColor;
    return self;
}

- (void)setSvgName:(NSString *)imageName;
{
    self.backgroundColor = UIColor.clearColor;
    self.svgImage = [JAMSVGImage imageNamed:imageName];
    
    [self setUserInteractionEnabled:YES];
    [self setMultipleTouchEnabled:YES];
    twoFingerTapIsPossible = YES;
    multipleTouches = NO;
}

- (void)sizeToFit;
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                            self.svgImage.size.width, self.svgImage.size.height);
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    if (_contentMode != contentMode) {
        _contentMode = contentMode;
        [self setNeedsDisplay];
    }
}

- (void)layoutSubviews;
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGRect destinationRect = CGRectZero;
    CGFloat scalingFactor = 1.f;
    CGFloat halfRectWidth = rect.size.width / 2.0;
    CGFloat halfRectHeight = rect.size.height / 2.0;
    CGFloat halfSVGWidth = self.svgImage.size.width / 2.0;
    CGFloat halfSVGHeight = self.svgImage.size.height / 2.0;
    
    switch (self.contentMode) {
        case UIViewContentModeBottom:
            destinationRect = CGRectMake(halfRectWidth - halfSVGWidth, rect.size.height - self.svgImage.size.height,
                                         self.svgImage.size.width, self.svgImage.size.height);
            break;
        case UIViewContentModeBottomLeft:
            destinationRect = CGRectMake(0, rect.size.height - self.svgImage.size.height,
                                         self.svgImage.size.width, self.svgImage.size.height);
            break;
        case UIViewContentModeBottomRight:
            destinationRect = CGRectMake(rect.size.width - self.svgImage.size.width, rect.size.height - self.svgImage.size.height,
                                         self.svgImage.size.width, self.svgImage.size.height);
            break;
        case UIViewContentModeCenter:
            destinationRect = CGRectMake(halfRectWidth - halfSVGWidth, halfRectHeight - halfSVGHeight,
                                         self.svgImage.size.width, self.svgImage.size.height);
            break;
        case UIViewContentModeLeft:
            destinationRect = CGRectMake(0, halfRectHeight - halfSVGHeight,
                                         self.svgImage.size.width, self.svgImage.size.height);
            break;
        case UIViewContentModeRedraw: // This option doesn't make sense with SVG. We'll redraw regardless.
            destinationRect = rect;
            break;
        case UIViewContentModeRight:
            destinationRect = CGRectMake(rect.size.width - self.svgImage.size.width,
                                         halfRectHeight - halfSVGHeight,
                                         self.svgImage.size.width,
                                         self.svgImage.size.height);
            break;
        case UIViewContentModeScaleAspectFill:
            scalingFactor = MAX(rect.size.width / self.svgImage.size.width, rect.size.height / self.svgImage.size.height);
            destinationRect = CGRectMake(halfRectWidth - (halfSVGWidth * scalingFactor),
                                         halfRectHeight - (halfSVGHeight * scalingFactor),
                                         self.svgImage.size.width * scalingFactor,
                                         self.svgImage.size.height * scalingFactor);
            break;
        case UIViewContentModeScaleAspectFit:
            scalingFactor = MIN(rect.size.width / self.svgImage.size.width, rect.size.height / self.svgImage.size.height);
            destinationRect = CGRectMake(halfRectWidth - (halfSVGWidth * scalingFactor),
                                         halfRectHeight - (halfSVGHeight * scalingFactor),
                                         self.svgImage.size.width * scalingFactor,
                                         self.svgImage.size.height * scalingFactor);
            break;
        case UIViewContentModeScaleToFill:
            destinationRect = rect;
            break;
        case UIViewContentModeTop:
            destinationRect = CGRectMake(halfRectWidth - halfSVGWidth, 0,
                                         self.svgImage.size.width, self.svgImage.size.height);
            break;
        case UIViewContentModeTopLeft:
            destinationRect = CGRectMake(0, 0,
                                         self.svgImage.size.width, self.svgImage.size.height);
            break;
        case UIViewContentModeTopRight:
            destinationRect = CGRectMake(rect.size.width - self.svgImage.size.width, 0,
                                         self.svgImage.size.width, self.svgImage.size.height);
            break;
        default:
            destinationRect = rect;
            break;
    }
    [self.svgImage drawInRect:destinationRect];
}

//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;
//{
//    if (![super pointInside:point withEvent:event]) {
//        return NO;
//    }
//    
//    return [self.svgImage containsPoint:point];
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // cancel any pending handleSingleTap messages
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleSingleTap) object:nil];
    
    // update our touch state
    if ([[event touchesForView:self] count] > 1)
        multipleTouches = YES;
    if ([[event touchesForView:self] count] > 2)
        twoFingerTapIsPossible = NO;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL allTouchesEnded = ([touches count] == [[event touchesForView:self] count]);
    
    // first check for plain single/double tap, which is only possible if we haven't seen multiple touches
    if (!multipleTouches) {
        UITouch *touch = [touches anyObject];
        tapLocation = [touch locationInView:self];
        
        if ([touch tapCount] == 1) {
            [self performSelector:@selector(handleSingleTap) withObject:nil afterDelay:DOUBLE_TAP_DELAY];
        } else if([touch tapCount] == 2) {
            [self handleDoubleTap];
        }
    }
    
    // check for 2-finger tap if we've seen multiple touches and haven't yet ruled out that possibility
    else if (multipleTouches && twoFingerTapIsPossible) {
        
        // case 1: this is the end of both touches at once
        if ([touches count] == 2 && allTouchesEnded) {
            int i = 0;
            int tapCounts[2]; CGPoint tapLocations[2];
            for (UITouch *touch in touches) {
                tapCounts[i]    = [touch tapCount];
                tapLocations[i] = [touch locationInView:self];
                i++;
            }
            if (tapCounts[0] == 1 && tapCounts[1] == 1) { // it's a two-finger tap if they're both single taps
                tapLocation = midpointBetweenPoints(tapLocations[0], tapLocations[1]);
                [self handleTwoFingerTap];
            }
        }
        
        // case 2: this is the end of one touch, and the other hasn't ended yet
        else if ([touches count] == 1 && !allTouchesEnded) {
            UITouch *touch = [touches anyObject];
            if ([touch tapCount] == 1) {
                // if touch is a single tap, store its location so we can average it with the second touch location
                tapLocation = [touch locationInView:self];
            } else {
                twoFingerTapIsPossible = NO;
            }
        }
        
        // case 3: this is the end of the second of the two touches
        else if ([touches count] == 1 && allTouchesEnded) {
            UITouch *touch = [touches anyObject];
            if ([touch tapCount] == 1) {
                // if the last touch up is a single tap, this was a 2-finger tap
                tapLocation = midpointBetweenPoints(tapLocation, [touch locationInView:self]);
                [self handleTwoFingerTap];
            }
        }
    }
    
    // if all touches are up, reset touch monitoring state
    if (allTouchesEnded) {
        twoFingerTapIsPossible = YES;
        multipleTouches = NO;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    twoFingerTapIsPossible = YES;
    multipleTouches = NO;
}

#pragma mark Private

- (void)handleSingleTap {
    if ([delegate respondsToSelector:@selector(tapDetectingImageView:gotSingleTapAtPoint:)])
        [delegate tapDetectingImageView:self gotSingleTapAtPoint:tapLocation];
}

- (void)handleDoubleTap {
    if ([delegate respondsToSelector:@selector(tapDetectingImageView:gotDoubleTapAtPoint:)])
        [delegate tapDetectingImageView:self gotDoubleTapAtPoint:tapLocation];
}

- (void)handleTwoFingerTap {
    if ([delegate respondsToSelector:@selector(tapDetectingImageView:gotTwoFingerTapAtPoint:)])
        [delegate tapDetectingImageView:self gotTwoFingerTapAtPoint:tapLocation];
}

@end

CGPoint midpointBetweenPoints(CGPoint a, CGPoint b) {
    CGFloat x = (a.x + b.x) / 2.0;
    CGFloat y = (a.y + b.y) / 2.0;
    return CGPointMake(x, y);
}
