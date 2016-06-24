//
//  QianPiViewController.h
//  PosN38Universal
//
//  Created by work on 14-8-22.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASINetworkQueue.h"
#import "NewVersionView.h"
#import "PosInformationViewController.h"


@class AppDelegate;

@interface QianPiViewController : UIViewController{
    NewVersionView *newVersionVi;
    AppDelegate *appdeletate;
    
    ASINetworkQueue *queue;
    
    int isHiddenType;
    
    UIView *returnView;
    
}
@property(nonatomic,retain)UIImage *uploadImage;
@property(nonatomic,retain)NSString *exchangeTypeStr;
@property(nonatomic,assign)int qianpitype;
@property(nonatomic,retain)NSString *currentLiushuiStr;
@property(nonatomic,retain)NSString *lastLiushuiStr;


@property (nonatomic, copy) NSDictionary* transInformation;

@property (nonatomic, assign) PosNoteUseFor userFor;

-(void)getCurretnLiushui:(NSString *)liushui;

-(void)leftTitle:(NSString *)title;
-(void)qianpiType:(int)type;

//撤销支付的流水号
-(void)chexiaozhifuliushui:(NSString *)lastliushui;

@end
