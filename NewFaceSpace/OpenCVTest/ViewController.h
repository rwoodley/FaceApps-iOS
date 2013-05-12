//
//  ViewController.h
//  FaceSpace
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
    NSDate *_cameraStartRequestTime;

    MyCvVideoCamera *_videoCamera;
    UISegmentedControl *_segmentedControl;
    NSString *userSelection;
    bool cameraFrontFacing;
    cv::CascadeClassifier *lbpCascade;
    cv::CascadeClassifier *alt2Cascade;
    cv::CascadeClassifier *myCascade;
    UIImage *_FinalFaceImage;
}
#ifdef __cplusplus
- (cv::CascadeClassifier*)loadCascade:(NSString*)filename;
- (UIImage *)UIImageFromIplImage:(IplImage *)image;
#endif
- (int)detectFace:(cv::Mat&)image withCascade:(cv::CascadeClassifier *)cascade showIn:(UIImageView *)imageView;
- (IBAction)unwindFromPickerToMain:(UIStoryboardSegue *) segue;
- (void)startCamera;


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *TopLabel;

@property (weak, nonatomic) IBOutlet UIImageView *LBPImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ALTImageView;
@property (weak, nonatomic) IBOutlet UIImageView *MYImageView;
@property (nonatomic, retain) UIImage *TempFaceImage;
@property (nonatomic, retain) UIImage *FinalFaceImage;
@property (nonatomic, retain) MyCvVideoCamera *videoCamera;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end
