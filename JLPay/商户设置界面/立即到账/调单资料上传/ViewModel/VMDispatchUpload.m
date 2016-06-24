//
//  VMDispatchUpload.m
//  JLPay
//
//  Created by jielian on 16/5/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMDispatchUpload.h"
#import "ImageMaterialCapCell.h"
#import "MDispatchOrderDetail.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>
#import "MD5Util.h"
#import "QianPiViewController.h"
#import "RepeatSignCell.h"

@implementation VMDispatchUpload

- (instancetype)init {
    self = [super init];
    if (self) {
        NameWeakSelf(wself);
        [RACObserve(self, commandImgPicker) subscribeNext:^(id x) {
            [wself modelsOnRACCommands];
        }];
    }
    return self;
}
- (void)dealloc {
    JLPrint(@"----------VMDispatchUpload dealloc---------");
}


# pragma mask 1 RACCommands
- (void) modelsOnRACCommands {
    @weakify(self);
    [self.commandImgPicker.executionSignals subscribeNext:^(RACSignal* sig) {
        [[sig dematerialize] subscribeNext:^(NSArray* imgs) {
            @strongify(self);
            [self.imagesPicked addObjectsFromArray:imgs];
            self.imgCount = self.imagesPicked.count;
        } error:^(NSError *error) {
        } completed:^{
        }];
    }];
}


# pragma mask 2 UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3 + 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return self.titlesOfCell.count;
            break;
        default:
            return 1;
            break;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifierAtIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self newCellAtIndexPath:indexPath];
    }
    
    [self setDatasToCell:cell AtIndexPath:indexPath];
    
    return cell;
}

# pragma mask 2 UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        CGFloat uniteHeight = (tableView.frame.size.width - 15 * 2 - 5 * 2) / 3;
        NSInteger imgCount = self.imagesPicked.count + 1;
        return ((imgCount%3 == 0)?(imgCount/3):(imgCount/3 + 1)) * (uniteHeight + 5) + 5;
    }
    else if (indexPath.section == 2) {
        return 200;
    }
    else {
        return 40;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        return YES;
    } else {
        return NO;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        [self doPushVCToQianPi];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
        {
            NSString* refuse = [self.originDispatchDetail refuseReason];
            NSString* reason = [self.originDispatchDetail dispatchReason];
            NSString* detail = [self.originDispatchDetail dispatchExplain];
            if (refuse && refuse.length > 0) {
                return refuse;
            } else {
                return (detail)?([reason stringByAppendingFormat:@"(%@)",detail]):(reason);
            }
        }
            break;
        default:
            return @"";
            break;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 2:
        {
            return @"重签小票(视需要选择是否重签)";
        }
            break;
        case 3:
            return @"请拍照或上传调单资料图片";
            break;
        default:
            return @"";
            break;
    }
}


# pragma mask 3 push to QianPiViewC
- (void) doPushVCToQianPi {
    QianPiViewController  *qianpi=[[QianPiViewController alloc] initWithNibName:nil bundle:nil];
    [qianpi qianpiType:1];
    [qianpi leftTitle:self.originDispatchDetail.transMoney];
    NSMutableDictionary* transInformation = [NSMutableDictionary dictionary];
    [transInformation setObject:self.originDispatchDetail.businessName forKey:@"businessName"];
    [transInformation setObject:self.originDispatchDetail.businessNo forKey:@"businessNum"];
    [transInformation setObject:self.originDispatchDetail.terminalNo forKey:@"terminal"];
    [transInformation setObject:self.originDispatchDetail.cardNo forKey:@"2"];
    [transInformation setObject:self.originDispatchDetail.transType forKey:@"3"];
    [transInformation setObject:[PublicInformation intMoneyFromDotMoney:self.originDispatchDetail.transMoney] forKey:@"4"];
    [transInformation setObject:self.originDispatchDetail.seqNo forKey:@"11"];
    [transInformation setObject:[self.originDispatchDetail.originDateAndTime substringToIndex:8] forKey:@"13"];
    [transInformation setObject:[self.originDispatchDetail.originDateAndTime substringFromIndex:8] forKey:@"12"];
    [transInformation setObject:self.originDispatchDetail.referenceNo forKey:@"37"];

    [qianpi setTransInformation:transInformation];
    qianpi.userFor = PosNoteUseForDispatch;
    if (self.pushQianPiVCBlock) {
        self.pushQianPiVCBlock(qianpi);
    }
}


