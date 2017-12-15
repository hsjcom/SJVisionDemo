//
//  SJDetectItem.m
//  SJVisionDemo
//
//  Created by Soldier on 2017/12/4.
//  Copyright © 2017年 Shaojie Hong. All rights reserved.
//

#import "SJDetectItem.h"

@implementation SJDetectItem

- (NSMutableArray *)textAllRect {
    if (!_textAllRect) {
        _textAllRect = @[].mutableCopy;
    }
    return _textAllRect;
}

- (NSMutableArray *)faceAllRect {
    if (!_faceAllRect) {
        _faceAllRect = @[].mutableCopy;
    }
    return _faceAllRect;
}

- (NSMutableArray *)facePoints{
    if (!_facePoints) {
        _facePoints = @[].mutableCopy;
    }
    return _facePoints;
}

@end




@implementation JSDetectFaceItem

- (NSMutableArray *)allPoints {
    if (!_allPoints) {
        _allPoints = @[].mutableCopy;
    }
    return _allPoints;
}

@end
