//
//  PosInformationViewController.m
//  PosN38Universal
//
//  Created by work on 14-9-15.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//
#define Screen_Height  [UIScreen mainScreen].bounds.size.height
#define Screen_Width  [UIScreen mainScreen].bounds.size.width

#import "PosInformationViewController.h"

#import "BitmapMaker.h"
#import "JLJBIGEnCoder.h"
#import "JCAlertView.h"

#import "EncodeString.h"
#import "Packing8583.h"
#import "F55Reader.h"


@implementation PosInformationViewController





#pragma mask 0 界面布局
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.92 green:0.93 blue:0.98 alpha:1.0];
    self.title = @"请签名";//@"POS-签购单";
    
    [self loadsSubviews];
    [self addKVOs];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.tabBarController.tabBar.hidden = YES;
    /* 滚动到底部 */
    if (self.userFor == PosNoteUseForUpload) {
        [self.posScrollView scrollRectToVisible:CGRectMake(0, self.posScrollView.contentSize.height - self.posScrollView.frame.size.height, self.posScrollView.frame.size.width, self.posScrollView.frame.size.height) animated:YES];
    }


}

// 视图退出,要取消
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void) addKVOs {
    @weakify(self);
    if (self.userFor == PosNoteUseForUpload) {
        
        RAC(self.rightBarBtn, title) = [RACObserve(self, uploadState) map:^id(NSNumber* state) {
            switch (state.integerValue) {
                case PosNoteUploadStatePreUpload:
                    return @"上传";
                    break;
                case PosNoteUploadStateUploading:
                    return @"正在上传";
                    break;
                case PosNoteUploadStateUploadedFail:
                    return @"重新上传";
                    break;
                case PosNoteUploadStateUploadedSuc:
                    return @"完成";
                    break;
                default:
                    return @"上传";
                    break;
            }
        }];
        RAC(self.rightBarBtn, enabled) = [RACObserve(self, uploadState) map:^id(NSNumber* state) {
            switch (state.integerValue) {
                case PosNoteUploadStatePreUpload:
                case PosNoteUploadStateUploadedFail:
                case PosNoteUploadStateUploadedSuc:
                    return @(YES);
                    break;
                default:
                    return @(NO);
                    break;
            }
        }];
    }
    
    [self.picUploader.cmdUploader.executionSignals subscribeNext:^(RACSignal* sig) {
        [[[sig dematerialize] deliverOnMainThread] subscribeNext:^(id x) {
            @strongify(self);
            self.uploadState = PosNoteUploadStateUploading;
            [self.hud showNormalWithText:@"正在上传签名图片..." andDetailText:nil];
        } error:^(NSError *error) {
            @strongify(self);
            self.uploadState = PosNoteUploadStateUploadedFail;
            [self.hud showFailWithText:@"签名图片上传失败" andDetailText:[error localizedDescription] onCompletion:^{
                
            }];
        } completed:^{
            @strongify(self);
            self.uploadState = PosNoteUploadStateUploadedSuc;
            [self.hud showSuccessWithText:@"上传成功" andDetailText:nil onCompletion:nil];
        }];
    }];
    
}

// 简化代码:label可以用同一个产出方式
- (UILabel*) newTextLabelWithText:(NSString*)text
                          inFrame:(CGRect)frame
                        alignment:(NSTextAlignment)textAlignment
                             font:(UIFont*)font
{
    UILabel* textLabel = [[UILabel alloc] initWithFrame:frame];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.text = text;
    textLabel.textAlignment = textAlignment;
    textLabel.textColor = [UIColor blackColor];
    textLabel.font = font;
    // 设置自动换行
    [textLabel setNumberOfLines:0];
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    return textLabel;
}


# pragma mask 3 IBAction

- (IBAction) clickedOnHandleBtn:(UIButton*)sender {
    
    if (self.userFor == PosNoteUseForUpload) {
        if (self.uploadState == PosNoteUploadStateUploadedSuc) {
            /* 成功则退出到根界面 */
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            /* 失败的重新上传 */
            [self doElecSignPicUpload];
        }
    } else {
        /* 回退到调单界面 */
        for (UIViewController* viewC in self.navigationController.viewControllers) {
            if ([NSStringFromClass([viewC class]) isEqualToString:@"DispatchMaterialUploadViewCtr"]) {
                DispatchMaterialUploadViewCtr* dispatchUploadVC = (DispatchMaterialUploadViewCtr*)viewC;
                dispatchUploadVC.dispatchUploader.signedImage = [self getNormalImage:self.posScrollView];
                [dispatchUploadVC.tableView reloadData];
                [self.navigationController popToViewController:dispatchUploadVC animated:YES];
            }
        }
    }
}

