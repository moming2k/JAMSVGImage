
#import "JAMViewController.h"
#import "JAMSVGUtilities.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

@interface UITouch (Utilities)

- (CGPoint)previousTouchDeltaInView:(UIView *)view;

@end

@implementation UITouch (Utilities)

- (CGPoint)previousTouchDeltaInView:(UIView *)view;
{
    return CGPointMake([self locationInView:view].x - [self previousLocationInView:view].x,
                       [self locationInView:view].y - [self previousLocationInView:view].y);
}

@end

@implementation JAMViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.svgImageView.delegate = self;
    [self.svgImageView setTag:ZOOM_VIEW_TAG];
    
    CGSize size = [self.svgImageView.svgImage size];
    CGSize finalizeSize = [self fitSVGSizeToImageView:size];
    
    self.svgImageView.frame = CGRectMake(self.svgImageView.frame.origin.x, self.svgImageView.frame.origin.y, finalizeSize.width, finalizeSize.height);
    
    [self.imageScrollView setContentSize: finalizeSize];
    

    
}

- (CGSize)fitSVGSizeToImageView:(CGSize)imageSize //withImageViewSize:(CGSize)imageViewSize
{
    float ratio = 1.0f * imageSize.width / imageSize.height;
    
    CGSize finalSize = CGSizeMake(900 , imageSize.height );
    return finalSize;
}

- (CGSize)fitSVGSizeToImageView2:(CGSize)imageSize withImageViewSize:(CGSize)imageViewSize
{
    float ratio = 1.0f * imageSize.width / imageSize.height;
    
    CGSize finalSize = CGSizeMake(imageViewSize.height * ratio , imageViewSize.height );
    return finalSize;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
    self.svgImageView.center = CGPointAddPoints(self.svgImageView.center, [touches.anyObject previousTouchDeltaInView:self.view]);
}

- (IBAction)sliderSlid:(UISlider *)sender
{
    CGPoint center = self.svgImageView.center;
    CGRect frame = self.svgImageView.frame;
    frame.size.width = sender.value;
    frame.size.height = sender.value;
    self.svgImageView.frame = frame;
    self.svgImageView.center = center;
}

- (IBAction)buttonTapped:(UIButton *)sender;
{
    
}

@end
