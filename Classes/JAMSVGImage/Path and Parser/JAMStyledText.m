//
//  JAMStyledText.m
//  JAMSVGImage
//
//  Created by Chan Chris on 30/12/14.
//  Copyright (c) 2014 Jeff Menter. All rights reserved.
//

#import "JAMStyledText.h"
#import "JAMSVGUtilities.h"

@interface JAMStyledText ()
@property (nonatomic) NSMutableAttributedString *string;
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) NSDictionary* attributes;
@property (nonatomic) UIColor *fillColor;
@property (nonatomic) UIColor *strokeColor;
@property (nonatomic) float strokeLineWidth;
@property (nonatomic) NSArray *affineTransforms;
@property (nonatomic) NSNumber *opacity;
@end

@implementation JAMStyledText

+ (instancetype)styledTextWithString:(NSMutableAttributedString *)string
                               withX:(float)x
                               withY:(float)y
                         fillColor:(UIColor *)fillColor
                       strokeColor:(UIColor *)strokeColor
                  affineTransforms:(NSArray *)transforms
                           opacity:(NSNumber *)opacity
                          attributes:attributes
{
    JAMStyledText *styledText = JAMStyledText.new;
    styledText.x = x;
    styledText.y = y;
    styledText.string = string;
    styledText.strokeLineWidth = 1;
    styledText.fillColor = fillColor;
    styledText.strokeColor = strokeColor;
    styledText.affineTransforms = transforms;
    styledText.opacity = opacity;
    styledText.attributes = attributes;
    
    return styledText;
}

- (void)drawStyledTextInContext:(CGContextRef)context
{
//    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return;
    
    CGContextSaveGState(context);
    for (NSValue *transform in self.affineTransforms) {
        CGContextConcatCTM(context, transform.CGAffineTransformValue);
    }
    if (self.opacity) {
        CGContextSetAlpha(context, self.opacity.floatValue);
    }
    
    CGRect rect = [self.string boundingRectWithSize:CGSizeMake(3000, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    
    if (self.strokeColor && self.strokeLineWidth > 0.f) {
        [self.strokeColor setStroke];
        
        // Draw outlined text.
        CGContextSetTextDrawingMode(context, kCGTextStroke);
        // Make the thickness of the outline a function of the font size in use.
        CGContextSetLineWidth(context, self.strokeLineWidth);
        CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
        [self.string drawAtPoint:CGPointMake(self.x, self.y - rect.size.height)];
    }
    
    if (self.fillColor) {
        CGContextSetTextDrawingMode(context, kCGTextFill);
        CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
        
//        NSDictionary *getFromFont = [self.string attributesAtIndex:0 longestEffectiveRange:nil inRange:NSMakeRange(0, self.string.length)];
        NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];
        if([self.attributes objectForKey:@"font-size"])
        {
            float font_size = [[self.attributes objectForKey:@"font-size"] floatValue];
            UIFont *font = [UIFont systemFontOfSize:font_size];
            [textAttributes setObject:font forKey:NSFontAttributeName];
        }
        if([self.attributes objectForKey:@"fill"])
        {
            UIColor *color = [UIColor colorFromString:[self.attributes objectForKey:@"fill"]];
            [textAttributes setObject:color forKey:NSForegroundColorAttributeName];
        }
        
//        NSDictionary *textAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:5.0]}; //[self.string attributesAtIndex:0 longestEffectiveRange:nil inRange:NSMakeRange(0, self.string.length)]; // @{NSFontAttributeName: [UIFont systemFontOfSize:6.0]};

        NSStringDrawingContext *drawingContext = [[NSStringDrawingContext alloc] init];
//        [self.string drawAtPoint:CGPointMake(self.x, self.y - rect.size.height)];
        
        CGRect drawRect = CGRectMake(0.0, 0.0, 200.0, 100.0);
//        NSAttributedString *string2 = [[NSAttributedString alloc] initWithString:@""];
        [[self.string string] drawWithRect:drawRect options:NSStringDrawingUsesDeviceMetrics attributes:textAttributes context:drawingContext];
    }
    
    CGContextRestoreGState(context);
}

- (BOOL)containsPoint:(CGPoint)point;
{
    return false;// [self.path containsPoint:point];
}

- (void)setStringContent:(NSString *)string
{
    NSLog(@"attributes = %@",self.attributes);
    [self.string replaceCharactersInRange:NSMakeRange(0, self.string.length) withString:string];
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"    styledText:%p\n    string:%@\n    x: %f\n    y:%f\n    fill: %@\n    stroke: %@\n    transform: %@\n    opacity: %@", self, self.string, self.x, self.y, self.fillColor, self.strokeColor, self.affineTransforms, self.opacity];
}

@end