- (IBAction) reSign:(id)sender {
    [self.elecSignView.elecSignView reSign];
}


/* 上传签名图片 */
- (void) doElecSignPicUpload {
    if ([self.rightBarBtn.title isEqualToString:@"上传"]) {
        [self rePackingUploadPackage];
    }
    self.picUploader.pakingInfo = self.transInformation;
    [self.picUploader.cmdUploader execute:nil];
}

- (void) rePackingUploadPackage {
    
    NSMutableDictionary* copyTransInfo = [NSMutableDictionary dictionaryWithDictionary:self.transInformation];
    /* 重设15域 */
    NSString* f15 = [copyTransInfo objectForKey:@"15"];
    NSString* f13 = [copyTransInfo objectForKey:@"13"];
    if (!f15 || f15.length == 0) {
        if (f13 && f13.length > 0) {
            [copyTransInfo setObject:f13 forKey:@"15"];
        } else {
            NSString* curDate = [PublicInformation currentDateAndTime];
            [copyTransInfo setObject:[curDate substringWithRange:NSMakeRange(4, 4)] forKey:@"15"];
        }
    }
    /* 重设55域 */
    [copyTransInfo setObject:[self f55MadeByResponseInfo:self.transInformation] forKey:@"55"];
    
    /* 重设62域 */
    BitmapMaker* bmpMaker = [BitmapMaker new];
    size_t len = 0;
    unsigned char* pbmStr = JLJBIGEncode([bmpMaker bmpFromView:self.elecSignView], bmpMaker.bmpWidth, bmpMaker.bmpHeight, bmpMaker.bmpTotalSize, &len);
    NSMutableString* log = [NSMutableString string];
    for (int i = 0; i < len; i++) {
        [log appendFormat:@"%02x", pbmStr[i]];
    }
    [copyTransInfo setObject:log forKey:@"62"];
    free(pbmStr);
    
    self.transInformation = copyTransInfo;
}

