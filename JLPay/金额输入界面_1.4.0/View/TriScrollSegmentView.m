//
//  TriScrollSegmentView.m
//  CustomViewMaker
//
//  Created by jielian on 16/9/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "TriScrollSegmentView.h"
#import "TSSV_itemView.h"
#import "UIColor+HexColor.h"
#import "Masonry.h"



@interface TriScrollSegmentView() <UIScrollViewDelegate>

@property (nonatomic, strong) TSSV_itemView* itemView0;

@property (nonatomic, strong) TSSV_itemView* itemView1;

@property (nonatomic, strong) TSSV_itemView* itemView2;

@property (nonatomic, copy) void (^ midItemViewClicked) (void);

@property (nonatomic, assign) CGFloat minScale;

@end


static BOOL firstLayout = YES;


@implementation TriScrollSegmentView

- (instancetype)initWithSegInfos:(NSArray *)segInfos andMidItemCliecked:(void (^)(void))midItemClicked {
    self = [super init];
    if (self) {
        self.segInfos = [NSArray arrayWithArray:segInfos];
        self.midItemViewClicked = midItemClicked;
        
        firstLayout = YES;
        [self initialProperties];
        [self loadSubviews];
        
        // 点击item后切换到指定的cell
        UITapGestureRecognizer* tapGestr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedWithGesture:)];
        [self addGestureRecognizer:tapGestr];
        
    }
    return self;
}



- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentSize = CGSizeMake(self.itemSize.width * 3, self.bounds.size.height);
    
    if (self.bounds.size.width > 1 && firstLayout) {
        CGPoint curOffset = self.contentOffset;
        curOffset.x = self.itemSize.width * 0.5;
        self.contentOffset = curOffset;
        [self reloadData];
        firstLayout = NO;
    }
    
}


- (void)updateConstraints {
    __weak typeof(self) wself = self;
    
    CGFloat verticalInset = self.itemSize.height * (1 - self.minScale) * 0.3;
    
    [self.itemView0 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(wself.itemSize.width);
        make.top.mas_equalTo(wself.mas_top).offset(verticalInset);
        make.height.mas_equalTo(wself.itemSize.height);
    }];
    
    [self.itemView1 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wself.itemView0.mas_right);
        make.width.mas_equalTo(wself.itemSize.width);
        make.top.mas_equalTo(wself.mas_top).offset(verticalInset);
        make.height.mas_equalTo(wself.itemSize.height);
    }];
    
    [self.itemView2 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wself.itemView1.mas_right);
        make.width.mas_equalTo(wself.itemSize.width);
        make.top.mas_equalTo(wself.mas_top).offset(verticalInset);
        make.height.mas_equalTo(wself.itemSize.height);
    }];
    
    self.itemView0.layer.cornerRadius = self.itemSize.height * 0.5;
    self.itemView1.layer.cornerRadius = self.itemSize.height * 0.5;
    self.itemView2.layer.cornerRadius = self.itemSize.height * 0.5;

    [super updateConstraints];
}

- (void)drawRect:(CGRect)rect {
    CGFloat verticalInset = self.itemSize.height * (1 - self.minScale) * 0.3;
    CGFloat verticalOffsetYItem = self.bounds.size.height - verticalInset - self.itemSize.height * 0.5 - verticalInset - self.itemSize.height * 0.5 * self.minScale;
    
    CGFloat radius = ((verticalOffsetYItem * verticalOffsetYItem) + (self.bounds.size.width * 0.5 * self.bounds.size.width * 0.5)) / verticalOffsetYItem/2;

    CGPoint arcCenterP = CGPointMake(rect.origin.x + rect.size.width * 0.5, verticalInset + self.itemSize.height * 0.5 + radius);

    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:arcCenterP];
    [path addArcWithCenter:arcCenterP radius:radius startAngle:0 endAngle:M_PI clockwise:NO];
    [path closePath];
    
    [self.backCircleColor setFill];
    
    [path fill];
    
}


