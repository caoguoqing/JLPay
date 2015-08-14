//
//  AreaDataSourceViewController.m
//  TestForSQLite
//
//  Created by jielian on 15/8/10.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "AreaDataSourceViewController.h"
#import "MySQLiteManager.h"
#import "UserRegisterViewController.h"
#import "Define_Header.h"

@interface AreaDataSourceViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, retain) MySQLiteManager* sqliteManager;
@property (nonatomic, strong) UITableView* provinceTableView;
@property (nonatomic, strong) UITableView* cityTableView;
@property (nonatomic, strong) NSArray* provinceArray;
@property (nonatomic, strong) NSArray* cityArray;
@property (nonatomic, strong) UITextField* searchTextField;
@property (nonatomic, strong) UIBarButtonItem* doneBarButtonItem;

@property (nonatomic, strong) UITableViewCell* lastSelectedCell;
@property (nonatomic, strong) NSString* selectedCity;
@property (nonatomic, strong) NSString* selectedCityKey;
@end


int tagOfProvince = 13;
int tagOfCity = 14;

@implementation AreaDataSourceViewController
@synthesize sqliteManager = _sqliteManager;
@synthesize provinceTableView = _provinceTableView;
@synthesize cityTableView = _cityTableView;
@synthesize provinceArray = _provinceArray;
@synthesize cityArray = _cityArray;
@synthesize searchTextField = _searchTextField;
@synthesize doneBarButtonItem = _doneBarButtonItem;
@synthesize lastSelectedCell;
@synthesize selectedCity;
@synthesize selectedCityKey;




#pragma mask ---- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == tagOfProvince) {
        // 执行查询语句
        NSString* descr = [[self.provinceArray objectAtIndex:indexPath.row] valueForKey:@"KEY"];
        NSString* selectString = [NSString stringWithFormat:@"select value,key from cst_sys_param where owner = 'CITY' and descr = '%@' ",descr];
        self.cityArray = [self.sqliteManager selectedDatasWithSQLString:selectString];
        [self.cityTableView reloadData];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        if (self.lastSelectedCell && self.lastSelectedCell != cell) {
            self.lastSelectedCell.accessoryType = UITableViewCellAccessoryNone;
        }
        self.lastSelectedCell = cell;
        self.selectedCity = [cell.textLabel.text copy];
        self.selectedCityKey = [[[self.cityArray objectAtIndex:indexPath.row] valueForKey:@"KEY"] copy];
    }
}
#pragma mask ---- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == tagOfProvince) {
        return self.provinceArray.count;
    } else /*if (tableView.tag == tagOfCity)*/ {
        return self.cityArray.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"cellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (tableView.tag == tagOfProvince) {
        NSDictionary* dict = [self.provinceArray objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = [dict valueForKey:@"VALUE"];
    } else /*if (tableView.tag == tagOfCity)*/ {
        NSDictionary* dict = [self.cityArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [dict valueForKey:@"VALUE"];
        if ([cell.textLabel.text isEqualToString:self.selectedCity]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [cell setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1]];
    }
    return cell;
}


#pragma mask ---- 文本框- Return 按键的回调
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if ([textField.text length] == 0) {
        [self alertShowWithMessage:@"输入的城市名为空"];
        return YES;
    }
    NSString* selectString = [NSString stringWithFormat:@"select value,key,descr from cst_sys_param where owner = 'CITY' and value like '%@%%' ",textField.text];
    // 执行查询
    NSArray* searchArray = [self.sqliteManager selectedDatasWithSQLString:selectString];
    
    
    
    if (searchArray == nil || searchArray.count == 0) {
        [self alertShowWithMessage:@"没有查询到输入的城市"];
    } else if (searchArray.count > 1) {
        NSString* text =  [NSString stringWithFormat:@"输入的城市[%@]有重复", textField.text];
        [self alertShowWithMessage:text];
    }
    // 已查询到城市:
    else {
        NSDictionary* searchedDict = [searchArray objectAtIndex:0];
        NSUInteger searchedIndex = 0;
        // 切换已选择的 province cell 到查询到得省
        for (NSDictionary* dict in self.provinceArray) {
            if ([[dict valueForKey:@"KEY"] isEqualToString:[searchedDict valueForKey:@"DESCR"]]) {
                searchedIndex = [self.provinceArray indexOfObject:dict];
                break;
            }
        }
        NSIndexPath* cellIndex = [NSIndexPath indexPathForRow:searchedIndex inSection:0];
        [self.provinceTableView selectRowAtIndexPath:cellIndex animated:YES scrollPosition:UITableViewScrollPositionTop];
        
        // 重新加载当前已选择的省份下面的所有城市
        [self reloadCityTableViewInProvinceKey:[searchedDict valueForKey:@"DESCR"] andSelectCity:[searchedDict valueForKey:@"VALUE"]];
    }
    return YES;
}


