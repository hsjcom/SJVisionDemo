//
//  SJVisionViewUtils.h
//  SJVisionDemo
//
//  Created by Soldier on 2018/2/22.
//  Copyright © 2018年 Shaojie Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Vision/Vision.h>

@interface SJVisionViewUtils : NSObject

+ (UIImage *)drawImage:(UIImage *)source
           observation:(VNFaceObservation *)observation
            pointArray:(NSArray *)pointArray;

+ (UIView *)getRectViewWithFrame:(CGRect)frame;

@end
