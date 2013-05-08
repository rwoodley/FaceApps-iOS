//
//  ViewController.h
//  OpenCVTest
//
//  Created by Woodley, Bob on 4/22/13.
//  Copyright (c) 2013 Woodley, Bob. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
#import "MyCvVideoCamera.h"
//using namespace cv;

@interface ViewController : UIViewController <CvVideoCameraDelegate>
{
    MyCvVideoCamera *videoCamera;
    UISegmentedControl *segmentedControl;
    bool cameraFrontFacing;
    cv::CascadeClassifier *lbpCascade;
    cv::CascadeClassifier *alt2Cascade;
    cv::CascadeClassifier *myCascade;
    UIImage *_FoundFace;
}
#ifdef __cplusplus
// delegate method for processing image frames
- (cv::CascadeClassifier*)loadCascade:(NSString*)filename;
- (UIImage *)UIImageFromIplImage:(IplImage *)image;
- (int)detectFace:(cv::Mat&)image withCascade:(cv::CascadeClassifier *)cascade showIn:(UIImageView *)imageView;
#endif

//- (void)detectFace:(cv::Mat&)image withCascade:(cv::CascadeClassifier *)cascade;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *TopLabel;

@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIImageView *LBPImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ALTImageView;
@property (weak, nonatomic) IBOutlet UIImageView *MYImageView;
@property (nonatomic, retain) UIImage *FoundFace;

- (void)resizeImage;
- (IBAction)segmentedControlIndexChanged:(id)sender;
@end
