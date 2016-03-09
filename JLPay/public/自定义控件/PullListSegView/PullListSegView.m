//
//  PullListSegView.m
//  JLPay
//
//  Created by jielian on 16/3/3.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//


#import "PullListSegView.h"
//#import "PublicInformation.h"


@interface PullListSegView()
<UITableViewDataSource, UITableViewDelegate>
{
    CGFloat animationDuration;
    NSInteger iMaxDisplayCount;
    CGFloat  fHeightOfSegViewCell;
    CGFloat  fWidthOfTri;
    CGFloat  fHeightOfTri;

}
@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, copy) void (^selectedBlock) (NSInteger selectedIndex);

@end

@implementation PullListSegView

- (instancetype) initWithDataSource:(NSArray*)dataSource {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.97;
        self.dataSouces = dataSource;
        self.selectedIndex = -1;
        [self loadSubViews];
        [self initialProperties];
    }
    return self;
}

- (void) initialProperties {
    animationDuration = 0.3;
    iMaxDisplayCount = 5;
    fHeightOfSegViewCell = 37.f;
    fWidthOfTri = 20.f;
    fHeightOfTri = 20.f * 2.f/3.f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat height = (self.dataSouces.count > iMaxDisplayCount)?(iMaxDisplayCount * fHeightOfSegViewCell):(self.dataSouces.count * fHeightOfSegViewCell);
    height += fHeightOfTri;
    CGRect frame = self.frame;
    frame.size.height = height;
    [self setFrame:frame];
    
    frame.origin.x = 0;
    frame.origin.y = fHeightOfTri;
    frame.size.height -= fHeightOfTri;
    [self.tableView setFrame:frame];
}

- (void) loadSubViews {
    [self addSubview:self.tableView];
}

- (void)drawRect:(CGRect)rect {
    CGFloat centerX = rect.size.width/2.f;
    // 三角
    UIBezierPath* triPath = [UIBezierPath bezierPath];
    [triPath moveToPoint:CGPointMake(centerX, 0)];
    [triPath addLineToPoint:CGPointMake(centerX - fWidthOfTri/2.f, fHeightOfTri)];
    [triPath addLineToPoint:CGPointMake(centerX + fWidthOfTri/2.f, fHeightOfTri)];
    [triPath closePath];
    UIColor* fillColor = [UIColor colorWithWhite:0.2 alpha:0.9];
    [fillColor setFill];
    [triPath fill];
    // 矩形
    CGRect rectFrame = CGRectMake(0, fHeightOfTri, rect.size.width, rect.size.height - fHeightOfTri);
    UIBezierPath* rectPath = [UIBezierPath bezierPathWithRoundedRect:rectFrame cornerRadius:5.f];
    [rectPath fill];
}

#pragma mask 0 public interface
- (void)showForSelection:(void (^)(NSInteger))selectedBlock {
    self.selectedBlock = selectedBlock;
    [self.tableView reloadData];
    [self setNeedsDisplay];
    [self setNeedsLayout];
    [self animationShow];
}


#pragma mask 1 touch 

#pragma mask 2 UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.dataSouces) {
        return 0;
    } else {
        return self.dataSouces.count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return fHeightOfSegViewCell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [self.dataSouces objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    if (indexPath.row == self.selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
#pragma mask 2 UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndex = indexPath.row;
    [tableView reloadData];
    
    [self animationHidden];
    self.selectedBlock(self.selectedIndex);
}

#pragma mask 3 private interface
// -- animation: show
- (void) animationShow {
    self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:animationDuration animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
    }];
}
// -- animation: hidden
- (void) animationHidden {
    [UIView animateWithDuration:animationDuration delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        self.transform = CGAffineTransformIdentity;
    }];
}


#pragma mask 4 geter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorInset = UIEdgeInsetsMake(15, 0, 0, 15);
    }
    return _tableView;
}


@end
