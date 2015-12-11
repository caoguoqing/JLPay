//
//  FeeRateTableViewController.m
//  JLPay
//
//  Created by jielian on 15/12/8.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "FeeRateTableViewController.h"
#import "ModelFeeRates.h"
#import "PublicInformation.h"


@interface FeeRateTableViewController()
<UITableViewDataSource, UITableViewDelegate>
{
    NSInteger selectedCellIndex;
}
@property (nonatomic, strong) UILabel* labelFeeRateName;
@end


@implementation FeeRateTableViewController


- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        if ([ModelFeeRates isSavedFeeRate]) {
            for (int i = 0; i < [ModelFeeRates arrayOfFeeRates].count; i++) {
                NSString* feeRateName = [[ModelFeeRates arrayOfFeeRates] objectAtIndex:i];
                if ([[ModelFeeRates feeRateNameSaved] isEqualToString:feeRateName]) {
                    selectedCellIndex = i;
                    break;
                }
            }
        } else {
            selectedCellIndex = -1;
        }
        self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        self.tableView.canCancelContentTouches = NO;
        self.tableView.delaysContentTouches = NO;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setBackBarButtonItem:[PublicInformation newBarItemWithNullTitle]];
}

#pragma mask ---- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [ModelFeeRates arrayOfFeeRates].count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"cellIdentifier__";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.textLabel.text = [[ModelFeeRates arrayOfFeeRates] objectAtIndex:indexPath.row];
    if (indexPath.row == selectedCellIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
#pragma mask ---- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 100;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGRect rectOfFooter = [tableView rectForFooterInSection:section];
    CGRect frame = rectOfFooter;
    CGFloat inset = 5;
    CGFloat heightButton = 40;

    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    // 加载费率显示标签
    frame.origin.x = inset * 3;
    frame.origin.y = inset;
    frame.size.height = 20;
    UILabel* labelFeeRateDisplay = [self labelForFeeRateDisplayInFrame:frame];
    [view addSubview:labelFeeRateDisplay];
    // 加载费率标签
    frame.origin.x += labelFeeRateDisplay.frame.size.width;
    frame.size.width -= frame.origin.x;
    [self.labelFeeRateName setFrame:frame];
    self.labelFeeRateName.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:frame.size andScale:1.0]];
    [view addSubview:self.labelFeeRateName];
    if ([ModelFeeRates isSavedFeeRate]) {
        self.labelFeeRateName.text = [ModelFeeRates feeRateNameSaved];
        self.labelFeeRateName.textColor = [UIColor brownColor];
    } else {
        self.labelFeeRateName.text = @"无";
        self.labelFeeRateName.textColor = [UIColor grayColor];
        
    }

    // 加载清空按钮
    frame.origin.y += frame.size.height + inset * 3;
    frame.size.height = heightButton;
    frame.size.width = (rectOfFooter.size.width - inset*3*3)/2.0;
    frame.origin.x = inset*3;
    [view addSubview:[self buttonCleenInFrame:frame]];
    // 加载保存按钮
    frame.origin.x += frame.size.width + inset*3;
    [view addSubview:[self buttonSavingInFrame:frame]];
    
    return view;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == selectedCellIndex) {
        selectedCellIndex = -1;
    } else {
        selectedCellIndex = indexPath.row;
    }
    [tableView reloadData];
}

#pragma mask ---- PRIVATE INTERFACE
/* 生成保存按钮 */
- (UIButton*) buttonSavingInFrame:(CGRect)frame {
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    button.backgroundColor = [PublicInformation returnCommonAppColor:@"red"];
    [button setTitle:@"保存" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(touchOut:) forControlEvents:UIControlEventTouchUpOutside];
    [button addTarget:self action:@selector(touchToSaveSelectedFeeRate:) forControlEvents:UIControlEventTouchUpInside];

    button.layer.cornerRadius = 5.0;
    return button;
}
/* 生成清空按钮 */
- (UIButton*) buttonCleenInFrame:(CGRect)frame {
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    button.backgroundColor = [UIColor grayColor];
    [button setTitle:@"清空" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(touchOut:) forControlEvents:UIControlEventTouchUpOutside];
    [button addTarget:self action:@selector(touchToCleanSaving:) forControlEvents:UIControlEventTouchUpInside];

    button.layer.cornerRadius = 5.0;
    return button;
}

/* 生成label: 显示已保存费率 */
- (UILabel*) labelForFeeRateDisplayInFrame:(CGRect)frame {
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont systemFontOfSize:[PublicInformation resizeFontInSize:frame.size andScale:1.0]];
    label.text = @"已保存费率:";
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor grayColor];
    [label sizeToFit];
    return label;
}

- (UILabel *)labelFeeRateName {
    if (_labelFeeRateName == nil) {
        _labelFeeRateName = [[UILabel alloc] initWithFrame:CGRectZero];
        _labelFeeRateName.textAlignment = NSTextAlignmentLeft;
    }
    return _labelFeeRateName;
}

/* 保存费率 */
- (void) savingSelectedFeeRate {
    if (selectedCellIndex >= 0) {
        [ModelFeeRates savingFeeRateName:[[ModelFeeRates arrayOfFeeRates] objectAtIndex:selectedCellIndex]];
        [self.tableView reloadData];
    } else {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未选择费率类型,请选择" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}
/* 清空保存 */
- (void) cleanSaving {
    if ([ModelFeeRates isSavedFeeRate]) {
        [ModelFeeRates cleanSavingFeeRate];
        [self.tableView reloadData];
    }
}


- (IBAction) touchDown:(UIButton*)sender {
    sender.transform = CGAffineTransformMakeScale(0.95, 0.95);
}
- (IBAction) touchOut:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
}
- (IBAction) touchToSaveSelectedFeeRate:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
    
    if (selectedCellIndex >= 0) {
        [ModelFeeRates savingFeeRateName:[[ModelFeeRates arrayOfFeeRates] objectAtIndex:selectedCellIndex]];
        [self.tableView reloadData];
    } else {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未选择费率类型,请选择" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }

}
- (IBAction) touchToCleanSaving:(UIButton*)sender {
    sender.transform = CGAffineTransformIdentity;
    if ([ModelFeeRates isSavedFeeRate]) {
        [ModelFeeRates cleanSavingFeeRate];
        [self.tableView reloadData];
    }
}

@end
