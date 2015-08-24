//
//  settingViewController.m
//  JLPay
//
//  Created by jielian on 15/4/10.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "settingViewController.h"
#import "DeviceSettingViewController.h"
#import <UIKit/UIKitDefines.h>
#import "TransDetailsViewController.h"
#import "Define_Header.h"
#import "DeviceSignInViewController.h"
#import "RateViewController.h"

#define LeftInsetOfCellCent             0.1f                    // 单元格元素的左边界距离
#define ImageViewWidthInCellCent        0.1f                    // 单元格内的imageView.width占宽带比例
#define LabelViewWidthInCellCent        0.4f                    // 单元格内的labelView.width占宽带比例
#define FirstCellLargerCent             1.5f                    // 第一个单元格的放大比例
#define FontOfLittleLabel               12.f                    // 小窗口的字体大小



@interface settingViewController ()<UIAlertViewDelegate>
@property (nonatomic, strong) NSArray *cellNames;           // 单元格对应的功能名称
@property (nonatomic, strong) NSMutableDictionary *cellNamesAndImages; // 单元格表示的数据字典
@end


@implementation settingViewController
@synthesize cellNames  = _cellNames;
@synthesize cellNamesAndImages      = _cellNamesAndImages;



- (void)viewDidLoad {
    self.tableView.rowHeight        = 50.f;                               // 设置cell的行高
    self.tableView.separatorInset   = UIEdgeInsetsMake(0, 0, 0, 0);       // 设置cell的间隔线的左边距
    
    // 设置 title 的字体颜色
    UIColor *color                  = [UIColor redColor];
    NSDictionary *dict              = [NSDictionary dictionaryWithObject:color  forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    self.navigationController.navigationBar.tintColor = color;
    
    [super viewDidLoad];
    
    [self setExtraCellLineHidden:self.tableView];
    
    // 只校验一次
    NSString* identifier = [[NSUserDefaults standardUserDefaults] valueForKey:DeviceIDOfBinded];
    if (identifier == nil) {
        UIViewController* viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"deviceSigninVC"];
        [self.navigationController pushViewController:viewController animated:YES];
    }

}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem* backBarButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(backToLastViewController)];
    [self.navigationItem setBackBarButtonItem:backBarButton];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void) backToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}


/*************************************
 * 功  能 : 设置 tableView 的 section 个数;
 *************************************/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/*************************************
 * 功  能 : UITableViewDelegate :numberOfRowsInSection 协议;
 *************************************/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellNames.count;
}


/*************************************
 * 功  能 : UITableViewDataSource :heightForRowAtIndexPath 协议:设置行高
 *************************************/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return tableView.rowHeight * FirstCellLargerCent;
    }
    return tableView.rowHeight;
}

/*************************************
 * 功  能 : UITableViewDelegate :屏蔽指定cell 的点击高亮效果
 *************************************/
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return NO;
    }
    return YES;
}

/*************************************
 * 功  能 : UITableViewDataSource :cellForRowAtIndexPath 协议;
 * 参  数 :
 *          (UITableView *)tableView  当前表视图
 *          (NSIndexPath *)indexPath  cell的索引
 * 返  回 :
 *          UITableViewCell*          新创建或被复用的cell
 *************************************/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier    = @"cellWithIdentifier";
    UITableViewCell * cell              = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    // 下面是 cell 的装载
    if (indexPath.row == 0) {
        [self loadFirstCell:cell inTabelView:tableView];
    } else {
        [self loadCell:cell atIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}


/*************************************
 * 功  能 : 单元格的点击动作实现;
 *          -账号名称及信息
 *          -交易明细
 *          -绑定机具
 *          -额度查询
 *          -修改密码
 *          -意见反馈
 *          -参数设置
 *          -帮助和关于
 * 参  数 :
 *          (UITableView *)tableView  当前表视图
 *          (NSIndexPath *)indexPath  被点击单元格索引
 * 返  回 : 无
 *************************************/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    NSString* cellName = [self.cellNames objectAtIndex:indexPath.row];
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* viewController = nil;
    
    if ([cellName isEqualToString:@"交易明细"]) {
        viewController = [storyBoard instantiateViewControllerWithIdentifier:@"transDetailsVC"];
    }
    else if ([cellName isEqualToString:@"绑定机具"]) {
        viewController = [storyBoard instantiateViewControllerWithIdentifier:@"deviceSigninVC"];
    }
    else if ([cellName isEqualToString:@"修改密码"]) {
        viewController = [storyBoard instantiateViewControllerWithIdentifier:@"changePinVC"];
        [viewController setTitle:cellName];
    }
    else if ([cellName isEqualToString:@"帮助和关于"]) {
        viewController = [storyBoard instantiateViewControllerWithIdentifier:@"helperAndAboutVC"];
        [viewController setTitle:cellName];
    }
    else if ([cellName isEqualToString:@"费率选择"]) {
    }
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}



