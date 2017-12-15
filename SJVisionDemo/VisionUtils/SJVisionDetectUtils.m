//
//  SJVisionDetectUtils.m
//  SJVisionDemo
//
//  Created by Soldier on 2017/12/4.
//  Copyright © 2017年 Shaojie Hong. All rights reserved.
//

#import "SJVisionDetectUtils.h"
#import <Vision/Vision.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^CompletionHandler)(VNRequest * _Nullable request, NSError * _Nullable error);

@implementation SJVisionDetectUtils

+ (void)detectImageWithType:(SJDetectType)type image:(UIImage *_Nullable)image complete:(detectImageHandler _Nullable )complete {
    // 转换CIImage
    CIImage *convertImage = [[CIImage alloc] initWithImage:image];
    
    // 创建处理requestHandler
    VNImageRequestHandler *detectRequestHandler = [[VNImageRequestHandler alloc]initWithCIImage:convertImage options:@{}];
    
    // 创建BaseRequest
    VNImageBasedRequest *detectRequest = [[VNImageBasedRequest alloc]init];
    
    // 设置回调
    CompletionHandler completionHandler = ^(VNRequest *request, NSError * _Nullable error) {
        NSArray *observations = request.results;
        [self handleImageWithType:type image:image observations:observations complete:complete];
    };
    
    switch (type) {
        case SJDetectTypeFace:
            detectRequest = [[VNDetectFaceRectanglesRequest alloc] initWithCompletionHandler:completionHandler];
            break;
        case SJDetectTypeLandmark:
            detectRequest = [[VNDetectFaceLandmarksRequest alloc] initWithCompletionHandler:completionHandler];
            break;
        case SJDetectTypeTextRectangles:
            detectRequest = [[VNDetectTextRectanglesRequest alloc] initWithCompletionHandler:completionHandler];
            [detectRequest setValue:@(YES) forKey:@"reportCharacterBoxes"]; //设置识别具体文字
            break;
        default:
            break;
    }
    
    // 发送识别请求
    [detectRequestHandler performRequests:@[detectRequest] error:nil];
}

+ (void)handleImageWithType:(SJDetectType)type image:(UIImage *_Nullable)image observations:(NSArray *)observations complete:(detectImageHandler _Nullable )complete{
    switch (type) {
        case SJDetectTypeFace:
            
            break;
            
        case SJDetectTypeLandmark:
        {
            
            break;
        }
        case SJDetectTypeTextRectangles:
        {
            
            break;
        }
        default:
            break;
    }
}

@end
