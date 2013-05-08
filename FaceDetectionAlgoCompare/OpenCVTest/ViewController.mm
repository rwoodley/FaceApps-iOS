//
//  ViewController.m
//  OpenCVTest
//
//  Created by Woodley, Bob on 4/22/13.
//  Copyright (c) 2013 Woodley, Bob. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize segmentedControl;

- (void)viewDidLoad
{
    [super viewDidLoad];

    videoCamera = [[MyCvVideoCamera alloc] initWithParentView:_imageView];
	videoCamera.defaultFPS = 15;
	//videoCamera.grayscaleMode = YES;
	videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
	videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
	videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    videoCamera.delegate = self;

    // This has to be done before video camera is started because then MyCvVideoCamera->layoutPreview defeats resize somehow.
    // adjust aspect ratio of UIImage so that there is no distortion of the image.
    // aspect ratio of UIImage * aspect ratio of the video should = 1.
    double newHeight = _imageView.frame.size.width * (352.0/288.0);
    _imageView.frame = CGRectMake(
                                  _imageView.frame.origin.x,
                                  _imageView.frame.origin.y, _imageView.frame.size.width, newHeight);
    NSLog(@"image h*w = %f,%f", _imageView.frame.size.height, _imageView.frame.size.width);

    cameraFrontFacing = true;
    [videoCamera start];
    
	lbpCascade = [self loadCascade:@"lbpcascade_frontalface"];
	alt2Cascade = [self loadCascade:@"haarcascade_frontalface_alt2"];
	myCascade = [self loadCascade:@"haarcascade_constrainedFrontalFace"];
}
- (void)resizeImage
{
    
    NSLog(@"image h*w = %f,%f", _imageView.frame.size.height, _imageView.frame.size.width);
    NSLog(@"video h*w = %d,%d", videoCamera.imageHeight, videoCamera.imageWidth);
    
    if (videoCamera.imageWidth != 0) {
        // adjust aspect ratio of UIImage so that there is no distortion of the image.
        // aspect ratio of UIImage * aspect ratio of the video should = 1.
        double newHeight = _imageView.frame.size.width * ((float)videoCamera.imageWidth/(float)videoCamera.imageHeight);
        _imageView.frame = CGRectMake(
                                  _imageView.frame.origin.x,
                                  _imageView.frame.origin.y, _imageView.frame.size.width, newHeight);
        NSLog(@"image h*w = %f,%f", _imageView.frame.size.height, _imageView.frame.size.width);
    }
}


#ifdef __cplusplus
- (cv::CascadeClassifier*)loadCascade:(NSString*)filename;
{
	NSString *real_path = [[NSBundle mainBundle] pathForResource:filename ofType:@"xml"];
	cv::CascadeClassifier* mycascade = new cv::CascadeClassifier();
	
	if (real_path != nil && !mycascade->load([real_path UTF8String])) {
		NSLog(@"Unable to load cascade file %@.xml", filename);
	} else {
		NSLog(@"Loaded cascade file %@.xml", filename);
	}
	return mycascade;
}

- (void)processImage:(cv::Mat&)image;
{
    int ts;
    NSString *label;
    ts = [self detectFace: image withCascade: lbpCascade showIn:_LBPImageView];
    label = [NSString stringWithFormat:@" %d ms", ts];
    cv::putText(image, [label UTF8String], cv::Point(10,10), cv::FONT_HERSHEY_COMPLEX_SMALL, 0.5, CV_RGB(255,0,0));
    ts = [self detectFace: image withCascade: alt2Cascade showIn:_ALTImageView];
    label = [NSString stringWithFormat:@" %d ms", ts];
    cv::putText(image, [label UTF8String], cv::Point(10,20), cv::FONT_HERSHEY_COMPLEX_SMALL, 0.5, CV_RGB(255,0,0));
    ts = [self detectFace: image withCascade: myCascade showIn:_MYImageView];
    label = [NSString stringWithFormat:@" %d ms", ts];
    cv::putText(image, [label UTF8String], cv::Point(10,30), cv::FONT_HERSHEY_COMPLEX_SMALL, 0.5, CV_RGB(255,0,0));
}
- (int)detectFace:(cv::Mat&)image withCascade:(cv::CascadeClassifier *)cascade showIn:(UIImageView *)imageView
{
    @autoreleasepool {
        float haar_scale = 1.15;
        int haar_minNeighbors = 3;
        int haar_flags = 0 | CV_HAAR_SCALE_IMAGE | CV_HAAR_DO_CANNY_PRUNING;
        int minSize = 60;
        cv::Size haar_minSize = cvSize(minSize, minSize);
        std::vector<cv::Rect> faces;

        NSDate *start = [NSDate date];
        cascade->detectMultiScale(image, faces, haar_scale,
                                     haar_minNeighbors, haar_flags, haar_minSize );
        NSTimeInterval timeInterval = [start timeIntervalSinceNow];
        
        // draw faces
        for( int i = 0; i < faces.size(); i++ ) {
            
            cv::Rect* r = &faces[i];
            cv::rectangle(image,
                          cvPoint( r->x, r->y ),
                          cvPoint( r->x + r->width, r->y + r->height),
                          CV_RGB(0,0,255));
            
            if (i == 0) {
                cv::Mat subImg = image(faces[i]);
                IplImage temp = subImg;
                self.FoundFace = [self UIImageFromIplImage:&temp];
                subImg.release();
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = self.FoundFace;
                });
            }
        }
        int tmp = (int) (timeInterval * -1000);
        return tmp;
    }
}

- (UIImage *)UIImageFromIplImage:(IplImage *)image {
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
	CGImageRef imageRef = CGImageCreate(image->width, image->height,
										image->depth, image->depth * image->nChannels, image->widthStep,
										colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
										provider, NULL, false, kCGRenderingIntentDefault);
	UIImage *ret = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);
	return ret;
}
#endif
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)segmentedControl:(id)sender {
}
- (IBAction)segmentedControlIndexChanged:(id)sender {
    NSLog(@"Segment selected is %i", segmentedControl.selectedSegmentIndex);
    if (segmentedControl.selectedSegmentIndex == 0) {
        if (!cameraFrontFacing) [videoCamera switchCameras];
        cameraFrontFacing = true;
    }
    if (segmentedControl.selectedSegmentIndex == 1) {
        if (cameraFrontFacing) [videoCamera switchCameras];
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch]) {
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOn];  // use AVCaptureTorchModeOff to turn off
            [device unlockForConfiguration];
        }
        cameraFrontFacing = false;
    }
}
@end