- (NSString*) f55MadeByResponseInfo:(NSDictionary*)responseInfo {
    NSMutableString* f55 = [NSMutableString string];
    
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    
    // FF00 商户名称 M
    NSData* businessNameData = [[PublicInformation returnBusinessName] dataUsingEncoding:gbkEncoding];
    [f55 appendFormat:@"FF00%@", [[PublicInformation ToBHex:(int)businessNameData.length] substringFromIndex:2]];
    Byte* temp = (Byte*)[businessNameData bytes];
    for (int i = 0; i < businessNameData.length; i++) {
        [f55 appendFormat:@"%02x", temp[i]];
    }
    
    // FF01 交易类型 M
    NSString* transType = [responseInfo objectForKey:@"3"];
    if (transType && transType.length > 0) {
        if ([transType isEqualToString:TranType_Consume]) {
            transType = @"消费";
        }
        else if ([transType isEqualToString:TranType_ConsumeRepeal]) {
            transType = @"消费撤销";
        }
        else {
            transType = @"消费";
        }
    } else {
        transType = @"消费";
    }
    NSData* transTypeData = [transType dataUsingEncoding:gbkEncoding];
    [f55 appendFormat:@"FF01%@", [[PublicInformation ToBHex:(int)transTypeData.length] substringFromIndex:2]];
    temp = (Byte*)[transTypeData bytes];
    for (int i = 0; i < transTypeData.length; i++) {
        [f55 appendFormat:@"%02x", temp[i]];
    }
    
    // FF02 操作员号 M
    [f55 appendString:@"FF020101"];
    
    NSString* f44 = [responseInfo objectForKey:@"44"];
    if (f44 && f44.length > 0) {
        // FF03 收单机构 C
        [f55 appendFormat:@"FF03%@%@", [[PublicInformation ToBHex:(int)f44.length/4] substringFromIndex:2], [f44 substringToIndex:f44.length/2]];
        // FF04 发卡机构 C
        [f55 appendFormat:@"FF04%@%@", [[PublicInformation ToBHex:(int)f44.length/4] substringFromIndex:2], [f44 substringFromIndex:f44.length/2]];
    }
    // FF05 有效期 C
    NSString* f14 = [responseInfo objectForKey:@"14"];
    if (f14 && f14.length > 0) {
        [f55 appendFormat:@"FF05%@%@", [[PublicInformation ToBHex:(int)f14.length/2] substringFromIndex:2], f14];
    }
    
    // FF06 日期时间 M YYYYMMDDhhmmss
    NSString* f12 = [responseInfo objectForKey:@"12"];
    NSString* f13 = [responseInfo objectForKey:@"13"];
    f13 = [[[[PublicInformation currentDateAndTime] substringToIndex:4] stringByAppendingString:f13] stringByAppendingString:f12];
    [f55 appendFormat:@"FF06%@%@", [[PublicInformation ToBHex:(int)f13.length/2] substringFromIndex:2], f13];
    
    // FF07 授权码 M YYYYMMDDhhmmss
    NSString* f38 = [responseInfo objectForKey:@"38"];
    if (f38 && f38.length > 0) {
        [f55 appendFormat:@"FF07%@%@", [[PublicInformation ToBHex:(int)f38.length/2] substringFromIndex:2], f38];
    }
    
    // packing origin_F55 infos if IC
    if ([responseInfo objectForKey:@"55"] && [[responseInfo objectForKey:@"55"] length] > 0) {
        NSArray* origin55Subfields = [F55Reader subFieldsReadingByOriginF55:[[self.transInformation objectForKey:@"55"] uppercaseString]];
        
        NSDictionary* node = nil;
        // FF20-FF22
        if ((node = [self getDicFromArray:origin55Subfields OnKey:@"84"])) {
            NSString* keyLen = [node objectForKey:F55SubFieldKeyLen];
            NSString* keyValue = [node objectForKey:F55SubFieldKeyValue];
            if ([keyValue substringFromIndex:keyValue.length - 1].integerValue == 1) {
                [f55 appendString:@"FF200A50424F43204445424954"];
                [f55 appendString:@"FF210A50424F43204445424954"];
            } else {
                [f55 appendString:@"FF200B50424F4320437265646974"];
                [f55 appendString:@"FF210B50424F4320437265646974"];
            }
            // FF22 84
            [f55 appendFormat:@"FF22%@%@", keyLen, keyValue];
        }
        
        if ((node = [self getDicFromArray:origin55Subfields OnKey:@"9F26"])) {
            NSString* keyLen = [node objectForKey:F55SubFieldKeyLen];
            NSString* keyValue = [node objectForKey:F55SubFieldKeyValue];
            [f55 appendFormat:@"FF23%@%@", keyLen, keyValue];
        }
        
        if ((node = [self getDicFromArray:origin55Subfields OnKey:@"9F37"])) {
            NSString* keyLen = [node objectForKey:F55SubFieldKeyLen];
            NSString* keyValue = [node objectForKey:F55SubFieldKeyValue];
            [f55 appendFormat:@"FF26%@%@", keyLen, keyValue];

        }
        if ((node = [self getDicFromArray:origin55Subfields OnKey:@"82"])) {
            NSString* keyLen = [node objectForKey:F55SubFieldKeyLen];
            NSString* keyValue = [node objectForKey:F55SubFieldKeyValue];
            [f55 appendFormat:@"FF27%@%@", keyLen, keyValue];
        }
        if ((node = [self getDicFromArray:origin55Subfields OnKey:@"95"])) {
            NSString* keyLen = [node objectForKey:F55SubFieldKeyLen];
            NSString* keyValue = [node objectForKey:F55SubFieldKeyValue];
            [f55 appendFormat:@"FF28%@%@", keyLen, keyValue];

        }
        if ((node = [self getDicFromArray:origin55Subfields OnKey:@"9F36"])) {
            NSString* keyLen = [node objectForKey:F55SubFieldKeyLen];
            NSString* keyValue = [node objectForKey:F55SubFieldKeyValue];
            [f55 appendFormat:@"FF2A%@%@", keyLen, keyValue];

        }
        if ((node = [self getDicFromArray:origin55Subfields OnKey:@"9F10"])) {
            NSString* keyLen = [node objectForKey:F55SubFieldKeyLen];
            NSString* keyValue = [node objectForKey:F55SubFieldKeyValue];
            [f55 appendFormat:@"FF2B%@%@", keyLen, keyValue];

        }
        
        // FF2F 序列号
        NSString* cardSeqNo = [self.transInformation objectForKey:@"23"];
        NSString* seqNo = [cardSeqNo substringWithRange:NSMakeRange(cardSeqNo.length - 3, 3)];
        [f55 appendFormat:@"FF2F03%@", [EncodeString encodeBCD:seqNo]];
    }

    
    return [f55 uppercaseString];
}

