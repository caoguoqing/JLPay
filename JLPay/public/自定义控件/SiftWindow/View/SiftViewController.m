//
//  SiftViewController.m
//  JLPay
//
//  Created by jielian on 16/5/27.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "SiftViewController.h"
#import "Define_Header.h"
#import "Masonry.h"
#import <ReactiveCocoa.h>


@implementation SiftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];
    
    [self loadSubviews];
    [self layoutSubviews];
    [self addKVOs];
    
}


- (void) loadSubviews {
    [self.view addSubview:self.assistantSectionTBV];
    [self.view addSubview:self.mainSectionTBV];
    [self.view addSubview:self.sureButton];
    [self.view addSubview:self.resetButton];
}

- (void) layoutSubviews {
    NameWeakSelf(wself);
    
    CGFloat heightTBV = self.view.frame.size.height * 0.5;
    CGFloat widthMainTBV = self.view.frame.size.width * 0.35;
    CGFloat heightButton = self.view.frame.size.height * 1/14;
    
    self.sureButton.titleLabel.font = [UIFont systemFontOfSize:[@"xx" resizeFontAtHeight:heightButton scale:0.44]];
    self.resetButton.titleLabel.font = [UIFont systemFontOfSize:[@"xx" resizeFontAtHeight:heightButton scale:0.44]];
    
    [self.mainSectionTBV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.top.equalTo(wself.view.mas_top);
        make.size.mas_equalTo(CGSizeMake(widthMainTBV, heightTBV));
    }];
    
    [self.assistantSectionTBV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.mainSectionTBV.mas_right).offset(-1);
        make.right.equalTo(wself.view.mas_right);
        make.top.equalTo(wself.view.mas_top);
        make.height.mas_equalTo(heightTBV);
    }];
    
    
    [self.sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(wself.view.mas_right).offset(0);
        make.left.equalTo(wself.view.mas_centerX);
        make.top.equalTo(wself.assistantSectionTBV.mas_bottom);
        make.height.mas_equalTo(heightButton);
    }];
    
    [self.resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(wself.view.mas_centerX).offset(0);
        make.left.equalTo(wself.view.mas_left);
        make.top.equalTo(wself.mainSectionTBV.mas_bottom);
        make.height.mas_equalTo(heightButton);
    }];
    
}

- (void) addKVOs {
    
    @weakify(self);
    [RACObserve(self.siftDataSources, mainSelected) subscribeNext:^(id x) {
        @strongify(self);
        [self.assistantSectionTBV reloadData];
    }];
    [RACObserve(self.siftDataSources, assistantSelected) subscribeNext:^(id x) {
        @strongify(self);
        [self.mainSectionTBV reloadData];
    }];
    
}


# pragma mask 2 IBActions 
- (IBAction) beSureSifted:(id)sender {
    if (self.siftFinished) {
        self.siftFinished(self.siftDataSources.indexListSifted);
    }
}

- (IBAction) cancelSifted:(id)sender {
    if (self.siftCanceled) {
        self.siftCanceled();
    }
}

- (IBAction) resetSifted:(id)sender {
    [self.siftDataSources clearsSiftedIndexs];
    [self.mainSectionTBV reloadData];
    [self.assistantSectionTBV reloadData];
}


# pragma mask 3 touches 
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* curTouch = [touches anyObject];
    
    CGFloat originYWhiteSpace = self.sureButton.frame.origin.y + self.sureButton.frame.size.height;
    CGRect whiteSpaceArea = CGRectMake(0, originYWhiteSpace, self.view.frame.size.width, self.view.frame.size.height - originYWhiteSpace);
    
    CGPoint clickedPoint = [curTouch locationInView:self.view];
    if (CGRectContainsPoint(whiteSpaceArea, clickedPoint) && self.siftCanceled) {
        self.siftCanceled();
    }

}



# pragma mask 4 getter

- (VMSiftDataSourcesAndSifter *)siftDataSources {
    if (!_siftDataSources) {
        _siftDataSources = [[VMSiftDataSourcesAndSifter alloc] init];
    }
    return _siftDataSources;
}

- (UITableView *)mainSectionTBV {
    if (!_mainSectionTBV) {
        _mainSectionTBV = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_mainSectionTBV setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        _mainSectionTBV.tag = TagOfSiftTBVMain;
        _mainSectionTBV.delegate = self.siftDataSources;
        _mainSectionTBV.dataSource = self.siftDataSources;
        _mainSectionTBV.separatorInset = UIEdgeInsetsZero;
        _mainSectionTBV.layoutMargins = UIEdgeInsetsZero;
        
        _mainSectionTBV.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:0.5].CGColor;
        _mainSectionTBV.layer.borderWidth = 0.27;
    }
    return _mainSectionTBV;
}

- (UITableView *)assistantSectionTBV {
    if (!_assistantSectionTBV) {
        _assistantSectionTBV = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_assistantSectionTBV setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        _assistantSectionTBV.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
        _assistantSectionTBV.tag = TagOfSiftTBVAssistant;
        _assistantSectionTBV.delegate = self.siftDataSources;
        _assistantSectionTBV.dataSource = self.siftDataSources;
        _assistantSectionTBV.separatorInset = UIEdgeInsetsZero;
        _assistantSectionTBV.layoutMargins = UIEdgeInsetsZero;
        
        _assistantSectionTBV.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:0.5].CGColor;
        _assistantSectionTBV.layer.borderWidth = 0.27;
    }
    return _assistantSectionTBV;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton new];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        [_sureButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.7] forState:UIControlStateHighlighted];
        [_sureButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.7] forState:UIControlStateDisabled];
        [_sureButton addTarget:self action:@selector(beSureSifted:) forControlEvents:UIControlEventTouchUpInside];
        _sureButton.backgroundColor = [UIColor colorWithHex:HexColorTypeLightBlue alpha:1];
    }
    return _sureButton;
}


- (UIButton *)resetButton {
    if (!_resetButton) {
        _resetButton = [UIButton new];
        [_resetButton setTitle:@"重置" forState:UIControlStateNormal];
        [_resetButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_resetButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.7] forState:UIControlStateHighlighted];
        [_resetButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.7] forState:UIControlStateDisabled];
        [_resetButton addTarget:self action:@selector(resetSifted:) forControlEvents:UIControlEventTouchUpInside];
        _resetButton.backgroundColor = [UIColor whiteColor];
    }
    return _resetButton;
}

@end
