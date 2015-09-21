//
//  Unpacking8583.m
//  PosN38Universal
//
//  Created by work on 14-8-8.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import "Unpacking8583.h"
#import "PublicInformation.h"
#import "ISOFieldFormation.h"


#import "DesUtil.h"
#import "ErrorType.h"
#import "Define_Header.h"
#import "PosLib.h"
#import "JHNconnect.h"
#import "AppDelegate.h"

static Unpacking8583 *sharedObj2 = nil;

@implementation Unpacking8583
@synthesize delegate;

+(Unpacking8583 *)getInstance{
    @synchronized([Unpacking8583 class]){
        if(sharedObj2 ==nil){
            sharedObj2 = [[self alloc] init];
        }
    }
    return sharedObj2;
}

/*
//1.（2字节包长）
//2. (5 字节 TPDU)
//3. (6 字节报文头)
//4. (4 字节交易类型)
//5. (8 字节 BITMAP 位图)
//6. (实际交易数据)

*/

-(void)unpackingSignin:(NSString *)signin method:(NSString *)methodStr getdelegate:(id)de{
    NSLog(@"方法名=====%@data====%@",methodStr,signin);
    self.delegate=de;
    NSString  *rebackStr=@"";
    BOOL rebackState=NO;
    NSLog(@"交易名称：[%@]", methodStr);
    /**********置空配置变量**********/
    // 授权码
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:AuthNo_38];
    [[NSUserDefaults standardUserDefaults] synchronize];
    #pragma mark ----------签到
     if ([methodStr isEqualToString:TranType_DownWorkKey]) { //tcpsignin
        @try {
            NSArray *bitmapArr=[[Unpacking8583 getInstance] bitmapArr:[PublicInformation getBinaryByhex:[signin substringWithRange:NSMakeRange(30, 16)]]];//11,12,13,13....
            NSLog(@"位图====%@",bitmapArr);
            NSString *pathToConfigFile = [[NSBundle mainBundle] pathForResource:@"newisoconfig" ofType:@"plist"];
            NSDictionary *allElementDic = [NSDictionary dictionaryWithContentsOfFile:pathToConfigFile];
            NSMutableDictionary *bitDic=[[NSMutableDictionary alloc] init];
            for (int i=0; i<[bitmapArr count]; i++) {
                NSString *bitStr=[bitmapArr objectAtIndex:i];
                for (int a=0; a<[[allElementDic allKeys] count]; a++) {
                    if ([bitStr isEqualToString:[[allElementDic allKeys] objectAtIndex:a]]) {
                        [bitDic addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[allElementDic objectForKey:[[allElementDic allKeys] objectAtIndex:a]] forKey:[[allElementDic allKeys] objectAtIndex:a]]];
                    }
                }
            }
            NSArray* sortArr = [[NSArray alloc] initWithArray:bitmapArr];
            NSLog(@"签到=======%@",sortArr);
            //数据包
            NSMutableString *dataStr=(NSMutableString *)[signin substringWithRange:NSMakeRange(46, ([signin length]-46))];
            NSLog(@"数据包长度====%u,数据=====%@",[dataStr length],dataStr);
            NSMutableArray *arr=[[NSMutableArray alloc] init];
            
            int location=0;
            int length=0;
            NSString *deleteStr=@"";
            
            for (int c=0; c<[sortArr count]; c++) {
                
                if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"99"]) {
                    
                    //剩下长度
                    NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                    
                    
                    if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"type"] isEqualToString: @"bcd"]) {
                        //取一个字节，表示长度
                        int oneCharLength=(([[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]+1)/2 *2)+2;
                        length=oneCharLength;
                        
                    }else
                    {
                        //取一个字节，表示长度
                        int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]*2+2;
                        length=oneCharLength;
                    }
                    
                }else if([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"999"]){
                    //剩下长度
                    NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                    //                    //取两个字节，表示长度
                    //                    int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]*2+4;
                    //                    length=oneCharLength;
                    if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"type"] isEqualToString: @"bcd"]) {
                        //取两个字节，表示长度
                        int oneCharLength=(([[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]+1)/2*2)+4;
                        length=oneCharLength;
                        
                    }else
                    {
                        //取两个字节，表示长度
                        int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]*2+4;
                        
                        length=oneCharLength;
                    }
                    NSLog(@"--------------remainstr%@    length%d",[remainStr substringWithRange:NSMakeRange(0, 4)],length);
                }else{
                    length=[[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"length"] intValue];
                }
                
                deleteStr=[dataStr substringWithRange:NSMakeRange(location, length)];
                location += length;
                [arr addObject:deleteStr];
                
                NSLog(@"methodStr====%@位域====%@,长度=====%@,值====%@",methodStr,[sortArr objectAtIndex:c],[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"length"],deleteStr);
                
                
                if ([[sortArr objectAtIndex:c] isEqualToString:@"62"]) {
                    // 前面6位为长度
                    NSString *str1 = [deleteStr substringFromIndex:6];

                    NSMutableString *workStr = [[NSMutableString alloc]init];
                    // 锦宏霖A60设备需要处理下62域
                    // M60不需要处理
                    NSString* deviceType = [[NSUserDefaults standardUserDefaults] valueForKey:DeviceType];
                    if ([deviceType isEqualToString:DeviceType_JHL_A60]) {
                        for (int i = 1; i<[str1 length]+1; i++) {
                            if ( !( ( ((i+1)%40 == 0 )|| (i%40 == 0) ) ) ) {
                                NSString *str = [str1 substringWithRange:NSMakeRange(i-1, 1)];
                                [workStr appendString:str];
                            }
                        }
                    } else /*if ([deviceType isEqualToString:DeviceType_JHL_M60]) */{
                        [workStr appendString:str1];
                    }
                    
                    NSLog(@"workstr ---------%@",workStr);
                    
                    [[NSUserDefaults standardUserDefaults] setValue:workStr forKey:WorkKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                //交易结果
                if ([[sortArr objectAtIndex:c] isEqualToString:@"39"]) {
                    if ([self IC_exchangeSuccess:deleteStr]){
                        if ([methodStr isEqualToString:@"tcpsignin"]){
                            rebackStr=@"签到成功";
                        }
                        rebackState=YES;
                    }else{
                        rebackStr=[self IC_exchangeResult:deleteStr];
                        rebackState=NO;
                    }
                }
                
            }

            
            NSLog(@"arr=====+%@",arr);
            [self.delegate managerToCardState:rebackStr isSuccess:rebackState method:methodStr];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            rebackStr=@"签到失败";
            [self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr];
        }
        @finally {
            
        }
        
        }

    #pragma mark ----------消费
    else if ([methodStr isEqualToString:TranType_Consume]){ //cousume
        @try {
            NSArray *bitmapArr=[[Unpacking8583 getInstance] bitmapArr:[PublicInformation getBinaryByhex:[signin substringWithRange:NSMakeRange(30, 16)]]];//11,12,13,13....
            NSLog(@"位图====%@",bitmapArr);
            NSString *pathToConfigFile = [[NSBundle mainBundle] pathForResource:@"newisoconfig" ofType:@"plist"];
            NSDictionary *allElementDic = [NSDictionary dictionaryWithContentsOfFile:pathToConfigFile];
            NSMutableDictionary *bitDic=[[NSMutableDictionary alloc] init];
            for (int i=0; i<[bitmapArr count]; i++) {
                NSString *bitStr=[bitmapArr objectAtIndex:i];
                for (int a=0; a<[[allElementDic allKeys] count]; a++) {
                    if ([bitStr isEqualToString:[[allElementDic allKeys] objectAtIndex:a]]) {
                        [bitDic addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[allElementDic objectForKey:[[allElementDic allKeys] objectAtIndex:a]] forKey:[[allElementDic allKeys] objectAtIndex:a]]];
                    }
                }
            }
            NSArray* sortArr = [[NSArray alloc] initWithArray:bitmapArr];
            //数据包
            NSMutableString *dataStr=(NSMutableString *)[signin substringWithRange:NSMakeRange(46, ([signin length]-46))];
            NSLog(@"数据包长度====%d,数据=====%@",(int)[dataStr length],dataStr);
            NSMutableArray *arr=[[NSMutableArray alloc] init];
            
            int location=0;
            int length=0;
            NSString *deleteStr=@"";
            for (int c=0; c<[sortArr count]; c++) {
                
                if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"99"]) {
                    //剩下长度
                    NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                    if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"type"] isEqualToString: @"bcd"]) {
                        //取一个字节，表示长度
                        int oneCharLength=(([[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]+1)/2 *2)+2;
                        length=oneCharLength;
                    }else
                    {
                        //取一个字节，表示长度
                        int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]*2+2;
                        length=oneCharLength;
                    }
                }else if([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"999"]){
                    //剩下长度
                    NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                    if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"type"] isEqualToString: @"bcd"]) {
                        //取两个字节，表示长度
                        int oneCharLength=(([[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]+1)/2*2)+4;
                        length=oneCharLength;
                    }else
                    {
                        //取两个字节，表示长度
                        int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]*2+4;
                        length=oneCharLength;
                    }
                }else{
                    length=[[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"length"] intValue];
                }
                
                deleteStr=[dataStr substringWithRange:NSMakeRange(location, length)];
                location += length;
                [arr addObject:deleteStr];
                NSLog(@"methodStr====[%@] 位域====[%@] 长度=====[%@] 值====[%@]",methodStr,[sortArr objectAtIndex:c],
                      [[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"length"],deleteStr);
                
                //保存消费成功的交易金额
                if (([[sortArr objectAtIndex:c] isEqualToString:@"4"])) {
//                    float money=[deleteStr floatValue]/100;
//                    NSString *newDeleteStr=[NSString stringWithFormat:@"%0.2f",money];
//                    [[NSUserDefaults standardUserDefaults] setValue:newDeleteStr forKey:SuccessConsumerMoney];
                }
                else if ([[sortArr objectAtIndex:c] isEqualToString:@"12"]) {
                    // hhmmss 时间
                    [[NSUserDefaults standardUserDefaults] setValue:deleteStr forKey:Trans_Time_12];
                }
                else if ([[sortArr objectAtIndex:c] isEqualToString:@"13"]) {
                    // MMDD 日期
                    [[NSUserDefaults standardUserDefaults] setValue:deleteStr forKey:Trans_Date_13];
                }
                else if ([[sortArr objectAtIndex:c] isEqualToString:@"14"]) {
                    // 卡有效期
                    NSString* yyyymm = [NSString stringWithFormat:@"20%@/%@",[deleteStr substringToIndex:2],[deleteStr substringFromIndex:2]];
                    [[NSUserDefaults standardUserDefaults] setValue:yyyymm forKey:EXP_DATE_14];
                }
                else if ([[sortArr objectAtIndex:c] isEqualToString:@"37"]) {
                    //获取搜索参考号
                    [[NSUserDefaults standardUserDefaults] setValue:deleteStr forKey:Consumer_Get_Sort];
                }
                else if ([[sortArr objectAtIndex:c] isEqualToString:@"38"]) {
                    // 授权码
                    NSString* authNo_38 = [PublicInformation stringFromHexString:deleteStr];
                    [[NSUserDefaults standardUserDefaults] setValue:authNo_38 forKey:AuthNo_38];
                }
                else if ([[sortArr objectAtIndex:c] isEqualToString:@"44"]) {
                    // 发卡行代码 + 收单行代码
                    int len = [[deleteStr substringToIndex:2] intValue];
                    NSString* iss_no = [deleteStr substringWithRange:NSMakeRange(2, len)];
                    NSString* acq_no = [deleteStr substringWithRange:NSMakeRange(2+len, len)];
                    iss_no = [PublicInformation stringFromHexString:iss_no];
                    acq_no = [PublicInformation stringFromHexString:acq_no];
                    [[NSUserDefaults standardUserDefaults] setValue:iss_no forKey:ISS_NO_44_1];
                    [[NSUserDefaults standardUserDefaults] setValue:acq_no forKey:ACQ_NO_44_2];
                }
                
                //交易结果
                else if ([[sortArr objectAtIndex:c] isEqualToString:@"39"]) {
                    if ([self IC_exchangeSuccess:deleteStr] ) {
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:Is_Or_Consumer];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        //保存消费刷卡记录
                        rebackStr=@"交易成功";
                        rebackState=YES;
//                        [self saveExchangeResultMethod];
                    }else{
                        rebackStr=[self zhifubaoexchangeSuccess:deleteStr];
                        rebackState=NO;
                        
                    }
                }
                // ExchangeMoney_Type 交易类型 中文
                [[NSUserDefaults standardUserDefaults] setValue:@"消费" forKey:ExchangeMoney_Type];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
            NSLog(@"arr=====+%@",arr);
            NSLog(@"rebackState======%d",rebackState);
            [self.delegate managerToCardState:rebackStr isSuccess:rebackState method:methodStr];
        }
        @catch (NSException *exception) {
            //NSLog(@"%@", exception.reason);
            rebackStr=@"交易失败";
            [self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr];
        }
        @finally {
            
        }
    }
    #pragma mark-------------消费撤销
    else if ([methodStr isEqualToString:TranType_ConsumeRepeal]){ //consumeRepeal
            @try {
                NSArray *bitmapArr=[[Unpacking8583 getInstance] bitmapArr:[PublicInformation getBinaryByhex:[signin substringWithRange:NSMakeRange(30, 16)]]];//11,12,13,13....
                NSLog(@"位图====%@",bitmapArr);
                NSString *pathToConfigFile = [[NSBundle mainBundle] pathForResource:@"newisoconfig" ofType:@"plist"];
                NSDictionary *allElementDic = [NSDictionary dictionaryWithContentsOfFile:pathToConfigFile];
                NSMutableDictionary *bitDic=[[NSMutableDictionary alloc] init];
                for (int i=0; i<[bitmapArr count]; i++) {
                    NSString *bitStr=[bitmapArr objectAtIndex:i];
                    for (int a=0; a<[[allElementDic allKeys] count]; a++) {
                        if ([bitStr isEqualToString:[[allElementDic allKeys] objectAtIndex:a]]) {
                            [bitDic addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[allElementDic objectForKey:[[allElementDic allKeys] objectAtIndex:a]] forKey:[[allElementDic allKeys] objectAtIndex:a]]];
                        }
                    }
                }
                NSArray* sortArr = [[NSArray alloc] initWithArray:bitmapArr];
                //数据包
                NSMutableString *dataStr=(NSMutableString *)[signin substringWithRange:NSMakeRange(46, ([signin length]-46))];
                NSLog(@"数据包长度====%d,数据=====%@",[dataStr length],dataStr);
                NSMutableArray *arr=[[NSMutableArray alloc] init];
                
                int location=0;
                int length=0;
                NSString *deleteStr=@"";
                for (int c=0; c<[sortArr count]; c++) {
                    
                    if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"99"]) {
                        
                        //剩下长度
                        NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                        
                        
                        if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"type"] isEqualToString: @"bcd"]) {
                            //取一个字节，表示长度
                            int oneCharLength=(([[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]+1)/2 *2)+2;
                            length=oneCharLength;
                            
                        }else
                        {
                            //取一个字节，表示长度
                            int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]*2+2;
                            length=oneCharLength;
                        }
                        
                    }else if([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"999"]){
                        //剩下长度
                        NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                        //                    //取两个字节，表示长度
                        //                    int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]*2+4;
                        //                    length=oneCharLength;
                        if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"type"] isEqualToString: @"bcd"]) {
                            //取两个字节，表示长度
                            int oneCharLength=(([[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]+1)/2*2)+4;
                            length=oneCharLength;
                            
                        }else
                        {
                            //取两个字节，表示长度
                            int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]*2+4;
                            
                            length=oneCharLength;
                        }
                        NSLog(@"--------------remainstr%@    length%d",[remainStr substringWithRange:NSMakeRange(0, 4)],length);
                    }else{
                        length=[[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"length"] intValue];
                    }
                    
                    deleteStr=[dataStr substringWithRange:NSMakeRange(location, length)];
                    location += length;
                    [arr addObject:deleteStr];
                    
                    NSLog(@"methodStr====%@位域====%@,长度=====%@,值====%@",methodStr,[sortArr objectAtIndex:c],[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"length"],deleteStr);
                    
                    
                    if ([[sortArr objectAtIndex:c] isEqualToString:@"12"]) {
                        // hhmmss 时间
                        [[NSUserDefaults standardUserDefaults] setValue:deleteStr forKey:Trans_Time_12];
                    }
                    else if ([[sortArr objectAtIndex:c] isEqualToString:@"13"]) {
                        // MMDD 日期
                        [[NSUserDefaults standardUserDefaults] setValue:deleteStr forKey:Trans_Date_13];
                    }
                    else if ([[sortArr objectAtIndex:c] isEqualToString:@"14"]) {
                        // 卡有效期
                        NSString* yyyymm = [NSString stringWithFormat:@"20%@/%@",[deleteStr substringToIndex:2],[deleteStr substringFromIndex:2]];
                        [[NSUserDefaults standardUserDefaults] setValue:yyyymm forKey:EXP_DATE_14];
                    }
                    else if ([[sortArr objectAtIndex:c] isEqualToString:@"37"]) {
                        //获取搜索参考号
                        NSLog(@"Consumer_Get_Sort=[%@]", deleteStr);
                        [[NSUserDefaults standardUserDefaults] setValue:deleteStr forKey:Consumer_Get_Sort];
                    }
                    else if ([[sortArr objectAtIndex:c] isEqualToString:@"38"]) {
                        // 授权码
                        NSString* authNo_38 = [PublicInformation stringFromHexString:deleteStr];
                        [[NSUserDefaults standardUserDefaults] setValue:authNo_38 forKey:AuthNo_38];
                    }
                    else if ([[sortArr objectAtIndex:c] isEqualToString:@"39"]) {
                        //交易结果
                        if ([self IC_exchangeSuccess:deleteStr]){
                            if ([methodStr isEqualToString:@"consumeRepeal"]){
                                rebackStr=@"交易成功";
                            }
                            rebackState=YES;
                        }else{
                            rebackStr=[self IC_exchangeResult:deleteStr];
                            rebackState=NO;
                        }
                    }
                    else if ([[sortArr objectAtIndex:c] isEqualToString:@"44"]) {
                        // 发卡行代码 + 收单行代码
                        int len = [[deleteStr substringToIndex:2] intValue];
                        NSString* iss_no = [deleteStr substringWithRange:NSMakeRange(2, len)];
                        NSString* acq_no = [deleteStr substringWithRange:NSMakeRange(2+len, len)];
                        iss_no = [PublicInformation stringFromHexString:iss_no];
                        acq_no = [PublicInformation stringFromHexString:acq_no];
                        [[NSUserDefaults standardUserDefaults] setValue:iss_no forKey:ISS_NO_44_1];
                        [[NSUserDefaults standardUserDefaults] setValue:acq_no forKey:ACQ_NO_44_2];
                    }
                    
                    // ExchangeMoney_Type 交易类型 中文
                    [[NSUserDefaults standardUserDefaults] setValue:@"消费撤销" forKey:ExchangeMoney_Type];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                NSLog(@"arr=====+%@",arr);
                [self.delegate managerToCardState:rebackStr isSuccess:rebackState method:methodStr];
            }
            @catch (NSException *exception) {
                //NSLog(@"%@", exception.reason);
                rebackStr=@"撤销失败";
                [self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr];
            }
            @finally {
                
            }
        }
    #pragma mark-------------消费冲正
    else if ([methodStr isEqualToString:TranType_Chongzheng]){
            @try {
                NSArray *bitmapArr=[[Unpacking8583 getInstance] bitmapArr:[PublicInformation getBinaryByhex:[signin substringWithRange:NSMakeRange(30, 16)]]];//11,12,13,13....
                NSLog(@"位图====%@",bitmapArr);
                NSString *pathToConfigFile = [[NSBundle mainBundle] pathForResource:@"newisoconfig" ofType:@"plist"];
                NSDictionary *allElementDic = [NSDictionary dictionaryWithContentsOfFile:pathToConfigFile];
                //NSLog(@"allElementDic======%@",allElementDic);
                NSMutableDictionary *bitDic=[[NSMutableDictionary alloc] init];
                for (int i=0; i<[bitmapArr count]; i++) {
                    NSString *bitStr=[bitmapArr objectAtIndex:i];
                    for (int a=0; a<[[allElementDic allKeys] count]; a++) {
                        if ([bitStr isEqualToString:[[allElementDic allKeys] objectAtIndex:a]]) {
                            [bitDic addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[allElementDic objectForKey:[[allElementDic allKeys] objectAtIndex:a]] forKey:[[allElementDic allKeys] objectAtIndex:a]]];
                        }
                    }
                }
                NSArray* sortArr = [[NSArray alloc] initWithArray:bitmapArr];
                //数据包
                NSMutableString *dataStr=(NSMutableString *)[signin substringWithRange:NSMakeRange(46, ([signin length]-46))];
                NSLog(@"数据包长度====%d,数据=====%@",[dataStr length],dataStr);
                NSMutableArray *arr=[[NSMutableArray alloc] init];
                
                int location=0;
                int length=0;
                NSString *deleteStr=@"";
                for (int c=0; c<[sortArr count]; c++) {
                    
                    if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"99"]) {
                        
                        //剩下长度
                        NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                        
                        
                        if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"type"] isEqualToString: @"bcd"]) {
                            //取一个字节，表示长度
                            int oneCharLength=(([[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]+1)/2 *2)+2;
                            length=oneCharLength;
                            
                        }else
                        {
                            //取一个字节，表示长度
                            int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]*2+2;
                            length=oneCharLength;
                        }
                        
                    }else if([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"999"]){
                        //剩下长度
                        NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                        //                    //取两个字节，表示长度
                        //                    int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]*2+4;
                        //                    length=oneCharLength;
                        if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"type"] isEqualToString: @"bcd"]) {
                            //取两个字节，表示长度
                            int oneCharLength=(([[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]+1)/2*2)+4;
                            length=oneCharLength;
                            
                        }else
                        {
                            //取两个字节，表示长度
                            int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]*2+4;
                            
                            length=oneCharLength;
                        }
                        NSLog(@"--------------remainstr%@    length%d",[remainStr substringWithRange:NSMakeRange(0, 4)],length);
                    }else{
                        length=[[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"length"] intValue];
                    }
                    
                    deleteStr=[dataStr substringWithRange:NSMakeRange(location, length)];
                    location += length;
                    [arr addObject:deleteStr];
                    
                    NSLog(@"methodStr====%@位域====%@,长度=====%@,值====%@",methodStr,[sortArr objectAtIndex:c],[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"length"],deleteStr);
                    
                    
                    if ([[sortArr objectAtIndex:c] isEqualToString:@"62"]) {
                        
                        NSString *str1 = [deleteStr substringFromIndex:6];
                        
                        NSMutableString *workStr = [[NSMutableString alloc]init];
                        for (int i = 1; i<[str1 length]+1; i++) {
                            if ( !((((i+1)%40 == 0 )|| (i%40 == 0)))) {
                                
                                NSString *str = [str1 substringWithRange:NSMakeRange(i-1, 1)];
                                [workStr appendString:str];
                                
                            }
                        }
                        NSLog(@"workstr ---------%@",workStr);
                        
                        [[NSUserDefaults standardUserDefaults] setValue:workStr forKey:WorkKey];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [[JHNconnect shareView]WriteWorkKey:57 :workStr];
                    }
                    
                    //交易结果
                    if ([[sortArr objectAtIndex:c] isEqualToString:@"39"]) {
                        if ([self IC_exchangeSuccess:deleteStr]){
                            if ([methodStr isEqualToString:@"tcpsignin"]){
                                rebackStr=@"签到成功";
                            }
                            rebackState=YES;
                        }else{
                            rebackStr=[self IC_exchangeResult:deleteStr];
                            rebackState=NO;
                        }
                    }
                    
                }
                NSLog(@"arr=====+%@",arr);
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception.reason);
                rebackStr=@"冲正失败";
            }
            @finally {
                
            }
        }
    #pragma mark----主密钥下载
    else if ([methodStr isEqualToString:TranType_DownMainKey] ){//主密钥下载结束 downloadMainKey
        @try {
            NSArray *bitmapArr=[[Unpacking8583 getInstance] bitmapArr:[PublicInformation getBinaryByhex:[signin substringWithRange:NSMakeRange(30, 16)]]];//11,12,13,13....
            NSLog(@"位图====%@",bitmapArr);
            NSString *pathToConfigFile = [[NSBundle mainBundle] pathForResource:@"newisoconfig" ofType:@"plist"];
            NSDictionary *allElementDic = [NSDictionary dictionaryWithContentsOfFile:pathToConfigFile];
            NSMutableDictionary *bitDic=[[NSMutableDictionary alloc] init];
            for (int i=0; i<[bitmapArr count]; i++) {
                NSString *bitStr=[bitmapArr objectAtIndex:i];
                for (int a=0; a<[[allElementDic allKeys] count]; a++) {
                    if ([bitStr isEqualToString:[[allElementDic allKeys] objectAtIndex:a]]) {
                        [bitDic addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[allElementDic objectForKey:[[allElementDic allKeys] objectAtIndex:a]] forKey:[[allElementDic allKeys] objectAtIndex:a]]];
                    }
                }
            }
            NSArray* sortArr = [[NSArray alloc] initWithArray:bitmapArr];
            //            NSLog(@"签到=======%@",sortArr);
            //数据包
            NSMutableString *dataStr=(NSMutableString *)[signin substringWithRange:NSMakeRange(46, ([signin length]-46))];
            NSLog(@"数据包长度====%d,数据=====%@",[dataStr length],dataStr);
            NSMutableArray *arr=[[NSMutableArray alloc] init];
            
            int location=0;
            int length=0;
            NSString *deleteStr=@"";
            NSLog(@"sortarr  count %lu",(unsigned long)[sortArr count]);
            
            for (int c=0; c<[sortArr count]; c++) {
                
                if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"99"]) {
                    
                    //剩下长度
                    NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                    
                    
                    if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"type"] isEqualToString: @"bcd"]) {
                        //取一个字节，表示长度
                        int oneCharLength=(([[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]+1)/2 *2)+2;
                        length=oneCharLength;
                        
                    }else
                    {
                        //取一个字节，表示长度
                        int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]*2+2;
                        length=oneCharLength;
                    }
                    
                }else if([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"999"]){
                    //剩下长度
                    NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                    //                    //取两个字节，表示长度
                    //                    int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]*2+4;
                    //                    length=oneCharLength;
                    if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"type"] isEqualToString: @"bcd"]) {
                        //取两个字节，表示长度
                        int oneCharLength=(([[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]+1)/2*2)+4;
                        length=oneCharLength;
                        
                    }else
                    {
                        //取两个字节，表示长度
                        int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]*2+4;
                        
                        length=oneCharLength;
                    }
                    NSLog(@"--------------remainstr%@    length%d",[remainStr substringWithRange:NSMakeRange(0, 4)],length);
                }else{
                    length=[[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"length"] intValue];
                }
                
                deleteStr=[dataStr substringWithRange:NSMakeRange(location, length)];
                location += length;
                [arr addObject:deleteStr];
                
                NSLog(@"methodStr====%@位域====%@,长度=====%@,值====%@",methodStr,[sortArr objectAtIndex:c],[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"length"],deleteStr);
                
                
                if (rebackState) {
                    if ([[sortArr objectAtIndex:c] isEqualToString:@"62"]) {
                        
                        NSRange range = [deleteStr rangeOfString:@"DF0210"];
                        //62域工作秘钥
                        //(1),获取秘钥明文（3des解密）(pin秘钥密文和工作秘钥)
                        NSString *astring = [deleteStr substringFromIndex:range.location+range.length];
                        NSString *pinString=[self threeDESdecrypt:astring keyValue:@"EF2AE9F834BFCDD5260B974A70AD1A4A"];
                        NSLog(@"atring %@",astring);
                        
                        NSLog(@"pin明文====%@",pinString);
                        
                        [[NSUserDefaults standardUserDefaults] setValue:pinString forKey:Sign_in_PinKey];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
               
                //交易结果
                if ([[sortArr objectAtIndex:c] isEqualToString:@"39"]) {
                    if ([self IC_exchangeSuccess:deleteStr]){
                        if ([methodStr isEqualToString:@"downloadMainKey"]){
                            rebackStr=@"主密钥下载成功";
                        }
                        rebackState=YES;
                    }else{
                        rebackStr=[self IC_exchangeResult:deleteStr];
                        rebackState=NO;
                    }
                }
                
            }
            NSLog(@"arr=====+%@",arr);
            
            [self.delegate managerToCardState:rebackStr isSuccess:rebackState method:methodStr];
        }
        @catch (NSException *exception) {
            NSLog(@"--------%@", exception.reason);
            rebackStr=@"主密钥下载失败";
            [self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr];
        }
        @finally {
            
        }
        
    }
    #pragma mark---- 批上送
    else if ([methodStr isEqualToString:TranType_BatchUpload]){ //batchUpload
        {
            @try {
                NSArray *bitmapArr=[[Unpacking8583 getInstance] bitmapArr:[PublicInformation getBinaryByhex:[signin substringWithRange:NSMakeRange(30, 16)]]];//11,12,13,13....
                NSLog(@"位图====%@",bitmapArr);
                
                
                NSString *pathToConfigFile = [[NSBundle mainBundle] pathForResource:@"newisoconfig" ofType:@"plist"];
                NSDictionary *allElementDic = [NSDictionary dictionaryWithContentsOfFile:pathToConfigFile];
                NSMutableDictionary *bitDic=[[NSMutableDictionary alloc] init];
                for (int i=0; i<[bitmapArr count]; i++) {
                    NSString *bitStr=[bitmapArr objectAtIndex:i];
                    for (int a=0; a<[[allElementDic allKeys] count]; a++) {
                        if ([bitStr isEqualToString:[[allElementDic allKeys] objectAtIndex:a]]) {
                            // 保存每个
                            [bitDic addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[allElementDic objectForKey:[[allElementDic allKeys] objectAtIndex:a]]
                                                                                         forKey:[[allElementDic allKeys] objectAtIndex:a]]];
                        }
                    }
                }
                // 位图域名
                NSArray* sortArr = [[NSArray alloc] initWithArray:bitmapArr];
                //数据包
                NSMutableString *dataStr=(NSMutableString *)[signin substringWithRange:NSMakeRange(46, ([signin length]-46))];
                NSLog(@"数据包长度====%d,数据=====%@",[dataStr length],dataStr);
                NSMutableArray *arr=[[NSMutableArray alloc] init];
                
                int location=0;
                int length=0;
                NSString *deleteStr=@"";
                for (int c=0; c<[sortArr count]; c++) {
                    
                    if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"99"]) {
                        
                        //剩下长度
                        NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                        
                        
                        if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"type"] isEqualToString: @"bcd"]) {
                            //取一个字节，表示长度
                            int oneCharLength=(([[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]+1)/2 *2)+2;
                            length=oneCharLength;
                            
                        }else
                        {
                            //取一个字节，表示长度
                            int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]*2+2;
                            length=oneCharLength;
                        }
                        
                    }else if([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"999"]){
                        //剩下长度
                        NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                        if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"type"] isEqualToString: @"bcd"]) {
                            //取两个字节，表示长度
                            int oneCharLength=(([[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]+1)/2*2)+4;
                            length=oneCharLength;
                            
                        }else
                        {
                            //取两个字节，表示长度
                            int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]*2+4;
                            
                            length=oneCharLength;
                        }
                        NSLog(@"--------------remainstr%@    length%d",[remainStr substringWithRange:NSMakeRange(0, 4)],length);
                    }else{
                        length=[[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"length"] intValue];
                    }
                    
                    deleteStr=[dataStr substringWithRange:NSMakeRange(location, length)];
                    location += length;
                    [arr addObject:deleteStr];
                    
                    NSLog(@"methodStr====%@位域====%@,长度=====%@,值====%@",methodStr,[sortArr objectAtIndex:c],[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"length"],deleteStr);
                    //交易结果
                    if ([[sortArr objectAtIndex:c] isEqualToString:@"39"]) {
                        if ([self IC_exchangeSuccess:deleteStr] ) {
                            rebackStr=@"披上送成功";
                            rebackState=YES;
                        }else{
                            rebackStr=[self zhifubaoexchangeSuccess:deleteStr];
                            rebackState=NO;
                            
                        }
                    }
                    
                }
                NSLog(@"arr=====+%@",arr);
                NSLog(@"rebackState======%d",rebackState);
                [self.delegate managerToCardState:rebackStr isSuccess:rebackState method:methodStr];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception.reason);
                rebackStr=@"批上送失败";
                [self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr];
            }
            @finally {
                
            }
        }
    }
}




