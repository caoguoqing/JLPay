//
//  CustomSegmentView.m
//  CustomViewMaker
//
//  Created by 冯金龙 on 16/3/4.
//  Copyright © 2016年 冯金龙. All rights reserved.
//

#import "CustomSegmentView.h"

@interface CustomSegmentView()
{
    CGFloat tintViewDirectionInset;
    CGFloat animationDuration;
}
@property (nonatomic, strong) UIView* tintView;
@property (nonatomic, strong) NSArray* items;
@property (nonatomic, strong) NSArray* itemViews;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) CGFloat itemHeight;


@end

@implementation CustomSegmentView


- (instancetype) initWithItems:(NSArray*)items {
    self = [super init];
    if (self) {
        self.items = items;
        self.canTurnOnSegment = YES;
        [self initialProperties];
        [self loadSubViews];
        [self addObserver:self forKeyPath:kKeyPathSegSelectedItem options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        self.clipsToBounds = YES;
    }
    return self;
}
- (void)dealloc {
    [self removeObserver:self forKeyPath:kKeyPathSegSelectedItem];
}

- (void) loadSubViews {
    [self addSubview:self.tintView];
    for (UIView* item in self.itemViews) {
        [self addSubview:item];
    }
}

- (void) initialProperties {
    tintViewDirectionInset = 0.1;
    animationDuration = 0.2;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.items || self.items.count == 0) {
        return;
    }
    CGRect frame = self.bounds;
    self.itemWidth = frame.size.width/self.items.count;
    self.itemHeight = frame.size.height;
    // items
    frame.size.width = self.itemWidth;
    frame.size.height = self.itemHeight;
    for (int i = 0; i < self.itemViews.count; i++) {
        frame.origin.x = i * frame.size.width;
        UILabel* item = [self.itemViews objectAtIndex:i];
        [item setFrame:frame];
        if (i == self.selectedItem) {
            item.textColor = self.textSelectedColor;
        } else {
            item.textColor = self.textColor;
        }
    }
    // tintView
    [self.tintView setFrame:[self frameForTintViewCurrently]];
    self.tintView.backgroundColor = self.tintColor;
}

// -- frame for tintView, at index: selectedItem rect
- (CGRect) frameForTintViewCurrently {
    CGRect tintFrame = CGRectZero;
    // 扩展: 根据方向设置frame ...
    switch (self.selectedType) {
        case CustSegSelectedTypeUnderLine:
        {
            tintFrame.origin.x = self.itemWidth * self.selectedItem;
            tintFrame.origin.y = self.itemHeight * (1 - tintViewDirectionInset);
            tintFrame.size.width = self.itemWidth;
            tintFrame.size.height = self.itemHeight * tintViewDirectionInset;
        }
            break;
        case CustSegSelectedTypeSingleRect:
        {
            tintFrame.origin.x = self.itemWidth * self.selectedItem;
            tintFrame.origin.y = 0;
            tintFrame.size.width = self.itemWidth;
            tintFrame.size.height = self.itemHeight;
        }
            break;
        default: break;
    }
    return tintFrame;
}

#pragma mask 2 touch begin 
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.canTurnOnSegment) {
        return;
    }
    UITouch* touch = [touches anyObject];
    CGPoint curTouchPoint = [touch locationInView:self];
    NSInteger offset = curTouchPoint.x / self.itemWidth;
    if (self.selectedItem != offset) {
        self.selectedItem = offset;
    }
}

#pragma mask 2 KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kKeyPathSegSelectedItem]) {
        NSInteger oldIndex = [[change objectForKey:NSKeyValueChangeOldKey] integerValue];
        NSInteger newIndex = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        if (oldIndex != newIndex) {
            __weak typeof(self) wself = self;
            [UIView animateWithDuration:animationDuration animations:^{
                // 需要扩展: 根据方向定义动画方向
                CGPoint oldCenter = wself.tintView.center;
                oldCenter.x += (newIndex - oldIndex) * wself.itemWidth;
                wself.tintView.center = oldCenter;
            } completion:^(BOOL finished) {
                [wself setNeedsLayout];
            }];
            self.canTurnOnSegment = NO;
        }
    }
}

#pragma mask 4 getter
- (NSArray *)itemViews {
    if (!_itemViews) {
        NSMutableArray* itemArray = [NSMutableArray array];
        for (int i = 0; i < self.items.count; i++) {
            UILabel* item = [UILabel new];
            item.textAlignment = NSTextAlignmentCenter;
            item.text = [self.items objectAtIndex:i];
            [itemArray addObject:item];
        }
        _itemViews = [NSArray arrayWithArray:itemArray];
    }
    return _itemViews;
}
- (UIView *)tintView {
    if (!_tintView) {
        _tintView = [UIView new];
    }
    return _tintView;
}

- (UIColor *)textColor {
    if (!_textColor) {
        // default 26 26 26
        _textColor = [UIColor colorWithRed:38.f/255.f green:38.f/255.f blue:38.f/255.f alpha:1];
    }
    return _textColor;
}
- (UIColor *)tintColor {
    if (!_tintColor) {
        _tintColor = [UIColor blueColor];
    }
    return _tintColor;
}
- (UIColor *)textSelectedColor {
    if (!_textSelectedColor) {
        _textSelectedColor = [UIColor blueColor];
    }
    return _textSelectedColor;
}

@end