/*************************************
 * 功  能 : 给指定序号的cell进行自定义装载;
 * 参  数 :
 *          (UITableViewCell*)cell  指定的cell
 *          (NSInteger)index        data索引号
 * 返  回 : 无
 *************************************/
- (void) loadCell: (UITableViewCell*)cell atIndex: (NSInteger)index {
    
    NSString *labelName         = [self.cellNames objectAtIndex:index];
    NSString *imageName         = [self.cellNamesAndImages objectForKey:labelName];
    
    
    // 设置 imageView.frame in cell
    CGFloat   imageFrameHeight;
    CGFloat   y;
    if (cell.bounds.size.height >= cell.bounds.size.width * ImageViewWidthInCellCent) {
        imageFrameHeight        = cell.bounds.size.width * ImageViewWidthInCellCent;
        y                       = (self.tableView.rowHeight - imageFrameHeight)/2;

    } else {
        imageFrameHeight        = self.tableView.rowHeight;

        y                       = 0;
    }
    CGRect       imageFrame     = CGRectMake(cell.bounds.size.width * LeftInsetOfCellCent,
                                             y,
                                             imageFrameHeight,
                                             imageFrameHeight);
    UIImageView *imageView      = [[UIImageView alloc] initWithFrame:imageFrame];
    
    // 装载 nameLabel
    CGRect       labelFrame     = CGRectMake(cell.bounds.size.width * LeftInsetOfCellCent + imageFrameHeight + 15,
                                             0,
                                             cell.bounds.size.width * LabelViewWidthInCellCent,
                                             self.tableView.rowHeight);
    UILabel     *nameLabel      = [[UILabel alloc] initWithFrame:labelFrame];
    nameLabel.text              = labelName;
    [cell addSubview:nameLabel];
    
    // imageView is loaded in GCD queue
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        UIImage  *image         = [UIImage imageNamed:imageName];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            imageView.image     = image;
            [cell addSubview:imageView];
        });
    });
    
    
}


/*************************************
 * 功  能 : 给序号0的cell进行自定义装载;
 * 参  数 :
 *          (UITableViewCell*)cell      指定的 cell
 *          (UITableView *)tableView    指定的 tableView
 * 返  回 : 无
 *************************************/
