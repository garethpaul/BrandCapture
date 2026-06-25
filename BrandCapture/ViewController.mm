#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "features.hpp"
#include "CaptureSessionState.hpp"
#include "ImageMatrixLayout.hpp"
#include <limits>

static NSString * const BrandCaptureReferenceImageName = @"clipper.jpg";
static const int BrandCaptureDefaultFPS = 40;
static const int BrandCaptureOverlayThickness = 12;

static brandcapture::CameraAuthorization
BrandCaptureCameraAuthorization(AVAuthorizationStatus status)
{
    switch (status)
    {
        case AVAuthorizationStatusAuthorized:
            return brandcapture::CameraAuthorization::Authorized;
        case AVAuthorizationStatusDenied:
            return brandcapture::CameraAuthorization::Denied;
        case AVAuthorizationStatusRestricted:
            return brandcapture::CameraAuthorization::Restricted;
        case AVAuthorizationStatusNotDetermined:
            return brandcapture::CameraAuthorization::NotDetermined;
    }

    return brandcapture::CameraAuthorization::Denied;
}

static BOOL BrandCaptureGetImagePixelSize(UIImage *image, int *cols, int *rows)
{
    if (image == nil || image.CGImage == nil || cols == NULL || rows == NULL)
    {
        return NO;
    }

    size_t pixelWidth = CGImageGetWidth(image.CGImage);
    size_t pixelHeight = CGImageGetHeight(image.CGImage);
    size_t maxOpenCVDimension = static_cast<size_t>(std::numeric_limits<int>::max());
    if (pixelWidth == 0 || pixelHeight == 0 ||
        pixelWidth > maxOpenCVDimension || pixelHeight > maxOpenCVDimension)
    {
        return NO;
    }

    *cols = static_cast<int>(pixelWidth);
    *rows = static_cast<int>(pixelHeight);
    return YES;
}

@interface ViewController ()
{
    brandcapture::CaptureSessionState captureState;
    id captureSessionDidStartObserver;
    id captureSessionDidStopObserver;
    id captureSessionInterruptedObserver;
    id captureSessionRuntimeErrorObserver;
}

- (void)stopCaptureIfNeeded;
- (void)updateCaptureControls;
- (void)requestCameraAuthorizationForGeneration:(unsigned long)generation;
- (void)startCaptureSessionForGeneration:(unsigned long)generation;
- (void)addCaptureSessionObserversForGeneration:(unsigned long)generation;
- (void)removeCaptureSessionObservers;
- (void)applicationWillResignActive:(NSNotification *)notification;
- (void)applicationDidBecomeActive:(NSNotification *)notification;
- (void)applicationDidEnterBackground:(NSNotification *)notification;

@end

@implementation ViewController

@synthesize imageView;
@synthesize startCaptureButton;
@synthesize stopCaptureButton;
@synthesize toolbar;
@synthesize videoCamera;

