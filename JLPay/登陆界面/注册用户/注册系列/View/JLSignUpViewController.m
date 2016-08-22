//
//  JLSignUpViewController.m
//  JLPay
//
//  Created by 冯金龙 on 16/6/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "JLSignUpViewController.h"
#import "VMSignUpManager.h"
#import "Define_Header.h"
#import "Masonry.h"
#import <ReactiveCocoa.h>
#import "MBProgressHUD+CustomSate.h"
#import "VMPhoneChecking.h"


static NSString* const SignUpRightBarTitleNextStep  = @"下一步";
static NSString* const SignUpRightBarTitleSignUp    = @"注册";

@implementation JLSignUpViewController 

- (void)setFirstStep {
    [[VMSignUpManager sharedInstance] resetDataSource];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    tapGes.delegate = self;
    [self.view addGestureRecognizer:tapGes];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = [[VMSignUpManager sharedInstance].signUpInputs.itemsTitles objectAtIndex:self.seperatedIndex];
    
    [VMSignUpManager sharedInstance].superVC = self;

    [self loadSubviews];
    [self layoutSubviews];
    
    [self viewsOnKVOs];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [VMSignUpManager sharedInstance].seperatedIndex = self.seperatedIndex;
    [VMSignUpManager sharedInstance].superVC = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullUpViewOrNotWhenKeyBoardShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullDownViewWhenKeyBoardHiden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([self.title isEqualToString:kSignUpItemsTitleMobileCheck]) {
        [[VMSignUpManager sharedInstance].phoneChecking.checkWaitingTimer stopTimer];
    }
}

- (void) loadSubviews {
    [self.navigationItem setRightBarButtonItem:self.nextBarBtn];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.progressHud];
}

- (void) layoutSubviews {
    NameWeakSelf(wself);
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right);
        make.top.equalTo(wself.view.mas_top).offset(64);
        make.bottom.equalTo(wself.view.mas_bottom);
    }];
}

- (void) viewsOnKVOs {
    @weakify(self);
    [self.nextBarBtn.rac_command.executionSignals subscribeNext:^(RACSignal* sig) {
        [[sig dematerialize] subscribeNext:^(id x) {
            
        } error:^(NSError *error) {
            // 错误提示都是在VM中就处理了
        } completed:^{
            @strongify(self);
            // 如果是'注册': 则跳转回登陆界面;否则跳转到下一个页面;
            if (self.seperatedIndex < [VMSignUpManager sharedInstance].signUpInputs.itemsTitles.count - 1) {
                JLSignUpViewController* nextSignUpStepVC = [[JLSignUpViewController alloc] initWithNibName:nil bundle:nil];
                nextSignUpStepVC.seperatedIndex = self.seperatedIndex + 1;
                [VMSignUpManager sharedInstance].seperatedIndex = nextSignUpStepVC.seperatedIndex;
                [self.navigationController pushViewController:nextSignUpStepVC animated:YES];
            }
            else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }];
    
    
}



# pragma mask 2 IBAction


- (void) endEditing {
    [self.view endEditing:YES];
}

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


# pragma mask 3 UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint curPoint = [touch locationInView:self.tableView];
    NSIndexPath* cellIndexPath = [self.tableView indexPathForRowAtPoint:curPoint];
    return (cellIndexPath)?(NO):(YES);
}


# pragma mask 4 getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = [VMSignUpManager sharedInstance];
        _tableView.dataSource = [VMSignUpManager sharedInstance];
    }
    return _tableView;
}



- (UIBarButtonItem *)nextBarBtn {
    if (!_nextBarBtn) {
        NSString* title = (self.seperatedIndex == ([VMSignUpManager sharedInstance].signUpInputs.itemsTitles.count - 1))?(SignUpRightBarTitleSignUp):(SignUpRightBarTitleNextStep);
        _nextBarBtn = [[UIBarButtonItem alloc] init];
        _nextBarBtn.title = title;
        _nextBarBtn.style = UIBarButtonItemStylePlain;
        _nextBarBtn.rac_command = [[VMSignUpManager sharedInstance] newCommandForInputsCheckingOnCurIndex];
    }
    return _nextBarBtn;
}

- (MBProgressHUD *)progressHud {
    if (!_progressHud) {
        _progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _progressHud;
}


@end
