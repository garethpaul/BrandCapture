#import "ViewController.h"
#import "features.hpp"

static NSString * const BrandCaptureReferenceImageName = @"clipper.jpg";
static const int BrandCaptureDefaultFPS = 40;
static const int BrandCaptureOverlayThickness = 12;

@interface ViewController ()

- (void)stopCaptureIfNeeded;
- (void)updateCaptureControls;

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
    
    self.videoCamera = [[CvVideoCamera alloc]
                        initWithParentView:imageView];
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
    isCapturing = NO;
    [self updateCaptureControls];
}

- (NSUInteger)supportedInterfaceOrientations
{
    // Only portrait orientation
    return UIInterfaceOrientationMaskPortrait;
}

-(IBAction)startCaptureButtonPressed:(id)sender
{
    if (isCapturing || !isDetectorReady || self.videoCamera == nil)
    {
        return;
    }

    [self.videoCamera start];
    isCapturing = YES;
    [self updateCaptureControls];
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
    [self stopCaptureIfNeeded];
    self.videoCamera.delegate = nil;
}

- (void)stopCaptureIfNeeded
{
    if (isCapturing && self.videoCamera != nil)
    {
        [self.videoCamera stop];
        isCapturing = NO;
        [self updateCaptureControls];
    }
}

- (void)updateCaptureControls
{
    startCaptureButton.enabled = isDetectorReady && !isCapturing;
    stopCaptureButton.enabled = isDetectorReady && isCapturing;
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    if (image == nil || image.CGImage == nil)
    {
        return cv::Mat();
    }

    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    int cols = static_cast<int>(image.size.width);
    int rows = static_cast<int>(image.size.height);
    if (colorSpace == NULL || cols <= 0 || rows <= 0)
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

    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    int cols = static_cast<int>(image.size.width);
    int rows = static_cast<int>(image.size.height);
    if (colorSpace == NULL || cols <= 0 || rows <= 0)
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

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    if (cvMat.empty() || cvMat.data == NULL || cvMat.cols <= 0 || cvMat.rows <= 0)
    {
        return nil;
    }

    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
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
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
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