# pragma mask 2 UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint curOffset = self.contentOffset;
    
    if (self.contentOffset.x > self.itemSize.width) {
        self.curSegIndex = (self.curSegIndex == self.segInfos.count - 1) ? (0) : (self.curSegIndex + 1);
        curOffset.x = 0;
    }
    else if (self.contentOffset.x < 0) {
        self.curSegIndex = (self.curSegIndex == 0) ? (self.segInfos.count - 1) : (self.curSegIndex - 1);
        curOffset.x = self.itemSize.width;
    }
    
    if (!CGPointEqualToPoint(self.contentOffset, curOffset)) {
        self.contentOffset = curOffset;
    }
    
    [self makeTransformsForItemViews];
    
    [self reloadData];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        CGPoint curOffset = self.contentOffset;
        curOffset.x = self.itemSize.width * 0.5;
        __weak typeof(self) wself = self;
        [UIView animateWithDuration:0.2 animations:^{
            wself.contentOffset = curOffset;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint curOffset = self.contentOffset;
    curOffset.x = self.itemSize.width * 0.5;
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.2 animations:^{
        wself.contentOffset = curOffset;
    } completion:^(BOOL finished) {
        
    }];
}


# pragma mask 3 IBAction

- (IBAction) clickedWithGesture:(UITapGestureRecognizer*)sender {
    CGPoint clickedPoint = [sender locationInView:self];
    
    if (CGRectContainsPoint(self.itemView1.frame, clickedPoint) && self.midItemViewClicked) {
        //self.midItemViewClicked();
        __weak typeof(self) wself = self;
        /* 冒泡动效 */
        [UIView animateWithDuration:0.1 animations:^{
            wself.itemView1.transform = CGAffineTransformMakeScale(1.2, 1.2);
        } completion:^(BOOL finished) {
            wself.midItemViewClicked();
            [UIView animateWithDuration:0.2 animations:^{
                wself.itemView1.transform = CGAffineTransformMakeScale(1, 1);
            } completion:^(BOOL finished) {
            }];
        }];
    }

}


# pragma mask 3 private interfunctions

- (void) initialProperties {
    self.minScale = 0.6;
    self.curSegIndex = 0;
    
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.delegate = self;

}


// 加载子视图
- (void) loadSubviews {
    [self addSubview:self.itemView0];
    [self addSubview:self.itemView1];
    [self addSubview:self.itemView2];
}


// 重载数据
- (void) reloadData {
    
    NSDictionary* node0 = [self.segInfos objectAtIndex:(self.curSegIndex <= 0 ? self.segInfos.count - 1: self.curSegIndex - 1)];
    NSDictionary* node1 = [self.segInfos objectAtIndex:self.curSegIndex];
    NSDictionary* node2 = [self.segInfos objectAtIndex:(self.curSegIndex >= self.segInfos.count - 1 ? 0: self.curSegIndex + 1)];
    
    self.itemView0.imageView.image = [UIImage imageNamed:[node0 objectForKey:@"imgName"]];
    self.itemView0.titleLabel.text = [node0 objectForKey:@"title"];
    self.itemView0.titleLabel.textColor = [node0 objectForKey:@"titleColor"];
    self.itemView0.backgroundColor = [node0 objectForKey:@"backColor"];

    self.itemView1.imageView.image = [UIImage imageNamed:[node1 objectForKey:@"imgName"]];
    self.itemView1.titleLabel.text = [node1 objectForKey:@"title"];
    self.itemView1.titleLabel.textColor = [node1 objectForKey:@"titleColor"];
    self.itemView1.backgroundColor = [node1 objectForKey:@"backColor"];

    self.itemView2.imageView.image = [UIImage imageNamed:[node2 objectForKey:@"imgName"]];
    self.itemView2.titleLabel.text = [node2 objectForKey:@"title"];
    self.itemView2.titleLabel.textColor = [node2 objectForKey:@"titleColor"];
    self.itemView2.backgroundColor = [node2 objectForKey:@"backColor"];

}

