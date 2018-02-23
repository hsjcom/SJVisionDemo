//
//  ViewController.m
//  SJVisionDemo
//
//  Created by Soldier on 2017/12/4.
//  Copyright © 2017年 Shaojie Hong. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Extension.h"
#import "CameraCaptureController.h"
#import "FaceViewController.h"


@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = @[@"人脸识别", @"特征识别", @"文字识别", @"实时检测"];
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *content = self.dataArray[indexPath.row];
    
    if ([content isEqualToString:@"人脸识别"]) {
        FaceViewController *vc = [[FaceViewController alloc] initWithDetectionType:SJDetectTypeFace];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    else if ([content isEqualToString:@"特征识别"]) {
        FaceViewController *vc = [[FaceViewController alloc] initWithDetectionType:SJDetectTypeLandmark];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    else if ([content isEqualToString:@"文字识别"]) {
        FaceViewController *vc = [[FaceViewController alloc] initWithDetectionType:SJDetectTypeTextRectangles];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    else if ([content isEqualToString:@"实时检测"]) {
        CameraCaptureController *vc = [[CameraCaptureController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UITableView *)tableView {
    if (nil == _tableView){
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, statusBarHeight + 44, self.view.width, self.view.height - statusBarHeight - 44) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
        }
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[];
    }
    return _dataArray;
}

@end
