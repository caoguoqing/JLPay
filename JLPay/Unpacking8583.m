//
//  Unpacking8583.m
//  PosN38Universal
//
//  Created by work on 14-8-8.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import "Unpacking8583.h"
#import "PublicInformation.h"
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
//2.(5 字节 TPDU)
//3.(6 字节报文头)
//4.(4 字节交易类型)
//5.(8 字节 BITMAP 位图)
//6.(实际交易数据)

*/

-(void)unpackingSignin:(NSString *)signin method:(NSString *)methodStr getdelegate:(id)de{
    NSLog(@"方法名=====%@data====%@",methodStr,signin);
    self.delegate=de;
    NSString  *rebackStr=@"";
    BOOL rebackState=NO;
    NSLog(@"交易名称：[%@]", methodStr);
#pragma mark---------支付宝支付，(预下订单)
    //saomaOrder
    if ([methodStr isEqualToString:@"saomaOrder"]) {
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
            NSLog(@"预下订单=======%@",sortArr);
            //数据包
            NSMutableString *dataStr=(NSMutableString *)[signin substringWithRange:NSMakeRange(46, ([signin length]-46))];
            NSLog(@"数据包长度====%d,数据=====%@",[dataStr length],dataStr);
            NSMutableArray *arr=[[NSMutableArray alloc] init];
            
            BOOL erweimaAndReturn=NO;
            
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
            NSLog(@"arr=====+%@",arr);//erweimaAndReturn
            
            if (rebackState && erweimaAndReturn) {
               [self.delegate managerToCardState:rebackStr isSuccess:YES method:methodStr];
            }else{
                [self.delegate managerToCardState:@"预下订单失败" isSuccess:NO method:methodStr];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            rebackStr=@"预下订单失败";
            [self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr] ;
        }
        @finally {
            
        }
    }
#pragma mark-----------支付宝扫码查询
    else if ([methodStr isEqualToString:@"searchOrder"]){
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
            NSLog(@"支付宝查询=======%@",sortArr);
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
            //支付宝查询成功
            if (rebackState) {
                [self zhifubaoSaomaSaveMethod];
            }
            NSLog(@"arr=====+%@",arr);
            [self.delegate managerToCardState:rebackStr isSuccess:rebackState method:methodStr];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            rebackStr=@"支付宝查询失败";
            [self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr] ;
        }
        @finally {
            
        }
    }
#pragma mark-----------支付宝条形码消费(下订单并支付)
    //tiaoxingmaOrder
    else if ([methodStr isEqualToString:@"tiaoxingmaOrder"]) {
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
            NSLog(@"条码支付=======%@",sortArr);
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
                
            }            NSLog(@"arr=====+%@",arr);
            //条码支付成功
            if (rebackState) {
                [self zhifubaoSaomaSaveMethod];
            }
            [self.delegate managerToCardState:rebackStr isSuccess:rebackState method:methodStr];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            rebackStr=@"条码支付失败";
            [self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr] ;
        }
        @finally {
            
        }
    }
#pragma mark-----------支付宝撤销支付
    else if ([methodStr isEqualToString:@"zhifubaochexiao"]) {
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
            NSLog(@"支付宝撤销支付=======%@",sortArr);
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
            //撤销成功
            if (rebackState) {
                [self zhifubaoReturnMoneySaveMethod:2];
            }
            [self.delegate managerToCardState:rebackStr isSuccess:rebackState method:methodStr];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            rebackStr=@"支付宝撤销支付失败";
            [self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr] ;
        }
        @finally {
            
        }
    }
#pragma mark-----------支付宝退款
    else if ([methodStr isEqualToString:@"zhifubaotuikuan"]) {
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
            NSLog(@"支付宝退款=======%@",sortArr);
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
            
            //退款成功
            if (rebackState) {
                [self zhifubaoReturnMoneySaveMethod:3];
            }
            
            [self.delegate managerToCardState:rebackStr isSuccess:rebackState method:methodStr];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            rebackStr=@"支付宝退款失败";
            [self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr] ;
        }
        @finally {
            
        }
    }