- (void) loadFirstCell: (UITableViewCell *)cell inTabelView: (UITableView *)tableView {
    cell.backgroundColor            = [UIColor colorWithRed:246.0/255.0 green:64.0/255.0 blue:59.0/255.0 alpha:1.0];
    
    CGFloat imageTopInset           = 6.0;
    CGFloat imageWidth              = tableView.rowHeight * FirstCellLargerCent - imageTopInset * 2.0;
    CGFloat imageLeftInset          = cell.bounds.size.width * ImageViewWidthInCellCent * 3.0/2.0 - imageWidth/2.0;
    
    CGFloat littleHeight            = tableView.rowHeight * FirstCellLargerCent * 4.0 / 21.0;
    CGFloat littleTopInset          = tableView.rowHeight * FirstCellLargerCent * 3.5 / 21.0;
    
    // imageView
    CGRect       frame              = CGRectMake(imageLeftInset, imageTopInset, imageWidth, imageWidth);
    UIImageView *imageView          = [[UIImageView alloc] initWithFrame:frame];
    imageView.backgroundColor       = [UIColor whiteColor];
    imageView.layer.cornerRadius    = imageView.bounds.size.width/2;
    imageView.layer.masksToBounds   = YES;
    imageView.image                 = [UIImage imageNamed:@"01_01"];
    [cell addSubview:imageView];
    
    // cellLabel
    CGFloat width                   = cell.bounds.size.width / 2.f;
    frame.origin.x                  = imageLeftInset + imageWidth + 14;
    frame.origin.y                  = littleTopInset;
    frame.size.width                = width;
    frame.size.height               = littleHeight * FirstCellLargerCent;
    UILabel *cellLabel              = [[UILabel alloc] initWithFrame:frame];
    cellLabel.text                  = [[NSUserDefaults standardUserDefaults] objectForKey:UserID];
    cellLabel.textColor             = [UIColor colorWithWhite:1 alpha:1];
    cellLabel.textAlignment         = NSTextAlignmentLeft;
    [cell addSubview:cellLabel];
    
    // nameLabel
    frame.origin.y                  += (littleHeight * FirstCellLargerCent);
    frame.size.height               = littleHeight;
    UILabel *nameLabel              = [[UILabel alloc] initWithFrame:frame];
    nameLabel.text                  = [[NSUserDefaults standardUserDefaults] objectForKey:Business_Name];
    nameLabel.font                  = [UIFont systemFontOfSize:FontOfLittleLabel];
    nameLabel.textColor             = [UIColor colorWithWhite:1 alpha:1];
    nameLabel.textAlignment         = NSTextAlignmentLeft;

    [cell addSubview:nameLabel];
    
    // mailLabel  -- 没用了,用来保存商户号
    frame.origin.y                  += littleHeight;
    frame.size.width                = width;
    UILabel *mailLabel              = [[UILabel alloc] initWithFrame:frame];
    mailLabel.text                  = [[NSUserDefaults standardUserDefaults] objectForKey:Business_Number]; // 商户编号
    mailLabel.font                  = [UIFont systemFontOfSize:FontOfLittleLabel];
    // 设置 maillabel 的自适应大小
    CGSize autoSize                 = [mailLabel.text sizeWithFont:mailLabel.font constrainedToSize:frame.size lineBreakMode:NSLineBreakByWordWrapping];
    frame                           = CGRectMake(frame.origin.x, frame.origin.y, autoSize.width, frame.size.height);
    mailLabel.frame                 = frame;
    // 设置 maillabel 的自适应大小
    mailLabel.textColor             = [UIColor colorWithWhite:1 alpha:1];
    mailLabel.textAlignment         = NSTextAlignmentLeft;
    [cell addSubview:mailLabel];
    
}


/*************************************
 * 功  能 : 重置图片的大小;
 *          新的比例通过传入的新的 width 来计算；
 * 参  数 : 
 *          (UIImage*)image  需要重置大小的图片
 *          (CGFloat)width   用来计算缩放比例的宽度
 * 返  回 : 无
 *************************************/
- (UIImage*) resizeImage:(UIImage*)image byWidth:(CGFloat)width {
    UIImage* newImage;
    CGFloat newHeight = [image size].height * width/[image size].width;
    CGSize newSize = CGSizeMake(width, newHeight);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, width, newHeight)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// pragma mask ::: 去掉多余的单元格的分割线
- (void) setExtraCellLineHidden: (UITableView*)tableView {
    UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}


#pragma mask ---- getter & setter
// 功能名称:cell名
- (NSArray *)cellNames {
    if (_cellNames == nil) {
        _cellNames = [NSArray arrayWithObjects:
                      @"账号名称",
                      @"交易明细",
                      // @"费率选择",
                      @"绑定机具",
                      // @"额度查询",
                      @"修改密码",
                      // @"意见反馈",
                      @"帮助和关于", nil];
    }
    return _cellNames;
}
- (NSMutableDictionary *)cellNamesAndImages {
    if (_cellNamesAndImages == nil) {
        _cellNamesAndImages = [[NSMutableDictionary alloc] init];
        [_cellNamesAndImages setValue:@"01_01" forKey:@"账号名称"];
        [_cellNamesAndImages setValue:@"01_10" forKey:@"交易明细"];
        [_cellNamesAndImages setValue:@"01_14" forKey:@"绑定机具"];
        [_cellNamesAndImages setValue:@"01_18" forKey:@"修改密码"];
        [_cellNamesAndImages setValue:@"01_24" forKey:@"帮助和关于"];
        // @"费率选择":@"01_12",
        // @"额度查询":@"01_16",
        // @"意见反馈":@"01_20",
    }
    return _cellNamesAndImages;
}


@end