/* 
 * 重新加载当前已选择的省份下面的所有城市
 * 1.用省份码查询下挂的所有城市
 * 2.用城市码切换到已选择的城市cell
 */
- (void) reloadCityTableViewInProvinceKey:(NSString*)provinceKey andSelectCity:(NSString*)city {
    NSString* selectString = [NSString stringWithFormat:@"select value,key,descr from cst_sys_param where owner = 'CITY' and descr = '%@' ",provinceKey];
    self.cityArray = [self.sqliteManager selectedDatasWithSQLString:selectString];
    if (self.cityArray.count == 0) {
        NSString* message = [NSString stringWithFormat:@"省份代码[%@]下面没有城市",provinceKey];
        [self alertShowWithMessage:message];
        return;
    }
    self.selectedCity = city;
    if (self.lastSelectedCell) {
        self.lastSelectedCell.accessoryType = UITableViewCellAccessoryNone;
    }
    [self.cityTableView reloadData];
    
    // 调整位置
    NSInteger index = -1;
    for (NSDictionary* dict in self.cityArray) {
        if ([[dict valueForKey:@"VALUE"] isEqualToString:city]) {
            self.selectedCityKey = [dict valueForKey:@"KEY"];
            index = [self.cityArray indexOfObject:dict];
            break;
        }
    }
    if (index > 0) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.cityTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        self.lastSelectedCell = [self.cityTableView cellForRowAtIndexPath:indexPath];
    }
}

#pragma mask ---- UIBarButtonItem 确定 的点击事件
- (void) popToRegisterView {
    // 获取上层界面,并将 城市-城市代码 传给它 ...
    [self.navigationController popViewControllerAnimated:YES];
    UserRegisterViewController* viewCs = (UserRegisterViewController*)self.navigationController.topViewController;
    // 传之前要将尾空白字符去掉
    self.selectedCity = [self clearSpaceCharAtLastOfString:self.selectedCity];
    viewCs.areaLabel.text = [NSString stringWithFormat:@"%@(%@)",self.selectedCity,self.selectedCityKey];
}
- (NSString*) clearSpaceCharAtLastOfString:(NSString*)string {
    const char* originString = [string cStringUsingEncoding:NSUTF8StringEncoding];
    char* newString = (char*)malloc(strlen(originString) + 1);
    memset(newString, 0x00, strlen(originString) + 1);
    int copylen = (int)strlen(originString);
    char* tmp = (char*)(originString + copylen - 1);
    while (1) {
        if (isspace(*tmp)) {
            tmp--;
            copylen--;
        } else {
            break;
        }
    }
    memcpy(newString, originString, copylen);
    NSString* retString = [NSString stringWithCString:newString encoding:NSUTF8StringEncoding];
    free(newString);
    return retString;
}