#pragma mark ----------签到
//签到
    else if ([methodStr isEqualToString:@"tcpsignin"] || [methodStr isEqualToString:@"blue_signinic"]) {
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
#pragma mark ----------终端初始化
//终端初始化
    else if ([methodStr isEqualToString:@"terminal"] || [methodStr isEqualToString:@"terminal_IC"]){
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
                
                //转换后20个字节
                
                NSString *reallyLengthStr=[PublicInformation stringFromHexString:[[arr objectAtIndex:4] substringWithRange:NSMakeRange(4, 80)]];
                NSLog(@"reallyLengthStr====%@",reallyLengthStr);
                
//61域主秘钥验证数据
                //(1),获取秘钥明文（3des解密）(pin秘钥密文和工作秘钥)
                NSString *pinresult=[reallyLengthStr substringWithRange:NSMakeRange(32, 8)];
                NSString *pinString=[self threeDESdecrypt:[reallyLengthStr substringWithRange:NSMakeRange(0, 32)] keyValue:DECRYPT_KEY];
                NSLog(@"主密钥明文====%@",pinString);
                
//主密钥更新
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IsOrRefresh_MainKey];
                [[NSUserDefaults standardUserDefaults] setValue:pinString forKey:Refresh_Later_MainKey];
                [NSUserDefaults standardUserDefaults];
                
                
                NSString *pinEncryptVlaue=[self threeDesEncrypt:@"0000000000000000" keyValue:pinString];
                NSLog(@"加密结果===%@",pinEncryptVlaue);
                NSString *pinvalue=[pinEncryptVlaue substringWithRange:NSMakeRange(0, 8)];
                NSLog(@"pinresult====%@,pinvalue====%@",pinresult,pinvalue);
                
//59域为00，且主秘钥验证通过
                if ([self exchangeSuccess:[arr objectAtIndex:3]] && [pinresult isEqualToString:pinvalue]) {
                    rebackStr=@"终端初始化成功";
                    rebackState=YES;
                }else{
                    rebackState=NO;
                    rebackStr=[self exchangeResult:[arr objectAtIndex:3]];
                }

                //62域解析数据
                int relaxLength=[[[arr objectAtIndex:5] substringWithRange:NSMakeRange(0, 4)] intValue];
                //实际内容
                NSString *relaxStr=[[arr objectAtIndex:5] substringWithRange:NSMakeRange(4, relaxLength*2)];
                //40个数据
                int everylength=0;
                int everyLocation=0;
                NSString *deleteEveryStr=@"";
                NSMutableArray *everyArr=[[NSMutableArray alloc] init];
                for (int i=0; i<40; i++) {
                    
                    NSString *remainStr=[relaxStr substringWithRange:NSMakeRange(everyLocation, [relaxStr length]-everyLocation)];
                    //取两个字节，表示长度
                    int everyCharLength=[[PublicInformation stringFromHexString:[remainStr substringWithRange:NSMakeRange(0, 4)]] intValue]*2+4;
                    everylength=everyCharLength;
                    if (everylength > 4) {
                        deleteEveryStr=[relaxStr substringWithRange:NSMakeRange(everyLocation+4, everylength-4)];
                    }else{
                        deleteEveryStr=[relaxStr substringWithRange:NSMakeRange(everyLocation, everylength)];
                    }
                    
                    everyLocation += everylength;
                    [everyArr addObject:[PublicInformation stringFromHexString:deleteEveryStr]];
                    NSLog(@"进制转换====%d,内容===%@",i,[PublicInformation stringFromHexString:deleteEveryStr]);
                }
                NSLog(@"everyArr====%@",everyArr);
                
                //0,1,4终端号和商户号,商户名称
                [[NSUserDefaults standardUserDefaults] setValue:[everyArr objectAtIndex:0] forKey:Terminal_Number];
                [[NSUserDefaults standardUserDefaults] setValue:[everyArr objectAtIndex:1] forKey:Business_Number];
                [[NSUserDefaults standardUserDefaults] setValue:[everyArr objectAtIndex:4] forKey:Business_Name];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.delegate managerToCardState:rebackStr isSuccess:rebackState method:methodStr];
                
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception.reason);
                rebackStr=@"终端初始化失败";
                [self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr] ;
            }
            @finally {
                
            }
    }
