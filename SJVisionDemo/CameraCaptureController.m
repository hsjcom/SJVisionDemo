//
//  CameraCaptureController.m
//  SJVisionDemo
//
//  Created by Soldier on 2018/2/9.
//  Copyright © 2018年 Shaojie Hong. All rights reserved.
//

#import "CameraCaptureController.h"
#import <AVFoundation/AVFoundation.h>
#import "SJVisionDetectUtils.h"


typedef void(^detectFaceRequestHandler)(VNRequest *request, NSError * _Nullable error);


@interface CameraCaptureController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *dataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@property (nonatomic, strong) NSMutableArray *layers;
@property (nonatomic, strong) NSMutableArray *hats;

@end


@implementation CameraCaptureController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"实时检测";
    
    [self getAuthorization];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _captureVideoPreviewLayer.frame = self.view.bounds;
}

- (void)initCapture {
    [self.captureSession beginConfiguration];
    
    [self addVideo];
    [self addPreviewLayer];
    
    [self.captureSession commitConfiguration];
    [self.captureSession startRunning];
}

//添加预览视图
- (void)addPreviewLayer {
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _captureVideoPreviewLayer.frame = self.view.bounds;
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    // 显示在视图表面的图层
    CALayer *layer = self.view.layer;
    layer.masksToBounds = true;
    [self.view layoutIfNeeded];
    [layer addSublayer:_captureVideoPreviewLayer];
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
        }
    }
    return _captureSession;
}

- (void)addVideo {
    _videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
    
    [self addVideoInput];
    [self addDataOutput];
}

//获取设备
- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            captureDevice = device;
            break;
        }
    }
    return captureDevice;
}

- (void)addVideoInput {
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:NULL];
    
    if ([self.captureSession canAddInput:_videoInput]) {
        [self.captureSession addInput:_videoInput];
    }
}

/// 添加数据输出
- (void)addDataOutput {
    // 拍摄视频输出对象
    // 初始化输出设备对象，用户获取输出数据
    _dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_dataOutput setSampleBufferDelegate:self queue:dispatch_queue_create("CameraCaptureSampleBufferDelegateQueue", NULL)];
    
    if ([self.captureSession canAddOutput:_dataOutput]) {
        [self.captureSession addOutput:_dataOutput];
        AVCaptureConnection *captureConnection = [_dataOutput connectionWithMediaType:AVMediaTypeVideo];
        
        if ([captureConnection isVideoOrientationSupported]) {
            [captureConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        }
        // 视频稳定设置
        if ([captureConnection isVideoStabilizationSupported]) {
            captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
        
        // 设置输出图片方向
        captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
}

- (void)getAuthorization {
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (videoStatus) {
        case AVAuthorizationStatusAuthorized:
            break;
            
        case AVAuthorizationStatusNotDetermined:
            [self initCapture];
            break;
            
        case AVAuthorizationStatusDenied:
            break;
            
        case AVAuthorizationStatusRestricted: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"相机未授权" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureFileOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef BufferRef = CMSampleBufferGetImageBuffer(sampleBuffer);
    VNDetectFaceRectanglesRequest *detectFaceRequest = [[VNDetectFaceRectanglesRequest alloc ]init];
    VNImageRequestHandler *detectFaceRequestHandler = [[VNImageRequestHandler alloc]initWithCVPixelBuffer:BufferRef options:@{}];
    
    [detectFaceRequestHandler performRequests:@[detectFaceRequest] error:nil];
    NSArray *results = detectFaceRequest.results;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addViewToDetectionFace:results];
    });
}

- (void)addViewToDetectionFace:(NSArray *)results {
    //矩形
    for (CALayer *layer in self.layers) {
        [layer removeFromSuperlayer];
    }
    
    //帽子
    for (UIImageView *imageV in self.hats) {
        [imageV removeFromSuperview];
    }
    
    [self.layers removeAllObjects];
    [self.hats removeAllObjects];
    
    for (VNFaceObservation *observation in results) {
        CGRect oldRect = observation.boundingBox;
        CGFloat w = oldRect.size.width * self.view.bounds.size.width;
        CGFloat h = oldRect.size.height * self.view.bounds.size.height;
        CGFloat x = oldRect.origin.x * self.view.bounds.size.width;
        CGFloat y = self.view.bounds.size.height - (oldRect.origin.y * self.view.bounds.size.height) - h;
        
        //添加矩形
        CGRect rect = CGRectMake(x, y, w, h);
        CALayer *testLayer = [[CALayer alloc] init];
        testLayer.borderWidth = 2;
        testLayer.cornerRadius = 3;
        testLayer.borderColor = [UIColor redColor].CGColor;
        testLayer.frame = CGRectMake(x, y, w, h);
        
        [self.layers addObject:testLayer];
        
        // 添加帽子
        CGFloat hatWidth = w;
        CGFloat hatHeight = h;
        CGFloat hatX = rect.origin.x - hatWidth / 4 + 3;
        CGFloat hatY = rect.origin.y - hatHeight;
        CGRect hatRect = CGRectMake(hatX, hatY, hatWidth, hatHeight);
        
        UIImageView *hatImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hat"]];
        hatImage.frame = hatRect;
        [self.hats addObject:hatImage];
    }
    
    //矩形
    for (CALayer *layer in self.layers) {
        [self.view.layer addSublayer:layer];
    }
    
    //帽子
    for (UIImageView *imageV in self.hats) {
        [self.view addSubview:imageV];
    }
}

- (NSMutableArray *)layers {
    if (!_layers) {
        _layers = [NSMutableArray array];
    }
    return _layers;
}

- (NSMutableArray *)hats {
    if (!_hats) {
        _hats = @[].mutableCopy;
    }
    return _hats;
}

@end
