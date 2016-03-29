//
//  HTTPRequestFeeBusiness.m
//  JLPay
//
//  Created by jielian on 15/12/23.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "HTTPRequestFeeBusiness.h"
#import "HTTPInstance.h"
#import "PublicInformation.h"
#import <UIKit/UIKit.h>

static NSString* const kHttpBusinessErrorDomainName = @"kHttpBusinessErrorDomainName";

/* 响应数据域名 - responseInfo */
static NSString* const kFeeBusinessListName = @"merchInfoList"; // 商户信息列表名
static NSString* const kFeeBusinessBusinessName = @"mchtNm"; // 商户名
static NSString* const kFeeBusinessBusinessNum = @"mchtNo"; // 商户号
static NSString* const kFeeBusinessTerminalNum = @"termNo"; // 终端号



@interface HTTPRequestFeeBusiness()
<HTTPInstanceDelegate,UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) HTTPInstance* http;

@property (nonatomic, copy) void (^ requestSucBlock) (void);
@property (nonatomic, copy) void (^ requestErrBlock) (NSError* error);

@property (nonatomic, copy) NSArray* businessInfosRequested;


@end

@implementation HTTPRequestFeeBusiness


// block 的申请接口
- (void) requestFeeBusinessOnFeeType:(NSString*)feeType
                            areaCode:(NSString*)areaCode
                          onSucBlock:(void (^) (void))sucBlock
                          onErrBlock:(void (^) (NSError* error))errBlock
{
    self.requestSucBlock = sucBlock;
    self.requestErrBlock = errBlock;
    
    [self.http startRequestingWithDelegate:self packingHandle:^(ASIFormDataRequest *http) {
        [http addPostValue:feeType forKey:@"feeType"];
        [http addPostValue:areaCode forKey:@"areaCode"];
        [http addPostValue:[PublicInformation returnBusiness] forKey:@"mchtNo"];
    }];
}

/* 终止请求 */
- (void)terminateRequest {
    [self.http terminateRequesting];
}

#pragma mask ---- HTTPInstanceDelegate
- (void)httpInstance:(HTTPInstance *)httpInstance didRequestingFailedWithError:(NSDictionary *)errorInfo
{
    if (self.requestErrBlock) {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[errorInfo objectForKey:kHTTPInstanceErrorMessage] forKey:NSLocalizedDescriptionKey];
        NSError* error = [NSError errorWithDomain:kHttpBusinessErrorDomainName code:[[errorInfo objectForKey:kHTTPInstanceErrorCode] integerValue] userInfo:userInfo];
        self.requestErrBlock(error);
    }
}
- (void)httpInstance:(HTTPInstance *)httpInstance didRequestingFinishedWithInfo:(NSDictionary *)info
{
    NSArray* businessInfos = [info objectForKey:kFeeBusinessListName];
    if (businessInfos && businessInfos.count > 0) {
        self.businessInfosRequested = [info objectForKey:kFeeBusinessListName];
        if (self.requestSucBlock) {
            self.requestSucBlock();
        }
    } else {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:@"查无商户数据\n请切换'费率'或'地区'" forKey:NSLocalizedDescriptionKey];
        NSError* error = [NSError errorWithDomain:kHttpBusinessErrorDomainName code:99 userInfo:userInfo];
        self.requestErrBlock(error);
    }
}

#pragma mask 2 UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = @"cellidentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        CGRect frame = [tableView rectForRowAtIndexPath:indexPath];
        frame.origin.x = frame.origin.y = 0;
        UIView* backView = [[UIView alloc] initWithFrame:frame];
        backView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.35];
        cell.selectedBackgroundView = backView;
    }
    cell.textLabel.text = [self businessNameAtIndex:indexPath.row];
    if ([cell.textLabel.text isEqualToString:self.businessNameSelected]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.businessInfosRequested.count;
}
#pragma mask 2 UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.businessCodeSelected = [self businessCodeAtIndex:indexPath.row];
    self.businessNameSelected = [self businessNameAtIndex:indexPath.row];
    self.terminalCodeSelected = [self terminalCodeAtIndex:indexPath.row];
    [tableView reloadData];
}

#pragma mask 3 model
- (NSString*) businessNameAtIndex:(NSInteger)index {
    NSDictionary* businessNode = [self.businessInfosRequested objectAtIndex:index];
    return [businessNode objectForKey:kFeeBusinessBusinessName];
}
- (NSString*) businessCodeAtIndex:(NSInteger)index {
    NSDictionary* businessNode = [self.businessInfosRequested objectAtIndex:index];
    return [businessNode objectForKey:kFeeBusinessBusinessNum];
}
- (NSString*) terminalCodeAtIndex:(NSInteger)index {
    NSDictionary* businessNode = [self.businessInfosRequested objectAtIndex:index];
    return [businessNode objectForKey:kFeeBusinessTerminalNum];
}


#pragma mask ---- getter
- (HTTPInstance *)http {
    if (_http == nil) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/getInstMchtInfo",
                               [PublicInformation getServerDomain],
                               [PublicInformation getHTTPPort]];
        _http = [[HTTPInstance alloc] initWithURLString:urlString];
    }
    return _http;
}

@end