#pragma mark ----------消费
//消费cousume
    else if ([methodStr isEqualToString:@"cousume"]){
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
                
                //保存消费成功的交易金额
                if (([[sortArr objectAtIndex:c] isEqualToString:@"4"])) {
                    NSLog(@"消费的次数");
                    float money=[deleteStr floatValue]/100;
                    NSString *newDeleteStr=[NSString stringWithFormat:@"%0.2f",money];
                    [[NSUserDefaults standardUserDefaults] setValue:newDeleteStr forKey:SuccessConsumerMoney];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                if ([[sortArr objectAtIndex:c] isEqualToString:@"37"]) {
                    //获取搜索参考号
                    [[NSUserDefaults standardUserDefaults] setValue:deleteStr forKey:Consumer_Get_Sort];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                // ExchangeMoney_Type 交易类型 中文
                [[NSUserDefaults standardUserDefaults] setValue:@"消费" forKey:ExchangeMoney_Type];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //交易结果
                if ([[sortArr objectAtIndex:c] isEqualToString:@"39"]) {
                    if ([self IC_exchangeSuccess:deleteStr] ) {
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:Is_Or_Consumer];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        //保存消费刷卡记录
                        rebackStr=@"交易成功";
                        rebackState=YES;
                        [self saveExchangeResultMethod];
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
            //NSLog(@"%@", exception.reason);
            rebackStr=@"交易失败";
            [self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr];
        }
        @finally {
            
        }
    }
#pragma mark-------------IC卡消费//blue_cousume
    else if ([methodStr isEqualToString:@"blue_cousume"]){
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
    else if ([methodStr isEqualToString:@"consumeRepeal"]){
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
                    
                    // ExchangeMoney_Type 交易类型 中文
                    [[NSUserDefaults standardUserDefaults] setValue:@"消费撤销" forKey:ExchangeMoney_Type];
                    [[NSUserDefaults standardUserDefaults] synchronize];

                    
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
                //NSLog(@"%@", exception.reason);
                rebackStr=@"撤销失败";
                [self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr];
            }
            @finally {
                
            }
        }
#pragma mark-------------余额查询
    else if ([methodStr isEqualToString:@"balancesearch"]){
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
                [self.delegate managerToCardState:rebackStr isSuccess:rebackState method:methodStr];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception.reason);
                rebackStr=@"查询失败";
                [self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr];
            }
            @finally {
                
            }
        }
    }
#pragma mark-------------IC卡余额查询 blue_balancesearch
    else if ([methodStr isEqualToString:@"blue_balancesearch"]){
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
            [self.delegate managerToCardState:rebackStr isSuccess:rebackState method:methodStr];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            rebackStr=@"查询失败";
            [self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr];
        }
        @finally {
            
        }
        
    }
    