#pragma mask ---- 重写8583报文解包函数 -----------------------------------------------------------
/*
 //1. (2 字节包长)
 //2. (5 字节 TPDU)
 //3. (6 字节报文头)
 //4. (4 字节交易类型)
 //5. (8 字节 BITMAP 位图)
 //6. (实际交易数据)
 */

-(void)unpacking8583:(NSString *)responseString withDelegate:(id<Unpacking8583Delegate>)sdelegate {
    self.stateDelegate = sdelegate;
    
    NSString* rebackStr = nil;
    BOOL rebackState = YES;
    @try {
        // map数组: bitmap串(16进制) -> 二进制串 -> 取串中'1'的位置
        NSArray *bitmapArr=[self bitmapArr:[PublicInformation getBinaryByhex:[responseString substringWithRange:NSMakeRange(30, 16)]]];
        NSLog(@"位图:[%@]",[bitmapArr componentsJoinedByString:@" "]);
        
        // 截取纯域值串
        NSMutableString* dataString = [[NSMutableString alloc] initWithString:[responseString substringFromIndex:4+10+12+8+16]];
        
        // 根据位图信息循环拆包
        NSMutableDictionary* dictFields = [NSMutableDictionary dictionaryWithCapacity:bitmapArr.count];
        for (NSString* bitIndex in bitmapArr) {
            // 并将拆包数据打包到字典
            NSString* content = [[ISOFieldFormation sharedInstance] unformatStringWithFormation:dataString atIndex:bitIndex.intValue];
            [dictFields setValue:content forKey:bitIndex];
        }
        
        // 组合响应信息
        NSString* responseCode = [dictFields valueForKey:@"39"];
        responseCode = [PublicInformation stringFromHexString:responseCode];
        rebackStr = [ErrorType errInfo:responseCode];
        rebackStr = [NSString stringWithFormat:@"[%@]%@",responseCode, rebackStr];
        
        // 根据39域值,解析错误类型消息;
        if (self.stateDelegate && [self.stateDelegate respondsToSelector:@selector(didUnpackDatas:onState:withErrorMsg:)]) {
            [self.stateDelegate didUnpackDatas:dictFields onState:rebackState withErrorMsg:rebackStr];
        }
        
    }
    @catch (NSException *exception) {
        if (self.stateDelegate && [self.stateDelegate respondsToSelector:@selector(didUnpackDatas:onState:withErrorMsg:)]) {
            [self.stateDelegate didUnpackDatas:nil onState:NO withErrorMsg:exception.reason];
        }
    }
    @finally {}
}








