//
//  RgAddrTableViewCell.h
//  TestForRegister
//
//  Created by jielian on 15/8/20.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RgAddrTableViewCell;
@protocol RgAddrTableViewCellDelegate <NSObject>

// 点击了地区按钮 placeType: 0:省份,1:城市,2:区县
- (void) addrCell:(RgAddrTableViewCell*)addrCell choosePlaceInType:(int)placeType;
// 输完了详细地址
- (void) addrCell:(RgAddrTableViewCell*)addrCell inputedDetailPlace:(NSString*)detailPlace;
@end


@interface RgAddrTableViewCell : UITableViewCell
@property (nonatomic, weak) id<RgAddrTableViewCellDelegate>delegate;

// 判断是否正在输入
- (BOOL) isTextEditing;
// 取消输入动作
- (void) endingTextEditing;

// 设置省份
- (void) setProvince:(NSString*)province;
- (NSString*) province;
// 设置市
- (void) setCity:(NSString*)city;
- (NSString*) city;
// 设置区/县
- (void) setArea:(NSString*)area;
- (NSString*) area;

// 详细地址
- (NSString*) detailPlace;

@end