#pragma mark-------------消费冲正
    else if ([methodStr isEqualToString:@"cousumereturn"]){
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
    
#pragma mark----blue pos状态上送_pos公钥下载
    else if ([methodStr isEqualToString:@"blue_gongyao_status"] ||//状态上送-公钥下载
             [methodStr isEqualToString:@"blue_gongyaoload_statussend"] ||//参数传递-公钥下载
             [methodStr isEqualToString:@"blue_gongyaoload_end"]||//公钥下载结束
             [methodStr isEqualToString:@"blue_parameter_status"] ||//状态上送-参数下载
             [methodStr isEqualToString:@"blue_parameterload_statussend"] ||//参数传递-公钥下载
             [methodStr isEqualToString:@"blue_parameterload_end"]){//公钥下载结束
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
                NSLog(@"---------位域：%@",[sortArr objectAtIndex:c]);
                
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

                if ([methodStr isEqualToString:@"blue_gongyao_status"]){
                    //公钥下载62—tlv
                    if ([[sortArr objectAtIndex:c] isEqualToString:@"62"]) {
                        [[NSUserDefaults standardUserDefaults] setValue:deleteStr forKey:BlueIC_GongyaoLoad_TLV];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }else if ([methodStr isEqualToString:@"blue_parameter_status"]){
                   //参数下载62—tlv
                    [[NSUserDefaults standardUserDefaults] setValue:deleteStr forKey:BlueIC_ParameterLoad_TLV];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                

                //交易结果
                if ([[sortArr objectAtIndex:c] isEqualToString:@"39"]) {
                    if ([self IC_exchangeSuccess:deleteStr]){
                        if ([methodStr isEqualToString:@"blue_gongyao_status"]){
                           rebackStr=@"公钥下载状态上送成功";
                        }else if ([methodStr isEqualToString:@"blue_gongyaoload_statussend"]){
                            rebackStr=@"公钥下载参数传递成功";
                        }
                        else if ([methodStr isEqualToString:@"blue_gongyaoload_end"]){
                            rebackStr=@"公钥下载结束";
                        }
                        else if ([methodStr isEqualToString:@"blue_parameter_status"]){
                            rebackStr=@"参数下载参数传递成功";
                        }
                        else if ([methodStr isEqualToString:@"blue_parameterload_statussend"]){
                            rebackStr=@"参数下载参数传递成功";
                        }
                        else if ([methodStr isEqualToString:@"blue_parameterload_end"]){
                            rebackStr=@"参数下载结束";
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
            rebackStr=@"签到失败";
            //[self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr];
        }
        @finally {
            
        }
        
    }
#pragma mark----主密钥下载
    else if ([methodStr isEqualToString:@"downloadMainKey"] ){//主密钥下载结束
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
                

                
                if ([[sortArr objectAtIndex:c] isEqualToString:@"62"]) {
                    
                    NSRange range = [deleteStr rangeOfString:@"DF0210"];
                    
//                    NSString *reallyLengthStr=[deleteStr substringWithRange:NSMakeRange(4, length-4)];//[arr objectAtIndex:9]
                    //62域工作秘钥
                    //(1),获取秘钥明文（3des解密）(pin秘钥密文和工作秘钥)
                    NSString *astring = [deleteStr substringFromIndex:range.location+range.length];
//                    NSString *pinresult=[reallyLengthStr substringWithRange:NSMakeRange(32, 8)];
//                    NSString *pinString=[self threeDESdecrypt:[reallyLengthStr substringWithRange:NSMakeRange(0, 32)] keyValue:@"EF2AE9F834BFCDD5260B974A70AD1A4A"];
                    NSString *pinString=[self threeDESdecrypt:astring keyValue:@"EF2AE9F834BFCDD5260B974A70AD1A4A"];
                    NSLog(@"atring %@",astring);

                    NSLog(@"pin明文====%@",pinString);
                    
                    [[NSUserDefaults standardUserDefaults] setValue:pinString forKey:Sign_in_PinKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[JHNconnect shareView]WriteMainKey:16 :pinString];
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
            rebackStr=@"签到失败";
            //[self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr];
        }
        @finally {
            
        }
        
    }

#pragma mark----blue IC签到
    else if ([methodStr isEqualToString:@"blue_signinic"]){
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
            for (int c=0; c<[sortArr count]; c++) {
                
                if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"99"]) {
                    //剩下长度
                    NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                    //取一个字节，表示长度
                    int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]*2+2;
                    length=oneCharLength;
                }else if([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"999"]){
                    //剩下长度
                    NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                    //取两个字节，表示长度
                    int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]*2+4;
                    length=oneCharLength;
                }else{
                    length=[[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"length"] intValue];
                }
                NSLog(@"location   :   %d   length:  %d",location,length);
                NSLog(@"位域====%@,长度=====%@,值====%@",[sortArr objectAtIndex:c],[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"length"],deleteStr);
                deleteStr=[dataStr substringWithRange:NSMakeRange(location, length)];
                location += length;
                [arr addObject:deleteStr];

                
                if ([[sortArr objectAtIndex:c] isEqualToString:@"56"]) {
                    NSLog(@"deleteStr====%@",deleteStr);
                    [[NSUserDefaults standardUserDefaults] setValue:deleteStr forKey:Get_Sort_Number];//[arr objectAtIndex:7]
                    NSLog(@"签到返回的批次号====%@",[[NSUserDefaults standardUserDefaults] valueForKey:Get_Sort_Number]);
                }
                
                if ([[sortArr objectAtIndex:c] isEqualToString:@"62"]) {
                    NSString *reallyLengthStr=[deleteStr substringWithRange:NSMakeRange(4, 80)];//[arr objectAtIndex:9]
                    //62域工作秘钥
                    //(1),获取秘钥明文（3des解密）(pin秘钥密文和工作秘钥)
                    NSString *pinresult=[reallyLengthStr substringWithRange:NSMakeRange(32, 8)];
                    NSString *pinString=[self threeDESdecrypt:[reallyLengthStr substringWithRange:NSMakeRange(0, 32)] keyValue:Main_Work_key];
                    NSLog(@"pin明文====%@",pinString);
                    
                    [[NSUserDefaults standardUserDefaults] setValue:pinString forKey:Sign_in_PinKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    NSString *pinEncryptVlaue=[self threeDesEncrypt:@"0000000000000000" keyValue:pinString];
                    NSString *pinvalue=[pinEncryptVlaue substringWithRange:NSMakeRange(0, 8)];
                    NSLog(@"pinresult====%@,pinvalue====%@",pinresult,pinvalue);
                    
                    //mac验证数据
                    
                    NSString *macresult=[reallyLengthStr substringWithRange:NSMakeRange(72, 8)];
                    NSString *macString=[self threeDESdecrypt:[reallyLengthStr substringWithRange:NSMakeRange(40, 32)] keyValue:Main_Work_key];
                    NSLog(@"mac明文====%@",macString);
                    
                    [[NSUserDefaults standardUserDefaults] setValue:macString forKey:Sign_in_MacKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    NSString *macEncryptVlaue=[DesUtil encryptUseDES:@"0000000000000000" key:macString];
                    NSString *macvalue=[macEncryptVlaue substringWithRange:NSMakeRange(0, 8)];
                    NSLog(@"macresult====%@,macString====%@",macresult,macvalue);
                    
                }
                //交易结果
                if ([[sortArr objectAtIndex:c] isEqualToString:@"59"]) {
                    //59域00，pin校验，mac校验
                    //if ([self exchangeSuccess:deleteStr] && [pinresult isEqualToString:pinvalue] && [macresult isEqualToString:macvalue]) {//[arr objectAtIndex:8]
                    if ([self exchangeSuccess:deleteStr]){
                        rebackStr=@"签到成功";
                        rebackState=YES;
                    }else{
                        rebackStr=[self exchangeResult:deleteStr];
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
#pragma mark----blue IC余额查询
    else if ([methodStr isEqualToString:@"blue_searchMoneyic"]){
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

                    if (([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"bcd99"])) {
                        //剩下长度
                        NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                        //取一个字节，表示长度
                        int otherLength=[[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]+2;
                        if (otherLength%2 > 0) {
                            otherLength=[[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]+2+1;
                        }
                        length=otherLength;
                    }
                    else if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"99"]) {
                        //剩下长度
                        NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                        //取一个字节，表示长度
                        int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]*2+2;
                        length=oneCharLength;
                    }else if([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"999"]){
                        //剩下长度
                        NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                        //取两个字节，表示长度
                        int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]*2+4;
                        length=oneCharLength;
                    }else{
                        length=[[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"length"] intValue];
                    }

                    //NSLog(@"location===%d,length====%d",location,length);
                    deleteStr=[dataStr substringWithRange:NSMakeRange(location, length)];
                    location += length;
                    [arr addObject:deleteStr];
                    
                    if ([[sortArr objectAtIndex:c] isEqualToString:@"54"]) {
                        
                        double money = [[deleteStr substringWithRange:NSMakeRange([deleteStr length]-12, 12)] doubleValue]*0.01;
                        NSString *newDeleteStr=[NSString stringWithFormat:@"%0.2f",money];
                        NSLog(@"money=====%.2f",money);
                        [[NSUserDefaults standardUserDefaults] setValue:newDeleteStr forKey:SearchCard_Money];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    //59域00，pin校验，mac校验
                    if ([[sortArr objectAtIndex:c] isEqualToString:@"59"]) {
                        if ([self exchangeSuccess:deleteStr] ) {
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:Is_Or_Consumer];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            rebackStr=@"查询成功";
                            rebackState=YES;
                        }else{
                            rebackStr=[self exchangeResult:deleteStr];
                            rebackState=NO;
                        }
                    }
                    NSLog(@"位域====%@,长度=====%@,值====%@",[sortArr objectAtIndex:c],[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"length"],deleteStr);
                }
                NSLog(@"arr=====+%@",arr);
                [self.delegate managerToCardState:rebackStr isSuccess:rebackState method:methodStr];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception.reason);
                rebackStr=@"查询失败";
                [self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr];
            }
            @finally {
                
            }
        }
    }
#pragma mark---- 商户登陆
    else if ([methodStr isEqualToString:@"loadIn"]){
        {
            @try {
                // ---------解析位图
                NSArray *bitmapArr=[[Unpacking8583 getInstance] bitmapArr:[PublicInformation getBinaryByhex:[signin substringWithRange:NSMakeRange(30, 16)]]];
                NSLog(@"位图====%@",bitmapArr);
                
                // --- 本地配置文件，保存的信息是:::响应数据的 每个域索引号+域值 的字典
                NSString *pathToConfigFile = [[NSBundle mainBundle] pathForResource:@"newisoconfig" ofType:@"plist"];
                NSDictionary *allElementDic = [NSDictionary dictionaryWithContentsOfFile:pathToConfigFile];
                
                // --- 解析出每个域的值，保存到临时字典
                NSMutableDictionary *bitDic=[[NSMutableDictionary alloc] init];
                for (int i=0; i<[bitmapArr count]; i++) {
                    NSString *bitStr=[bitmapArr objectAtIndex:i]; // 域索引值
                    // --- 扫描本地配置信息
                    for (int a=0; a<[[allElementDic allKeys] count]; a++) {
                        if ([bitStr isEqualToString:[[allElementDic allKeys] objectAtIndex:a]]) {
                            [bitDic addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[allElementDic objectForKey:[[allElementDic
                                                                                                                              allKeys] objectAtIndex:a]]
                                                                                         forKey:[[allElementDic allKeys] objectAtIndex:a]]];
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
                    
                    // --- 解析 99 域
                    if (([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"bcd99"])) {
                        //剩下长度
                        NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                        //取一个字节，表示长度
                        int otherLength=[[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]+2;
                        if (otherLength%2 > 0) {
                            otherLength=[[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]+2+1;
                        }
                        length=otherLength;
                    }
                    else if ([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"99"]) {
                        //剩下长度
                        NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                        //取一个字节，表示长度
                        int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 2)] intValue]*2+2;
                        length=oneCharLength;
                    }else if([[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"special"] isEqualToString:@"999"]){
                        //剩下长度
                        NSString *remainStr=[dataStr substringWithRange:NSMakeRange(location, [dataStr length]-location)];
                        //取两个字节，表示长度
                        int oneCharLength=[[remainStr substringWithRange:NSMakeRange(0, 4)] intValue]*2+4;
                        length=oneCharLength;
                    }else{
                        length=[[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"length"] intValue];
                    }
                    
                    NSLog(@"location===%d,length====%d",location,length);
                    deleteStr=[dataStr substringWithRange:NSMakeRange(location, length)];
                    location += length;
                    [arr addObject:deleteStr];
                    
                    // 60，62域的解析要单独解析
                    
                    //39域,交易结果
                    if ([[sortArr objectAtIndex:c] isEqualToString:@"39"]) {
                        NSLog(@">>>>>>>>>>>39 = [%@]", deleteStr);
                        if ([self IC_exchangeSuccess:deleteStr] ) {
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:Is_Or_Consumer];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            rebackStr=@"登陆成功";
                            rebackState=YES;
                        }else{
                            rebackStr=[self IC_exchangeResult:deleteStr];
                            rebackState=NO;
                        }
//                        break;
                    }
                    NSLog(@"位域====%@,长度=====%@,值====%@",[sortArr objectAtIndex:c],[[bitDic objectForKey:[sortArr objectAtIndex:c]] objectForKey:@"length"],deleteStr);
                }
                
                NSLog(@"arr=====+%@",arr);
                [self.delegate managerToCardState:rebackStr isSuccess:rebackState method:methodStr];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception.reason);
                rebackStr=@"查询失败";
                [self.delegate managerToCardState:rebackStr isSuccess:NO method:methodStr];
            }
            @finally {
                
            }
        }
    }

}

