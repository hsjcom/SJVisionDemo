//
//  FaceViewController.m
//  SJVisionDemo
//
//  Created by Soldier on 2018/2/22.
//  Copyright © 2018年 Shaojie Hong. All rights reserved.
//

#import "FaceViewController.h"
#import "SJDetectItem.h"
#import "UIView+Extension.h"
#import "SJVisionViewUtils.h"

@interface FaceViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) SJDetectType detectType;

@property (nonatomic, strong) UIImageView *showImageView;
@property (nonatomic, strong) UIImagePickerController *pickerVC;

@end



@implementation FaceViewController

- (instancetype _Nullable )initWithDetectionType:(SJDetectType)type {
    if (self = [super init]) {
        _detectType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.showImageView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:self.pickerVc animated:NO completion:nil];
    });
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *, id> *)editingInfo {
    [self.pickerVC dismissViewControllerAnimated:NO completion:nil];
    [self detectFace:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.pickerVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)detectFace:(UIImage *)image {
    UIImage *localImage = [self scaleImage:image width:self.view.width];
    [self.showImageView setImage:localImage];
    self.showImageView.size = localImage.size;
    
    [SJVisionDetectUtils detectImageWithType:self.detectType image:localImage complete:^(SJDetectItem * _Nullable detectData) {
        switch (self.detectType) {
            case SJDetectTypeFace:
                for (NSValue *rectValue in detectData.faceAllRect) {
                    [self.showImageView addSubview: [SJVisionViewUtils getRectViewWithFrame:rectValue.CGRectValue]];
                }
                break;
                
            case SJDetectTypeLandmark:
                for (SJDetectFaceItem *faceData in detectData.facePoints) {
                    self.showImageView.image = [SJVisionViewUtils drawImage:self.showImageView.image observation:faceData.observation pointArray:faceData.allPoints];
                }
                break;
                
            case SJDetectTypeTextRectangles:
                for (NSValue *rectValue in detectData.textAllRect) {
                    [self.showImageView addSubview: [SJVisionViewUtils getRectViewWithFrame:rectValue.CGRectValue]];
                }
                break;
                
            default:
                break;
        }
    }];
}

//图片压缩到指定大小
- (UIImage *)scaleImage:(UIImage *)image width:(CGFloat)width {
    CGFloat height = image.size.height * width / image.size.width;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [image drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    NSData *tempData = UIImageJPEGRepresentation(result, 0.5);
    return [UIImage imageWithData:tempData];
}

- (UIImageView *)showImageView {
    if (!_showImageView) {
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        _showImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, statusBarHeight + 44, self.view.width, self.view.width)];
        _showImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _showImageView;
}

- (UIImagePickerController *)pickerVc {
    if (!_pickerVC) {
        _pickerVC = [[UIImagePickerController alloc] init];
        _pickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _pickerVC.delegate = self;
    }
    return _pickerVC;
}

@end
