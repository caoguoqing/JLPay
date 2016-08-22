//
//  MPubkeyFormator.h
//  JLPay
//
//  Created by jielian on 16/8/10.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPubkeyFormator : NSObject

- (instancetype) initWithPublicKey:(NSString*)pubkey;

@property (nonatomic, copy) NSString* preData;  /*  */
@property (nonatomic, copy) NSString* sufData;  /**/
@property (nonatomic, copy) NSString* keyData;  /**/

/* RSA加密后重组的公钥 */
@property (nonatomic, strong) NSString* repackedPubkey;

@end
