//
//  GuanyuViewController.m
//  JLPay
//
//  Created by jielian on 15/8/16.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "GuanyuViewController.h"
#import "Define_Header.h"
#import "ModelAppInformation.h"

@interface GuanyuViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* cellTextArray;
@property (nonatomic, strong) NSDictionary* dataSourceDict;
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel* appNameLabel;
@end

CGFloat cellHeight = 40.0;

@implementation GuanyuViewController
@synthesize tableView = _tableView;
@synthesize cellTextArray = _cellTextArray;
@synthesize dataSourceDict = _dataSourceDict;


#pragma mask ---- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if ([alertView.title hasPrefix:@"呼叫"]) {
            NSRange gbkTextRange = [alertView.title rangeOfString:@"呼叫"];
            NSString* telURL = [alertView.title substringFromIndex:gbkTextRange.location + gbkTextRange.length];
            telURL = [telURL stringByReplacingOccurrencesOfString:@" " withString:@""];
            telURL = [telURL stringByReplacingOccurrencesOfString:@"-" withString:@""];
            telURL = [@"tel://" stringByAppendingString:telURL];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telURL]];
        } else if ([alertView.title hasPrefix:@"访问"]) {
            // 访问网址
            NSString* urlString = [alertView.title substringFromIndex:[alertView.title rangeOfString:@"www"].location];
            urlString = [@"http://" stringByAppendingString:urlString];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }
    }
}



#pragma mask ---- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellTextArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"cellIdentier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    }
    cell.backgroundColor = [UIColor whiteColor];
    NSString* text = [self.cellTextArray objectAtIndex:indexPath.row];
    cell.textLabel.text = text;
    if ([text isEqualToString:@"联系方式:"] || [text isEqualToString:@"官方网址:"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.detailTextLabel.text = [self.dataSourceDict valueForKey:cell.textLabel.text];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}
#pragma mask ---- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString* alerTitle = nil;
    if ([cell.textLabel.text isEqualToString:@"联系方式"]) {
        alerTitle = [NSString stringWithFormat:@"呼叫 %@",cell.detailTextLabel.text];
    } else {
        alerTitle = [NSString stringWithFormat:@"访问 %@", cell.detailTextLabel.text];
    }
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:alerTitle message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryNone) {
        return NO;
    }
    return YES;
}




#pragma mask ---- 界面生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1]];
    [self.view addSubview:self.tableView];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat naviAndStatusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    CGFloat labelHeight = 40;
    CGFloat horizontalInset = 40;
    CGFloat verticalInset = 15;
    CGFloat imageWidth = 60;
    
    CGRect frame = CGRectMake((self.view.bounds.size.width - imageWidth)/2.0,
                              naviAndStatusHeight + (self.view.bounds.size.height - naviAndStatusHeight - tabBarHeight - imageWidth - horizontalInset - labelHeight*3 - verticalInset*2 - labelHeight)/2.0,
                              imageWidth,
                              imageWidth );
    // 图标
    [self.imageView setFrame:frame];
    [self.view addSubview:self.imageView];
    // app名
    frame.origin.x = 0;
    frame.origin.y += frame.size.height;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = labelHeight;
    [self.appNameLabel setFrame:frame];
    [self.view addSubview:self.appNameLabel];
    // 表视图
    frame.origin.y += frame.size.height + horizontalInset;
    frame.size.height = cellHeight * self.cellTextArray.count;
    self.tableView.frame = frame;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


#pragma mask ---- getter & setter 
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView setTableFooterView:view];
        [_tableView setBounces:NO];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
    }
    return _tableView;
}
- (NSMutableArray *)cellTextArray {
    if (_cellTextArray == nil) {
        _cellTextArray = [[NSMutableArray alloc] init];
        [_cellTextArray addObject:@"版本信息:"];
        [_cellTextArray addObject:@"联系方式:"];
        [_cellTextArray addObject:@"官方网址:"];
    }
    return _cellTextArray;
}
- (NSDictionary *)dataSourceDict {
    if (_dataSourceDict == nil) {
        NSMutableArray* values = [[NSMutableArray alloc] init];
        NSString* version = [@"V" stringByAppendingString:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey]];
        [values addObject:version];
        [values addObject:[PublicInformation telephoneOfCompany]];
        [values addObject:[PublicInformation urlOfCompany]];
        _dataSourceDict = [NSDictionary dictionaryWithObjects:values forKeys:self.cellTextArray];
    }
    return _dataSourceDict;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.image = [PublicInformation iconImageOfApp];
    }
    return _imageView;
}
- (UILabel *)appNameLabel {
    if (!_appNameLabel) {
        _appNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _appNameLabel.textAlignment = NSTextAlignmentCenter;
        _appNameLabel.text = [PublicInformation appNameOnDifferentBranch];
    }
    return _appNameLabel;
}



@end
