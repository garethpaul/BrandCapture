//
//  features.hpp
//  BrandCapture
//
//  Created by Gareth on 7/23/16.
//  Copyright © 2016 gpj. All rights reserved.
//

#ifndef features_hpp
#define features_hpp

#import <Foundation/Foundation.h>
#import <opencv2/core/core.hpp>

bool setup(NSString* filename);
cv::vector<cv::Point2f> detect(cv::Mat img_scene);
bool hasValidCorners(const cv::vector<cv::Point2f>& corners);

#endif /* features_hpp */
