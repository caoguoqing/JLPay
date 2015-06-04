#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Photo : NSObject {
	
}

/*
 * 图片转换为字符串
 */
+ (NSString *) image2String:(UIImage *)image;

/*
 * 字符串转换为图片
 */
+ (UIImage *) string2Image:(NSString *)string;



@end