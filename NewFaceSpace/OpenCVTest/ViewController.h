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

@interface ViewController : UIViewController <CvVideoCameraDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    bool _preventRecursion;

    NSDate *_cameraStartRequestTime;
	SystemSoundID	_sound1;
	SystemSoundID	_sound2;
	SystemSoundID	_sound3;
    bool _playedSound1;
    bool _playedSound2;
    bool _playedSound3;
    MyCvVideoCamera *_videoCamera;

    NSString *userSelection;
    bool cameraFrontFacing;
    bool torchIsOn;
    bool torchShouldBeOn;
    cv::CascadeClassifier *lbpCascade;
    cv::CascadeClassifier *alt2Cascade;
    cv::CascadeClassifier *myCascade;
    UIImage *_FinalFaceImage;
    NSURL *_URLFromCameraRoll;
}
#ifdef __cplusplus
- (cv::CascadeClassifier*)loadCascade:(NSString*)filename;
- (UIImage *)UIImageFromIplImage:(IplImage *)image;
#endif
- (int)detectFace:(cv::Mat&)image
       cleanImage:(cv::Mat&)cimage
      withCascade:(cv::CascadeClassifier *)cascade
           showIn:(UIImageView *)imageView
       defaultPng:(NSString *)defaultPng;

- (void)startCamera;
- (void)showAlert;

- (IBAction) unwindToMain:(UIStoryboardSegue *) sender;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *TopLabel;

@property (weak, nonatomic) IBOutlet UIImageView *LBPImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ALTImageView;
@property (weak, nonatomic) IBOutlet UIImageView *MYImageView;
@property (nonatomic, retain) UIImage *TempFaceImage;                   // grey scale for thumbnails
@property (nonatomic, retain) UIImage *TempFaceImage_Histogram;         // for passing....
@property (nonatomic, retain) UIImage *FinalFaceImage;                  // grey scale on SecondViewController
@property (nonatomic, retain) UIImage *FinalFaceImage_Histogram;        // goes to web-site
@property (nonatomic, retain) MyCvVideoCamera *videoCamera;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end
