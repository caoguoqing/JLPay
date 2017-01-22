//
//  MLFilterView2Section.m
//  CustomViewMaker
//
//  Created by jielian on 2016/12/8.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MLFilterView2Section.h"
#import <ReactiveCocoa.h>



static NSInteger tagMLMainTableView = 232;
static NSInteger tagMLSubTableView = 233;



# pragma mask ************ MLFilterViewCell ************

@interface  MLFilterViewCell : UITableViewCell

@property (nonatomic, strong) UIView* mlCheckView;
@property (nonatomic, strong) UILabel* mlNumTagLabel;

@end

@implementation MLFilterViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.mlCheckView];
        [self addSubview:self.mlNumTagLabel];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.contentView.frame;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    frame.size.width = screenWidth * 5/320.f;
    self.mlCheckView.frame = frame;
    
    frame.size.height *= 0.4;
    frame.size.width = frame.size.height;
    frame.origin.y = (self.contentView.frame.size.height - frame.size.height) * 0.5;
    frame.origin.x = self.contentView.frame.size.width - 15 - frame.size.width;
    self.mlNumTagLabel.frame = frame;
    self.mlNumTagLabel.layer.masksToBounds = YES;
    self.mlNumTagLabel.layer.cornerRadius = frame.size.height * 0.5;
}


# pragma mask 4 getter

- (UIView *)mlCheckView {
    if (!_mlCheckView) {
        _mlCheckView = [UIView new];
    }
    return _mlCheckView;
}

- (UILabel *)mlNumTagLabel {
    if (!_mlNumTagLabel) {
        _mlNumTagLabel = [UILabel new];
        _mlNumTagLabel.font = [UIFont systemFontOfSize:9];
        _mlNumTagLabel.textColor = [UIColor whiteColor];
        _mlNumTagLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _mlNumTagLabel;
}

@end




# pragma mask ************ MLFilterView2Section ************


@interface MLFilterView2Section() <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

/* 父视图控制器 */
@property (nonatomic, weak) UIViewController* superVC;

/* 背景视图 */
@property (nonatomic, strong) UIView* bgView;
/* 承载视图 */
@property (nonatomic, strong) UIView* bearView;

/* 主选项表 */
@property (nonatomic, strong) UITableView* mainTableView;
/* 副选项表 */
@property (nonatomic, strong) UITableView* subTableView;
/* 重置按钮 */
@property (nonatomic, strong) UIButton* resetBtn;
/* 确定按钮 */
@property (nonatomic, strong) UIButton* doneBtn;



/* 选择完毕的回调 */
@property (nonatomic, copy) void (^ filterCompleted) (NSArray<NSArray<NSNumber*> *> * subSelectedArray);

/* 选择取消的回调 */
@property (nonatomic, copy) void (^ filterCanceled) (void);




/* 当前主选项索引 */
@property (nonatomic, assign) NSInteger curIndexMainItems;

@end




@implementation MLFilterView2Section


/* 初始化: 自动添加和卸载筛选器到指定视图控制器,默认是有导航器的 */
- (instancetype)initWithSuperVC:(UIViewController *)superVC {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.superVC = superVC;
        self.isSpread = NO;
        UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureSelector:)];
        tapGes.delegate = self;
        [self addGestureRecognizer:tapGes];
        [self addKVO];
    }
    return self;
}


/* 显示筛选器: 带2个输入和3个响应回调 */
- (void)showOnCompletion:(void (^)(NSArray<NSArray<NSNumber *> *> *))completionBlock
                 onCancel:(void (^)(void))cancelBlock
{
    self.filterCompleted = completionBlock;
    self.filterCanceled = cancelBlock;
    
    [self showAnimationOnCompletion:^{
        
    }];
}

/* 隐藏筛选器 */
- (void) hideOnCompletion:(void (^) (void))hideCompletion {
    [self hideAnimationOnCompletion:^{
        if (hideCompletion) {
            hideCompletion();
        }
    }];
}

/* 重置筛选器 */
- (void) resetData {
    self.curIndexMainItems = 0;
    for (NSMutableArray* subIndexs in self.subSelectedArray) {
        for (int i = 0 ; i < subIndexs.count; i++) {
            [subIndexs replaceObjectAtIndex:i withObject:@(NO)];
        }
    }
}



# pragma mask 1 IBAction

