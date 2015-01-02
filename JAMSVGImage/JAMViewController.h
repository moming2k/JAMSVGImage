
#import <UIKit/UIKit.h>
#import "JAMSVGImageView.h"
#import "JAMSVGButton.h"
#import "TapDetectingImageView.h"

@interface JAMViewController : UIViewController <TapDetectingImageViewDelegate>

@property (weak, nonatomic) IBOutlet TapDetectingImageView *svgImageView;
@property (weak, nonatomic) IBOutlet JAMSVGButton *button;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;

@end
