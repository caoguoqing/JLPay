//
//  SQLRequestAreas.m
//  JLPay
//
//  Created by jielian on 16/3/8.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "SQLRequestAreas.h"
#import "ModelAreaCodeSelector.h"
#import <UIKit/UIKit.h>
#import "PublicInformation.h"

static NSString* const kSQLAreaCode = @"KEY";
static NSString* const kSQLAreaName = @"VALUE";


typedef enum {
    SQLRequestAreaTypeProvince,
    SQLRequestAreaTypeCity
}SQLRequestAreaType;


@interface SQLRequestAreas()
<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, assign) SQLRequestAreaType areaType;
@property (nonatomic, copy) NSArray* provincesRequested;
@property (nonatomic, copy) NSArray* citiesRequested;

@end


@implementation SQLRequestAreas

- (void) requestAreasOnCode:(NSString*)areaCode
                 onSucBlock:(void (^) (void))sucBlock
                 onErrBlock:(void (^) (NSError* error))errBlock {
    if ([areaCode isEqualToString:@"156"]) {
        self.areaType = SQLRequestAreaTypeProvince;
        NSArray* provinces = [ModelAreaCodeSelector allProvincesSelected];
        if (provinces && provinces.count > 0) {
            self.provincesRequested = [provinces copy];
            sucBlock();
        } else {
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:@"查询省数据失败" forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:@"SQLRequestAreasDomain" code:99 userInfo:userInfo];
            errBlock(error);
        }
    } else {
        self.areaType = SQLRequestAreaTypeCity;
        NSArray* cities = [ModelAreaCodeSelector allCitiesSelectedAtProvinceCode:areaCode];
        if (cities && cities.count > 0) {
            self.citiesRequested = [cities copy];
            sucBlock();
        } else {
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:@"查询市数据失败" forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:@"SQLRequestAreasDomain" code:99 userInfo:userInfo];
            errBlock(error);
        }
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
    }
    if (self.areaType == SQLRequestAreaTypeProvince) {
        cell.textLabel.text = [self provinceNameAtIndex:indexPath.row];
        if ([cell.textLabel.text isEqualToString:self.provinceNameSelected]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        cell.textLabel.text = [self cityNameAtIndex:indexPath.row];
        if ([cell.textLabel.text isEqualToString:self.cityNameSelected]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.areaType == SQLRequestAreaTypeProvince) {
        return self.provincesRequested.count;
    } else {
        return self.citiesRequested.count;
    }
}
#pragma mask 2 UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.areaType == SQLRequestAreaTypeProvince) {
        self.provinceNameSelected = [self provinceNameAtIndex:indexPath.row];
        self.provinceCodeSelected = [self provinceCodeAtIndex:indexPath.row];
    } else {
        self.cityNameSelected = [self cityNameAtIndex:indexPath.row];
        self.cityCodeSelected = [self cityCodeAtIndex:indexPath.row];
    }
    [tableView reloadData];
}

#pragma mask 3 model
- (NSString*) provinceNameAtIndex:(NSInteger)index {
    NSDictionary* provinceNode = [self.provincesRequested objectAtIndex:index];
    return [PublicInformation clearSpaceCharAtLastOfString:[provinceNode objectForKey:kSQLAreaName]];
}
- (NSString*) provinceCodeAtIndex:(NSInteger)index {
    NSDictionary* provinceNode = [self.provincesRequested objectAtIndex:index];
    return [PublicInformation clearSpaceCharAtLastOfString:[provinceNode objectForKey:kSQLAreaCode]];
}
- (NSString*) cityNameAtIndex:(NSInteger)index {
    NSDictionary* cityNode = [self.citiesRequested objectAtIndex:index];
    return [PublicInformation clearSpaceCharAtLastOfString:[cityNode objectForKey:kSQLAreaName]];
}
- (NSString*) cityCodeAtIndex:(NSInteger)index {
    NSDictionary* cityNode = [self.citiesRequested objectAtIndex:index];
    return [PublicInformation clearSpaceCharAtLastOfString:[cityNode objectForKey:kSQLAreaCode]];
}


@end