- (IBAction) clickedResetBtn:(id)sender {
    [self resetData];
    [self.mainTableView reloadData];
    [self.subTableView reloadData];
}

- (IBAction) clickedDoneBtn:(id)sender {
    __weak typeof(self) wself = self;
    [self hideAnimationOnCompletion:^{
        if (wself.filterCompleted) {
            wself.filterCompleted(wself.subSelectedArray);
        }
    }];
}

- (IBAction) tapGestureSelector:(UITapGestureRecognizer*)tapGes {
    CGPoint localP = [tapGes locationInView:self.bearView];
    CGRect frame = self.doneBtn.frame;
    if (localP.y > frame.origin.y + frame.size.height) {
        __weak typeof(self) wself = self;
        [self hideAnimationOnCompletion:^{
            if (wself.filterCanceled) {
                wself.filterCanceled();
            }
        }];
    }
}


# pragma mask 3 UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == tagMLMainTableView) {
        return self.mainItems.count;
    } else {
        NSArray* curSubitems = [self.subItems objectAtIndex:self.curIndexMainItems];
        return curSubitems.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    if (tableView.tag == tagMLMainTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"tagMLMainTableView"];
        if (!cell) {
            cell = [[MLFilterViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tagMLMainTableView"];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            cell.selectedBackgroundView = [UIView new];
            ((MLFilterViewCell*)cell).mlCheckView.backgroundColor = self.tintColor;
            ((MLFilterViewCell*)cell).mlNumTagLabel.backgroundColor = self.tintColor;
        }
        cell.textLabel.text = [self.mainItems objectAtIndex:indexPath.row];
        ((MLFilterViewCell*)cell).mlNumTagLabel.text =  [NSString stringWithFormat:@"%ld",[self numberOfSelectedAtSubItemsIndex:indexPath.row]];
        ((MLFilterViewCell*)cell).mlNumTagLabel.hidden = [self numberOfSelectedAtSubItemsIndex:indexPath.row] > 0 ? NO : YES;
        
        if (indexPath.row == self.curIndexMainItems) {
            ((MLFilterViewCell*)cell).mlCheckView.hidden = NO;
            cell.textLabel.textColor = self.tintColor;
        } else {
            cell.textLabel.textColor = self.mainNormalColor;
            ((MLFilterViewCell*)cell).mlCheckView.hidden = YES;
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"tagMLSubTableView"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tagMLSubTableView"];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectedBackgroundView = [UIView new];
            cell.tintColor = self.tintColor;
        }
        NSArray* curSubitems = [self.subItems objectAtIndex:self.curIndexMainItems];
        cell.textLabel.text = [curSubitems objectAtIndex:indexPath.row];
        if ([self subItemsContainSelectedIndex:indexPath.row]) {
            cell.textLabel.textColor = self.tintColor;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.textLabel.textColor = self.subNormalColor;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}


# pragma mask 3 UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UIScreen mainScreen].bounds.size.width * 40 / 320.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (tableView.tag == tagMLMainTableView) {
        if (self.curIndexMainItems != indexPath.row) {
            self.curIndexMainItems = indexPath.row;
            [self.mainTableView reloadData];
            [self.subTableView reloadData];
        }
    } else {
        if ([self subItemsContainSelectedIndex:indexPath.row]) {
            [self updateSubselectedArrayWithIndex:indexPath.row selectedOrNot:NO];
        } else {
            [self updateSubselectedArrayWithIndex:indexPath.row selectedOrNot:YES];
        }
        [self.mainTableView reloadData];
        [self.subTableView reloadData];
    }
}



# pragma mask 3 UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}


# pragma mask 3 tools 

/* 显示动画 */
- (void) showAnimationOnCompletion:(void (^) (void))completion {
    // 初始化data
    [self initialDatas];
    // 添加子视图
    [self loadSubviews];
    // 初始化frame
    [self initialFrame];
    // 动画
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        wself.bgView.alpha = 1;
        CGRect frame = wself.bearView.frame;
        frame.origin.y = 20;
        wself.bearView.frame = frame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            CGRect frame = wself.bearView.frame;
            frame.origin.y = 0;
            wself.bearView.frame = frame;
        } completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
            wself.isSpread = YES;
        }];
    }];
    
}

