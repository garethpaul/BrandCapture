#include <stdio.h>
#include <cmath>
#include <iostream>
#include <limits>
#import "features.hpp"
#include "opencv2/core/core.hpp"
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/calib3d/calib3d.hpp"
#include "opencv2/nonfree/nonfree.hpp"

using namespace cv;

void readme();

static const int kMinHessian = 400;
static const int kExpectedCornerCount = 4;
static const int kMinimumGoodMatches = 4;
static const double kGoodMatchDistanceMultiplier = 3.0;

static std::vector<Point2f> emptyCorners()
{
    return std::vector<Point2f>();
}

Mat img_object;
Mat img_scene;
SurfFeatureDetector detector(kMinHessian);
std::vector<KeyPoint> keypoints_object, keypoints_scene;
SurfDescriptorExtractor extractor;
Mat descriptors_object, descriptors_scene;


bool setup(NSString* filename)
{
    if (filename == nil) {
        return false;
    }

    NSString* path = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension]
                                                     ofType:[filename pathExtension]];
    if (path == nil) {
        return false;
    }

    img_object = imread([path UTF8String], CV_LOAD_IMAGE_GRAYSCALE);
    
    if( !img_object.data) {
        return false;
    }
    
    
    //-- Step 1: Detect the keypoints using SURF Detector
    keypoints_object.clear();
    descriptors_object.release();
    detector.detect( img_object, keypoints_object );
    if (keypoints_object.empty()) {
        return false;
    }
    
    //-- Step 2: Calculate descriptors (feature vectors)
    extractor.compute( img_object, keypoints_object, descriptors_object );
    
    return !descriptors_object.empty();
    
}





vector<Point2f> detect(Mat img_scene)
{
    
    if( !img_object.data || !img_scene.data )
    {
        return emptyCorners();
    }
    keypoints_scene.clear();
    descriptors_scene.release();
    detector.detect( img_scene, keypoints_scene );
    extractor.compute( img_scene, keypoints_scene, descriptors_scene );
    if (descriptors_object.empty() || descriptors_scene.empty()) {
        return emptyCorners();
    }
    
    
    //-- Step 3: Matching descriptor vectors using FLANN matcher
    FlannBasedMatcher matcher;
    std::vector< DMatch > matches;
    try {
        matcher.match( descriptors_object, descriptors_scene, matches );
    } catch (const cv::Exception&) {
        return emptyCorners();
    }

    if (matches.size() < kMinimumGoodMatches) {
        return emptyCorners();
    }
    
    
    double min_dist = std::numeric_limits<double>::max();
    
    //-- Quick calculation of max and min distances between keypoints
    for( size_t i = 0; i < matches.size(); i++ )
    { double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
    }
    
    //-- Draw only "good" matches (i.e. whose distance is less than 3*min_dist )
    std::vector< DMatch > good_matches;
    
    for( size_t i = 0; i < matches.size(); i++ )
    { if( matches[i].distance < kGoodMatchDistanceMultiplier*min_dist )
    { good_matches.push_back( matches[i]); }
    }

    if (good_matches.size() < kMinimumGoodMatches)
    {
        return emptyCorners();
    }
    //-- Localize the object
    std::vector<Point2f> object;
    std::vector<Point2f> scene;
    
    for( size_t i = 0; i < good_matches.size(); i++ )
    {
        if (good_matches[i].queryIdx < 0 || good_matches[i].trainIdx < 0 ||
            static_cast<size_t>(good_matches[i].queryIdx) >= keypoints_object.size() ||
            static_cast<size_t>(good_matches[i].trainIdx) >= keypoints_scene.size())
        {
            return emptyCorners();
        }

        //-- Get the keypoints from the good matches
        object.push_back( keypoints_object[ good_matches[i].queryIdx ].pt );
        scene.push_back( keypoints_scene[ good_matches[i].trainIdx ].pt );
    }

    if (object.size() < kMinimumGoodMatches || scene.size() < kMinimumGoodMatches)
    {
        return emptyCorners();
    }
    
    try {
        Mat H = findHomography(object, scene, CV_RANSAC );
        if (H.empty()) {
            return emptyCorners();
        }
        
        
        //-- Get the corners from the image_1 ( the object to be "detected" )
        std::vector<Point2f> obj_corners(kExpectedCornerCount);
        obj_corners[0] = cvPoint(0,0);
        obj_corners[1] = cvPoint( img_object.cols, 0 );
        obj_corners[2] = cvPoint( img_object.cols, img_object.rows );
        obj_corners[3] = cvPoint( 0, img_object.rows );
        std::vector<Point2f> scene_corners(kExpectedCornerCount);
        
        perspectiveTransform( obj_corners, scene_corners, H);
        
        return scene_corners;
        
    } catch (const cv::Exception&) {
        return emptyCorners();
    }
}

bool hasValidCorners(const vector<Point2f>& corners)
{
    if (corners.size() != kExpectedCornerCount)
    {
        return false;
    }

    for (size_t i = 0; i < corners.size(); i++)
    {
        if (!std::isfinite(corners[i].x) || !std::isfinite(corners[i].y))
        {
            return false;
        }
    }

    return true;
}



/** @function readme */
void readme()
{ std::cout << " Usage: ./SURF_descriptor <img1> <img2>" << std::endl; }
