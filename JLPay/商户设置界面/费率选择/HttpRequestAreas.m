//
//  HttpRequestAreas.m
//  JLPay
//
//  Created by jielian on 16/3/3.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "HttpRequestAreas.h"
#import "HTTPInstance.h"
#import "PublicInformation.h"
#import <UIKit/UIKit.h>

typedef enum {
    HttpRequestAreaTypeProvince,
    HttpRequestAreaTypeCity
}HttpRequestAreaType;


static NSString* const kHttpAreaCode = @"key";
static NSString* const kHttpAreaName = @"value";

static NSString* const kHttpAreasErrorDomainName = @"kHttpAreasErrorDomainName";

@interface HttpRequestAreas()
<HTTPInstanceDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, assign) HttpRequestAreaType areaType;


@property (nonatomic, strong) HTTPInstance* http;
@property (nonatomic, copy) void (^requestSuccessWithAreas) (void);
@property (nonatomic, copy) void (^requestFailWithError) (NSError* error);

@property (nonatomic, copy) NSArray* provincesRequested;
@property (nonatomic, copy) NSArray* citiesRequested;


@end

@implementation HttpRequestAreas

- (void)requestAreasOnCode:(NSString *)areaCode
                onSucBlock:(void (^)(void))sucBlock
                onErrBlock:(void (^)(NSError *))errBlock
{
    if ([areaCode isEqualToString:@"156"]) {
        self.areaType = HttpRequestAreaTypeProvince;
    } else {
        self.areaType = HttpRequestAreaTypeCity;
    }
    self.requestSuccessWithAreas = sucBlock;
    self.requestFailWithError = errBlock;
    [self.http startRequestingWithDelegate:self packingHandle:^(ASIFormDataRequest *http) {
        [http addPostValue:areaCode forKey:@"descr"];
    }];
}

- (void) terminateRequesting {
    [self.http terminateRequesting];
}


#pragma mask 2 HTTPInstanceDelegate
- (void) httpInstance:(HTTPInstance*)httpInstance didRequestingFinishedWithInfo:(NSDictionary*)info {
    NSArray* datas = [info objectForKey:@"areaList"];
    if (datas && datas.count > 0) {
        if (self.areaType == HttpRequestAreaTypeProvince) {
            self.provincesRequested = [datas copy];
        }
        else if (self.areaType == HttpRequestAreaTypeCity) {
            self.citiesRequested = [datas copy];
        }
        self.requestSuccessWithAreas();
    } else {
        NSDictionary* userInfo = nil;
        if (self.areaType == HttpRequestAreaTypeProvince) {
            userInfo = [NSDictionary dictionaryWithObject:@"查无省数据" forKey:NSLocalizedDescriptionKey];
        }
        else if (self.areaType == HttpRequestAreaTypeCity) {
            userInfo = [NSDictionary dictionaryWithObject:@"查无市数据" forKey:NSLocalizedDescriptionKey];
        }
        NSError* error = [NSError errorWithDomain:kHttpAreasErrorDomainName code:99 userInfo:userInfo];
        self.requestFailWithError(error);
    }
}

- (void) httpInstance:(HTTPInstance*)httpInstance didRequestingFailedWithError:(NSDictionary*)errorInfo {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[errorInfo objectForKey:kHTTPInstanceErrorMessage] forKey:NSLocalizedDescriptionKey];
    NSError* error = [NSError errorWithDomain:kHttpAreasErrorDomainName code:[[errorInfo objectForKey:kHTTPInstanceErrorCode] integerValue] userInfo:userInfo];
    self.requestFailWithError(error);
}

#pragma mask 2 UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (self.areaType == HttpRequestAreaTypeProvince) {
        rows = self.provincesRequested.count;
    }
    else if (self.areaType == HttpRequestAreaTypeCity) {
        rows = self.citiesRequested.count;
    }
    return rows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* identifier = @"identifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    if (self.areaType == HttpRequestAreaTypeProvince) {
        cell.textLabel.text = [self provinceNameAtIndex:indexPath.row];
        if ([cell.textLabel.text isEqualToString:self.provinceNameSelected]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else if (self.areaType == HttpRequestAreaTypeCity) {
        cell.textLabel.text = [self cityNameAtIndex:indexPath.row];
        if ([cell.textLabel.text isEqualToString:self.cityNameSelected]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}
#pragma mask 2 UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.areaType == HttpRequestAreaTypeProvince) {
        self.provinceNameSelected = [self provinceNameAtIndex:indexPath.row];
        self.provinceCodeSelected = [self provinceCodeAtIndex:indexPath.row];
    }
    else if (self.areaType == HttpRequestAreaTypeCity) {
        self.cityNameSelected = [self cityNameAtIndex:indexPath.row];
        self.cityCodeSelected = [self cityCodeAtIndex:indexPath.row];
    }
    [tableView reloadData];
}

#pragma mask 3 model
// -- 省名:指定序号
- (NSString*) provinceNameAtIndex:(NSInteger)index {
    NSDictionary* provinceNode = [self.provincesRequested objectAtIndex:index];
    return [provinceNode objectForKey:kHttpAreaName];
}
// -- 省代码:指定序号
- (NSString*) provinceCodeAtIndex:(NSInteger)index {
    NSDictionary* provinceNode = [self.provincesRequested objectAtIndex:index];
    return [provinceNode objectForKey:kHttpAreaCode];
}
// -- 市名:指定序号
- (NSString*) cityNameAtIndex:(NSInteger)index {
    NSDictionary* cityNode = [self.citiesRequested objectAtIndex:index];
    return [cityNode objectForKey:kHttpAreaName];
}
// -- 市代码:指定序号
- (NSString*) cityCodeAtIndex:(NSInteger)index {
    NSDictionary* cityNode = [self.citiesRequested objectAtIndex:index];
    return [cityNode objectForKey:kHttpAreaCode];
}


#pragma mask 4 getter 
- (HTTPInstance *)http {
    if (_http == nil) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/getAreaList",
                               [PublicInformation getServerDomain],
                               [PublicInformation getHTTPPort]];
        _http = [[HTTPInstance alloc] initWithURLString:urlString];
    }
    return _http;
}


@end
