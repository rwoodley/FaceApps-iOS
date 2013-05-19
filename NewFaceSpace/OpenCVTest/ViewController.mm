//
//  ViewController.m
//  FaceSpace
//
//  Created by Woodley, Bob on 4/22/13.
//  Copyright (c) 2013 Woodley, Bob. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize segmentedControl;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // get orientation right:

    // see: http://stackoverflow.com/questions/9826920/uinavigationcontroller-force-rotate
    //set statusbar to the desired rotation position
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    //present/dismiss viewcontroller in order to activate rotating.
    UIViewController *mVC = [[UIViewController alloc] init];
    [self presentViewController:mVC animated:NO completion:NULL];
    [self dismissViewControllerAnimated:NO completion:NULL];
    
    self.videoCamera = [[MyCvVideoCamera alloc] initWithParentView:_imageView];
	self.videoCamera.defaultFPS = 15;
	//self.videoCamera.grayscaleMode = YES;
	self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
	self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
	self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.delegate = self;

    // This has to be done before video camera is started because then MyCvVideoCamera->layoutPreview defeats resize somehow.
    // adjust aspect ratio of UIImage so that there is no distortion of the image.
    // aspect ratio of UIImage * aspect ratio of the video should = 1.
    double newHeight = _imageView.frame.size.width * (352.0/288.0);
    _imageView.frame = CGRectMake(
                                  _imageView.frame.origin.x,
                                  _imageView.frame.origin.y, _imageView.frame.size.width, newHeight);
    NSLog(@"image h*w = %f,%f", _imageView.frame.size.height, _imageView.frame.size.width);

    cameraFrontFacing = true;
    [self startCamera];
	lbpCascade = [self loadCascade:@"lbpcascade_frontalface"];
	alt2Cascade = [self loadCascade:@"haarcascade_frontalface_alt2"];
	myCascade = [self loadCascade:@"constrained_frontalface"];

//    [self.view addSubview:_LBPImageView];
    _LBPImageView.image = [UIImage imageNamed:@"1.png"];
    _ALTImageView.image = [UIImage imageNamed:@"2.png"];
    _MYImageView.image = [UIImage imageNamed:@"3.png"];
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
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
    NSTimeInterval timeInterval = [_cameraStartRequestTime timeIntervalSinceNow];
    if (fabs(timeInterval)*1000 < 2000) {   // a nice pause before we go straight back to submit screen.
        dispatch_async(dispatch_get_main_queue(), ^{
            _LBPImageView.image = [UIImage imageNamed:@"1.png"];
            _ALTImageView.image = [UIImage imageNamed:@"2.png"];
            _MYImageView.image = [UIImage imageNamed:@"3.png"];
        });

        //NSLog(@"TimeInterval =  %f", timeInterval);
        return;
    }
    
    int votes = 0;
    int nFaces = 0;
    nFaces = [self detectFace: image withCascade: lbpCascade showIn:_LBPImageView defaultPng:@"1.png"];
    if (nFaces > 0) votes++;
    nFaces = [self detectFace: image withCascade: alt2Cascade showIn:_ALTImageView defaultPng:@"2.png"];
    if (nFaces > 0) votes++;
    nFaces = [self detectFace: image withCascade: myCascade showIn:_MYImageView defaultPng:@"3.png"];
    if (nFaces > 0) votes++;
    if (votes > 3) {
        self.FinalFaceImage = self.TempFaceImage;
        self.FinalFaceImage_Histogram = self.TempFaceImage_Histogram;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"gotFaceSegue" sender:self];
        });
        
//        SecondViewController *secondViewController =
//        [self.storyboard instantiateViewControllerWithIdentifier:@"secondViewController"];
//        [self.navigationController pushViewController:secondViewController animated:NO];
    }
}
-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation  {
    [self.videoCamera updateOrientation];
}
-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.videoCamera updateOrientation];
}
//- (void)processImage:(cv::Mat&)image;

- (int)detectFace:(cv::Mat&)image
      withCascade:(cv::CascadeClassifier *)cascade
           showIn:(UIImageView *)imageView
       defaultPng:(NSString *)defaultPng
{
    @autoreleasepool {
        float haar_scale = 1.15;
        int haar_minNeighbors = 3;
        int haar_flags = 0 | CV_HAAR_SCALE_IMAGE | CV_HAAR_DO_CANNY_PRUNING;
        int minSize = 60;
        cv::Size haar_minSize = cvSize(minSize, minSize);
        std::vector<cv::Rect> faces;

        //NSDate *start = [NSDate date];
        cascade->detectMultiScale(image, faces, haar_scale,
                                     haar_minNeighbors, haar_flags, haar_minSize );
        //NSTimeInterval timeInterval = [start timeIntervalSinceNow];
        if (faces.size() == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = [UIImage imageNamed:defaultPng];
            });
        }
        // draw faces
        for( int i = 0; i < faces.size(); i++ ) {
            
            cv::Rect* r = &faces[i];
            cv::rectangle(image,
                          cvPoint( r->x, r->y ),
                          cvPoint( r->x + r->width, r->y + r->height),
                          CV_RGB(0,0,255));
            
            if (i == 0) {
                bool avoidCrash = (
                                   0 <= r->x && 0 <= r->width &&
                                   r->x + r->width <= image.cols &&
                                   0 <= r->y && 0 <= r->height &&
                                   r->y + r->height <= image.rows);
                if (!avoidCrash) return 0;
                cv::Mat subImg = image(*r);
                cv::Mat subImg_Grey;
                cv::Mat subImg_Histogram;
                cv::cvtColor(subImg, subImg_Grey, CV_RGB2GRAY);
                cv::equalizeHist(subImg_Grey, subImg_Histogram);

                IplImage temp = subImg_Grey;
                self.TempFaceImage = [self UIImageFromIplImage:&temp];
                IplImage temph = subImg_Histogram;
                self.TempFaceImage_Histogram = [self UIImageFromIplImage:&temph];
                subImg.release();
                subImg_Grey.release();
                subImg_Histogram.release();
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = self.TempFaceImage;
                });
            }
            
        }
        return faces.size();
    }
}

- (UIImage *)UIImageFromIplImage:(IplImage *)image {
	
	//CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
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
- (IBAction)sgmentedControlIndexChanged:(id)sender {
    if (segmentedControl.selectedSegmentIndex == 0) {
        if (!cameraFrontFacing) [self.videoCamera switchCameras];
        cameraFrontFacing = true;
    }
    if (segmentedControl.selectedSegmentIndex == 1) {
        if (cameraFrontFacing) [self.videoCamera switchCameras];
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch]) {
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOn];  // use AVCaptureTorchModeOff to turn off
            [device unlockForConfiguration];
        }
        cameraFrontFacing = false;
    }
    if (segmentedControl.selectedSegmentIndex == 2) {
    }
    if (segmentedControl.selectedSegmentIndex == 3) {
    }
}


- (void)startCamera {
    _cameraStartRequestTime = [NSDate date];
    [self.videoCamera start];
}
- (IBAction)unwindFromPickerToMain:(UIStoryboardSegue *) segue {
    NSLog(@"Unwind seque called.");
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [self.videoCamera stop];
    NSLog(@"prepareForSegue: %@", segue.identifier);
    SecondViewController *sv = [segue destinationViewController];
    sv.FaceImage = self.FinalFaceImage;
    sv.FaceImage_Histogram = self.FinalFaceImage_Histogram;
}



@end