# pragma mask 3 tools for UITableView

- (NSString*) cellIdentifierAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == 3) {
        return @"imgCellId";
    }
    else if (indexPath.section == 2) {
        return @"signCellId";
    }
    else {
        return @"normalCellId";
    }
}

- (UITableViewCell*) newCellAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == 3) {
        ImageMaterialCapCell* imgCell = [[ImageMaterialCapCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[self cellIdentifierAtIndexPath:indexPath]];
        imgCell.addButton.rac_command = self.commandImgPicker;
        return imgCell;
    }
    else if (indexPath.section == 2) {
        return [[RepeatSignCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[self cellIdentifierAtIndexPath:indexPath]];
    }
    else {
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[self cellIdentifierAtIndexPath:indexPath]];
    }
}

- (void) setDatasToCell:(UITableViewCell*)cell AtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == 0) {
        cell.textLabel.text = @"调单状态:";
        if (self.originDispatchDetail.checkedFlag == 0) {
            cell.detailTextLabel.textColor = [UIColor colorWithHex:HexColorTypeGreen alpha:1];
            cell.detailTextLabel.text = @"已审核";
        }
        else if (self.originDispatchDetail.checkedFlag == 1) {
            if (self.originDispatchDetail.uploadted) {
                cell.detailTextLabel.text = @"审核中";
            } else {
                cell.detailTextLabel.text = @"未上传调单资料";
                cell.detailTextLabel.textColor = [UIColor colorWithHex:HexColorTypeLightOrangeRed alpha:1];
            }
        }
        else if (self.originDispatchDetail.checkedFlag == 2) {
            cell.detailTextLabel.textColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
            cell.detailTextLabel.text = @"审核未通过";
        }
    }
    else if (indexPath.section == 1) {
        NSString* title = [self.titlesOfCell objectAtIndex:indexPath.row];
        cell.textLabel.text = title;
        if ([title isEqualToString:@"卡号:"]) {
            cell.detailTextLabel.text = [self.originDispatchDetail cardNo];
        }
        else if ([title isEqualToString:@"交易金额:"]) {
            cell.detailTextLabel.text = [@"￥" stringByAppendingString:[self.originDispatchDetail transMoney]];
        }
        else if ([title isEqualToString:@"交易类型:"]) {
            cell.detailTextLabel.text = [self.originDispatchDetail transType];
        }
        else if ([title isEqualToString:@"交易日期:"]) {
            cell.detailTextLabel.text = [self.originDispatchDetail transDate];
        }
        else if ([title isEqualToString:@"交易时间:"]) {
            cell.detailTextLabel.text = [self.originDispatchDetail transTime];
        }
        else if ([title isEqualToString:@"交易参考号:"]) {
            cell.detailTextLabel.text = [self.originDispatchDetail referenceNo];
        }
        else if ([title isEqualToString:@"商户名:"]) {
            cell.detailTextLabel.text = [self.originDispatchDetail businessName];
        }
        else if ([title isEqualToString:@"商户号:"]) {
            cell.detailTextLabel.text = [self.originDispatchDetail businessNo];
        }
        else if ([title isEqualToString:@"终端号:"]) {
            cell.detailTextLabel.text = [self.originDispatchDetail terminalNo];
        }
    }
    else if (indexPath.section == 2) {
        RepeatSignCell* signedCell = (RepeatSignCell*)cell;
        if (self.signedImage) {
            signedCell.signImgView.image = self.signedImage;
        }
    }
    else {
        ImageMaterialCapCell* imgCell = (ImageMaterialCapCell*)cell;
        [imgCell.imgViewListCaptured removeAllObjects];
        for (UIImage* image in self.imagesPicked) {
            [imgCell.imgViewListCaptured addObject:[[UIImageView alloc] initWithImage:image]];
        }
        [imgCell setNeedsDisplay];
    }
}