- (void)viewDidLoad
{
    [super viewDidLoad];

    captureState = brandcapture::CaptureSessionState();
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    if (self.imageView == nil)
    {
        isDetectorReady = NO;
        [self updateCaptureControls];
        return;
    }

    self.videoCamera = [[CvVideoCamera alloc]
                        initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition =
    AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset =
    AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation =
    AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = BrandCaptureDefaultFPS;
    
    self.videoCamera.grayscaleMode = NO;
    
    isDetectorReady = setup(BrandCaptureReferenceImageName);
    [self updateCaptureControls];
}

- (NSUInteger)supportedInterfaceOrientations
{
    // Only portrait orientation
    return UIInterfaceOrientationMaskPortrait;
}

-(IBAction)startCaptureButtonPressed:(id)sender
{
    (void)sender;
    NSAssert([NSThread isMainThread], @"Capture state must change on the main thread.");
    if (!isDetectorReady || self.videoCamera == nil)
    {
        return;
    }

    AVAuthorizationStatus status =
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    brandcapture::CaptureTransition transition =
        captureState.beginCapture(BrandCaptureCameraAuthorization(status));
    [self updateCaptureControls];

    if (transition.requestAuthorization)
    {
        [self requestCameraAuthorizationForGeneration:transition.generation];
    }
    else if (transition.startSession)
    {
        [self startCaptureSessionForGeneration:transition.generation];
    }
}

-(IBAction)stopCaptureButtonPressed:(id)sender
{
    [self stopCaptureIfNeeded];
}

- (void)processImage:(cv::Mat&)image
{
    if (!isDetectorReady)
    {
        return;
    }

    // Frame processing exception boundary begins here.
    try
    {
        cv::vector<cv::Point2f> corners = detect(image);
        if (!hasValidCorners(corners))
        {
            return;
        }

        cv::line(image, corners[0], corners[1], cv::Scalar( 0, 0, 0 ), BrandCaptureOverlayThickness, 8);
        cv::line(image, corners[1], corners[2], cv::Scalar( 0, 0, 0 ), BrandCaptureOverlayThickness, 8);
        cv::line(image, corners[2], corners[3], cv::Scalar( 0, 0, 0 ), BrandCaptureOverlayThickness, 8);
        cv::line(image, corners[3], corners[0], cv::Scalar( 0, 0, 0 ), BrandCaptureOverlayThickness, 8);
    }
    // Frame processing exception boundary ends here.
    catch (const cv::Exception&)
    {
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopCaptureIfNeeded];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    [self stopCaptureIfNeeded];
    [self removeCaptureSessionObservers];
    self.videoCamera.delegate = nil;
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    (void)notification;
    NSAssert([NSThread isMainThread], @"Capture state must change on the main thread.");
    brandcapture::CaptureTransition transition =
        captureState.applicationWillResignActive();
    if (transition.refreshControls)
    {
        [self removeCaptureSessionObservers];
        [self updateCaptureControls];
    }
    if (transition.stopSession && self.videoCamera != nil)
    {
        [self.videoCamera stop];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    (void)notification;
    NSAssert([NSThread isMainThread], @"Capture state must change on the main thread.");
    brandcapture::CaptureTransition transition =
        captureState.applicationDidBecomeActive();
    if (transition.refreshControls)
    {
        [self updateCaptureControls];
    }
    if (transition.startSession)
    {
        [self startCaptureSessionForGeneration:transition.generation];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    (void)notification;
    NSAssert([NSThread isMainThread], @"Capture state must change on the main thread.");
    brandcapture::CaptureTransition transition =
        captureState.applicationDidEnterBackground();
    [self removeCaptureSessionObservers];
    if (transition.refreshControls)
    {
        [self updateCaptureControls];
    }
    if (transition.stopSession && self.videoCamera != nil)
    {
        [self.videoCamera stop];
    }
}

- (void)stopCaptureIfNeeded
{
    NSAssert([NSThread isMainThread], @"Capture state must change on the main thread.");
    brandcapture::CaptureTransition transition = captureState.stopForLifecycle();
    [self removeCaptureSessionObservers];
    [self updateCaptureControls];

    if (transition.stopSession && self.videoCamera != nil)
    {
        [self.videoCamera stop];
    }
}

- (void)updateCaptureControls
{
    NSAssert([NSThread isMainThread], @"Capture controls must change on the main thread.");
    brandcapture::CaptureControls controls = captureState.controls(isDetectorReady);
    startCaptureButton.enabled = controls.startEnabled;
    stopCaptureButton.enabled = controls.stopEnabled;
}

- (void)requestCameraAuthorizationForGeneration:(unsigned long)generation
{
    __weak ViewController *weakSelf = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ViewController *strongSelf = weakSelf;
            if (strongSelf == nil)
            {
                return;
            }

            brandcapture::CaptureTransition transition =
                strongSelf->captureState.resolveAuthorization(generation, granted);
            if (!transition.refreshControls)
            {
                return;
            }

            [strongSelf updateCaptureControls];
            if (transition.startSession)
            {
                [strongSelf startCaptureSessionForGeneration:transition.generation];
            }
        });
    }];
}