-(int)getlength:(NSMutableDictionary *)bitDic :(NSArray *)sortArr :(int)c :(NSMutableString * )dataStr :(int)location :(int)length
{
    
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
    return length;

}

//支付宝扫码\条码支付成功，缓存,
-(void)zhifubaoSaomaSaveMethod{
    NSString *zhifubaoliushui=[[NSUserDefaults standardUserDefaults] valueForKey:Zhifubao_search_liushui];
    NSString *zhifubaoNumber=[[NSUserDefaults standardUserDefaults] valueForKey:Zhifubao_Number];
    NSString *zhifubaoMoney=[[NSUserDefaults standardUserDefaults] valueForKey:ZhifubaoSaomaMoney];
    NSString *zhifubaoDingdanNum=[[NSUserDefaults standardUserDefaults] valueForKey:Zhifubao_Search_Order];

    NSMutableArray *resultArr=[[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:ZhifubaoTiaomaRecord]];
    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:
                       zhifubaoliushui,@"liushui",
                       zhifubaoNumber,@"card",
                       @"zhifubao",@"cardtype",
                       [NSString stringWithFormat:@"%0.2f",[zhifubaoMoney floatValue]*100],@"money",
                       [PublicInformation formatCompareDate],@"time",
                       zhifubaoDingdanNum,@"dingdan",
                       @"",@"noncard",
                       @"1",@"success",nil];
    NSLog(@"已经成功的订单zhifubaoDingdanNum======%@",zhifubaoDingdanNum);
    