#pragma mark ----------3des加密

-(NSString *)threeDesEncrypt:(NSString *)decryptDtr keyValue:(NSString *)key{
/*
加密:    双倍长密钥加密算法为：
    str = DES(str ,k21)
    str = UDES(str ,k22)
    str = DES(str ,k21)
    其对应的解密过程就不详解了。
*/
//3des加密8个0
    NSString *key21=[key substringWithRange:NSMakeRange(0, [key length]/2)];
    NSString *key22=[key substringWithRange:NSMakeRange([key length]/2, [key length]/2)];
     NSString *descryptStr1=[DesUtil encryptUseDES:decryptDtr key:key21];
    NSString *descryptStr2=[DesUtil decryptUseDES:descryptStr1 key:key22];
    NSString *descryptStr3=[DesUtil encryptUseDES:descryptStr2 key:key21];
    return descryptStr3;
}


#pragma mark ----------3des解密
-(NSString *)threeDESdecrypt:(NSString *)decryptStr keyValue:(NSString *)key{
    /*
     解密:    双倍长密钥解密算法为：
     str = UDES(str ,k21)
     str = DES(str ,k22)
     str = UDES(str ,k21)
     其对应的解密过程就不详解了。
     */
    NSString *key21=[key substringWithRange:NSMakeRange(0, [key length]/2)];
    NSString *key22=[key substringWithRange:NSMakeRange([key length]/2, [key length]/2)];
    NSString *descryptStr1=[DesUtil decryptUseDES:decryptStr key:key21];
    NSString *descryptStr2=[DesUtil encryptUseDES:descryptStr1 key:key22];
    NSString *descryptStr3=[DesUtil decryptUseDES:descryptStr2 key:key21];
    return descryptStr3;
}

