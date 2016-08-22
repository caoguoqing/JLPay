//
//  PosInformationViewController.h
//  PosN38Universal
//
//  Created by work on 14-9-15.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ElecSignFrameView.h"
#import "Define_Header.h"
#import "ASIFormDataRequest.h"
#import "Toast+UIView.h"
#import "JsonToString.h"
#import "MBProgressHUD+CustomSate.h"
#import "DispatchMaterialUploadViewCtr.h"
#import <ReactiveCocoa.h>
#import "VMElecSignPicUploader.h"

#import "BitmapMaker.h"

typedef enum {
    PosNoteUseForUpload,        /* 用作上传 */
    PosNoteUseForDispatch       /* 用作调单 */
} PosNoteUseFor;

typedef enum {
    PosNoteUploadStatePreUpload,            /* 未上传 */
    PosNoteUploadStateUploading,            /* 正在上传 */
    PosNoteUploadStateUploadedFail,         /* 上传失败 */
    PosNoteUploadStateUploadedSuc           /* 上传成功 */
}PosNoteUploadState;



@class AppDelegate;

@interface PosInformationViewController : UIViewController <ASIHTTPRequestDelegate>


@property (nonatomic, assign) PosNoteUseFor userFor;                        /* 本界面的显示作用 */

@property (nonatomic, copy) NSDictionary* transInformation;                 /* 交易信息 */

@property (nonatomic, assign) PosNoteUploadState uploadState;               /* 上传状态 */

@property (nonatomic, strong) UIScrollView* posScrollView;                  /* 小票视图(滚动视图) */

@property (nonatomic, strong) ElecSignFrameView* elecSignView;              /* 签名视图 */

//@property (nonatomic, strong) ASIFormDataRequest *uploadRequest;            /* 上传接口 */

//@property (nonatomic, strong) UIProgressView* progressView;                 /* 上传进度条 */

@property (nonatomic, strong) UIBarButtonItem* rightBarBtn;                 /* 上传按钮 */

@property (nonatomic, strong) UIBarButtonItem* reSignBarBtn;                /* 重签按钮 */

@property (nonatomic, strong) MBProgressHUD* hud;

@property (nonatomic, strong) VMElecSignPicUploader* picUploader;

@end