- (void)startCaptureSessionForGeneration:(unsigned long)generation
{
    NSAssert([NSThread isMainThread], @"Capture state must change on the main thread.");
    [self removeCaptureSessionObservers];
    [self addCaptureSessionObserversForGeneration:generation];

    BOOL startRaisedException = NO;
    @try
    {
        [self.videoCamera start];
    }
    @catch (NSException *exception)
    {
        (void)exception;
        startRaisedException = YES;
    }

    AVCaptureSession *session = self.videoCamera.captureSession;
    if (startRaisedException || session == nil ||
        !self.videoCamera.captureSessionLoaded || !session.isRunning)
    {
        brandcapture::CaptureTransition transition =
            captureState.sessionStartupFailed(generation);
        if (!transition.refreshControls)
        {
            return;
        }

        [self removeCaptureSessionObservers];
        [self updateCaptureControls];
        if (transition.stopSession && self.videoCamera != nil)
        {
            [self.videoCamera stop];
        }
    }
}

- (void)addCaptureSessionObserversForGeneration:(unsigned long)generation
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    __weak ViewController *weakSelf = self;

    captureSessionDidStartObserver =
        [center addObserverForName:AVCaptureSessionDidStartRunningNotification
                           object:nil
                            queue:mainQueue
                       usingBlock:^(NSNotification *notification) {
        ViewController *strongSelf = weakSelf;
        if (strongSelf == nil ||
            notification.object != strongSelf.videoCamera.captureSession)
        {
            return;
        }

        brandcapture::CaptureTransition transition =
            strongSelf->captureState.sessionDidStart(generation);
        if (transition.refreshControls)
        {
            [strongSelf updateCaptureControls];
        }
    }];

    captureSessionDidStopObserver =
        [center addObserverForName:AVCaptureSessionDidStopRunningNotification
                           object:nil
                            queue:mainQueue
                       usingBlock:^(NSNotification *notification) {
        ViewController *strongSelf = weakSelf;
        if (strongSelf == nil ||
            notification.object != strongSelf.videoCamera.captureSession)
        {
            return;
        }

        brandcapture::CaptureTransition transition =
            strongSelf->captureState.sessionDidStop(generation);
        if (transition.refreshControls)
        {
            [strongSelf removeCaptureSessionObservers];
            [strongSelf updateCaptureControls];
            if (strongSelf.videoCamera != nil)
            {
                [strongSelf.videoCamera stop];
            }
        }
    }];

    captureSessionInterruptedObserver =
        [center addObserverForName:AVCaptureSessionWasInterruptedNotification
                           object:nil
                            queue:mainQueue
                       usingBlock:^(NSNotification *notification) {
        ViewController *strongSelf = weakSelf;
        if (strongSelf == nil ||
            notification.object != strongSelf.videoCamera.captureSession)
        {
            return;
        }

        brandcapture::CaptureTransition transition =
            strongSelf->captureState.sessionInterrupted(generation);
        if (transition.refreshControls)
        {
            [strongSelf removeCaptureSessionObservers];
            [strongSelf updateCaptureControls];
            if (transition.stopSession && strongSelf.videoCamera != nil)
            {
                [strongSelf.videoCamera stop];
            }
        }
    }];

    captureSessionRuntimeErrorObserver =
        [center addObserverForName:AVCaptureSessionRuntimeErrorNotification
                           object:nil
                            queue:mainQueue
                       usingBlock:^(NSNotification *notification) {
        ViewController *strongSelf = weakSelf;
        if (strongSelf == nil ||
            notification.object != strongSelf.videoCamera.captureSession)
        {
            return;
        }

        brandcapture::CaptureTransition transition =
            strongSelf->captureState.sessionRuntimeError(generation);
        if (transition.refreshControls)
        {
            [strongSelf removeCaptureSessionObservers];
            [strongSelf updateCaptureControls];
            if (transition.stopSession && strongSelf.videoCamera != nil)
            {
                [strongSelf.videoCamera stop];
            }
        }
    }];
}

