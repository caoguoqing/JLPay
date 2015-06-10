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
#import "TransDetailsTableViewController.h"


#define LeftInsetOfCellCent             0.1f                    // 单元格元素的左边界距离
#define ImageViewWidthInCellCent        0.1f                    // 单元格内的imageView.width占宽带比例
#define LabelViewWidthInCellCent        0.4f                    // 单元格内的labelView.width占宽带比例
#define FirstCellLargerCent             1.5f                    // 第一个单元格的放大比例
#define FontOfLittleLabel               12.f                    // 小窗口的字体大小



@interface settingViewController ()
@property (nonatomic, strong) NSArray *cellNames;           // 单元格对应的功能名称
//@property (nonatomic, strong) NSMutableArray *imageNames;   // 单元格的图标图片
@property (nonatomic, strong) NSDictionary *cellNamesAndImages; // 单元格表示的数据字典
@end


@implementation settingViewController
//@synthesize imageNames = _imageNames;
@synthesize cellNames  = _cellNames;
@synthesize cellNamesAndImages      = _cellNamesAndImages;



- (void)viewDidLoad {
    // 初始化 cells 的 datas: cellNames, images
    [self makeDataIntoCellNamesAndImages];
    
    self.tableView.rowHeight        = 50.f;                               // 设置cell的行高
    self.tableView.separatorInset   = UIEdgeInsetsMake(0, 0, 0, 0);       // 设置cell的间隔线的左边距
    
    // 设置 title 的字体颜色
    UIColor *color                  = [UIColor redColor];
    NSDictionary *dict              = [NSDictionary dictionaryWithObject:color  forKey:UITextAttributeTextColor];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    self.navigationController.navigationBar.tintColor = color;
    
    // 自定义返回界面的按钮样式
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(backToPreVC:)];
    UIImage* image = [UIImage imageNamed:@"backItem"];
    [backItem setBackButtonBackgroundImage:[image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]
                                  forState:UIControlStateNormal
                                barMetrics:UIBarMetricsDefault];
    self.navigationItem.backBarButtonItem = backItem;

    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/*************************************
 * 功  能 : 设置 tableView 的 section 个数;
 * 参  数 :
 *          (UITableView *)tableView  当前表视图
 * 返  回 :
 *          NSInteger                 section 的个数
 *************************************/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/*************************************
 * 功  能 : UITableViewDelegate :numberOfRowsInSection 协议;
 * 参  数 :
 *          (UITableView *)tableView  当前表视图
 *          (NSInteger)section        指定的section部分
 * 返  回 :
 *          NSInteger                 指定 section 中的 cell 的个数
 *************************************/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.cellNames.count;
    return self.cellNamesAndImages.count;
}


/*************************************
 * 功  能 : UITableViewDataSource :heightForRowAtIndexPath 协议:设置行高
 * 参  数 :
 *          (UITableView *)tableView  当前表视图
 *          (NSIndexPath *)indexPath  cell的索引
 * 返  回 :
 *          CGFloat                   指定index的行高
 *************************************/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return tableView.rowHeight * FirstCellLargerCent;
    }
    return tableView.rowHeight;
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
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


/*************************************
 * 功  能 : 单元格的点击动作实现;
 *          -账号名称及信息
 *          -商户管理
 *          -交易管理
 *          -绑定机具
 *          -连接机具
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
    UITableViewCell *cell   = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected           = NO;
    if (indexPath.section == 0 ) {
        // 不要用 switch 分支,改到指定的方法模块中去实现
        // 在模块中，根据索引 indexPath.row 来匹配 dataSource 跟对应方法，以减少
        switch (indexPath.row) {
            case 0:
                // 账号名称
                break;
            case 1:
                // 商户管理
                break;
            case 2:
                // 交易管理
            {
                TransDetailsTableViewController* transDetailsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TransDetails"];
                [self.navigationController pushViewController:transDetailsVC animated:YES];
            }
                break;
            case 3:
                // 绑定机具
                break;
            case 4:
                // 连接机具
                break;
            case 5:
                // 额度查询
                break;
            case 6:
                // 修改密码
                break;
            case 7:
                // 参数设置
            {
                UIStoryboard* board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                DeviceSettingViewController* viewContr  = [board instantiateViewControllerWithIdentifier:@"deviceSettingViewController"];
                [self.navigationController pushViewController:viewContr animated:YES];
            }
                break;
            case 8:
                // 意见反馈
                break;
            case 9:
                // 帮助与关于
                break;
            // 如新版本新增功能，在后面添加 case...
            default:
                break;
        }
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
    cellLabel.text                  = [self.cellNames objectAtIndex:0 ];
    cellLabel.textColor             = [UIColor colorWithWhite:1 alpha:1];
    cellLabel.textAlignment         = NSTextAlignmentLeft;
    [cell addSubview:cellLabel];
    
    // nameLabel
    frame.origin.y                  += (littleHeight * FirstCellLargerCent);
    frame.size.height               = littleHeight;
    UILabel *nameLabel              = [[UILabel alloc] initWithFrame:frame];
    nameLabel.text                  = @"张三";      ////////////// 客户的名字需要根据登陆信息返回
    nameLabel.font                  = [UIFont systemFontOfSize:FontOfLittleLabel];
    nameLabel.textColor             = [UIColor colorWithWhite:1 alpha:1];
    nameLabel.textAlignment         = NSTextAlignmentLeft;

    [cell addSubview:nameLabel];
    
    // mailLabel
    frame.origin.y                  += littleHeight;
    frame.size.width                = width;
    UILabel *mailLabel              = [[UILabel alloc] initWithFrame:frame];
    mailLabel.text                  = @"1234567890@gmail.com";      // 客户的邮箱需要根据登陆信息返回
    mailLabel.font                  = [UIFont systemFontOfSize:FontOfLittleLabel];
    mailLabel.textColor             = [UIColor colorWithWhite:1 alpha:1];
    mailLabel.textAlignment         = NSTextAlignmentLeft;

    [cell addSubview:mailLabel];
    
    // panImageView
    frame.origin.x                  += width;
    frame.size.width                = littleHeight;
    UIImageView *panImageView       = [[UIImageView alloc] initWithFrame:frame];
    panImageView.image              = [UIImage imageNamed:@"bianji"];
    // image
    [cell addSubview:panImageView];
}

#pragma mask ::: 自定义返回上层界面按钮的功能
- (IBAction) backToPreVC :(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*************************************
 * 功  能 : 初始化 cellNamesAndImages 字典数据;
 *          版本更新功能时需要更新本模块；
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void) makeDataIntoCellNamesAndImages {
    // ...................图片名称需要更改
    self.cellNamesAndImages = @{
                               @"账号名称":@"01_01",
                               @"商户管理":@"01_07",
                               @"交易管理":@"01_10",
                               @"绑定机具":@"01_12",
                               @"连接机具":@"01_14",
                               @"额度查询":@"01_16",
                               @"修改密码":@"01_18",
                               @"参数设置":@"01_22",
                               @"意见反馈":@"01_20",
                               @"帮助和关于":@"01_24"};
    // 注意: 一旦“商户管理”板块添加了新功能，这里字典跟数组都要同步更新，包括它们对应的功能图标
    self.cellNames = [NSArray arrayWithObjects: @"账号名称",
                                                @"商户管理",
                                                @"交易管理",
                                                @"绑定机具",
                                                @"连接机具",
                                                @"额度查询",
                                                @"修改密码",
                                                @"参数设置",
                                                @"意见反馈",
                                                @"帮助和关于", nil];

}


@end