- (NSDictionary*) getDicFromArray:(NSArray*)array OnKey:(NSString*)key {
    NSDictionary* node = nil;
    for (NSDictionary* dic in array) {
        if ([key isEqualToString:[dic objectForKey:F55SubFieldKeyName]]) {
            node = dic;
            break;
        }
    }
    return node;
}




#pragma mark ----------------屏幕截图
//获取当前屏幕内容
- (UIImage *)getNormalImage:(UIScrollView *)view{
    CGRect oldFrame = view.frame;
    view.frame = CGRectMake(0, 0, view.contentSize.width, view.contentSize.height);
    CGSize size = CGSizeMake(view.frame.size.width, view.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, view.opaque, 1.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    img=[UIImage imageWithData:UIImageJPEGRepresentation(img, 0.5)];
    UIGraphicsEndImageContext();
    view.frame = oldFrame;
    return img;
    
}



# pragma mask 3 布局

/* 布局 */
- (void) loadsSubviews {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.navigationItem setRightBarButtonItem:self.rightBarBtn];
    [self.navigationItem setLeftBarButtonItem:self.reSignBarBtn];

    // 小字体
    UIFont* littleFont = [UIFont systemFontOfSize:10.f];
    NSDictionary* littleTextAttri = [NSDictionary dictionaryWithObject:littleFont forKey:NSFontAttributeName];
    // 中字体
    UIFont* midFont = [UIFont systemFontOfSize:17.f];
    NSDictionary* midTextAttri = [NSDictionary dictionaryWithObject:midFont forKey:NSFontAttributeName];
    // 大字体,加粗
    UIFont* bigFont = [UIFont systemFontOfSize:22.f];
    NSDictionary* bigTextAttri = [NSDictionary dictionaryWithObject:bigFont forKey:NSFontAttributeName];
    // 每组 label 之间的间隔
    CGFloat inset = 5.f;
    // 状态栏+导航栏高度
    CGFloat heightStatus = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat heightNavi = self.navigationController.navigationBar.bounds.size.height;
    
    // 小票是滚动视图
    CGRect frame = CGRectMake(0, heightStatus + heightNavi, self.view.bounds.size.width, self.view.bounds.size.height - heightNavi - heightStatus);

    [self.posScrollView setFrame:frame];
    
    
    JLPrint(@"dangqian交易信息节点M:[%@]",self.transInformation);
#pragma mask : 开始加载滚动视图的子视图


    //POS-签购单 商户存根
    NSString* text = @"POS-签购单";
    frame.origin.y = 0;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    UILabel* textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentCenter font:bigFont];
    [self.posScrollView addSubview:textLabel];
    // 商户存根
    text = @"商户存根";
    frame.origin.x = inset;
    frame.origin.y += frame.size.height;
    frame.size.width = self.posScrollView.bounds.size.width - inset*2;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentRight font:midFont];
    [self.posScrollView addSubview:textLabel];
    // 商户存根 - 英文描述
    text = @"MERCHANT COPY";
    frame.origin.y += frame.size.height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentRight font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 商户名称 - 名
    text = @"商户名称(MERCHANT NAME)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 商户名称 - 值
    if (self.userFor == PosNoteUseForUpload) {
        text = [PublicInformation returnBusinessName];
    } else {
        text = [self.transInformation objectForKey:@"businessName"];
    }
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:bigFont];
    [self.posScrollView addSubview:textLabel];
    
    // 商户编号 - 名
    text = @"商户编号(MERCHANT NO)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 商户编号 - 值
    if (self.userFor == PosNoteUseForUpload) {
        text = [PublicInformation returnBusiness];
    } else {
        text = [self.transInformation objectForKey:@"businessNum"];
    }
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 终端编号 - 名 并列
    text = @"终端号(TERMINAL NO)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 终端编号 - 值 并列
    if (self.userFor == PosNoteUseForUpload) {
        text = [PublicInformation returnTerminal];
    } else {
        text = [self.transInformation objectForKey:@"terminal"];
    }
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 卡号 - 名
    text = @"卡号(CARD NO)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 卡号 - 值
    text = [PublicInformation cuttingOffCardNo:[self.transInformation valueForKey:@"2"]];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:bigFont];
    [self.posScrollView addSubview:textLabel];
    
    // 交易类型 - 名
    text = @"交易类型(TRANS TYPE)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 交易类型 - 值
    if (self.userFor == PosNoteUseForUpload) {
        text = [PublicInformation transNameWithCode:[self.transInformation valueForKey:@"3"]];
    } else {
        text = [self.transInformation valueForKey:@"3"];
    }
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:bigFont];
    [self.posScrollView addSubview:textLabel];
    
    // 金额 - 名
    text = @"金额(AMOUNT)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 金额 - 值
    text = @"RMB: ";
    text = [text stringByAppendingString:[PublicInformation dotMoneyFromNoDotMoney:[self.transInformation valueForKey:@"4"]]];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:bigTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:bigFont];
    [self.posScrollView addSubview:textLabel];
    
    // 日期/时间 - 名
    text = @"日期/时间(DATE/TIME)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 日期/时间 - 值
    NSMutableString* detailDate = [[NSMutableString alloc] init];
    if (self.userFor == PosNoteUseForUpload) {
        [detailDate appendString:[[PublicInformation nowDate] substringToIndex:4]];
    } else {
        [detailDate appendString:[[self.transInformation valueForKey:@"13"] substringToIndex:4]];
    }
    [detailDate appendString:@"/"];
    if (self.userFor == PosNoteUseForUpload) {
        [detailDate appendString:[[self.transInformation valueForKey:@"13"] substringToIndex:2]];
    } else {
        [detailDate appendString:[[self.transInformation valueForKey:@"13"] substringWithRange:NSMakeRange(4, 2)]];
    }
    [detailDate appendString:@"/"];
    if (self.userFor == PosNoteUseForUpload) {
        [detailDate appendString:[[self.transInformation valueForKey:@"13"] substringFromIndex:2]];
    } else {
        [detailDate appendString:[[self.transInformation valueForKey:@"13"] substringWithRange:NSMakeRange(6, 2)]];
    }
    [detailDate appendString:@" "];
    [detailDate appendString:[[self.transInformation valueForKey:@"12"] substringToIndex:2]];
    [detailDate appendString:@":"];
    [detailDate appendString:[[self.transInformation valueForKey:@"12"] substringWithRange:NSMakeRange(2, 2)]];
    [detailDate appendString:@":"];
    [detailDate appendString:[[self.transInformation valueForKey:@"12"] substringFromIndex:4]];
    text = (NSString*)detailDate;
    
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    
    // 发卡行号 - 名
    text = @"发卡行号(ISS NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 发卡行号 - 值
    NSString* f44 = [PublicInformation stringFromHexString:[self.transInformation valueForKey:@"44"]];
    text = [f44 substringToIndex:f44.length/2];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 收单行号 - 名
    text = @"收单行号(ACQ NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 收单行号 - 值
    text = [f44 substringFromIndex:f44.length/2];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 批次号 - 名
    text = @"批次号(BATCH NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 批次号 - 值
    if (self.userFor == PosNoteUseForUpload) {
        text = [PublicInformation returnSignSort];
    } else {
        text = nil;
    }
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 凭证号 - 名
    text = @"凭证号(VOUCHER NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 凭证号 - 值
    text = [self.transInformation valueForKey:@"11"];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 授权码 - 名
    text = @"授权码(AUTH NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 授权码 - 值
    text = [self.transInformation valueForKey:@"38"];
    if (text == nil || [text isEqualToString:@""]) text = @" ";
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 交易参考号 - 名
    text = @"交易参考号(REFER NO)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 交易参考号 - 值
    text = [self.transInformation valueForKey:@"37"];
    if (self.userFor == PosNoteUseForUpload) {
        text = [PublicInformation stringFromHexString:text];
    }
    
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 有效期 - 名
    text = @"有效期(EXP DATE)";
    frame.origin.y += frame.size.height + inset;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 有效期 - 值
    text = [self.transInformation valueForKey:@"14"];
    frame.origin.y += frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    
    // 备注 - 名
    text = @"备注(REFERENCE)";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 备注 - 值
    text = @" ";
    frame.origin.y += frame.size.height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    // 持卡人签名 - 名
    text = @"持卡人签名(CARDHOLDER SIGNATURE):";
    frame.origin.y += inset + frame.size.height;
    frame.size.height = [text sizeWithAttributes:midTextAttri].height;
    // 重置高度:根据文本的长度跟frame.width的比例
    if ([text sizeWithAttributes:midTextAttri].width > frame.size.width) {
        CGFloat sizeWidth = [text sizeWithAttributes:midTextAttri].width;
        int n = (int)(sizeWidth/frame.size.width);
        frame.size.height *= n;
    }
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:midFont];
    [self.posScrollView addSubview:textLabel];
    // 持卡人签名 - 图片
    frame.origin.y += inset + frame.size.height;
    
    frame.size.height = 256;
    frame.size.width = (self.view.frame.size.width >= 600) ? (600) : (self.view.frame.size.width);
    if (self.view.frame.size.width < 237) {
        frame.size.width = 237;
    }
    else if (self.view.frame.size.width >= 600) {
        frame.size.width = 600;
    }
    frame.size.width = self.view.frame.size.width;
    frame.origin.x = (self.view.frame.size.width - frame.size.width)/2;
