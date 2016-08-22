//
//  VMElecSignPicUploader.h
//  JLPay
//
//  Created by jielian on 16/7/28.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACCommand;
@class TcpClientService;

@interface VMElecSignPicUploader : NSObject

# pragma mask : public

@property (nonatomic, copy) NSDictionary* pakingInfo;           /* 打包信息 */

@property (nonatomic, strong) RACCommand* cmdUploader;          /* 上传命令 */



# pragma mask : private

@property (nonatomic, strong) TcpClientService* tcpHandle;



@end
