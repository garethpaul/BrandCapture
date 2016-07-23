//
//  features.hpp
//  BrandCapture
//
//  Created by Gareth on 7/23/16.
//  Copyright © 2016 gpj. All rights reserved.
//

#ifndef features_hpp
#define features_hpp

#include <stdio.h>

bool setup(NSString* filename);
cv::vector<cv::Point2f> detect(cv::Mat img_scene);

#endif /* features_hpp */
