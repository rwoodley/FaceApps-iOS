#import "MyCvVideoCamera.h"

@implementation MyCvVideoCamera

// see: http://stackoverflow.com/questions/14876895/how-do-i-make-cvvideocamera-not-auto-rotate

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