//订单号，缓存支付信息
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:zhifubaoDingdanNum];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([resultArr count] > 0) {
        [resultArr insertObject:dic atIndex:0];
    }else{
        [resultArr addObject:dic];
    }
    
    NSMutableArray *newRecordArray=[[NSMutableArray alloc] initWithArray:resultArr];
    //-------------刷卡记录，保留7天
    for (int i=0; i<[resultArr count]; i++) {
        NSString *time=[PublicInformation NEWreturnUploadTime:[[resultArr objectAtIndex:i] objectForKey:@"time"]];
        NSLog(@"time====%@",time);
        if ([time isEqualToString:@"今天"]) {
        }else{
            if ([time integerValue] >= 7) {
                [newRecordArray removeObject:[resultArr objectAtIndex:i]];
            }else{
            }
        }
    }
    NSLog(@"newRecordArray===%d===%@",[newRecordArray count],newRecordArray);
    [[NSUserDefaults standardUserDefaults] setObject:newRecordArray forKey:ZhifubaoTiaomaRecord];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


//支付宝撤销、退款成功，缓存,
-(void)zhifubaoReturnMoneySaveMethod:(int)state{
//支付宝撤销、退款流水号,state=2,撤销成功；state=3，退款成功;
    
    NSString *zhifubaochexiaoliushui=[[NSUserDefaults standardUserDefaults] valueForKey:ZhifubaoChexiaoLiushui];
    NSString *zhifubaochexiaoNumber=[[NSUserDefaults standardUserDefaults] valueForKey:Zhifubao_Number];
    NSString *zhifubaochexiaoMoney=[[NSUserDefaults standardUserDefaults] valueForKey:ZhifubaoChexiaoMoney];
    NSString *zhifubaochexiaoDingdanNum=[[NSUserDefaults standardUserDefaults] valueForKey:ZhifubaoChexiaoDingdanNum];
    
    NSMutableArray *resultArr=[[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:ZhifubaoTiaomaRecord]];
    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:
                       zhifubaochexiaoliushui,@"liushui",
                       zhifubaochexiaoNumber,@"card",
                       @"zhifubao",@"cardtype",
                       [NSString stringWithFormat:@"%0.2f",[zhifubaochexiaoMoney floatValue]*100],@"money",
                       [PublicInformation formatCompareDate],@"time",
                       zhifubaochexiaoDingdanNum,@"dingdan",
                       @"",@"noncard",
                       [NSString stringWithFormat:@"%d",state],@"success",nil];
    
    if ([resultArr count] > 0) {
        [resultArr insertObject:dic atIndex:0];
    }else{
        [resultArr addObject:dic];
    }
    
    NSMutableArray *newRecordArray=[[NSMutableArray alloc] initWithArray:resultArr];
    //-------------刷卡记录，保留7天
    for (int i=0; i<[resultArr count]; i++) {
        NSString *time=[PublicInformation NEWreturnUploadTime:[[resultArr objectAtIndex:i] objectForKey:@"time"]];
        NSLog(@"time====%@",time);
        if ([time isEqualToString:@"今天"]) {
        }else{
            if ([time integerValue] >= 7) {
                [newRecordArray removeObject:[resultArr objectAtIndex:i]];
            }else{
            }
        }
    }
    NSLog(@"newRecordArray===%d===%@",[newRecordArray count],newRecordArray);
    [[NSUserDefaults standardUserDefaults] setObject:newRecordArray forKey:ZhifubaoTiaomaRecord];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