#pragma mask ---- 界面生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    _sqliteManager = [MySQLiteManager SQLiteManagerWithDBFile:DBFILENAME];
    [self.view addSubview:self.provinceTableView];
    [self.view addSubview:self.cityTableView];
    [self.view addSubview:self.searchTextField];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController.navigationBar.backItem setTitle:@"取消"];
    self.lastSelectedCell = nil;
    self.selectedCity = nil;
    self.selectedCityKey = nil;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString* provinceSQL = @"select value,key from cst_sys_param where owner = 'PROVINCE' and descr = '156'";
    self.provinceArray = [[_sqliteManager selectedDatasWithSQLString:provinceSQL] copy];
    
    
    CGFloat naviAndStateHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.bounds.size.height;
    CGFloat inset = 10;
    CGRect frame = CGRectMake(inset,
                              naviAndStateHeight + inset,
                              self.view.bounds.size.width - inset*2.0,
                              35.0);
    // 搜索输入框
    self.searchTextField.frame = frame;
    CGRect viewFrame = self.searchTextField.leftView.frame;
    viewFrame.size.height = frame.size.height;
    viewFrame.size.width = viewFrame.size.height;
    self.searchTextField.leftView.frame = viewFrame;
    self.searchTextField.layer.cornerRadius = self.searchTextField.frame.size.height/2.0;
    
    // 分割线
    CGFloat width = 0.5;
    frame.origin.x = 0;
    frame.origin.y += frame.size.height + inset - width;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = width;
    UIView* view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.5];
    [self.view addSubview:view];
    
    // 省份表视图
    frame.origin.x = 0;
    frame.origin.y += width;
    frame.size.width = self.view.bounds.size.width / 2.0;
    frame.size.height = self.view.bounds.size.height - frame.origin.y;
    self.provinceTableView.frame = frame;
    // 城市表视图
    frame.origin.x += frame.size.width;
    self.cityTableView.frame = frame;
    
    // 加载 barButtonItem
    [self.navigationItem setRightBarButtonItem:self.doneBarButtonItem];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBoard)];
    gesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gesture];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}
// 点击空白区域隐藏键盘
- (void) hiddenKeyBoard {
    [self.view endEditing:YES];
}



#pragma mask ---- Private interface function
- (void) alertShowWithMessage:(NSString*)msg {
    UIAlertView*  alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}


#pragma mask ---- getter & setter
- (UITableView *)provinceTableView {
    if (_provinceTableView == nil) {
        _provinceTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_provinceTableView setTag:tagOfProvince];
        UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
        [_provinceTableView setTableFooterView:view];
        [_provinceTableView setDelegate:self];
        [_provinceTableView setDataSource:self];
    }
    return _provinceTableView;
}
- (UITableView *)cityTableView {
    if (_cityTableView == nil) {
        _cityTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_cityTableView setTag:tagOfCity];
        [_cityTableView setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1]];
        UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
        [_cityTableView setTableFooterView:view];
        [_cityTableView setDelegate:self];
        [_cityTableView setDataSource:self];
    }
    return _cityTableView;
}
- (NSArray *)provinceArray {
    if (_provinceArray == nil) {
        _provinceArray = [[NSArray alloc] init];
    }
    return _provinceArray;
}
- (NSArray *)cityArray {
    if (_cityArray == nil) {
        _cityArray = [[NSArray alloc] init];
    }
    return _cityArray;
}
- (UITextField *)searchTextField {
    if (_searchTextField == nil) {
        _searchTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _searchTextField.placeholder = @"请输入城市中文名";
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.image = [UIImage imageNamed:@"search"];
        [_searchTextField setLeftView:imageView];
        [_searchTextField setLeftViewMode:UITextFieldViewModeAlways];
        _searchTextField.backgroundColor = [UIColor whiteColor];
        _searchTextField.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
        _searchTextField.layer.borderWidth = 0.5;
        _searchTextField.layer.cornerRadius = 5.0;
        _searchTextField.layer.masksToBounds = YES;
        _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _searchTextField.returnKeyType = UIReturnKeySearch;
        _searchTextField.clearsOnBeginEditing = YES;
        [_searchTextField setDelegate:self];
    }
    return _searchTextField;
}
- (UIBarButtonItem *)doneBarButtonItem {
    if (_doneBarButtonItem == nil) {
        _doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(popToRegisterView)];
    }
    return _doneBarButtonItem;
}

@end
