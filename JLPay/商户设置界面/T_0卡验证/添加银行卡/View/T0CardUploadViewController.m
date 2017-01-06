//
//  T0CardUploadViewController.m
//  JLPay
//
//  Created by jielian on 16/7/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "T0CardUploadViewController.h"
#import "Masonry.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>


@implementation T0CardUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加银行卡";
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    [self loadSubviews];
    [self layoutSuvbiews];
    [self addKVOs];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullUpViewOrNotWhenKeyBoardShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullDownViewWhenKeyBoardHiden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) loadSubviews {
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
    [self.navigationItem setRightBarButtonItem:self.uploadBarBtnItem];
    [self.view addSubview:self.progressHud];
}

- (void) layoutSuvbiews {
    NameWeakSelf(wself);
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.top.equalTo(wself.view.mas_top).offset(64);
        make.bottom.equalTo(wself.view.mas_bottom);
    }];
}

- (void) addKVOs {
    RAC(self.uploadHttp, cardType) = RACObserve(self.dataSource, cardType);
    RAC(self.uploadHttp, cardNo) = RACObserve(self.dataSource, cardNo);
    RAC(self.uploadHttp, userName) = RACObserve(self.dataSource, userName);
    RAC(self.uploadHttp, userId) = RACObserve(self.dataSource, userId);
    RAC(self.uploadHttp, mobilePhone) = RACObserve(self.dataSource, mobilePhone);
    RAC(self.uploadHttp, imageUploaded) = RACObserve(self.dataSource, imagePicked);
    
    @weakify(self);
    [self.uploadBarBtnItem.rac_command.executionSignals  subscribeNext:^(RACSignal* uploadSig) {
        [[uploadSig dematerialize] subscribeNext:^(NSProgress* progress) {
            MBProgressHUD* hud ;
            if (progress == nil) {
                hud = [MBProgressHUD showHorizontalProgressWithText:@"正在上传..." andDetailText:nil];
//                [MBProgressHUD showCircleProgressWithText:@"正在上传..." andDetailText:nil];
            }
            hud.progress = (CGFloat)progress.completedUnitCount/progress.totalUnitCount;
        } error:^(NSError *error) {
            [MBProgressHUD showFailWithText:@"上传失败" andDetailText:[error localizedDescription] onCompletion:^{
                
            }];
        } completed:^{
            @strongify(self);
            [MBProgressHUD showSuccessWithText:@"上传成功" andDetailText:nil onCompletion:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    @strongify(self);
                    [self.navigationController popViewControllerAnimated:YES];
                });;
            }];
        }];
    }];
}


# pragma mask 3 IBAction 

/* 键盘遮罩输入框时，界面上移 */
- (void) pullUpViewOrNotWhenKeyBoardShown:(NSNotification*)shownNoti {
    CGRect keyBoardFrame = [[shownNoti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect textFrame = self.inputedCell.frame;
    CGFloat lastSpaceTxt = self.view.frame.size.height - (textFrame.origin.y - self.tableView.contentOffset.y + textFrame.size.height + 64);
    NameWeakSelf(wself);
    if (lastSpaceTxt < keyBoardFrame.size.height) {
        self.tableView.transform = CGAffineTransformMakeTranslation(0, 0);
        [UIView animateWithDuration:0.2 animations:^{
            wself.tableView.transform = CGAffineTransformMakeTranslation(0, - (keyBoardFrame.size.height - lastSpaceTxt));
        }];
    }
}

- (void) pullDownViewWhenKeyBoardHiden:(NSNotification*)hidenNoti {
    NameWeakSelf(wself);
    [UIView animateWithDuration:0.2 animations:^{
        wself.tableView.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
}



# pragma mask 4 getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self.dataSource;
        _tableView.dataSource = self.dataSource;
    }
    return _tableView;
}

- (UIBarButtonItem *)uploadBarBtnItem {
    if (!_uploadBarBtnItem) {
        _uploadBarBtnItem = [[UIBarButtonItem alloc] init];
        _uploadBarBtnItem.title = @"上传";
        _uploadBarBtnItem.rac_command = self.uploadHttp.cmdUploading;
    }
    return _uploadBarBtnItem;
}

- (MBProgressHUD *)progressHud {
    if (!_progressHud) {
        _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _progressHud;
}

- (VMT0CardUploadHttp *)uploadHttp {
    if (!_uploadHttp) {
        _uploadHttp = [[VMT0CardUploadHttp alloc] init];
    }
    return _uploadHttp;
}

- (VMForT0UploadTBV *)dataSource {
    if (!_dataSource) {
        _dataSource = [[VMForT0UploadTBV alloc] init];
        _dataSource.superVC = self;
    }
    return _dataSource;
}

@end