#pragma mark ----------验证39域

-(NSString *)exchangeResult:(NSString *)result{
//143030E4BAA4E69893E68890E58A9F,00成功
    NSString *theResult=[result substringWithRange:NSMakeRange(2, 4)];
    NSString *codeResult=[ErrorType errInfo:[PublicInformation stringFromHexString:theResult]];
    return codeResult;
}

-(BOOL)exchangeSuccess:(NSString *)result{
    NSString *theResult=[PublicInformation stringFromHexString:[result substringWithRange:NSMakeRange(2, 4)]];
    if ([theResult isEqualToString:@"00"]) {
        return YES;
    }else{
        return NO;
    }
}

-(NSString *)zhifubaoexchangeSuccess:(NSString *)result{
    NSString *codeResult=[ErrorType errInfo:[PublicInformation stringFromHexString:result]];
    codeResult = [NSString stringWithFormat:@"[%@]:%@",[PublicInformation stringFromHexString:result], codeResult];
    return codeResult;
}

-(NSString *)IC_exchangeResult:(NSString *)result{
    //143030E4BAA4E69893E68890E58A9F,00成功
    NSString *theResult=result;
    NSString *codeResult=[ErrorType errInfo:[PublicInformation stringFromHexString:theResult]];
    codeResult = [NSString stringWithFormat:@"[%@]:%@",[PublicInformation stringFromHexString:theResult], codeResult];
    return codeResult;
}

-(BOOL)IC_exchangeSuccess:(NSString *)result{
    NSString *theResult=[PublicInformation stringFromHexString:result];
    if ([theResult isEqualToString:@"00"]) {
        return YES;
    }else{
        return NO;
    }
}


#pragma mark ::: 位图计算
-(NSArray *)bitmapArr:(NSString *)bitmapStr{
    //0000000000111000000000000000000000001010110000000000000100100110
    NSMutableArray *bitmapMuArr=[[NSMutableArray alloc] init];
    for (int i=0; i<([bitmapStr length]+0); i++) {
        if ([[bitmapStr substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"1"]) {
            [bitmapMuArr addObject:[NSString stringWithFormat:@"%d",i+1]];
        }
    }
    return bitmapMuArr;
}

@end