- (void)removeCaptureSessionObservers
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (captureSessionDidStartObserver != nil)
    {
        [center removeObserver:captureSessionDidStartObserver];
        captureSessionDidStartObserver = nil;
    }
    if (captureSessionDidStopObserver != nil)
    {
        [center removeObserver:captureSessionDidStopObserver];
        captureSessionDidStopObserver = nil;
    }
    if (captureSessionInterruptedObserver != nil)
    {
        [center removeObserver:captureSessionInterruptedObserver];
        captureSessionInterruptedObserver = nil;
    }
    if (captureSessionRuntimeErrorObserver != nil)
    {
        [center removeObserver:captureSessionRuntimeErrorObserver];
        captureSessionRuntimeErrorObserver = nil;
    }
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    if (image == nil || image.CGImage == nil)
    {
        return cv::Mat();
    }

    int cols = 0;
    int rows = 0;
    if (!BrandCaptureGetImagePixelSize(image, &cols, &rows))
    {
        return cv::Mat();
    }

    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    if (colorSpace == NULL)
    {
        return cv::Mat();
    }
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    if (contextRef == NULL)
    {
        return cv::Mat();
    }
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    
    
    return cvMat;
}

- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    if (image == nil || image.CGImage == nil)
    {
        return cv::Mat();
    }

    int cols = 0;
    int rows = 0;
    if (!BrandCaptureGetImagePixelSize(image, &cols, &rows))
    {
        return cv::Mat();
    }

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    if (colorSpace == NULL)
    {
        return cv::Mat();
    }
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNone);          // Bitmap info flags
    if (contextRef == NULL)
    {
        CGColorSpaceRelease(colorSpace);
        return cv::Mat();
    }
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    if (cvMat.empty() || cvMat.data == NULL || cvMat.cols <= 0 || cvMat.rows <= 0)
    {
        return nil;
    }

    if (cvMat.depth() != CV_8U || (cvMat.channels() != 1 && cvMat.channels() != 4))
    {
        return nil;
    }

    cv::Mat imageMat;
    try
    {
        const bool requiresClone = brandcapture::requiresPackedImageClone(
            static_cast<std::size_t>(cvMat.cols),
            cvMat.elemSize(),
            cvMat.step[0],
            cvMat.isContinuous());
        imageMat = requiresClone ? cvMat.clone() : cvMat;
    }
    catch (const cv::Exception&)
    {
        return nil;
    }

    brandcapture::ImageMatrixLayout layout;
    if (!brandcapture::getImageMatrixLayout(imageMat.cols,
                                            imageMat.rows,
                                            imageMat.channels(),
                                            imageMat.elemSize(),
                                            imageMat.step[0],
                                            &layout))
    {
        return nil;
    }

    NSData *data = [NSData dataWithBytes:imageMat.data length:layout.totalBytes];
    CGColorSpaceRef colorSpace;
    CGBitmapInfo bitmapInfo;
    
    if (layout.channelCount == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
        bitmapInfo = kCGImageAlphaNone;
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        bitmapInfo = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
    }
    if (colorSpace == NULL)
    {
        return nil;
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    if (provider == NULL)
    {
        CGColorSpaceRelease(colorSpace);
        return nil;
    }
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(imageMat.cols,                              //width
                                        imageMat.rows,                              //height
                                        8,                                          //bits per component
                                        8 * layout.channelCount,                    //bits per pixel
                                        layout.rowBytes,                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        bitmapInfo,                                 //bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    if (imageRef == NULL)
    {
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(colorSpace);
        return nil;
    }
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
