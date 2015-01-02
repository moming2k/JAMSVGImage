
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
    
    float minimumScale = [self.imageScrollView frame].size.width  / [self.svgImageView frame].size.width;
    [self.imageScrollView setMinimumZoomScale:minimumScale*3];
    [self.imageScrollView setZoomScale:minimumScale];
    
}

- (CGSize)fitSVGSizeToImageView:(CGSize)imageSize //withImageViewSize:(CGSize)imageViewSize
{
    float ratio = 1.0f * imageSize.width / imageSize.height;
    
    CGSize finalSize = CGSizeMake(imageSize.height*ratio , imageSize.height );
    return finalSize;
}

- (CGSize)fitSVGSizeToImageView2:(CGSize)imageSize withImageViewSize:(CGSize)imageViewSize
{
    float ratio = 1.0f * imageSize.width / imageSize.height;
    
    CGSize finalSize = CGSizeMake(imageViewSize.height * ratio , imageViewSize.height );
    return finalSize;
}

//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
//{
//    self.svgImageView.center = CGPointAddPoints(self.svgImageView.center, [touches.anyObject previousTouchDeltaInView:self.view]);
//}

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

/************************************** NOTE **************************************/
/* The following delegate method works around a known bug in zoomToRect:animated: */
/* In the next release after 3.0 this workaround will no longer be necessary      */
/**********************************************************************************/
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
    
    NSLog(@"scrollViewDidEndZooming - withView");
}


#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    NSLog(@"viewForZoomingInScrollView ");
    
    return [self.imageScrollView viewWithTag:ZOOM_VIEW_TAG];
}

#pragma mark TapDetectingImageViewDelegate methods

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotSingleTapAtPoint:(CGPoint)tapPoint {
    // single tap does nothing for now
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint {
    // double tap zooms in
    float newScale = [self.imageScrollView zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [self.imageScrollView zoomToRect:zoomRect animated:YES];
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint {
    // two-finger tap zooms out
    float newScale = [self.imageScrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [self.imageScrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [self.imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [self.imageScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

@end
