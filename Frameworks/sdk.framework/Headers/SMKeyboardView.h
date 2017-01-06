//
//  SMKeyboard.h
//  smitsdk
//
//  Created by smit on 15/12/3.
//  Copyright © 2015年 smit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Smit.h"

@class SMKeyboardView;
enum{
    SM_KEY_1=0,
    SM_KEY_2,
    SM_KEY_3,
    SM_KEY_4,
    SM_KEY_5,
    SM_KEY_6,
    SM_KEY_7,
    SM_KEY_8,
    SM_KEY_9,
    SM_KEY_CLEAR,
    SM_KEY_0,
    SM_KEY_OK,
};

@protocol SMKeyboardViewDelegate <NSObject>
@optional
-(void)smKeyboardView:(SMKeyboardView*)view didOK:(NSString*)text;
//-(void)smKeyboardView:(SMKeyboardView*)view changedText:(NSString*)text length:(NSInteger)length;
-(void)smKeyboardView:(SMKeyboardView*)view didCancel:(id)sender;
-(void)smKeyboardView:(SMKeyboardView*)view error:(NSString*)message;
@end

@interface SMKeyboardView : UIView
@property(nonatomic,strong) UIColor* titleTextColor;
@property(nonatomic,strong) UIColor* titleBackgroundColor;
@property(nonatomic,strong) UIColor* passwordTextColor;
@property(nonatomic,strong) UIColor* passwordBackgroundColor;
@property(nonatomic,strong) UIFont* keyFont;
@property(nonatomic,strong) UIColor* keyNumberTextColor;
@property(nonatomic,strong) UIColor* keyFunctionTextColor;
@property(nonatomic,strong) UIColor* keyNumberBackgroundColor;
@property(nonatomic,strong) UIColor* keyFunctionBackgroundColor;
@property(nonatomic,assign) CGFloat dividerSize;
@property(nonatomic,strong) UIColor* dividerColor;
@property(nonatomic,strong) NSString* title;
@property(nonatomic,strong) id<SMKeyboardViewDelegate> delegate;

-(void)setSmit:(Smit*)smit;

@end
