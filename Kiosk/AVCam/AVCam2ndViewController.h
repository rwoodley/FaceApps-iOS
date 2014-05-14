//
//  AVCam2ndViewController.h
//  AVCam
//
//  Created by Robert Woodley on 5/1/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AVCam2ndViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate>
{
    UIImage *_FaceImage;
    NSMutableData *_responseData;
    int _redirectionOption;
}
@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
@property (nonatomic, retain) UIImage *FaceImage;

@end