- (void) makeTransformsForItemViews {
    CGFloat contentCenterX = self.contentOffset.x + self.bounds.size.width * 0.5;
    
    // items相对于当前中点的距离
    CGFloat centerOffsetXItem0 = ABS(self.itemSize.width * 0.5 - contentCenterX);
    CGFloat centerOffsetXItem1 = ABS(self.itemSize.width * 1.5 - contentCenterX);
    CGFloat centerOffsetXItem2 = ABS(self.itemSize.width * 2.5 - contentCenterX);

    
    CGFloat verticalInset = self.itemSize.height * (1 - self.minScale) * 0.3;

    // 上下两个item的最大间距(center0.y - center1.y)
    CGFloat verticalOffsetYItem = self.bounds.size.height - verticalInset - self.itemSize.height * 0.5 - verticalInset - self.itemSize.height * 0.5 * self.minScale;
    
    CGFloat radius = ((verticalOffsetYItem * verticalOffsetYItem) + (self.bounds.size.width * 0.5 * self.bounds.size.width * 0.5)) / verticalOffsetYItem/2;
    
    // itemView0
    CGFloat ratioScale0 = 1 - (centerOffsetXItem0/(self.bounds.size.width * 0.5)) * (1 - self.minScale);
    CGAffineTransform transformScale0 = CGAffineTransformMakeScale(ratioScale0, ratioScale0);
    CGFloat translate0 = radius - sqrt(radius * radius - centerOffsetXItem0 * centerOffsetXItem0);
    CGAffineTransform transformTrans0 = CGAffineTransformMakeTranslation(0, translate0);
    self.itemView0.transform = CGAffineTransformConcat(transformScale0, transformTrans0);
    
    // itemView1
    CGFloat ratioScale1 = 1 - (centerOffsetXItem1/(self.bounds.size.width * 0.5)) * (1 - self.minScale);
    CGAffineTransform transformScale1 = CGAffineTransformMakeScale(ratioScale1, ratioScale1);
    CGFloat translate1 = radius - sqrt(radius * radius - centerOffsetXItem1 * centerOffsetXItem1);
    CGAffineTransform transformTrans1 = CGAffineTransformMakeTranslation(0, translate1);
    self.itemView1.transform = CGAffineTransformConcat(transformScale1, transformTrans1);

    // itemView2
    CGFloat ratioScale2 = 1 - (centerOffsetXItem2/(self.bounds.size.width * 0.5)) * (1 - self.minScale);
    CGAffineTransform transformScale2 = CGAffineTransformMakeScale(ratioScale2, ratioScale2);
    CGFloat translate2 = radius - sqrt(radius * radius - centerOffsetXItem2 * centerOffsetXItem2);
    CGAffineTransform transformTrans2 = CGAffineTransformMakeTranslation(0, translate2);
    self.itemView2.transform = CGAffineTransformConcat(transformScale2, transformTrans2);

}





# pragma mask 4 getter

- (TSSV_itemView *)itemView0 {
    if (!_itemView0) {
        _itemView0 = [[TSSV_itemView alloc] init];
    }
    return _itemView0;
}

- (TSSV_itemView *)itemView1 {
    if (!_itemView1) {
        _itemView1 = [[TSSV_itemView alloc] init];
    }
    return _itemView1;
}

- (TSSV_itemView *)itemView2 {
    if (!_itemView2) {
        _itemView2 = [[TSSV_itemView alloc] init];
    }
    return _itemView2;
}


- (UIColor *)backCircleColor {
    if (!_backCircleColor) {
        _backCircleColor = [UIColor colorWithHex:0xeeeeee alpha:1];
    }
    return _backCircleColor;
}


@end