/* 隐藏动画 */
- (void) hideAnimationOnCompletion:(void (^) (void))hideCompletion {
    // 动画
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = wself.bearView.frame;
        frame.origin.y = 20;
        wself.bearView.frame = frame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            wself.bgView.alpha = 0;
            CGRect frame = wself.bearView.frame;
            frame.origin.y = -frame.size.height;
            wself.bearView.frame = frame;
        } completion:^(BOOL finished) {
            wself.isSpread = NO;
            [wself removeAllSubviews];
            if (hideCompletion) {
                hideCompletion();
            }
        }];
    }];
}


- (void) addKVO {
    RAC(self, subSelectedArray) = [RACObserve(self, subItems) map:^id(NSArray<NSArray*>* subItems) {
        NSMutableArray* selectedArray = [NSMutableArray array];
        for (NSArray* items in subItems) {
            NSMutableArray* indexs = [NSMutableArray array];
            for (int i = 0 ; i < items.count; i++) {
                [indexs addObject:@(NO)];
            }
            [selectedArray addObject:indexs];
        }
        return [selectedArray mutableCopy];
    }];
}

/* 判断当前被选序号是否在sub被选组中 */
- (BOOL) subItemsContainSelectedIndex:(NSInteger)index {
    NSArray* curSubitems = [self.subSelectedArray objectAtIndex:self.curIndexMainItems];
    return [[curSubitems objectAtIndex:index] boolValue];
}

/* 更新index到对应的sub被选组: 指定被选中还是未选中 */
- (void) updateSubselectedArrayWithIndex:(NSInteger)index selectedOrNot:(BOOL)selected {
    NSMutableArray* curSubitems = [self.subSelectedArray objectAtIndex:self.curIndexMainItems];
    NSNumber* item = selected ? @(YES): @(NO);
    [curSubitems replaceObjectAtIndex:index withObject:item];
}

/* 被选中item个数: subSelectedArray中的组 */
- (NSInteger) numberOfSelectedAtSubItemsIndex:(NSInteger)subindex {
    NSMutableArray* curSubitems = [self.subSelectedArray objectAtIndex:subindex];
    NSInteger number = 0;
    for (NSNumber* item in curSubitems) {
        number += ([item boolValue] ? 1 : 0);
    }
    return number;
}





# pragma mask 4 布局

- (void) loadSubviews {
    [self.superVC.view addSubview:self];
    [self addSubview:self.bgView];
    [self addSubview:self.bearView];
    [self.bearView addSubview:self.mainTableView];
    [self.bearView addSubview:self.subTableView];
    [self.bearView addSubview:self.resetBtn];
    [self.bearView addSubview:self.doneBtn];
    self.doneBtn.backgroundColor = self.tintColor;
}

- (void) removeAllSubviews {
    [self.doneBtn removeFromSuperview];
    [self.resetBtn removeFromSuperview];
    [self.subTableView removeFromSuperview];
    [self.mainTableView removeFromSuperview];
    [self.bearView removeFromSuperview];
    [self.bgView removeFromSuperview];
    [self removeFromSuperview];
}

- (void) initialFrame {
    CGFloat screenWidth = self.superVC.view.frame.size.width;
    CGFloat screenHeight = self.superVC.view.frame.size.height;
    
    CGFloat widthMainTab = screenWidth * (1 - 0.618);
    CGFloat heightTab = (screenHeight - 64) * 0.618;
    
    CGFloat widthBtn = screenWidth * 0.5;
    CGFloat heightBtn = screenWidth * 48/320.f;
    
    CGRect frame = CGRectMake(0, 0, screenWidth, screenHeight);
    self.frame = frame;
    self.bgView.frame = frame;
    
    frame.origin.y -= frame.size.height;
    self.bearView.frame = frame;
    
    frame.origin.y = 64;
    frame.size.height = heightTab;
    frame.size.width = widthMainTab;
    self.mainTableView.frame = frame;
    
    frame.origin.x += frame.size.width;
    frame.size.width = screenWidth - widthMainTab;
    self.subTableView.frame = frame;
    
    frame.origin.y += frame.size.height;
    frame.origin.x = 0;
    frame.size.width = widthBtn;
    frame.size.height = heightBtn;
    self.resetBtn.frame = frame;
    
    frame.origin.x += frame.size.width;
    self.doneBtn.frame = frame;
}