//保存消费刷卡记录(全部7天)
-(void)saveExchangeResultMethod{
    NSLog(@"stringFromHexString===%@",[PublicInformation stringFromHexString:[PublicInformation returnConsumerMoney]]);
    NSLog(@"PublicInformation===%@",[PublicInformation returnConsumerMoney]);
    NSMutableArray *resultArr=[[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:TheCarcd_Record]];
    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:
                       [PublicInformation returnLiushuiHao],@"liushui",
                       [PublicInformation returnposCard],@"card",
                       @"yinhangka",@"cardtype",
                       [NSString stringWithFormat:@"%0.2f",[[PublicInformation returnConsumerMoney] floatValue]*100],@"money",
                       [PublicInformation formatCompareDate],@"time",
                       [[NSUserDefaults standardUserDefaults] valueForKey:GetCurrentCard_NotAll],@"noncard",
                       @"1",@"success",nil];
    if ([resultArr count] > 0) {
        [resultArr insertObject:dic atIndex:0];
    }else{
        [resultArr addObject:dic];
    }
    
    NSMutableArray *newRecordArray=[[NSMutableArray alloc] initWithArray:resultArr];
//-------------刷卡记录，保留7天
    for (int i=0; i<[resultArr count]; i++) {
        NSString *time=[PublicInformation NEWreturnUploadTime:[[resultArr objectAtIndex:i] objectForKey:@"time"]];
        NSLog(@"time====%@",time);
        if ([time isEqualToString:@"今天"]) {
        }else{
            if ([time integerValue] >= 7) {
                [newRecordArray removeObject:[resultArr objectAtIndex:i]];
            }else{
            }
        }
    }
    NSLog(@"newRecordArray===%d===%@",[newRecordArray count],newRecordArray);
    [[NSUserDefaults standardUserDefaults] setObject:newRecordArray forKey:TheCarcd_Record];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//保存消费撤销刷卡记录(全部7天)
