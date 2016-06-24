//
//  NewCustomSegmentView.m
//  JLPay
//
//  Created by jielian on 16/6/6.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "NewCustomSegmentView.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>
#import "Masonry.h"

@implementation NewCustomSegmentView

- (instancetype)initWithItems:(NSArray<NSString *> *)items {
    self = [super init];
    if (self) {
        self.items = [items copy];
        [self initialize];
        [self loadSubviews];
        [self addKVOs];
    }
    return self;
}

- (void) initialize {
    self.segmentType = CustomSegmentViewStypeUnderLineDown;
    self.selectedItem = 0;
}

- (void) loadSubviews {
    [self.layer addSublayer:self.segMaskLayer];
    for (UIButton* itemBtn in self.itemButtons) {
        [self addSubview:itemBtn];
    }
    for (UIView* seperationView in self.itemSeperationViews) {
        [self addSubview:seperationView];
    }
}

- (void) addKVOs {
    @weakify(self);
    [[[RACObserve(self, selectedItem) deliverOnMainThread] replayLast] subscribeNext:^(NSNumber* selected) {
        
        [UIView animateWithDuration:0.2 animations:^{
            @strongify(self);
            CGRect frame = self.segMaskLayer.frame;
            self.segMaskLayer.position = CGPointMake(selected.integerValue * frame.size.width, 0);
            
        } completion:^(BOOL finished) {
            @strongify(self);
            for (int i = 0; i < self.itemButtons.count; i++) {
                UIButton* itemBtn = [self.itemButtons objectAtIndex:i];
                if (i == selected.integerValue) {
                    if (self.segmentType == CustomSegmentViewStypeRect) {
                        [itemBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    } else {
                        [itemBtn setTitleColor:self.tintColor forState:UIControlStateNormal];
                    }
                } else {
                    [itemBtn setTitleColor:self.normalColor forState:UIControlStateNormal];
                }
            }
        }];
        
    }];
}

- (void)layoutShapeLayer {
    UIBezierPath* path = [UIBezierPath bezierPath];
    CGFloat widthUnite = self.frame.size.width * 1/self.itemButtons.count;
    CGFloat heightLine = 5;
    self.segMaskLayer.frame = CGRectMake(self.selectedItem * widthUnite, 0, widthUnite, self.frame.size.height);
    
    if (self.segmentType == CustomSegmentViewStypeUnderLineUp) {
        CGPoint leftUpP = CGPointMake(widthUnite * self.selectedItem, 0);
        CGPoint rightUpP = CGPointMake(widthUnite * (self.selectedItem + 1), 0);
        CGPoint rightDownP = CGPointMake(widthUnite * (self.selectedItem + 1), heightLine);
        CGPoint triRightP = CGPointMake(widthUnite * self.selectedItem + widthUnite * 0.5 + heightLine, heightLine);
        CGPoint triMidP = CGPointMake(widthUnite * self.selectedItem + widthUnite * 0.5, heightLine * 2);
        CGPoint triLeftP = CGPointMake(widthUnite * self.selectedItem + widthUnite * 0.5 - heightLine, heightLine);
        CGPoint leftDownP = CGPointMake(widthUnite * self.selectedItem, heightLine);
        
        [path moveToPoint:leftUpP];
        [path addLineToPoint:rightUpP];
        [path addLineToPoint:rightDownP];
        [path addLineToPoint:triRightP];
        [path addLineToPoint:triMidP];
        [path addLineToPoint:triLeftP];
        [path addLineToPoint:leftDownP];
        [path addLineToPoint:leftUpP];
        [path closePath];
        
    }
    else if (self.segmentType == CustomSegmentViewStypeUnderLineDown) {
        CGPoint leftUpP = CGPointMake(widthUnite * self.selectedItem, self.frame.size.height - heightLine);
        CGPoint rightUpP = CGPointMake(widthUnite * (self.selectedItem + 1), self.frame.size.height - heightLine);
        CGPoint rightDownP = CGPointMake(widthUnite * (self.selectedItem + 1), self.frame.size.height);
        CGPoint triRightP = CGPointMake(widthUnite * self.selectedItem + widthUnite * 0.5 + heightLine, self.frame.size.height - heightLine);
        CGPoint triMidP = CGPointMake(widthUnite * self.selectedItem + widthUnite * 0.5, self.frame.size.height - heightLine * 2);
        CGPoint triLeftP = CGPointMake(widthUnite * self.selectedItem + widthUnite * 0.5 - heightLine, self.frame.size.height - heightLine);
        CGPoint leftDownP = CGPointMake(widthUnite * self.selectedItem, self.frame.size.height);
        
        [path moveToPoint:leftUpP];
        [path addLineToPoint:leftDownP];
        [path addLineToPoint:rightDownP];
        [path addLineToPoint:rightUpP];
        [path addLineToPoint:triRightP];
        [path addLineToPoint:triMidP];
        [path addLineToPoint:triLeftP];
        [path addLineToPoint:leftUpP];
        [path closePath];
        
    }
    else { // CustomSegmentViewStypeRect
        path = [UIBezierPath bezierPathWithRect:CGRectMake(widthUnite * self.selectedItem, 0, widthUnite, self.frame.size.height)];
    }
    
    self.segMaskLayer.fillColor = self.tintColor.CGColor;
    self.segMaskLayer.path = path.CGPath;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutShapeLayer];
    
    NameWeakSelf(wself);
    
    CGFloat widthUnite = self.frame.size.width * 1/self.itemButtons.count;
    CGFloat heightSeperationView = self.frame.size.height * 0.4;
    CGFloat widthSeperationView = 0.6;
    
    for (int i = 0; i < self.itemButtons.count; i++) {
        UIButton* itemBtn = [self.itemButtons objectAtIndex:i];
        [itemBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wself.mas_left).offset(widthUnite * i);
            make.top.equalTo(wself.mas_top);
            make.bottom.equalTo(wself.mas_bottom);
            make.width.mas_equalTo(widthUnite);
        }];
    }
    
    for (int i = 0; i < self.itemSeperationViews.count; i++) {
        UIView* seperationView = [self.itemSeperationViews objectAtIndex:i];
        seperationView.layer.cornerRadius = widthSeperationView * 0.5;
        [seperationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(wself.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(widthSeperationView, heightSeperationView));
            make.centerX.equalTo(wself.mas_left).offset(widthUnite * (i + 1));
        }];
    }
    
}



