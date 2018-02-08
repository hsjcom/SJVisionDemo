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
#import <objc/runtime.h>


typedef void(^CompletionHandler)(VNRequest * _Nullable request, NSError * _Nullable error);


@implementation SJVisionDetectUtils

+ (void)detectImageWithType:(SJDetectType)type image:(UIImage *_Nullable)image complete:(detectImageHandler _Nullable )complete {
    // 转换CIImage
    CIImage *convertImage = [[CIImage alloc] initWithImage:image];
    
    // 创建处理requestHandler
    VNImageRequestHandler *detectRequestHandler = [[VNImageRequestHandler alloc] initWithCIImage:convertImage options:@{}];
    
    // 创建BaseRequest
    VNImageBasedRequest *detectRequest = [[VNImageBasedRequest alloc] init];
    
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

+ (void)handleImageWithType:(SJDetectType)type image:(UIImage *_Nullable)image observations:(NSArray *)observations complete:(detectImageHandler _Nullable )complete {
    switch (type) {
        case SJDetectTypeFace:
            [self faceRectangles:observations image:image complete:complete];
            break;
            
        case SJDetectTypeLandmark:
            [self faceLandmarks:observations image:image complete:complete];
            break;
        
        case SJDetectTypeTextRectangles:
        
            [self textRectangles:observations image:image complete:complete];
            break;
        
        default:
            break;
    }
}

/*
 处理文本回调
 */
+ (void)textRectangles:(NSArray *)observations image:(UIImage *_Nullable)image complete:(detectImageHandler _Nullable )complete {
    
    SJDetectItem *detectTextData = [[SJDetectItem alloc] init];
    
    NSMutableArray *tempArray = @[].mutableCopy;
    for (VNTextObservation *observation in observations) {
        for (VNRectangleObservation *box in observation.characterBoxes) {
            // CreateBoxView
            NSValue *ractValue = [NSValue valueWithCGRect:[self convertRect:box.boundingBox imageSize:image.size]];
            [tempArray addObject:ractValue];
        }
    }
    detectTextData.textAllRect = tempArray;
    
    if (complete) {
        complete(detectTextData);
    }
}

/*
 处理人脸识别回调
 */
+ (void)faceRectangles:(NSArray *)observations image:(UIImage *_Nullable)image complete:(detectImageHandler _Nullable )complete {
    
    SJDetectItem *detectFaceData = [[SJDetectItem alloc] init];
    
    NSMutableArray *tempArray = @[].mutableCopy;
    for (VNFaceObservation *observation in observations) {
        NSValue *ractValue = [NSValue valueWithCGRect:[self convertRect:observation.boundingBox imageSize:image.size]];
        [tempArray addObject:ractValue];
    }
    detectFaceData.faceAllRect = tempArray;
    
    if (complete) {
        complete(detectFaceData);
    }
}

/*
 处理人脸特征回调
 */
+ (void)faceLandmarks:(NSArray *)observations image:(UIImage *_Nullable)image complete:(detectImageHandler _Nullable )complete{
    
    SJDetectItem *detectData = [[SJDetectItem alloc] init];
    
    for (VNFaceObservation *observation in observations) {
        
        // 创建特征存储对象
        SJDetectFaceItem *detectFaceData = [[SJDetectFaceItem alloc]init];
        
        // 获取细节特征
        VNFaceLandmarks2D *landmarks = observation.landmarks;
        
        [self getAllkeyWithClass:[VNFaceLandmarks2D class] isProperty:YES block:^(NSString *key) {
            // 过滤属性
            if ([key isEqualToString:@"allPoints"]) {
                return;
            }
            
            // 得到对应细节具体特征（鼻子，眼睛。。。）
            VNFaceLandmarkRegion2D *region2D = [landmarks valueForKey:key];
            // 特征存储对象进行存储
//            [detectFaceData setValue:region2D forKey:key];
            [detectFaceData.allPoints addObject:region2D];
        }];
        detectFaceData.observation = observation;
        detectFaceData.landmarks = landmarks;
        
        [detectData.facePoints addObject:detectFaceData];
    }
    
    if (complete) {
        complete(detectData);
    }
}

//转换Rect
+ (CGRect)convertRect:(CGRect)oldRect imageSize:(CGSize)imageSize{
    CGFloat w = oldRect.size.width * imageSize.width;
    CGFloat h = oldRect.size.height * imageSize.height;
    CGFloat x = oldRect.origin.x * imageSize.width;
    CGFloat y = imageSize.height - (oldRect.origin.y * imageSize.height) - h;
    
    return CGRectMake(x, y, w, h);
}

// 获取对象属性keys
+ (NSArray *)getAllkeyWithClass:(Class)class isProperty:(BOOL)property block:(void(^)(NSString *key))block {
    NSMutableArray *keys = @[].mutableCopy;
    unsigned int outCount = 0;
    
    Ivar *vars = NULL;
    objc_property_t *propertys = NULL;
    const char *name;
    
    if (property) {
        propertys = class_copyPropertyList(class, &outCount);
    } else {
        vars = class_copyIvarList(class, &outCount);
    }
    
    for (int i = 0; i < outCount; i ++) {
        if (property) {
            objc_property_t property = propertys[i];
            name = property_getName(property);
        } else {
            Ivar var = vars[i];
            name = ivar_getName(var);
        }
        NSString *key = [NSString stringWithUTF8String:name];
        block(key);
    }
    free(vars);
    
    return keys.copy;
}


@end