-(void)saveExchangeReturnMethod{
    NSLog(@"stringFromHexString===%@",[PublicInformation stringFromHexString:[PublicInformation returnConsumerMoney]]);
    NSLog(@"PublicInformation===%@",[PublicInformation returnConsumerMoney]);
    //保留当天数据
    NSMutableArray *resultArr=[[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:TheCarcd_Record]];
//本次刷卡撤销的流水号
     NSString *currentLiushuiStr=[[NSUserDefaults standardUserDefaults] valueForKey:Current_Liushui_Number];
//撤销的金额
    NSString *chexiaoMoneyStr=[[NSUserDefaults standardUserDefaults] valueForKey:Save_Return_Money];
    
    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:
                       currentLiushuiStr,@"liushui",
                       [PublicInformation returnposCard],@"card",
                       @"yinhangka",@"cardtype",
                       chexiaoMoneyStr,@"money",
                       [PublicInformation formatCompareDate],@"time",
                       [[NSUserDefaults standardUserDefaults] valueForKey:GetCurrentCard_NotAll],@"noncard",
                       @"0",@"success",nil];
    if ([resultArr count] > 0) {
        [resultArr insertObject:dic atIndex:0];
    }else{
        [resultArr addObject:dic];
    }
    
    NSMutableArray *newRecordArray=[[NSMutableArray alloc] initWithArray:resultArr];
    //-------------刷卡记录，保留7天
    for (int i=0; i<[resultArr count]; i++) {
        NSString *time=[PublicInformation NEWreturnUploadTime:[[resultArr objectAtIndex:i] objectForKey:@"time"]];
        NSLog(@"time====%@",time);
        if ([time isEqualToString:@"今天"]) {
        }else{
            if ([time integerValue] >= 7) {
                [newRecordArray removeObject:[resultArr objectAtIndex:i]];
            }else{
            }
        }
    }
    NSLog(@"newRecordArray===%d===%@",[newRecordArray count],newRecordArray);
    [[NSUserDefaults standardUserDefaults] setObject:newRecordArray forKey:TheCarcd_Record];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    return codeResult;
}

-(NSString *)IC_exchangeResult:(NSString *)result{
    //143030E4BAA4E69893E68890E58A9F,00成功
    NSString *theResult=result;
    NSString *codeResult=[ErrorType errInfo:[PublicInformation stringFromHexString:theResult]];
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


#pragma mark ----------位图计算
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
