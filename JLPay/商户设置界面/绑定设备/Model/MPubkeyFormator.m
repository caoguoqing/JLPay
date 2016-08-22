//
//  MPubkeyFormator.m
//  JLPay
//
//  Created by jielian on 16/8/10.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MPubkeyFormator.h"
#import "RSAEncoder.h"
#import "Define_Header.h"

@interface MPubkeyFormator()

@property (nonatomic, copy) NSString* oldPubkey;

@end

@implementation MPubkeyFormator

- (instancetype)initWithPublicKey:(NSString *)pubkey {
    self = [super init];
    if (self) {
        self.oldPubkey = pubkey;
    }
    return self;
}


- (NSString *)preData {
    if (!_preData) {
        /*
         note: 应该要修改下;不要写死了;
         */
        NSString* temp = [self.oldPubkey substringFromIndex:2];
        NSRange rangeDF05 = [temp rangeOfString:@"DF05"];
        _preData = [temp substringToIndex:rangeDF05.location];
    }
    return _preData;
}

- (NSString *)sufData {
    if (!_sufData) {
        NSString* temp = [self.oldPubkey substringFromIndex:2];
        NSRange rangeDF03 = [temp rangeOfString:@"DF03"];
        _sufData = [temp substringFromIndex:rangeDF03.location];
    }
    return _sufData;
}

- (NSString *)keyData {
    if (!_keyData) {
        NSString* temp = [self.oldPubkey substringFromIndex:2];
        NSRange rangeDF02 = [temp rangeOfString:@"DF02"];
        NSRange rangeDF03 = [temp rangeOfString:@"DF03"];
        temp = [temp substringWithRange:NSMakeRange(rangeDF02.location, rangeDF03.location - rangeDF02.location)];
        temp = [temp substringFromIndex:4];
        if ([[temp substringToIndex:2] isEqualToString:@"81"]) {
            temp = [temp substringFromIndex:2];
        }
        temp = [temp substringFromIndex:2];
        _keyData = temp;
    }
    return _keyData;
}

- (NSString *)repackedPubkey {
    if (!_repackedPubkey) {
        NSString* newKeyData = [RSAEncoder encodingPubkey:self.keyData];
        _repackedPubkey = [self.preData stringByAppendingFormat:@"DF998180%@",newKeyData];
    }
    return _repackedPubkey;
}

@end
