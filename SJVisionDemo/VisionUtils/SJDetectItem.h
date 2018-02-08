//
//  SJDetectItem.h
//  SJVisionDemo
//
//  Created by Soldier on 2017/12/4.
//  Copyright © 2017年 Shaojie Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Vision/Vision.h>

@interface SJDetectItem : NSObject

//所有识别的人脸坐标
@property (nonatomic, strong, nonnull) NSMutableArray *faceAllRect;

//所有识别的文本坐标
@property (nonatomic, strong, nonnull) NSMutableArray *textAllRect;

//所有识别的特征points
@property (nonatomic, strong, nonnull) NSMutableArray *facePoints;

@end





@interface SJDetectFaceItem : NSObject

@property (nonatomic, strong, nullable) VNFaceObservation *observation;
@property (nonatomic, strong, nullable) VNFaceLandmarks2D *landmarks;
@property (nonatomic, strong, nonnull) NSMutableArray *allPoints;

@end
