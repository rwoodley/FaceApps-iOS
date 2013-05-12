#import "MyCvVideoCamera.h"

@implementation MyCvVideoCamera

- (void)updateOrientation;
{
    // nop
}

- (void)layoutPreviewLayer;
{
    if (self.parentView != nil) {
        //CALayer* layer2 = super.customPreviewLayer;
        CALayer* layer = self.customPreviewLayer;
        //CGRect bounds = super.customPreviewLayer.bounds;
        CGRect bounds = self.customPreviewLayer.bounds;
        layer.position = CGPointMake(self.parentView.frame.size.width/2., self.parentView.frame.size.height/2.);
        layer.bounds = bounds;
    }
}

@end
