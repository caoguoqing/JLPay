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
#import "Define_Header.h"
#import "DeviceSignInViewController.h"

#define LeftInsetOfCellCent             0.1f                    // 单元格元素的左边界距离
#define ImageViewWidthInCellCent        0.1f                    // 单元格内的imageView.width占宽带比例
#define LabelViewWidthInCellCent        0.4f                    // 单元格内的labelView.width占宽带比例
#define FirstCellLargerCent             1.5f                    // 第一个单元格的放大比例
#define FontOfLittleLabel               12.f                    // 小窗口的字体大小



@interface settingViewController ()<UIActionSheetDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) NSArray *cellNames;           // 单元格对应的功能名称
@property (nonatomic, strong) NSDictionary *cellNamesAndImages; // 单元格表示的数据字典
@property (nonatomic, strong) NSArray* deviceTypeArray;
@end


@implementation settingViewController
//@synthesize imageNames = _imageNames;
@synthesize cellNames  = _cellNames;
@synthesize cellNamesAndImages      = _cellNamesAndImages;
@synthesize deviceTypeArray;



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
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(backToPreVC:)];
    UIImage* image = [UIImage imageNamed:@"backItem"];
    [backItem setBackButtonBackgroundImage:[image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]
                                  forState:UIControlStateNormal
                                barMetrics:UIBarMetricsDefault];
    self.navigationItem.backBarButtonItem = backItem;

    [super viewDidLoad];
    
    // 设备类型数组:后续有厂商对接，需要更新数组
    self.deviceTypeArray = [NSArray arrayWithObjects:
//                            DeviceType_JHL_A60,       // 先屏蔽音频设备
                            DeviceType_JHL_M60, nil];
    [self setExtraCellLineHidden:self.tableView];
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
 * 功  能 : UITableViewDelegate :屏蔽指定cell 的点击高亮效果
 * 参  数 :
 *          (NSIndexPath *)indexPath  cell的索引
 * 返  回 :
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
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


/*************************************
 * 功  能 : 单元格的点击动作实现;
 *          -账号名称及信息
 *          -交易管理
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
                // 交易管理
            {
                TransDetailsTableViewController* transDetailsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TransDetails"];
                [self.navigationController pushViewController:transDetailsVC animated:YES];
            }
                break;
            case 2:
                // 连接机具
            {
                // 先弹窗供用户选择设备类型,在选择完了设备类型后才跳转界面
                UIActionSheet* deviceTypeListSheet = [[UIActionSheet alloc] initWithTitle:@"请选择设备类型"
                                                                                 delegate:self
                                                                        cancelButtonTitle:@"取消"
                                                                   destructiveButtonTitle:nil
                                                                        otherButtonTitles:nil,nil];
                for(int i = 0; i < self.deviceTypeArray.count; i++) { // 如果后续有厂商对接，只需要更新array和宏就可以
                    [deviceTypeListSheet addButtonWithTitle:[self.deviceTypeArray objectAtIndex:i]];
                }
                [deviceTypeListSheet showFromToolbar:self.navigationController.toolbar];
                
            }
                break;
//            case 3:
//                // 参数设置
//            {
//                // 只有代理商才能进行设备的参数设置，所以这里加上操作员登陆功能
//                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"代理商请登陆"
//                                                                message:@"商户不用操作"
//                                                               delegate:self
//                                                      cancelButtonTitle:@"取消"
//                                                      otherButtonTitles:@"登陆", nil];
//                [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
//                UITextField* loginName = [alert textFieldAtIndex:0];    // 操作员账号
//                loginName.placeholder = @"请输入操作员账号";
//                UITextField* loginPassword = [alert textFieldAtIndex:1];    // 操作员密码
//                loginPassword.placeholder = @"请输入操作员密码";
//
//                [alert show];
//                
//                
//            }
//                break;
            case 3:
                // 额度查询
                break;
            case 4:
                // 修改密码
                break;
            case 5:
                // 意见反馈
                break;
            case 6:
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
    
    // mailLabel
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
 * 功  能 : actionSheet的点击并退出回调;
 *          要设置设备类型到本地，
 *          并跳转到设备选择界面
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    BOOL pushView = YES;
    NSLog(@"=====[%@]", [actionSheet buttonTitleAtIndex:buttonIndex]);
    if (buttonIndex == 0) { // 取消
        pushView = NO;
    }
    if (buttonIndex > 0) {
        // 设置设备类型到本地配置
        [[NSUserDefaults standardUserDefaults] setValue:[actionSheet buttonTitleAtIndex:buttonIndex] forKey:DeviceType];
    }
    if (pushView) {
//        ChooseDeviceTabelViewController* chooseDeviceVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"chooseDeviceVC"];        
        DeviceSignInViewController* deviceSigninVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"deviceSigninVC"];
        [self.navigationController pushViewController:deviceSigninVC animated:YES];
    }

}

/*************************************
 * 功  能 : 操作员登陆弹窗的按钮点击事件;
 *          确认后进行发送操作员登陆申请，
 *          在登陆的回调中跳转到设备参数设置界面
 * 参  数 : 无
 * 返  回 : 无
 *************************************/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {             // 取消
        
    } else if (buttonIndex == 1) {      // 确定
        UITextField* loginName = [alertView textFieldAtIndex:0];    // 操作员账号
        UITextField* loginPassword = [alertView textFieldAtIndex:1];    // 操作员密码

        // 操作员登陆
        if (![loginName.text isEqualToString:[PublicInformation returnOperatorNum]]) {
            [self alertForMessage:@"操作员编号错误"];
            return;
        }
        if (![loginPassword.text isEqualToString:[PublicInformation returnOperatorPassword]]) {
            [self alertForMessage:@"操作员密码错误"];
            return;
        }
        
        // 校验成功才跳转界面
        UIStoryboard* board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DeviceSettingViewController* viewContr  = [board instantiateViewControllerWithIdentifier:@"terminalSettingVC"];
        [self.navigationController pushViewController:viewContr animated:YES];
    }
}



#pragma mask ::: 自定义返回上层界面按钮的功能
- (IBAction) backToPreVC :(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// 错误提示
- (void) alertForMessage:(NSString*)message {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
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
                               @"交易管理":@"01_10",
                               @"绑定机具":@"01_14",
//                               @"参数设置":@"01_22",
                               @"额度查询":@"01_16",
                               @"修改密码":@"01_18",
                               @"意见反馈":@"01_20",
                               @"帮助和关于":@"01_24"};
    // 注意: 一旦“商户管理”板块添加了新功能，这里字典跟数组都要同步更新，包括它们对应的功能图标
    self.cellNames = [NSArray arrayWithObjects: @"账号名称",
                                                @"交易管理",
                                                @"绑定机具",
//                                                @"参数设置",
                                                @"额度查询",
                                                @"修改密码",
                                                @"意见反馈",
                                                @"帮助和关于", nil];

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
@end