- (void) initialDatas {
    [self.mainTableView reloadData];
    [self.subTableView reloadData];
//    if (self.subSelectedArray.count == self.subItems.count) {
//        return;
//    }
//    for (int i = 0; i < self.subItems.count; i++) {
//        NSArray* items = [self.subItems objectAtIndex:i];
//        NSMutableArray* selectedIndexs = [NSMutableArray arrayWithCapacity:items.count];
//        for (int j = 0; j < items.count; j++) {
//            [selectedIndexs addObject:@(NO)];
//        }
//        [self.subSelectedArray addObject:selectedIndexs];
//    }
}


# pragma mask 5 getter

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _mainTableView.backgroundColor = [UIColor whiteColor];
        _mainTableView.tableFooterView = [UIView new];
        _mainTableView.tag = tagMLMainTableView;
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    }
    return _mainTableView;
}

- (UITableView *)subTableView {
    if (!_subTableView) {
        _subTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _subTableView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        _subTableView.tableFooterView = [UIView new];
        _subTableView.tag = tagMLSubTableView;
        _subTableView.delegate = self;
        _subTableView.dataSource = self;
        _subTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    }
    return _subTableView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [UIView new];
        _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        _bgView.alpha = 0;
    }
    return _bgView;
}
- (UIView *)bearView {
    if (!_bearView) {
        _bearView = [UIView new];
        _bearView.backgroundColor = [UIColor clearColor];
    }
    return _bearView;
}

- (UIButton *)resetBtn {
    if (!_resetBtn) {
        _resetBtn = [UIButton new];
        [_resetBtn setTitle:@"重置" forState:UIControlStateNormal];
        [_resetBtn setTitleColor:[UIColor colorWithRed:(CGFloat)0x27/0xff green:(CGFloat)0x38/0xff blue:(CGFloat)0x4b/0xff alpha:1]
                        forState:UIControlStateNormal];
        [_resetBtn setTitleColor:[UIColor colorWithRed:(CGFloat)0x27/0xff green:(CGFloat)0x38/0xff blue:(CGFloat)0x4b/0xff alpha:0.5]
                        forState:UIControlStateHighlighted];
        _resetBtn.backgroundColor = [UIColor whiteColor];
        _resetBtn.layer.borderColor = [UIColor colorWithRed:(CGFloat)0xee/0xff green:(CGFloat)0xee/0xff blue:(CGFloat)0xee/0xff alpha:1].CGColor;
        _resetBtn.layer.borderWidth = 0.6;
        _resetBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_resetBtn addTarget:self action:@selector(clickedResetBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetBtn;
}
- (UIButton *)doneBtn {
    if (!_doneBtn) {
        _doneBtn = [UIButton new];
        [_doneBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_doneBtn setTitleColor:[UIColor colorWithRed:(CGFloat)0xff/0xff green:(CGFloat)0xff/0xff blue:(CGFloat)0xff/0xff alpha:1]
                        forState:UIControlStateNormal];
        [_doneBtn setTitleColor:[UIColor colorWithRed:(CGFloat)0xff/0xff green:(CGFloat)0xff/0xff blue:(CGFloat)0xff/0xff alpha:0.5]
                        forState:UIControlStateHighlighted];
        _doneBtn.backgroundColor = [UIColor colorWithRed:(CGFloat)0x00/0xff green:(CGFloat)0xbb/0xff blue:(CGFloat)0x9c/0xff alpha:1];
        _doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_doneBtn addTarget:self action:@selector(clickedDoneBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}

- (UIColor *)tintColor {
    if (!_tintColor) {
        _tintColor = [UIColor colorWithRed:(CGFloat)0x00/0xff green:(CGFloat)0xbb/0xff blue:(CGFloat)0x9c/0xff alpha:1];
    }
    return _tintColor;
}

- (UIColor *)mainNormalColor {
    if (!_mainNormalColor) {
        _mainNormalColor = [UIColor colorWithRed:(CGFloat)0x27/0xff green:(CGFloat)0x38/0xff blue:(CGFloat)0x4b/0xff alpha:1];
    }
    return _mainNormalColor;
}
- (UIColor *)subNormalColor {
    if (!_subNormalColor) {
        _subNormalColor = [UIColor colorWithRed:(CGFloat)0x66/0xff green:(CGFloat)0x66/0xff blue:(CGFloat)0x66/0xff alpha:1];
    }
    return _subNormalColor;
}



@end




