//    NSInteger intWidth = frame.size.width / 3 / 2;
//    frame.size.width = (CGFloat)(intWidth * 3 * 2);
//    frame.size.height = frame.size.width * (300.f/600.f);//(posImg.size.height/posImg.size.width);
    
    
    self.elecSignView.frame = frame;
    [self.posScrollView addSubview:self.elecSignView];
    
    // 描述信息
    text = @"本人确认以上交易,同意将其计入本卡账户.";
    frame.origin.x = 0;
    frame.origin.y += inset + frame.size.height;
    frame.size.width = self.posScrollView.frame.size.width;
    frame.size.height = [text sizeWithAttributes:littleTextAttri].height;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    // 英文描述
    text = @"I ACKNOWLEDGE SATISFATORY RECEIPT OF RELATIVE GOODS/SERVICES.";
    frame.origin.y += frame.size.height;
    frame.size.height *= 2.0;
    textLabel = [self newTextLabelWithText:text inFrame:frame alignment:NSTextAlignmentLeft font:littleFont];
    [self.posScrollView addSubview:textLabel];
    
    
    frame.origin.y += inset + frame.size.height;
    self.posScrollView.contentSize = CGSizeMake(Screen_Width, frame.origin.y); // 高度要重新定义
    [self.view addSubview:self.posScrollView];
    
    
    [self.view addSubview:self.hud];

}



