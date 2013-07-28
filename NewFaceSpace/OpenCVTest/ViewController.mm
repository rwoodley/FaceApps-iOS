//
//  ViewController.m
//  FaceSpace
//
//  Created by Woodley, Bob on 4/22/13.
//  Copyright (c) 2013 Woodley, Bob. All rights reserved.
//
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

#import "ViewController.h"
#import "SecondViewController.h"
#import "RollViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize segmentedControl;

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    
    self.videoCamera = [[MyCvVideoCamera alloc] initWithParentView:_imageView];
	self.videoCamera.defaultFPS = 15;
	//self.videoCamera.grayscaleMode = YES;
	self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
	self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
	self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.delegate = self;
    
    cameraFrontFacing = true;
    //[self startCamera];
    [segmentedControl setTitle:@"Front" forSegmentAtIndex:0];
    
    torchIsOn = false;
    torchShouldBeOn = false;
    [segmentedControl setTitle:@"No Flash" forSegmentAtIndex:1];
    
	lbpCascade = [self loadCascade:@"lbpcascade_frontalface"];
	alt2Cascade = [self loadCascade:@"haarcascade_frontalface_alt2"];
	myCascade = [self loadCascade:@"constrained_frontalface"];

    _LBPImageView.image = [UIImage imageNamed:@"1.png"];
    _ALTImageView.image = [UIImage imageNamed:@"2.png"];
    _MYImageView.image = [UIImage imageNamed:@"3.png"];
    NSString *sound; NSURL *soundURL;
    sound = [[NSBundle mainBundle] pathForResource:@"Bottle" ofType:@"aiff"];
    soundURL = [NSURL fileURLWithPath:sound];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_sound1);
    sound = [[NSBundle mainBundle] pathForResource:@"Bottle" ofType:@"aiff"];
    soundURL = [NSURL fileURLWithPath:sound];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_sound2);
    sound = [[NSBundle mainBundle] pathForResource:@"Tink" ofType:@"aiff"];
    soundURL = [NSURL fileURLWithPath:sound];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_sound3);
    _playedSound1 = false;
    _playedSound2 = false;
    _playedSound3 = false;

    self.navigationItem.rightBarButtonItem = nil;
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
- (void)manageTorch:(bool) turnOnTorch;
{
    if (turnOnTorch && torchIsOn) return;
    if (!turnOnTorch && !torchIsOn) return; // yes, i could use an XOR here.
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        if (turnOnTorch) {
            [device setTorchMode:AVCaptureTorchModeOn];
            torchIsOn = true;
            NSLog(@"Turning Torch on");
        }
        else {
            [device setTorchMode:AVCaptureTorchModeOff];
            torchIsOn = false;
            NSLog(@"Turning Torch off");
        }
        [device unlockForConfiguration];
    }

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
    cv::Mat cleanImage;         // won't be drawing boxes on this image.
    cleanImage = image.clone();
    
    int votes = 0;
    int nFaces = 0;
    nFaces = [self detectFace: image cleanImage:cleanImage withCascade: lbpCascade showIn:_LBPImageView defaultPng:@"1.png"];
    if (nFaces > 0) {
        votes++;
        if (!_playedSound1) {
            AudioServicesPlaySystemSound(_sound1);
            _playedSound1 = true;
        }
    }
    else
        _playedSound1 = false;
    
    nFaces = [self detectFace: image cleanImage:cleanImage withCascade: alt2Cascade showIn:_ALTImageView defaultPng:@"2.png"];
    if (nFaces > 0) {
        votes++;
        if (!_playedSound2) {
            AudioServicesPlaySystemSound(_sound2);
            _playedSound2 = true;
        }
    }
    else
        _playedSound2 = false;

    if (torchShouldBeOn && votes == 2)
        [self manageTorch:true];

    if (!torchShouldBeOn)
        [self manageTorch:false];

    nFaces = [self detectFace: image cleanImage:cleanImage withCascade: myCascade showIn:_MYImageView defaultPng:@"3.png"];
    bool myDetectorFoundFace = nFaces > 0;
    if (nFaces > 0) {
        votes++;
        AudioServicesPlaySystemSound(_sound3);
    }
    if (votes > 2 || myDetectorFoundFace) {    // change this to '2' to require all 3 haar algos to have a vote.

        [self manageTorch:false];
        self.FinalFaceImage = self.TempFaceImage;
        self.FinalFaceImage_Histogram = self.TempFaceImage_Histogram;
        dispatch_async(dispatch_get_main_queue(), ^{
            /*
            SecondViewController *sVC =
            [self.storyboard instantiateViewControllerWithIdentifier:@"secondViewController"];
            [self.navigationController pushViewController:sVC animated:YES];
            */
            [self performSegueWithIdentifier:@"gotFaceSegue" sender:self];
        });
        
    }
    cleanImage.release();
}
-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation  {
    [self.videoCamera updateOrientation];
}
-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.videoCamera updateOrientation];
}

