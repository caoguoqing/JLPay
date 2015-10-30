//
//  myCollectionCell.h
//  JLPay
//
//  Created by jielian on 15/8/4.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myCollectionCell : UICollectionViewCell

- (void) setImage:(UIImage*)image;
//- (void) setText:(NSString*)text;
@property (nonatomic, assign) NSString* title;

@end
