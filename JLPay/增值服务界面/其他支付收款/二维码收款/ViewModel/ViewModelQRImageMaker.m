//
//  ViewModelQRImageMaker.m
//  JLPay
//
//  Created by jielian on 15/11/3.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ViewModelQRImageMaker.h"

@implementation ViewModelQRImageMaker

#pragma mask ---- 根据传入的二维码值生成二维码图片
+ (UIImage*) imageForQRCode:(NSString*)QRCode {
    UIImage* image = nil;
    CIImage* ciimage = [self ciimageForQRCode:QRCode];
    image = [self imageResizeWithCIImage:ciimage inSize:300];
    return image;
}

/* CIImage生成 */
+ (CIImage*) ciimageForQRCode:(NSString*)QRCode {
    NSData* data = [QRCode dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter* QRFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容+纠错级别
    [QRFilter setValue:data forKey:@"inputMessage"];
    [QRFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // CIImage
    return [QRFilter outputImage];
}

/* 定制图片大小 */
+ (UIImage*) imageResizeWithCIImage:(CIImage*)ciimage inSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(ciimage.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, kCGImageAlphaNone);
    
    CIContext* context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:ciimage fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);

    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
}


@end