- (int)detectFace:(cv::Mat&)image
       cleanImage:(cv::Mat&)cleanImage
      withCascade:(cv::CascadeClassifier *)cascade
           showIn:(UIImageView *)imageView
       defaultPng:(NSString *)defaultPng
{
    @autoreleasepool {
        float haar_scale = 1.15;
        int haar_minNeighbors = 3;
        int haar_flags = 0 | CV_HAAR_SCALE_IMAGE | CV_HAAR_DO_CANNY_PRUNING;
        int minSize = 120;
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
            
            // expand so we don't cut off everyone's chin
            int newWidth = (int) r->width*0.30;
            (*r) += cv::Size(newWidth,newWidth);        // overall bigger
            (*r) -= cv::Point(newWidth/2,newWidth/2);   // recenter
            
            cv::rectangle(image,                // draw on 'dirty' image
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
                cv::Mat subImg = cleanImage(*r);    // grab face from clean image
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
        cameraFrontFacing = !cameraFrontFacing;
        [self.videoCamera switchCameras];
        if (cameraFrontFacing) {
            [segmentedControl setTitle:@"Front" forSegmentAtIndex:0];
            [segmentedControl setTitle:@"No Flash" forSegmentAtIndex:1];
            [segmentedControl setEnabled:false forSegmentAtIndex:1];
            [self manageTorch:false];
            torchShouldBeOn = false;
        }
        else {
            [segmentedControl setTitle:@"Back" forSegmentAtIndex:0];
            [segmentedControl setTitle:@"No Flash" forSegmentAtIndex:1];
            AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            if ([device hasTorch])
                [segmentedControl setEnabled:true forSegmentAtIndex:1];
            else
                [segmentedControl setEnabled:true forSegmentAtIndex:0];
            [self manageTorch:false];
            torchShouldBeOn = false;
        }
    }
    if (segmentedControl.selectedSegmentIndex == 1) {
        torchShouldBeOn = !torchShouldBeOn;
        if (torchShouldBeOn)
            [segmentedControl setTitle:@"Flash" forSegmentAtIndex:1];
        else
            [segmentedControl setTitle:@"No Flash" forSegmentAtIndex:1];
    }
    if (segmentedControl.selectedSegmentIndex == 2) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            
            imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
            
            imagePicker.delegate = self;
            //[self presentModalViewController: imagePicker animated: YES];
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:NULL];
        
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSURL *assetURL = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    [library assetForURL: assetURL
             resultBlock:^(ALAsset *asset) {
                 NSDictionary *metadata = asset.defaultRepresentation.metadata;
                 
                 //for(id key in metadata) NSLog(@"key=%@ value=%@", key, [metadata objectForKey:key]);
                 // We're caching the ID in the TIFF dictionary entry with this key: kCGImagePropertyTIFFMake
                 NSDictionary *tiffDictionary = [metadata objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
                 NSString *ourCachedValue = [tiffDictionary objectForKey:(NSString *)kCGImagePropertyTIFFMake];
                 if (ourCachedValue != NULL) {
                     if (ourCachedValue.length < 11) {
                         [self showAlert];
                     }
                     else {
                         NSString *value = [ourCachedValue substringWithRange:NSMakeRange(0, 11)];
                         if ([value isEqualToString:@"FaceFieldID"]) {
                             NSString *idString =[ourCachedValue substringWithRange:NSMakeRange(11, [ourCachedValue length]-11)];
                             NSLog(@"idString: %@", idString);
                             NSString *urlString = [NSString stringWithFormat:@"http://facefield.org?ukey=%d", idString.intValue];
                             _URLFromCameraRoll = [[NSURL alloc] initWithString:urlString];
                             
                             self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style: UIBarButtonItemStyleBordered target:nil action:nil];

                             [self performSegueWithIdentifier:@"gotFaceFromRollSegue" sender:self];
                         }
                         else
                             [self showAlert];
                 
                     }
                 }
                 else
                     [self showAlert];
             } failureBlock:^(NSError *error) {
                 NSLog(@"Error getting Asset from URL");
             }];
    
}

- (void)showAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"This photo was not taken with the FaceField app. Go ahead and take a new photo of a face on the main window."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

}
- (void)startCamera {
    // see: http://stackoverflow.com/questions/9826920/uinavigationcontroller-force-rotate
    //set statusbar to the desired rotation position
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    //present/dismiss viewcontroller in order to activate rotating.
    UIViewController *mVC = [[UIViewController alloc] init];
    [self presentViewController:mVC animated:NO completion:NULL];
    [self dismissViewControllerAnimated:NO completion:NULL];
    
    // This has to be done before video camera is started because then MyCvVideoCamera->layoutPreview defeats resize somehow.
    // adjust aspect ratio of UIImage so that there is no distortion of the image.
    // aspect ratio of UIImage * aspect ratio of the video should = 1.
    double newHeight = _imageView.frame.size.width * (352.0/288.0);
    _imageView.frame = CGRectMake(
                                  _imageView.frame.origin.x,
                                  _imageView.frame.origin.y, _imageView.frame.size.width, newHeight);
    NSLog(@"image h*w = %f,%f", _imageView.frame.size.height, _imageView.frame.size.width);
    _cameraStartRequestTime = [NSDate date];
    [self.videoCamera start];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [self.videoCamera stop];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style: UIBarButtonItemStyleBordered target:nil action:nil];
    NSLog(@"prepareForSegue: %@", segue.identifier);
    if ([segue.identifier isEqualToString: @"gotFaceSegue"]) {
        SecondViewController *sv = [segue destinationViewController];
        sv.FaceImage = self.FinalFaceImage;
        sv.FaceImage_Histogram = self.FinalFaceImage_Histogram;
    }
    if ([segue.identifier isEqualToString:@"gotFaceFromRollSegue"]) {
        RollViewController *rvc = [segue destinationViewController];
        rvc.FaceFieldURL = _URLFromCameraRoll;
    }
}
- (IBAction) unwindToMain:(UIStoryboardSegue *) sender {
    NSLog(@"Unwind seque called");
    [self.videoCamera start];
}
- (void)viewDidAppear:(BOOL)animated
{
    if (_preventRecursion) return;
    _preventRecursion = true;

    NSLog(@"******viewDidAppear*****");
    [self startCamera];
    _preventRecursion = false;
}
@end
