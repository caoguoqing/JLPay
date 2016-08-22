//
//  BitmapMaker.m
//  JLPay
//
//  Created by jielian on 16/7/22.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "BitmapMaker.h"

@implementation BitmapMaker

- (unsigned char* ) bmpFromView:(UIView*)view {
    
    return [self convertUIImageToBitmapRGBA8:[self imageForView:view]];
}

- (UIImage*) imageForView:(UIView*)view {
    float width = view.frame.size.width;
    float height = view.frame.size.height;
    UIGraphicsBeginImageContextWithOptions((CGSizeMake(width, height)), NO, 1.f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    image=[UIImage imageWithData:UIImageJPEGRepresentation(image, 1)];
    UIGraphicsEndImageContext();
    return image;
}


- (unsigned char *) convertUIImageToBitmapRGBA8:(UIImage *) image {
    
    CGImageRef imageRef = image.CGImage;
    
    // Create a bitmap context to draw the uiimage into
    CGContextRef context = [self newBitmapRGBA8ContextFromImage:imageRef];
    
    if(!context) {
        return NULL;
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // Draw image into the context to get the raw image data
    CGContextDrawImage(context, rect, imageRef);
    
    // Get a pointer to the data
    unsigned char *bitmapData = (unsigned char *)CGBitmapContextGetData(context);
    
    // Copy the data and release the memory (return memory allocated with new)
    size_t bytesPerRow = CGBitmapContextGetBytesPerRow(context);
    
    size_t bufferLength = bytesPerRow * height;
    
    unsigned char *newBitmap = NULL;
    
    self.bmpTotalSize = 0;
    if(bitmapData) {
        newBitmap = (unsigned char *)malloc(sizeof(unsigned char) * bytesPerRow * height);
        self.bmpTotalSize = bytesPerRow * height;
        
        if(newBitmap) {    // Copy the data
            for(int i = 0; i < bufferLength; ++i) {
                newBitmap[i] = bitmapData[i];
            }
        }
        
        free(bitmapData);
        
    } else {
        NSLog(@"Error getting bitmap pixel data\n");
    }
    
    CGContextRelease(context);
    
    NSLog(@">>>>>>>>>>>>>\nbufferLength=[%ld],malloc_len[%ld],bmpTotalSize=[%ld] ", bufferLength, bytesPerRow * height, self.bmpTotalSize );
//    NSLog(@"\n/ ---------------begin-bmp--------------------");
//    printf("01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f \n");
//    int len = self.bmpTotalSize;
//    int tSize = 0;
//    while (tSize < len) {
//        int minLen = (len - tSize >= 16) ? (16) : (len - tSize);
//        for (int i = 0; i < minLen; i ++) {
//            printf("%02x ", *(newBitmap + tSize + i));
//        }
//        printf("\n");
//        tSize += 16;
//    }
//    NSLog(@"\n/ ---------------end-bmp--------------------");

    
    return newBitmap;
}

- (CGContextRef) newBitmapRGBA8ContextFromImage:(CGImageRef) image {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    uint32_t *bitmapData;
    
    size_t bitsPerPixel = 8 * 4;//32;
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    
    self.bmpWidth = CGImageGetWidth(image);
    self.bmpHeight = CGImageGetHeight(image);
    
    
    size_t bytesPerRow = self.bmpWidth * bytesPerPixel;
    size_t bufferLength = bytesPerRow * self.bmpHeight;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if(!colorSpace) {
        NSLog(@"Error allocating color space RGB\n");
        return NULL;
    }
    
    // Allocate memory for image data
    bitmapData = (uint32_t *)malloc(bufferLength);
    
    if(!bitmapData) {
        NSLog(@"Error allocating memory for bitmap\n");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    //Create bitmap context
    
    context = CGBitmapContextCreate(bitmapData,
                                    self.bmpWidth,
                                    self.bmpHeight,
                                    bitsPerComponent,
                                    bytesPerRow,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedLast);    // RGBA
    if(!context) {
        free(bitmapData);
        NSLog(@"Bitmap context not created");
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return context;
}


@end
