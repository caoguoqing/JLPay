//
//  SwitchBtnsScrollView.m
//  JLPay
//
//  Created by jielian on 16/7/18.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "SwitchBtnsScrollView.h"
#import "LeftImgRightTitleBtn.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>



@implementation SwitchBtnsScrollView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubviews];
        [self addKVOs];
    }
    return self;
}

- (void)dealloc {
    JLPrint(@"---- dealloc of SwitchBtnsScrollView");
}

- (void)switchToPage:(NSInteger)page {
    if (page <= 0) {
        page = 3;
    }
    else if (page >= 4) {
        page = 1;
    }
    NameWeakSelf(wself);
    [UIView animateWithDuration:0.3 animations:^{
        wself.contentOffset = CGPointMake(wself.frame.size.width * page, 0);
    } completion:^(BOOL finished) {
        
    }];
}


- (void) loadSubviews {
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.delegate = self;
    self.contentOffset = CGPointMake(self.frame.size.width, 0);
    for (LeftImgRightTitleBtn* btn in self.switchItemBtns) {
        [self addSubview:btn];
    }
    self.contentOffset = CGPointMake(self.frame.size.width * self.page, 0);

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat inset = 5;
    CGRect btnFrame = CGRectMake(inset, 0, self.frame.size.width - inset * 2, self.frame.size.height);
        
    for (int i = 0; i < self.switchItemBtns.count; i++) {
        LeftImgRightTitleBtn* switchBtn = [self.switchItemBtns objectAtIndex:i];
        btnFrame.origin.x = i * self.frame.size.width + inset;
        switchBtn.frame = btnFrame;
        switchBtn.layer.cornerRadius = btnFrame.size.height * 0.5;
    }
    
    self.contentSize = CGSizeMake(self.frame.size.width * self.switchItemBtns.count, self.frame.size.height);
}

- (void) addKVOs {
    @weakify(self);
    RAC(self, page) = [RACObserve(self, contentOffset) map:^id (NSNumber* offset) {
        @strongify(self);
        return @((NSInteger)(offset.CGPointValue.x / self.frame.size.width));
    }];
}


# pragma mask 2 UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint curOffset = scrollView.contentOffset;
    if (curOffset.x >= (self.switchItemBtns.count - 1) * scrollView.frame.size.width) {
        scrollView.contentOffset = CGPointMake(curOffset.x - scrollView.frame.size.width * (self.switchItemBtns.count - 2), 0);
    }
    else if (curOffset.x < scrollView.frame.size.width) {
        scrollView.contentOffset = CGPointMake(curOffset.x + scrollView.frame.size.width * (self.switchItemBtns.count - 2), 0);
    }
}


# pragma mask 4 getter

- (NSMutableArray *)switchItemBtns {
    if (!_switchItemBtns) {
        _switchItemBtns = [NSMutableArray array];
        
        LeftImgRightTitleBtn* swipeBtn = [[LeftImgRightTitleBtn alloc] init];
        swipeBtn.rightTitleLabel.text = SwitchBtnsSwipe;
        swipeBtn.backgroundColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
        swipeBtn.leftImgView.image = [UIImage imageNamed:@"JLPayWhite"];
        [_switchItemBtns addObject:swipeBtn];
        
        LeftImgRightTitleBtn* alipayBtn_backup = [[LeftImgRightTitleBtn alloc] init];
        alipayBtn_backup.rightTitleLabel.text = SwitchBtnsAlipay;
        alipayBtn_backup.backgroundColor = [UIColor colorWithHex:HexColorTypeLightBlue alpha:1];
        alipayBtn_backup.leftImgView.image = [UIImage imageNamed:@"Alipay_white"];
        [_switchItemBtns addObject:alipayBtn_backup];
        
        LeftImgRightTitleBtn* wechatBtn = [[LeftImgRightTitleBtn alloc] init];
        wechatBtn.rightTitleLabel.text = SwitchBtnsWechat;
        wechatBtn.backgroundColor = [UIColor colorWithHex:HexColorTypeGreen alpha:1];
        wechatBtn.leftImgView.image = [UIImage imageNamed:@"WechatPay_white"];
        [_switchItemBtns addObject:wechatBtn];
        
        LeftImgRightTitleBtn* swipeBtn_backup = [[LeftImgRightTitleBtn alloc] init];
        swipeBtn_backup.rightTitleLabel.text = SwitchBtnsSwipe;
        swipeBtn_backup.backgroundColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
        swipeBtn_backup.leftImgView.image = [UIImage imageNamed:@"JLPayWhite"];
        [_switchItemBtns addObject:swipeBtn_backup];
        
        LeftImgRightTitleBtn* alipayBtn = [[LeftImgRightTitleBtn alloc] init];
        alipayBtn.rightTitleLabel.text = SwitchBtnsAlipay;
        alipayBtn.backgroundColor = [UIColor colorWithHex:HexColorTypeLightBlue alpha:1];
        alipayBtn.leftImgView.image = [UIImage imageNamed:@"Alipay_white"];
        [_switchItemBtns addObject:alipayBtn];

    }
    return _switchItemBtns;
}


@end
