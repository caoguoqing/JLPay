//
//  StepSegmentView.m
//  JLPay
//
//  Created by jielian on 16/8/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "StepSegmentView.h"
#import <ReactiveCocoa.h>
#import "Masonry.h"

@interface StepSegmentView()


/* 步骤序号组视图 */
@property (nonatomic, strong) NSMutableArray* stepNumberLabs;

/* 背景底视图 */
@property (nonatomic, strong) NSMutableArray* backStepViews;

/* 标题组 */
@property (nonatomic, strong) NSMutableArray* titleLabs;

@end


@implementation StepSegmentView

- (instancetype) initWithTitles:(NSArray*)titles {
    self = [super init];
    if (self) {
        self.titles = titles;
        self.itemSelected = -1;
        [self loadSubviews];
        [self addKVOs];
    }
    return self;
}




- (void) loadSubviews {
    for (UIView* lineView in self.backStepViews) {
        [self addSubview:lineView];
    }
    for (UILabel* stepView in self.stepNumberLabs) {
        [self addSubview:stepView];
    }
    for (UILabel* titleView in self.titleLabs) {
        [self addSubview:titleView];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

- (void) addKVOs {
    @weakify(self);
    [RACObserve(self, itemSelected) subscribeNext:^(NSNumber* item) {
        @strongify(self);
        for (int i = 0; i < self.stepNumberLabs.count; i ++) {
            UILabel* stepLab = [self.stepNumberLabs objectAtIndex:i];
            if (i <= item.integerValue) {
                stepLab.backgroundColor = (self.tintColor) ? (self.tintColor) : ([UIColor grayColor]);
                stepLab.textColor = [UIColor whiteColor];
            } else {
                stepLab.backgroundColor = (self.normalColor) ? (self.normalColor) : ([UIColor whiteColor]);
                stepLab.textColor = [UIColor grayColor];
            }
        }
        for (int i = 0; i < self.backStepViews.count; i ++) {
            UIView* backStepV = [self.backStepViews objectAtIndex:i];
            if (i < item.integerValue) {
                backStepV.backgroundColor = (self.tintColor) ? (self.tintColor) : ([UIColor grayColor]);
            } else {
                backStepV.backgroundColor = (self.normalColor) ? (self.normalColor) : ([UIColor whiteColor]);
            }
        }
        for (int i = 0; i < self.titleLabs.count; i ++) {
            UILabel* titleLab = [self.titleLabs objectAtIndex:i];
            if (i <= item.integerValue) {
                titleLab.alpha = 1;
                titleLab.font = [UIFont boldSystemFontOfSize:15.5];
            } else {
                titleLab.font = [UIFont boldSystemFontOfSize:13];
                titleLab.alpha = 0.5;
            }
        }
    }];
}

- (void)updateConstraints {
    
    CGFloat inset = 6;

    
    CGFloat heightLab = (self.frame.size.height - inset) * 0.5;
    CGFloat heightBackLineView = 6;
    
    CGFloat uniteWidth = self.frame.size.width / self.titles.count;
    
    
    __weak typeof(self) wself = self;
    
    for (int i = 0; i < self.stepNumberLabs.count; i++) {
        UILabel* stepNumLab = [self.stepNumberLabs objectAtIndex:i];
        stepNumLab.layer.cornerRadius = heightLab * 0.5;
        [stepNumLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(wself.mas_top);
            make.height.mas_equalTo(heightLab);
            make.width.mas_equalTo(heightLab);
            make.centerX.mas_equalTo(wself.mas_left).offset(uniteWidth * (i + 0.5));
        }];
    }
    
    UILabel* firstStepLab = [self.stepNumberLabs firstObject];
    for (int i = 0; i < self.backStepViews.count; i ++) {
        UIView* backLineV = [self.backStepViews objectAtIndex:i];
        [backLineV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(firstStepLab.mas_centerY);
            make.left.mas_equalTo(wself.mas_left).offset(uniteWidth * (i + 0.5));
            make.width.mas_equalTo(uniteWidth);
            make.height.mas_equalTo(heightBackLineView);
        }];
    }
    
    for (int i = 0; i < self.titleLabs.count; i++) {
        UILabel* titleView = [self.titleLabs objectAtIndex:i];
        titleView.textColor = (self.tintColor) ? (self.tintColor) : ([UIColor blackColor]);
        
        [titleView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(wself.mas_bottom);
            make.height.mas_equalTo(heightLab);
            make.left.mas_equalTo(wself.mas_left).offset(uniteWidth * i);
            make.width.mas_equalTo(uniteWidth);
        }];
    }
    
    
    [super updateConstraints];
}


# pragma mask 4 getter

- (NSMutableArray *)stepNumberLabs {
    if (!_stepNumberLabs) {
        _stepNumberLabs = [NSMutableArray array];
        if (self.titles) {
            for (int i = 0; i < self.titles.count; i ++) {
                UILabel* lab = [UILabel new];
                lab.text = [NSString stringWithFormat:@"%d", i + 1];
                lab.textColor = [UIColor grayColor];
                lab.textAlignment = NSTextAlignmentCenter;
                lab.backgroundColor = (self.normalColor) ? (self.normalColor) : ([UIColor whiteColor]);
                lab.font = [UIFont systemFontOfSize:10];
                lab.layer.masksToBounds = YES;
                [_stepNumberLabs addObject:lab];
            }
        }
    }
    return _stepNumberLabs;
}

- (NSMutableArray *)backStepViews {
    if (!_backStepViews) {
        _backStepViews = [NSMutableArray array];
        if (self.titles) {
            for (int i = 0; i < self.titles.count - 1; i ++) {
                UIView* lineView = [UIView new];
                lineView.backgroundColor = (self.normalColor) ? (self.normalColor) : ([UIColor whiteColor]);
                [_backStepViews addObject:lineView];
            }
        }
    }
    return _backStepViews;
}

- (NSMutableArray *)titleLabs {
    if (!_titleLabs) {
        _titleLabs = [NSMutableArray array];
        if (self.titles) {
            for (int i = 0; i < self.titles.count; i ++) {
                UILabel* lab = [UILabel new];
                lab.text = [NSString stringWithFormat:@"%@", [self.titles objectAtIndex:i]];
                lab.textAlignment = NSTextAlignmentCenter;
                lab.textColor = (self.tintColor) ? (self.tintColor) : ([UIColor blackColor]);
                lab.backgroundColor = [UIColor clearColor];
                lab.alpha = 0.7;
                lab.font = [UIFont systemFontOfSize:14];
                [_titleLabs addObject:lab];
            }
        }
    }
    return _titleLabs;
}

@end