# pragma mask 4 getter
- (NSArray *)titlesOfCell {
    if (!_titlesOfCell) {
        _titlesOfCell = @[@"卡号:",
                          @"交易金额:",
                          @"交易类型:",
                          @"交易日期:",
                          @"交易时间:",
                          @"交易参考号:",
                          @"商户名:",
                          @"商户号:",
                          @"终端号:"];
    }
    return _titlesOfCell;
}
- (NSMutableArray *)imagesPicked {
    if (!_imagesPicked) {
        _imagesPicked = [NSMutableArray array];
    }
    return _imagesPicked;
}
- (RACCommand *)commandDispatchUpload {
    if (!_commandDispatchUpload) {
        @weakify(self);
        RACSignal* imgCountEnabelSig = [RACObserve(self, imgCount) map:^id(NSNumber* count) {
            if (count.integerValue > 0) {
                return @(YES);
            } else {
                return @(NO);
            }
        }];
        RACSignal* signImgExitsSig = [RACObserve(self, signedImage) map:^id(UIImage* image) {
            if (image) {
                return @(YES);
            } else {
                return @(NO);
            }
        }];
        
        RACSignal* sigUploadEnable = [RACSignal combineLatest:@[imgCountEnabelSig,signImgExitsSig] reduce:^id(NSNumber* enable, NSNumber* exist){
            return @(enable.boolValue | exist.boolValue);
        }];
        
        _commandDispatchUpload = [[RACCommand alloc] initWithEnabled:sigUploadEnable signalBlock:^RACSignal *(id input) {
            return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [subscriber sendNext:nil];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self.httpUpload requestingOnPackingHandle:^(ASIFormDataRequest *http) {
                        @strongify(self);
                        
                        NSMutableString* source = [NSMutableString string];
                        
                        /* 商户号 */
                        [http addPostValue:[PublicInformation returnBusiness] forKey:@"mchtNo"];
                        [source appendFormat:@"mchtNo=%@&",[PublicInformation returnBusiness]];
                        
                        /* 参考号 */
                        if (self.originDispatchDetail.referenceNo && self.originDispatchDetail.referenceNo.length > 0) {
                            [http addPostValue:self.originDispatchDetail.referenceNo forKey:@"retrivlRef"];
                            [source appendFormat:@"retrivlRef=%@&",self.originDispatchDetail.referenceNo];
                        }
                        
                        /* 交易时间 */
                        [http addPostValue:self.originDispatchDetail.originDateAndTime forKey:@"tradeTime"];
                        [source appendFormat:@"tradeTime=%@&",self.originDispatchDetail.originDateAndTime];
                        
                        /* 资料图片组 */
                        for (int i = 1; i <= self.imgCount; i++) {
                            UIImage* originImg = [self.imagesPicked objectAtIndex:i - 1];
                            NSData* imgData = UIImageJPEGRepresentation(originImg, 0.1);
                            [http addPostValue:[imgData base64EncodedStringWithOptions:0] forKey:[NSString stringWithFormat:@"pic_%d",i]];
                        }
                        
                        /* 图片个数 & 小票 */
                        if (self.signedImage) {
                            [http addPostValue:[NSString stringWithFormat:@"%ld",self.imgCount + 1] forKey:@"picCount"];
                            [source appendFormat:@"picCount=%ld&", self.imgCount + 1];
                            
                            [http addPostValue:[UIImageJPEGRepresentation(self.signedImage, 0.1) base64EncodedStringWithOptions:0] forKey:[NSString stringWithFormat:@"pic_%ld",self.imgCount + 1]];
                        } else {
                            [http addPostValue:[NSString stringWithFormat:@"%ld",self.imgCount] forKey:@"picCount"];
                            [source appendFormat:@"picCount=%ld&", self.imgCount];
                        }
                        
                        /* MD5 */
                        [source appendString:@"key=shisongcheng"];
                        [http addPostValue:[MD5Util encryptWithSource:source] forKey:@"sign"];
                        
                    } onSucBlock:^(NSDictionary *info) {
                        [subscriber sendCompleted];
                    } onErrBlock:^(NSError *error) {
                        [subscriber sendError:error];
                    }];
                });
                
                return nil;
            }] replayLast] materialize];
        }];;
    }
    return _commandDispatchUpload;
}
- (HTTPInstance *)httpUpload {
    if (!_httpUpload) {
        NSString* url = [NSString stringWithFormat:@"http://%@:%@/jlagent/dispatchDataUpload",
                         [PublicInformation getServerDomain], [PublicInformation getHTTPPort]];
        _httpUpload = [[HTTPInstance alloc] initWithURLString:url];
    }
    return _httpUpload;
}

@end
