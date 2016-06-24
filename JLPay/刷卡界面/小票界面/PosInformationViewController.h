//
//  PosInformationViewController.h
//  PosN38Universal
//
//  Created by work on 14-9-15.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import <UIKit/UIKit.h>


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

@interface PosInformationViewController : UIViewController

@property(nonatomic,retain)UIImage *posImg;

@property(nonatomic,retain)UIImage *scrollAllImg;

@property (nonatomic, strong) NSDictionary* transInformation;


@property (nonatomic, assign) PosNoteUseFor userFor;

@property (nonatomic, assign) PosNoteUploadState uploadState;


@end