# pragma mask 3 IBAction
- (IBAction) clickedItem:(UIButton*)item {
    NSInteger lastIndex = [self.items indexOfObject:[item titleForState:UIControlStateNormal]];
    if (self.selectedItem != lastIndex) {
        self.selectedItem = lastIndex;
    }
}

# pragma mask 4 getter

- (UIColor *)tintColor {
    if (!_tintColor) {
        _tintColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
    }
    return _tintColor;
}

- (UIColor *)normalColor {
    if (!_normalColor) {
        _normalColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
    }
    return _normalColor;
}

- (NSMutableArray *)itemButtons {
    if (!_itemButtons) {
        _itemButtons = [NSMutableArray array];
        for (NSString* title in self.items) {
            UIButton* button = [UIButton new];
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitleColor:self.normalColor forState:UIControlStateNormal];
            [button addTarget:self action:@selector(clickedItem:) forControlEvents:UIControlEventTouchUpInside];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
            [_itemButtons addObject:button];
        }
    }
    return _itemButtons;
}

- (NSMutableArray *)itemSeperationViews {
    if (!_itemSeperationViews) {
        _itemSeperationViews = [NSMutableArray array];
        for (int i = 0; i < self.items.count - 1; i++) {
            UIView* seperationView = [[UIView alloc] init];
            seperationView.backgroundColor = [UIColor colorWithHex:HexColorTypeBlackGray alpha:0.78];
            [_itemSeperationViews addObject:seperationView];
        }
    }
    return _itemSeperationViews;
}

- (CAShapeLayer *)segMaskLayer {
    if (!_segMaskLayer) {
        _segMaskLayer = [CAShapeLayer layer];
        _segMaskLayer.strokeColor = [UIColor clearColor].CGColor;
        _segMaskLayer.anchorPoint = CGPointMake(0, 0);
    }
    return _segMaskLayer;
}

@end
