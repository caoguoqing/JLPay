//
//  EncodeString.m
//  PosSwipeCard
//
//  Created by work on 14-6-30.
//  Copyright (c) 2014年 ggwl. All rights reserved.
//

#import "EncodeString.h"

@implementation EncodeString


+ (NSString *)encodeBCD:(NSString *)bcdStr{
    NSData *data = [bcdStr dataUsingEncoding:NSUTF8StringEncoding];
    Byte *aaa = (Byte *)[data bytes];
    NSMutableString * str_tmp = [[NSMutableString alloc]init];
    NSString * ccc = @"0123456789ABCDEF";
    for (int i=0; i<data.length; i++) {
        str_tmp = (NSMutableString *)[str_tmp stringByAppendingFormat:@"%c",(char )[ccc characterAtIndex:((aaa[i] & 0xf0) >> 4)]];
        str_tmp = (NSMutableString *)[str_tmp stringByAppendingFormat:@"%c",(char )[ccc characterAtIndex:((aaa[i] & 0xf) >> 0)]];
    }
    return str_tmp;
}

+ (NSString *)encodeASC:(NSString *)ascStr{
    NSData* aData = [ascStr dataUsingEncoding: NSASCIIStringEncoding];
    Byte *aaa = (Byte *)[aData bytes];
    NSMutableString * str_tmp = [[NSMutableString alloc]init];
    NSString * ccc = @"0123456789ABCDEF";
    for (int i=0; i<aData.length; i++) {
        str_tmp = (NSMutableString *)[str_tmp stringByAppendingFormat:@"%c",(char )[ccc characterAtIndex:((aaa[i] & 0xf0) >> 4)]];
        str_tmp = (NSMutableString *)[str_tmp stringByAppendingFormat:@"%c",(char )[ccc characterAtIndex:((aaa[i] & 0xf) >> 0)]];
    }
    return str_tmp;
}


+(NSData *)newBcd:(NSString *)value{
    
    NSMutableData *vdata = [[NSMutableData alloc] init];
    __uint8_t bytes[1] = {6};
    [vdata appendBytes:&bytes length:1];
    NSRange range;
    range.location = 0;
    range.length = 1;
    for (int i = 0; i < [value length];) {
        range.location = i;
        NSString *temp = [value substringWithRange:range];
        int _intvalue1 = [temp intValue];
        _intvalue1 = _intvalue1 << 4;
        range.location = i + 1;
        temp = [value substringWithRange:range];
        int _intvalue2 = [temp intValue];
        int intvalue = _intvalue1 | _intvalue2;
        bytes[0] = intvalue;
        [vdata appendBytes:&bytes length:1];
        i += 2;
    }
    bytes[0] = 255;
    [vdata appendBytes:&bytes length:1];
    bytes[0] = 255;
    [vdata appendBytes:&bytes length:1];
    bytes[0] = 255;
    [vdata appendBytes:&bytes length:1];
    bytes[0] = 255;
    [vdata appendBytes:&bytes length:1];
    return vdata;

}

@end
