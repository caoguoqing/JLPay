//
//  BVC_vmPackageTransformer.m
//  JLPay
//
//  Created by jielian on 2016/11/17.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "BVC_vmPackageTransformer.h"
#import "F55Reader.h"
#import "Unpacking8583.h"
#import "Packing8583.h"
#import <ReactiveCocoa.h>
#import "ModelTCPTransPacking.h"
#import "Define_Header.h"
#import "ImageHelper.h"
#import "JLElecSignController.h"
#import "JLJBIGEnCoder.h"
#import "MTransMoneyCache.h"

@interface BVC_vmPackageTransformer()

@property (nonatomic, strong) NSMutableDictionary* consumeTransData;
@property (nonatomic, strong) NSDictionary* elecSignTransData;


@end


@implementation BVC_vmPackageTransformer


- (NSString *)macSourceMaking {
    self.sIntMoney = [NSString stringWithFormat:@"%012ld", [MTransMoneyCache sharedMoney].curMoneyUniteMinute];
    [[ModelTCPTransPacking sharedModel] packingFieldsInfo:self.consumeTransData forTransType:TranType_Consume];
    return [[ModelTCPTransPacking sharedModel] getMacStringAfterPacking];
}

- (NSString *)consumeMessageMaking {
    [[ModelTCPTransPacking sharedModel] repackingWithMacPin:self.macCalculated];
    return [[ModelTCPTransPacking sharedModel] packageFinalyPacking];
}

- (NSString *)elecSignMessageMaking {
    NSMutableDictionary* data = [NSMutableDictionary dictionaryWithDictionary:self.consumeResponseInfo];
    // 添加55域等信息，如果为ic卡
    if (self.cardIsIC) {
        [data setObject:[self.cardInfo objectForKey:@"55"] forKey:@"55"];
        [data setObject:[self.cardInfo objectForKey:@"23"] forKey:@"23"];
        NSString* f14 = [self.cardInfo objectForKey:@"14"];
        [data setObject:((f14 && f14.length > 0)?(f14):(@"")) forKey:@"14"];
    }
    // 重置
    self.elecSignTransData = [self repackElecSignData:data];

    /*
     * 在上一步里面调用 JBIGEncode 之后
     */
    [[ModelTCPTransPacking sharedModel] packingFieldsInfo:self.elecSignTransData forTransType:TranType_ElecSignPicUpload];
    return [[ModelTCPTransPacking sharedModel] packageFinalyPacking];
}


- (instancetype)init {
    self = [super init];
    if (self) {
        @weakify(self);
        /* 消费报文域数据 */
        RAC(self, consumeTransData) = [RACObserve(self, cardInfo) map:^id(NSDictionary* cardInfo) {
            if (cardInfo && cardInfo.count > 0) {
                NSMutableDictionary* data = [NSMutableDictionary dictionaryWithDictionary:cardInfo];
                NSString* pin = [data objectForKey:@"52"];
                if (!pin || pin.length == 0) {
                    [data setObject:@"0600000000000000" forKey:@"53"];
                }
                return data;
            } else {
                return nil;
            }
        }];
        
        
        /* 特征码 */
        RAC(self, characteristicCode) = [RACObserve(self, consumeResponseInfo) map:^id(NSDictionary* responseInfo) {
            if (responseInfo && responseInfo.count > 0) {
                NSString* transDate = [responseInfo objectForKey:@"13"];
                NSString* refNo = [PublicInformation stringFromHexString:[responseInfo objectForKey:@"37"]];
                
                NSString* preStr = [[transDate stringByAppendingString:refNo] substringToIndex:8];
                NSString* sufStr = [[transDate stringByAppendingString:refNo] substringFromIndex:8];
                
                NSMutableString* codeStr = [NSMutableString string];
                for (int i = 0; i < 8; i++) {
                    int preInt = [[preStr substringWithRange:NSMakeRange(i, 1)] intValue];
                    int sufInt = [[sufStr substringWithRange:NSMakeRange(i, 1)] intValue];
                    [codeStr appendString:[PublicInformation NoPreZeroHexStringFromInt:preInt ^ sufInt]];
                }
                return codeStr;
            } else {
                return nil;
            }
        }];
        
        /* 交易金额: f4 */
        [RACObserve(self, sIntMoney) subscribeNext:^(NSString* sIntMoney) {
            @strongify(self);
            if (sIntMoney && sIntMoney.length > 0) {
                [self.consumeTransData setObject:sIntMoney forKey:@"4"];
            }
        }];
        
        /* 密码: 52,53 */
        [RACObserve(self, pinEncrypted) subscribeNext:^(NSString* pin) {
            @strongify(self);
            if (pin && pin.length > 0) {
                NSMutableString* f22 = [NSMutableString stringWithString:[self.consumeTransData objectForKey:@"22"]];
                [f22 replaceCharactersInRange:NSMakeRange(2, 1) withString:@"1"];
                [self.consumeTransData setObject:f22 forKey:@"22"];
                [self.consumeTransData setObject:pin forKey:@"52"];
                [self.consumeTransData setObject:@"2600000000000000" forKey:@"53"];
            }
        }];
        
        
        /* 是否ic卡: out */
        RAC(self, cardIsIC) = [RACObserve(self, cardInfo) map:^id(NSDictionary* cardInfo) {
            NSString* f22 = [cardInfo objectForKey:@"22"];
            if ([f22 hasPrefix:@"02"]) {
                return @(NO);
            } else {
                return @(YES);
            }
        }];
        
    }
    return self;
}



# pragma mask 3 tools 
- (NSDictionary*) repackElecSignData:(NSDictionary*)data {
    
    NSMutableDictionary* copyTransInfo = [NSMutableDictionary dictionaryWithDictionary:data];
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
    [copyTransInfo setObject:[self f55MadeByResponseInfo:data] forKey:@"55"];
    
    /* 重设62域 */
    [copyTransInfo setObject:[self f62MadeByElecsignView] forKey:@"62"];
    
    return copyTransInfo;
}


- (NSString*) f62MadeByElecsignView {
    UIImage* image = [ImageHelper elecSignImgWithView:[JLElecSignController sharedElecSign].elecSignView];
    unsigned char* bmpStr = [ImageHelper convertUIImageToBitmapRGBA8:image];
    size_t len = 0;
    unsigned char* elecsignStr = JLJBIGEncode(bmpStr, image.size.width, image.size.height, &len);
    NSMutableString* f62 = [NSMutableString string];
    for (int i = 0; i < len; i++) {
        [f62 appendFormat:@"%02x", elecsignStr[i]];
    }
    free(bmpStr);
    free(elecsignStr);
    return f62;
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
        NSArray* origin55Subfields = [F55Reader subFieldsReadingByOriginF55:[[responseInfo objectForKey:@"55"] uppercaseString]];
        
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
        NSString* cardSeqNo = [responseInfo objectForKey:@"23"];
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

- (NSString *)sIntMoney {
    if (!_sIntMoney) {
        _sIntMoney = [NSString stringWithFormat:@"%012ld", [MTransMoneyCache sharedMoney].curMoneyUniteMinute];
    }
    return _sIntMoney;
}


@end
