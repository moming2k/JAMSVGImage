//
//  JAMStyledText.h
//  JAMSVGImage
//
//  Created by Chan Chris on 30/12/14.
//  Copyright (c) 2014 Jeff Menter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JAMSVGGradientParts.h"

#import <CoreText/CoreText.h>

@interface JAMStyledText : NSObject

/** Styled path creation */
+ (instancetype)styledTextWithString:(NSMutableAttributedString *)string
                               withX:(float)x
                               withY:(float)y
                           fillColor:(UIColor *)fillColor
                         strokeColor:(UIColor *)strokeColor
                    affineTransforms:(NSArray *)transforms
                             opacity:(NSNumber *)opacity;

/** Draws the styled text in the current graphics context. */
- (void)drawStyledText;

- (void)setStringContent:(NSString *)string;

/** Returns a Boolean value indicating whether the area enclosed by the path contains the specified point. */
- (BOOL)containsPoint:(CGPoint)point;

@end
