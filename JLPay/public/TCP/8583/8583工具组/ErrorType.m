//
//  ErrorType.m
//  PosN38Universal
//
//  Created by work on 14-8-12.
//  Copyright (c) 2014年 newPosTech. All rights reserved.
//

#import "ErrorType.h"

/**
 * @author songwei
 * @date 2014-7-18
 * @version V1.0
 * @description
 * 交易返回POS终端时都有39
 * 域，POS终端和终端操作员根据应答码要采取相应的操作，可以
 *  把操作分为以下几类：
 *  A：交易成功
 *  B：交易失败，可重试
 *  C：交易失败，不需要重试
 *  D：交易失败,终端操作员处理
 *  E：交易失败,系统故障，不需要重试
 *  注
 *  1：如果39域的内容不能在下表中找到，就显示“交易失败”
 *  2：如果POS交易的批次号和网络中心批次号不一致时应答码会填“77”，此时POS机应当提示操作员重新签到，再作交易。
 */

@implementation ErrorType

+(NSString *)errInfo:(NSString *)codeErr{
    NSArray *arr00=@[@"00",@"A",@"承兑或交易成功",@"交易成功"];
    NSArray *arr01=@[@"01",@"C",@"查发卡行",@"请持卡人与发卡银行联系"];
    NSArray *arr03=@[@"03",@"C",@"无效商户",@"无效商户"];
    NSArray *arr04=@[@"04",@"D",@"没收卡",@"此卡被没收"];
    NSArray *arr05=@[@"05",@"C",@"身份认证失败",@"持卡人认证失败"];
    NSArray *arr10=@[@"10",@"A",@"部分承兑",@"显示部分批准金额，提示操作员"];
    NSArray *arr11=@[@"11",@"A",@"重要人物批准（VIP）",@"成功，VIP客户"];
    NSArray *arr12=@[@"12",@"C",@"无效的关联交易",@"无效交易"];
    NSArray *arr13=@[@"13",@"B",@"金额为0或其他非法值",@"无效金额"];
    NSArray *arr14=@[@"14",@"B",@"无效卡号（无此账号）",@"无效卡号"];
    NSArray *arr15=@[@"15",@"C",@"无此发卡方",@"此卡无对应发卡方"];
    NSArray *arr21=@[@"21",@"C",@"卡未初始化",@"该卡未初始化或睡眠卡"];
    NSArray *arr22=@[@"22",@"C",@"故障怀疑，关联交易错误",@"该卡未初始化或睡眠卡"];
    NSArray *arr25=@[@"25",@"C",@"找不到原始交易",@"没有原始交易，请联系发卡方"];
    NSArray *arr30=@[@"30",@"C",@"报文格式错误",@"请重试"];
    NSArray *arr34=@[@"34",@"D",@"有作弊嫌疑",@"作弊卡，吞卡"];
    NSArray *arr38=@[@"38",@"D",@"超过允许输入PIN值范围",@"密码输入错误次数超限，请与发卡方联系"];
    NSArray *arr40=@[@"40",@"C",@"请求的功能尚不支持",@"发卡方不支持交易类型"];
    NSArray *arr41=@[@"41",@"D",@"挂失卡",@"挂失卡，请没收"];
    
    NSArray *arr43=@[@"43",@"D",@"被窃卡",@"被窃卡，请没收"];
    NSArray *arr45=@[@"45",@"D",@"使用芯片方式读卡",@"使用芯片方式读卡"];
    NSArray *arr51=@[@"51",@"C",@"资金不足",@"可用余额不足"];
    NSArray *arr54=@[@"54",@"C",@"过期卡",@"该卡已过期"];
    NSArray *arr55=@[@"55",@"C",@"密码错误",@"密码错误"];
    NSArray *arr57=@[@"57",@"C",@"不允许持卡人进行交易",@"不允许此卡交易"];
    NSArray *arr58=@[@"58",@"C",@"不允许终端进行的交易",@"发卡方不允许该卡在本终端进行交易"];
    NSArray *arr59=@[@"59",@"C",@"有作弊嫌疑",@"卡片校验错"];
    NSArray *arr61=@[@"61",@"C",@"超出金额限制",@"交易金额超限"];
    NSArray *arr62=@[@"62",@"C",@"受限制的卡",@"受限制的卡"];
    NSArray *arr64=@[@"64",@"C",@"原始金额错误",@"交易金额与原交易不匹配"];
    NSArray *arr65=@[@"65",@"C",@"超出消费次数限制",@"超出消费次数限制"];
    NSArray *arr68=@[@"68",@"C",@"发卡行响应超时",@"交易超时，请重试"];
    NSArray *arr75=@[@"75",@"C",@"允许的输入PIN次数超限",@"密码输入错误次数超限"];
    NSArray *arr77=@[@"77",@"D",@"交易的批次号和网络中心批次号不一致",@"请重新签到，再作交易"];
    NSArray *arr90=@[@"90",@"C",@"正在日中处理",@"系统日切，请稍后重试"];
    NSArray *arr91=@[@"91",@"C",@"发卡方不能操作",@"发卡方状态不正常，请稍后重试"];
    NSArray *arr92=@[@"92",@"C",@"金融机构或中间网络设置找不到或无法达到",@"发卡方线路异常，请稍后重试"];
    NSArray *arr94=@[@"94",@"C",@"重复交易",@"拒绝，重复交易，请稍后重试"];
    NSArray *arr96=@[@"96",@"C",@"银联处理中心系统异常、失效",@"拒绝，交易中心异常，请稍后重试"];
    NSArray *arr97=@[@"97",@"D",@"POS终端号找不到",@"终端未登记"];
    NSArray *arr98=@[@"98",@"E",@"银联处理中心收不到发卡方应答码",@"发卡方超时"];
    NSArray *arr99=@[@"99",@"B",@"PIN格式错",@"PIN格式错，请重新签到"];
    NSArray *arrA0=@[@"A0",@"B",@"MAC鉴别失效",@"MAC校验错，请重新签到"];
    NSArray *arrA1=@[@"A1",@"C",@"转账货币不一致",@"转账货币不一致"];
    NSArray *arrA2=@[@"A2",@"A",@"有缺陷成功",@"交易成功，请向发卡行确认"];
    NSArray *arrA3=@[@"A3",@"C",@"资金到账行，无此账户",@"账户不正确"];
    NSArray *arrA4=@[@"A4",@"A",@"有缺陷成功",@"交易成功，请向发卡行确认"];
    NSArray *arrA5=@[@"A5",@"A",@"有缺陷成功",@"交易成功，请向发卡行确认"];
    NSArray *arrA6=@[@"A6",@"A",@"有缺陷成功",@"交易成功，请向发卡行确认"];
    NSArray *arrA7=@[@"A7",@"C",@"安全处理失败",@"拒绝，交易中心异常，请稍后重试"];
    NSArray *arrT1=@[@"T1",@"C",@"安全处理失败",@"T+1商户不允许做T+0交易"];
    NSArray *arrT2=@[@"T2",@"C",@"安全处理失败",@"T+0商户未结算过T+1交易"];
    NSArray *arrTS=@[@"TS",@"C",@"安全处理失败",@"商户结算表无商户设置"];
    NSArray *arrT3=@[@"T3",@"C",@"安全处理失败",@"银行卡片未经T+0卡验证"];

    
    NSMutableArray *bigArr=[[NSMutableArray alloc] initWithObjects:arr00,arr01,arr03,arr04,arr05,arr10,arr11,arr12,arr13,arr14,arr15,arr21,arr22,arr25,arr30,arr34,arr38,arr40,arr41,arr43, arr45,arr51,arr54,arr55,arr57,arr58,arr59,arr61,arr62,arr64,arr65,arr68,arr75,arr77,arr90,arr91,arr92,arr94,arr96,arr97,arr98,arr99,arrA0,arrA1,arrA2,arrA3,arrA4,arrA5,arrA6,arrA7,arrT1,arrT2,arrTS, nil];
    [bigArr addObject:arrT3];
    
    NSString *errStr=@"";
    for (NSMutableArray *theArr in bigArr) {
        if ([codeErr isEqualToString:[theArr objectAtIndex:0]]) {
            errStr=[theArr objectAtIndex:3];
        }
    }
    return errStr;
}

@end
