/*
 
 Copyright (c) 2014 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>
#import "JAMSVGImage.h"

@protocol TapDetectingImageViewDelegate;

IB_DESIGNABLE



/** The JAMSVGImageView encapsulates a JAMSVGImage in a UIView. The SVG redraws at every frame/bounds change. */
@interface JAMSVGImageView : UIView
{
    CGPoint tapLocation;         // Needed to record location of single tap, which will only be registered after delayed perform.
    BOOL multipleTouches;        // YES if a touch event contains more than one touch; reset when all fingers are lifted.
    BOOL twoFingerTapIsPossible; // Set to NO when 2-finger tap can be ruled out (e.g. 3rd finger down, fingers touch down too far apart, etc).
}

@property (nonatomic, weak) id <TapDetectingImageViewDelegate> delegate;

/** The name of the svg in your app's main bundle. Mostly used by IBInspectable for Interface Builder previews. */
@property (nonatomic) IBInspectable NSString *svgName;
/** The SVGImage. Note: setting this does not change the frame of the view; call sizeToFit if needed. */
@property (nonatomic) JAMSVGImage *svgImage;
/** We respect the contentMode property.*/
@property (nonatomic) UIViewContentMode contentMode;

/** Creates a new JAMSVGImageView from a JAMSVGImage. */
- (instancetype)initWithSVGImage:(JAMSVGImage *)svgImage;

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;

@end

@protocol TapDetectingImageViewDelegate <NSObject>

@optional
- (void)tapDetectingImageView:(JAMSVGImageView *)view gotSingleTapAtPoint:(CGPoint)tapPoint;
- (void)tapDetectingImageView:(JAMSVGImageView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint;
- (void)tapDetectingImageView:(JAMSVGImageView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint;

@end


