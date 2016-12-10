
#import "JAMViewController.h"
#import "JAMStyledBezierPath.h"
#import "JAMSVGParser.h"
#import "JAMSVGUtilities.h"
#import "JAMSVGImage.h"

@implementation UITouch (Utilities)

- (CGPoint)previousTouchDeltaInView:(UIView *)view;
{
    return CGPointMake([self locationInView:view].x - [self previousLocationInView:view].x,
                       [self locationInView:view].y - [self previousLocationInView:view].y);
}

@end

@implementation JAMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"bear" ofType:@"svg"];
    JAMSVGParser *parser = [[JAMSVGParser alloc] initWithSVGDocument:filePath];
    [parser parseSVGDocument];
    NSArray<JAMStyledBezierPath *> *paths = parser.paths;
    
    for (JAMStyledBezierPath *path in paths) {
        NSLog(@"%@",path.attributes);
    }
    
    
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
