//
//  DispatchMaterialUploadViewCtr.m
//  JLPay
//
//  Created by jielian on 16/5/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DispatchMaterialUploadViewCtr.h"
#import "Define_Header.h"
#import "VMDispatchUpload.h"
#import "Masonry.h"
#import "VMImgPicker.h"
#import <ReactiveCocoa.h>
#import "QianPiViewController.h"


@implementation DispatchMaterialUploadViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"上传调单资料";
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self loadSubviews];
    [self layoutSubviews];
    [self addKVOs];
}

- (void) loadSubviews {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.uploadBtn];
    [self.view addSubview:self.progressHud];
}
- (void) layoutSubviews {
    NameWeakSelf(wself);
    
    CGFloat heightBtn = self.view.frame.size.height * 1/14.f;
    CGFloat inset = 10;
    
    [self.uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left).offset(inset);
        make.right.equalTo(wself.view.mas_right).offset(- inset);
        make.bottom.equalTo(wself.view.mas_bottom).offset(- inset);
        make.height.mas_equalTo(heightBtn);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wself.view.mas_top).offset(64);
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.bottom.equalTo(wself.uploadBtn.mas_top).offset(- inset);
    }];
}

# pragma mask 1 KVOs
- (void) addKVOs {
    
    @weakify(self);
    [self.dispatchUploader.commandDispatchUpload.executionSignals subscribeNext:^(RACSignal* sig) {
        [[[sig dematerialize] deliverOnMainThread] subscribeNext:^(id x) {
            @strongify(self);
            [self.dispatchUploader.httpUpload.httpRequester setUploadProgressDelegate:self.progressHud];
            [self.progressHud showCircleProgressWithText:@"正在上传图片资料..." andDetailText:nil];
        } error:^(NSError *error) {
            @strongify(self);
            [self.progressHud showFailWithText:@"上传失败" andDetailText:[error localizedDescription] onCompletion:^{
            }];
        } completed:^{
            @strongify(self);
            [self.progressHud showSuccessWithText:@"上传成功" andDetailText:nil onCompletion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
    }];
    
}

# pragma mask 4 getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self.dispatchUploader;
        _tableView.dataSource = self.dispatchUploader;
    }
    return _tableView;
}

- (UIButton *)uploadBtn {
    if (!_uploadBtn) {
        _uploadBtn = [UIButton new];
        _uploadBtn.backgroundColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
        [_uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
        [_uploadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_uploadBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.7] forState:UIControlStateHighlighted];
        [_uploadBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.7] forState:UIControlStateDisabled];
        _uploadBtn.layer.cornerRadius = 5.f;
        _uploadBtn.rac_command = self.dispatchUploader.commandDispatchUpload;
    }
    return _uploadBtn;
}
- (VMDispatchUpload *)dispatchUploader {
    if (!_dispatchUploader) {
        _dispatchUploader = [[VMDispatchUpload alloc] init];
        @weakify(self);
        _dispatchUploader.pushQianPiVCBlock = ^ (UIViewController* qianpi) {
            @strongify(self);
            [self.navigationController pushViewController:qianpi animated:YES];
        };

        _dispatchUploader.commandImgPicker = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self.imgPicker pickImgOnHandleViewC:self OnFinished:^(NSArray *imgs) {
                    [subscriber sendNext:imgs];
                    [subscriber sendCompleted];
                    [self.tableView reloadData];
                } onCancel:^{
                    [subscriber sendCompleted];
                }];
                return nil;
            }] materialize];
        }];
        
    }
    return _dispatchUploader;
}

- (VMImgPicker *)imgPicker {
    if (!_imgPicker) {
        _imgPicker = [[VMImgPicker alloc] init];
    }
    return _imgPicker;
}
- (MBProgressHUD *)progressHud {
    if (!_progressHud) {
        _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _progressHud;
}

@end
