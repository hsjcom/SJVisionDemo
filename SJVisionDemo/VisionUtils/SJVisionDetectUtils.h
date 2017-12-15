//
//  SJVisionDetectUtils.h
//  SJVisionDemo
//
//  Created by Soldier on 2017/12/4.
//  Copyright © 2017年 Shaojie Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SJDetectItem.h"

typedef NS_ENUM(NSUInteger, SJDetectType) {
    SJDetectTypeFace,           // 人脸识别
    SJDetectTypeLandmark,       // 特征识别
    SJDetectTypeTextRectangles // 文字识别
};

typedef void(^detectImageHandler)(SJDetectItem * __nullable detectItem);


@interface SJVisionDetectUtils : NSObject

+ (void)detectImageWithType:(SJDetectType)type image:(UIImage *_Nullable)image complete:(detectImageHandler _Nullable)complete;

@end
