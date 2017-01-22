//
//  MLFiterView1Section.m
//  CustomViewMaker
//
//  Created by jielian on 2017/1/4.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import "MLFilterView1Section.h"
#import "Define_Header.h"
#import "Masonry.h"
#import <ReactiveCocoa.h>


@interface MLFV_vCell1 : UITableViewCell

@property (nonatomic, strong) UILabel* checkedView;

@end

@implementation MLFV_vCell1

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.checkedView];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont boldSystemFontOfSize:13];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NameWeakSelf(wself);
    [self.checkedView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(wself.checkedView.mas_height);
        make.right.mas_equalTo(- ScreenWidth * 20/320.f);
    }];
}

- (UILabel *)checkedView {
    if (!_checkedView) {
        _checkedView = [UILabel new];
        _checkedView.textAlignment = NSTextAlignmentCenter;
        _checkedView.font = [UIFont fontAwesomeFontOfSize:15];
        _checkedView.text = [NSString fontAwesomeIconStringForEnum:FACheck];
    }
    return _checkedView;
}

@end





# pragma mask ************ MLFilterView1Section ************

@interface MLFilterView1Section() <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

/* 父视图控制器 */
@property (nonatomic, weak) UIViewController* superVC;

/* 背景视图 */
@property (nonatomic, strong) UIView* bgView;
/* 承载视图 */
@property (nonatomic, strong) UIView* contentView;

/* 主选项表 */
@property (nonatomic, strong) UITableView* tableView;


/* 主数据源组 */
@property (nonatomic, copy) NSArray* items;

/* 选择完毕的回调 */
@property (nonatomic, copy) void (^ filterCompleted) (NSInteger selectedIndex);

/* 选择取消的回调 */
@property (nonatomic, copy) void (^ filterCanceled) (void);

@end


@implementation MLFilterView1Section

# pragma mask 1 功能区
- (void)showWithItems:(NSArray *)items
         onCompletion:(void (^)(NSInteger))completionBlock
             onCancel:(void (^)(void))cancelBlock
{
    self.items = items;
    self.filterCompleted = completionBlock;
    self.filterCanceled = cancelBlock;
    
    if (self.isSpread) {
        [self hideFilterView];
    } else {
        [self showFilterView];
    }
}

- (void)hide {
    [self hideFilterView];
}


# pragma mask 2 tools
/* 显示: 动画 */
- (void) showFilterView {
    [self loadSubviews];
    [self makeFrames];
    [self showAnimation];
}
- (void) hideFilterView {
    [self hideAnimation];
}


- (void) showAnimation {
    NameWeakSelf(wself);
    self.isSpread = YES;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        wself.bgView.alpha = 1;
        CGRect frame = wself.contentView.frame;
        frame.origin.y = 20;
        wself.contentView.frame = frame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            CGRect frame = wself.contentView.frame;
            frame.origin.y = 0;
            wself.contentView.frame = frame;
        } completion:^(BOOL finished) {
        }];
    }];
}

/* 隐藏: 动画 */
- (void) hideAnimation {
    NameWeakSelf(wself);
    self.isSpread = NO;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = wself.contentView.frame;
        frame.origin.y = 20;
        wself.contentView.frame = frame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            wself.bgView.alpha = 0;
            CGRect frame = wself.contentView.frame;
            frame.origin.y = -frame.size.height;
            wself.contentView.frame = frame;
        } completion:^(BOOL finished) {
            [wself removeSubviews];
        }];
    }];
}




/* 点击空白隐藏 */
- (IBAction) clickedOutSpace:(id)sender {
    [self hideFilterView];
    if (self.filterCanceled) {
        self.filterCanceled();
    }
}

# pragma mask 2 UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    } else {
        return YES;
    }
}


# pragma mask 2 UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MLFV_vCell1* cell = [tableView dequeueReusableCellWithIdentifier:@"MLFV_vCell1"];
    if (!cell) {
        cell = [[MLFV_vCell1 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MLFV_vCell1"];
        cell.checkedView.textColor = self.tintColor;
        cell.backgroundColor = self.backgroundColorOfCell;
    }
    
    cell.textLabel.text = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.textColor = indexPath.row == self.selectedIndex ? self.tintColor : self.normalColor;
    cell.checkedView.hidden = !(indexPath.row == self.selectedIndex);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
    [tableView reloadData];
    
    NameWeakSelf(wself);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wself hideFilterView];
        if (wself.filterCompleted) {
            wself.filterCompleted(wself.selectedIndex);
        }
    });
}


# pragma mask 3 初始化+布局

- (instancetype)initWithSuperVC:(UIViewController *)superVC {
    self = [super init];
    if (self) {
        self.superVC = superVC;
        self.isSpread = NO;
        UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedOutSpace:)];
        tapGes.delegate = self;
        [self addGestureRecognizer:tapGes];
    }
    return self;
}



- (void) loadSubviews {
    [self.superVC.view addSubview:self];
    [self addSubview:self.bgView];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.tableView];
    [self.tableView reloadData];
}

- (void) removeSubviews {
    [self.tableView removeFromSuperview];
    [self.contentView removeFromSuperview];
    [self.bgView removeFromSuperview];
    [self removeFromSuperview];
}

- (void) makeFrames {
    CGRect frame = [UIScreen mainScreen].bounds;
    frame.origin.y = 64;
    frame.size.height -= frame.origin.y;
    self.frame = frame;
    
    frame.origin.y = 0;
    self.bgView.frame = frame;
    self.tableView.frame = frame;
    
    frame.origin.y -= frame.size.height;
    self.contentView.frame = frame;
}


# pragma mask 4 getter

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [UIView new];
        _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _bgView.alpha = 0;
    }
    return _bgView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (UIColor *)tintColor {
    if (!_tintColor) {
        _tintColor = [UIColor colorWithRed:(CGFloat)0x00/0xff
                                     green:(CGFloat)0xa1/0xff
                                      blue:(CGFloat)0xdc/0xff alpha:1];
    }
    return _tintColor;
}

- (UIColor *)normalColor {
    if (!_normalColor) {
        _normalColor = [UIColor colorWithRed:(CGFloat)0x66/0xff
                                       green:(CGFloat)0x66/0xff
                                        blue:(CGFloat)0x66/0xff alpha:1];
    }
    return _normalColor;
}

- (UIColor *)backgroundColorOfCell {
    if (!_backgroundColorOfCell) {
        _backgroundColorOfCell = [UIColor colorWithRed:(CGFloat)0xff/0xff
                                                 green:(CGFloat)0xff/0xff
                                                  blue:(CGFloat)0xff/0xff alpha:1];
    }
    return _backgroundColorOfCell;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = ScreenWidth * 40/320.f;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
