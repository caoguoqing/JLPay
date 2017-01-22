//
//  MLStepSegmentView.m
//  CustomViewMaker
//
//  Created by jielian on 2016/11/8.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MLStepSegmentView.h"
#import <ReactiveCocoa.h>
#import "Masonry.h"
#import "UIColor+HexColor.h"
#import "NSString+Formater.h"



@interface MLStepSegmentView()

/* 标题组 */
@property (nonatomic, copy) NSArray* titles;

/* 背景底视图 */
@property (nonatomic, strong) NSMutableArray* backStepViews;

/* 标题组 */
@property (nonatomic, strong) NSMutableArray* titleLabs;

@end




@implementation MLStepSegmentView

- (instancetype)initWithTitles:(NSArray *)titles {
    self = [super init];
    if (self) {
        self.titles = titles;
        [self initialDatas];
        [self addKVO];
    }
    return self;
}


- (void) addKVO {
    @weakify(self);
    [[RACObserve(self, itemSelected) deliverOnMainThread] subscribeNext:^(id index) {
        @strongify(self);
        [self setNeedsLayout];
    }];
}


- (IBAction) tapInStepView:(UITapGestureRecognizer*)tapGesture {
    CGPoint curPoint = [tapGesture locationInView:self];
    self.itemSelected = (NSInteger)(curPoint.x / (self.frame.size.width / self.titles.count));
}


// 数据初始化
- (void) initialDatas {
    self.itemSelected = -1;
    _titleLabs = [NSMutableArray array];
    _backStepViews = [NSMutableArray array];
    _tintColor = [UIColor colorWithHex:0x27384b alpha:1];
    _normalColor = [UIColor colorWithHex:0xe0e0e0 alpha:0.9];
    _stepIsSingle = NO;
    
    for (NSString* title in self.titles) {
        // 添加label
        UILabel* label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = title;
        [_titleLabs addObject:label];
        [self addSubview:label];
        
        // 添加backViews
        UIView* backView = [UIView new];
        [_backStepViews addObject:backView];
        [self addSubview:backView];
    }
    
    // 添加点击事件
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInStepView:)];
    [self addGestureRecognizer:tapGes];
}

/* 重新布局子视图 */
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat inset = 1.5;
    CGFloat uniteWidth = (self.frame.size.width - inset * (self.titles.count - 1) ) / self.titles.count;
    CGFloat labelHeight = self.frame.size.height * 26.f/30.f;
    CGFloat lineHeight = self.frame.size.height * 4.f/30.f;
    
    CGRect labelFrame = CGRectMake(0, 0, uniteWidth, labelHeight);
    CGRect lineFrame = CGRectMake(0, labelHeight, uniteWidth, lineHeight);
    
    for (int i = 0; i < self.titles.count; i ++) {
        UILabel* label = [self.titleLabs objectAtIndex:i];
        UIView* lineView = [self.backStepViews objectAtIndex:i];
        
        labelFrame.origin.x = (uniteWidth + inset) * i;
        lineFrame.origin.x = (uniteWidth + inset) * i;
        
        label.frame = labelFrame;
        lineView.frame = lineFrame;
        
        UIFont* maxFont = [UIFont boldSystemFontOfSize:[NSString resizeFontAtHeight:labelHeight scale:0.4]];
        UIFont* minFont = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:labelHeight scale:0.37]];
        
        if (i < self.itemSelected) {
            if (self.stepIsSingle) {
                label.textColor = self.normalColor;
                label.font = minFont;
                lineView.backgroundColor = self.normalColor;
            } else {
                label.textColor = self.tintColor;
                label.font = maxFont;
                lineView.backgroundColor = self.tintColor;
            }
        }
        else if (i == self.itemSelected) {
            label.textColor = self.tintColor;
            label.font = maxFont;
            lineView.backgroundColor = self.tintColor;
        }
        else {
            label.textColor = self.normalColor;
            label.font = minFont;
            lineView.backgroundColor = self.normalColor;
        }

    }
    
}



@end