#pragma mask ::: setter && getter


- (UIBarButtonItem *)rightBarBtn {
    if (!_rightBarBtn) {
        _rightBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(clickedOnHandleBtn:)];
    }
    return _rightBarBtn;
}

- (UIBarButtonItem *)reSignBarBtn {
    if (!_reSignBarBtn) {
        _reSignBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"重签" style:UIBarButtonItemStylePlain target:self action:@selector(reSign:)];
    }
    return _reSignBarBtn;
}

- (UIScrollView *)posScrollView {
    if (!_posScrollView) {
        _posScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _posScrollView.backgroundColor = [UIColor whiteColor];
        _posScrollView.bounces = NO;
    }
    return _posScrollView;
}


- (ElecSignFrameView *)elecSignView {
    if (!_elecSignView) {
        _elecSignView = [[ElecSignFrameView alloc] initWithFrame:CGRectZero];
        _elecSignView.backgroundColor = [UIColor clearColor];
        NSString* transDate = [self.transInformation objectForKey:@"13"];
        NSString* refNo = [PublicInformation stringFromHexString:[self.transInformation objectForKey:@"37"]];
        
        NSString* preStr = [[transDate stringByAppendingString:refNo] substringToIndex:8];
        NSString* sufStr = [[transDate stringByAppendingString:refNo] substringFromIndex:8];
        
        NSMutableString* codeStr = [NSMutableString string];
        for (int i = 0; i < 8; i++) {
            int preInt = [[preStr substringWithRange:NSMakeRange(i, 1)] intValue];
            int sufInt = [[sufStr substringWithRange:NSMakeRange(i, 1)] intValue];
            [codeStr appendString:[PublicInformation NoPreZeroHexStringFromInt:preInt ^ sufInt]];
        }
        _elecSignView.keyElementLabel.text = [codeStr uppercaseString];

    }
    return _elecSignView;
}

- (VMElecSignPicUploader *)picUploader {
    if (!_picUploader) {
        _picUploader = [[VMElecSignPicUploader alloc] init];
        _picUploader.pakingInfo = self.transInformation;
        
    }
    return _picUploader;
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _hud;
}

@end
