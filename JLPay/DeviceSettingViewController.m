//
//  DeviceSettingViewController.m
//  JLPay
//
//  Created by jielian on 15/4/1.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "DeviceSettingViewController.h"
#import "GroupPackage8583.h"
#import "TcpClientService.h"
#import "Define_Header.h"
#import "AsyncSocket.h"
#import "IC_GroupPackage8583.h"
#import "Unpacking8583.h"
#import "Toast+UIView.h"
#import "PosLib.h"
#import "MLTableAlert.h"
#import "MBProgressHUD.h"
#import "JHNconnect.h"
#import "IPSetViewController.h"
#import "AppDelegate.h"

typedef enum {
    ACTION_UNKNOWN = 0,
    ACTION_FLOW,
    ACTION_TEST,
    ACTION_TEST_EMV,
    
} EU_POS_ACTION;

typedef enum {
    USE_UNKNOWN = 0,    // 未知
    USE_MARCARD,        // 使用磁条卡
    USE_IC,             // 使用IC卡
} EU_POS_CARDTYPE;

@interface DeviceSettingViewController ()<MBProgressHUDDelegate, wallDelegate,managerToCard,UIAlertViewDelegate>
{
    NSMutableArray *m_arrayName;
    NSMutableArray *m_arrayUUID;
    EU_POS_ACTION m_euAction;
    
    MBProgressHUD *HUD;
}

@property (assign, nonatomic) EU_POS_SESSION sessionType;
@property (assign, nonatomic) EU_POS_RESULT responceCode;
@property (strong, nonatomic) MLTableAlert *alert;
@property (strong,nonatomic)JHNconnect *JHNCON;

@end

@implementation DeviceSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设备参数设置";
    m_arrayName = [[NSMutableArray alloc] init];
    m_arrayUUID = [[NSMutableArray alloc] init];
    m_euAction = ACTION_UNKNOWN;
    
     //第一步，注册与设备通讯驱动
//     PosLib_Init();
    
     //第二步，注册SDK回调函数
//     PosLib_SetDelegate((__bridge void*)self, PosLibResponce);
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark---------------------------------------------隐藏tabbar
- (void)hideTabBar {
    if (self.tabBarController.tabBar.hidden == YES) {
        return;
    }
    UIView *contentView;
    if ( [[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] )
        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
    else
        contentView = [self.tabBarController.view.subviews objectAtIndex:0];
    contentView.frame = CGRectMake(contentView.bounds.origin.x,  contentView.bounds.origin.y,  contentView.bounds.size.width, contentView.bounds.size.height + self.tabBarController.tabBar.frame.size.height);
    self.tabBarController.tabBar.hidden = YES;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if (self.JHNCON ==NULL)
        self.JHNCON = [JHNconnect shareView];
    
    [self hideTabBar];
    
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.tabBarController.tabBar.hidden = NO;
}


#pragma mark------------------------------------------------------tableviewDelegate
/*************************************
 * 功  能 : cell的点击事件；
 * 参  数 :
 * 返  回 :
 *************************************/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NULL
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"否"
                                          otherButtonTitles:@"是", nil];
    alert.delegate     = self;
    if ([[DeviceManager sharedInstance] isConnected]) {
        NSLog(@"index.row = [%d]", indexPath.row);
        switch (indexPath.row) {
            case 0:
            {
                // 跳转到终端设置界面
                IPSetViewController* ipViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"terminalSettingVC"]; //terminalSettingVC settingIPAndPorts
                [self.navigationController pushViewController:ipViewController animated:YES];
                cell.selected = NO;
                
                return;
            }
                break;
            case 1:
                // 主密钥下载
                alert.message = @"是否下载主密钥?";
                break;
            case 2:
                // IC卡公钥下载
                alert.message = @"是否下载IC卡公钥?";
                break;
            case 3:
                // EMV参数下载
                alert.message = @"是否下载EMV参数?";
                break;
            default:
                break;
        } // END of switch (indexPath.row) {
        [alert show];
    } else { // END of if ([appdelegate.device isConnected]) {
        UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请连接设备!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alter.delegate      = self;
        [alter show];
        cell.selected = NO;
    } // else
         
}



/*************************************
 * 功  能 : cell的点击事件的提示窗口；
 * 参  数 :
 * 返  回 :
 *************************************/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // 下载主密钥
    if ([alertView.message isEqualToString: @"是否下载主密钥?"]) {
        if (buttonIndex == 1) {  // 点击了 "是"
            [[TcpClientService getInstance] sendOrderMethod:[GroupPackage8583 downloadMainKey] IP:Current_IP PORT:Current_Port Delegate:self method:@"downloadMainKey"];
        }

    } else if ([alertView.message isEqualToString: @"是否下载IC卡公钥?"]) {
        if (buttonIndex == 1) {
            
        }
        
    } else if ([alertView.message isEqualToString: @"是否下载EMV参数?"]) {
        if (buttonIndex == 1) {
            
        }
    }
    else if ([alertView.message isEqualToString: @"请连接设备!"]) {
        // 连接设备
        [[DeviceManager sharedInstance] open];
    }
    // 被点击的 Cell 恢复未点击状态
    for (int i = 0; i<[self.tableView numberOfRowsInSection:0]; i++) {
        NSIndexPath* index      = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:index];
        if (cell.selected == YES) {
            cell.selected = NO;
            break;
        }
    }
}



#pragma mark==========================================managerToCard
-(void)managerToCardState:(NSString *)type  isSuccess:(BOOL)state method:(NSString *)metStr{
    if ([metStr isEqualToString:@"tcpsignin"]) {
        if (state) {
            [self.view makeToast:type];
            //            [app_delegate signInSuccessToLogin:Selected_DeviceIndex];
        }else{
            [self.view makeToast:type];
        }
    }else if ([metStr  isEqualToString:@"terminal"]){
        if (state) {
            [self.view makeToast:type];
        }else{
            [self.view makeToast:type];
        }
    }
    else if ([metStr  isEqualToString:@"terminal_IC"]){
        //        [app_delegate dismissWaitingView];
        if (state) {
            [self.view makeToast:type];
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"success_Status_download" object:self];
        }else{
            [self.view makeToast:type];
        }
    }
    //1.1 blue pos状态上送_pos公钥下载
    else if ([metStr  isEqualToString:@"blue_gongyao_status"]){
        if (state) {
            [self.view makeToast:type];
            //1.2
            [[NSNotificationCenter defaultCenter] postNotificationName:@"success_send_download" object:self];
            
        }else{
            [self.view makeToast:type];
        }
    }
    //1.2 blue pos参数传递_pos公钥下载
    else if ([metStr  isEqualToString:@"blue_gongyaoload_statussend"]){
        if (state) {
            [self.view makeToast:type];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"success_end_download" object:self];
            
        }else{
            [self.view makeToast:type];
        }
    }
    //1.3 blue pos公钥下载结束_pos公钥下载
    else if ([metStr  isEqualToString:@"blue_gongyaoload_end"]){
        if (state) {
            [self.view makeToast:type];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"success_Status_parameterdownload" object:self];
        }else{
            [self.view makeToast:type];
        }
    }
    //主密钥下载
    else if ([metStr isEqualToString:@"downloadMainKey"]){
        if (state) {
            [self.view makeToast:type];
            // [[NSNotificationCenter defaultCenter] postNotificationName:@"success_Status_parameterdownload" object:self];
        }else{
            [self.view makeToast:type];
        }
    }
    
    //2.1 blue pos状态上送_pos参数下载
    else if ([metStr  isEqualToString:@"blue_parameter_status"]){
        if (state) {
            [self.view makeToast:type];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"success_Send_parameterdownload" object:self];
            
        }else{
            [self.view makeToast:type];
        }
    }
    //2.2 blue pos参数传递_pos参数下载
    else if ([metStr  isEqualToString:@"blue_parameterload_statussend"]){
        if (state) {
            [self.view makeToast:type];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"success_End_parameterdownload" object:self];
        }else{
            [self.view makeToast:type];
        }
    }
    //2.3 blue pos参数下载结束_pos参数下载
    else if ([metStr  isEqualToString:@"blue_parameterload_end"]){
        if (state) {
            [self.view makeToast:type];
        }else{
            [self.view makeToast:type];
        }
    }
    //3.ic签到
    else if ([metStr  isEqualToString:@"blue_signinic"]){
        if (state) {
            [self.view makeToast:type];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"success_Status_download" object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"success_send_download" object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"success_Status_parameterdownload" object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"success_Status_parameterdownload" object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"success_Send_parameterdownload" object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"success_End_parameterdownload" object:nil];
            
            //            [app_delegate signInSuccessToLogin:Selected_DeviceIndex];
        }else{
            [self.view makeToast:type];
        }
    }
}

#pragma mark==========================================wallDelegate
-(void)receiveGetData:(NSString *)data method:(NSString *)str{
    NSLog(@"app---------------------------------%@",str);
    //签到成功
    if ([str  isEqualToString:@"tcpsignin"]) {
        //        [app_delegate dismissWaitingView];
        if ([data length] > 0) {
            [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
        }else{
            [self.view makeToast:@"签到失败，请重新签到"];
        }
    }
    //磁条卡_终端初始化成功
    else if ([str  isEqualToString:@"terminal"]){
        //        [app_delegate dismissWaitingView];
        if ([data length] > 0) {
            [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
        }else{
            [self.view makeToast:@"参数更新失败"];
        }
    }
    //IC卡_终端初始化成功
    else if ([str  isEqualToString:@"terminal_IC"]){
        //[app_delegate dismissWaitingView];
        if ([data length] > 0) {
            [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
        }else{
            [self.view makeToast:@"参数更新失败"];
        }
    }
    //blue pos状态上送_pos公钥下载
    else if ([str  isEqualToString:@"blue_gongyao_status"]){
        if ([data length] > 0) {
            [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
        }else{
            [self.view makeToast:@"公钥下载状态上传失败"];
        }
    }
    //1.2 blue pos参数传递_pos公钥下载
    else if ([str  isEqualToString:@"blue_gongyaoload_statussend"]){
        if ([data length] > 0) {
            [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
        }else{
            [self.view makeToast:@"pos参数传递失败"];
        }
    }
    //1.3 blue pos参数传递_pos公钥下载
    else if ([str  isEqualToString:@"blue_gongyaoload_end"]){
        if ([data length] > 0) {
            [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
        }else{
            [self.view makeToast:@"pos公钥下载失败"];
        }
    }
    //主密钥下载
    else if ([str isEqualToString:@"downloadMainKey"]){
        if ([data length] > 0) {
            [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
        }else{
            [self.view makeToast:@"主密钥下载失败"];
        }
    }
    //2.1 blue pos状态上送_pos参数下载
    else if ([str  isEqualToString:@"blue_parameter_status"]){
        if ([data length] > 0) {
            [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
        }else{
            [self.view makeToast:@"pos状态上送失败"];
        }
    }
    //2.2 blue pos参数传递_pos参数下载
    else if ([str  isEqualToString:@"blue_parameterload_statussend"]){
        if ([data length] > 0) {
            [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
        }else{
            [self.view makeToast:@"pos参数传递失败"];
        }
    }
    //2.3 blue pos参数下载结束_pos参数下载
    else if ([str  isEqualToString:@"blue_parameterload_end"]){
        //        [app_delegate dismissWaitingView];
        if ([data length] > 0) {
            [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
        }else{
            [self.view makeToast:@"pos参数下载失败"];
        }
    }
    //3.ic签到
    else if ([str  isEqualToString:@"blue_signinic"]){
        if ([data length] > 0) {
            [[Unpacking8583 getInstance] unpackingSignin:data method:str getdelegate:self];
        }else{
            [self.view makeToast:@"IC卡签到失败"];
        }
    }
}

-(void)falseReceiveGetDataMethod:(NSString *)str{
    //    [app_delegate dismissWaitingView];
    //签到
    if ([str  isEqualToString:@"tcpsignin"]) {
        [self.view makeToast:@"连接超时，请重新签到"];
    }
    //终端初始化
    else if([str  isEqualToString:@"terminal"]){
        [self.view makeToast:@"连接超时，请重新初始化终端"];
    }
    else if([str  isEqualToString:@"terminal_IC"]){
        [self.view makeToast:@"连接超时，请重新初始化终端"];
    }
    //2.1blue pos状态上送_pos参数下载
    else if ([str  isEqualToString:@"blue_parameter_status"]){
        [self.view makeToast:@"连接超时，pos状态上送失败"];
    }
    //2.2 blue pos参数传递_pos参数下载
    else if ([str  isEqualToString:@"blue_parameterload_statussend"]){
        [self.view makeToast:@"连接超时，pos参数传递失败"];
    }
    //2.3 blue pos参数下载结束_pos参数下载
    else if ([str  isEqualToString:@"blue_parameterload_end"]){
        [self.view makeToast:@"连接超时，pos参数下载失败"];
    }
    //3.ic签到
    else if ([str  isEqualToString:@"blue_signinic"]){
        [self.view makeToast:@"IC卡签到失败"];
    }
    
}


#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    HUD = nil;
}



#pragma mark------------------------------------------xin80
#if 0
-(void)AlertMsg: (NSString *)msg
{
    UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"提示" message: msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alter show];
}


-(void) actionFlow
{
    static EU_POS_CARDTYPE cardType = USE_UNKNOWN;
    
    // 开启读卡器
    if (self.sessionType == SESSION_OPEN_CARD) {
        EU_MSR_OPENCARD_RESP resp = OpenCardResp();
        NSLog(@"EU_MSR_OPENCARD_RESP = %d", resp);
        if (resp == RESP_OPENCARD_INSERT) {
            // IC卡插入
            //            [ProgressHUD show: @"准备读取IC卡"];
            cardType = USE_IC;
            StartEmv(1000, 0, FUNC_SALE, ECASH_FORBIT, PBOC_FULL, ONLINE_YES);
        } else if (resp == RESP_OPENCARD_USERCANCEL){
            [self AlertMsg: @"用户取消"];
        } else if (resp == RESP_OPENCARD_FINISH) {
            //            [ProgressHUD show: @"准备读磁条卡"];
            cardType = USE_MARCARD;
            ReadMagcard(READ_TRACK_COMBINED, READ_NOMASK);
        }
        return;
    }
    // 读磁条卡
    if (self.sessionType == SESSION_READ_CARD) {
        ST_READ_CARD *pstRet = ReadMagcardResp();
        if (pstRet->resp == RESP_READCARD_SUCC) {
            // 读卡成功
            NSLog(@"Account: %s\nPeroid: %s\nServiceCode: %s\n\
                  Track2Size: %d, nTrack3Size: %d\n\
                  Track2Data: %s\nTrack3Data: %s\n"
                  , pstRet->szAccount, pstRet->szPeriod, pstRet->szServiceCode
                  , pstRet->cTrack2Size, pstRet->cTrack3Size
                  , pstRet->szTrack2data, pstRet->szTrack3data);
            
            InputPin(8, 60, "123456789012345678");
        }
        return;
    }
    
    // START_EMV
    if (self.sessionType == SESSION_START_EMV) {
        ST_START_EMV *pstRet = StartEmvResp();
        if (pstRet->resp == RESP_EMV_SUCC) {
            if (pstRet->pinReq == PIN_EMV_REQ) {
                // 密码要求
                InputPin(8, 60, "123456789012345678");
            }
        } else {
            [self AlertMsg: @"IC卡处理失败"];
        }
        return;
    }
    
    // 密码输入
    if (self.sessionType == SESSION_INPUT_PIN) {
        ST_INPUT_PIN *pstRet = InputPinResp();
        NSLog(@"keyType=%d, pwdLen=%d\n, block=%02x%02x%02x%02x%02x%02x%02x%02x\n"
              , pstRet->keyType, pstRet->pwdLen
              , pstRet->pPinblock[0], pstRet->pPinblock[1], pstRet->pPinblock[2], pstRet->pPinblock[3]
              , pstRet->pPinblock[4], pstRet->pPinblock[5], pstRet->pPinblock[6], pstRet->pPinblock[7]);
        
        //char pData8583[1024] = "";
        //int nDataLen = 0;
        //        [ProgressHUD showSuccess: @"密码输入完毕，请组包"];
        
        if (cardType == USE_MARCARD) {
            // 磁条卡处理
            /**
             根据返回数据组8583包，此处省略...
             */
            //CalMac(MACALG_EBC, pData8583, nDataLen);
            /**
             与POSP通讯，此处省略...
             */
            [self AlertMsg: @"卡片余额为：1000"];
        } else if (cardType == USE_IC) {
            // IC卡处理
            /**
             根据返回数据组8583包，此处省略...
             */
            
            //GetEmvData(pData8583, nDataLen);
            
            /*
             * 根据返回数据组8583包，此处省略，pData8583假定为数据包
             */
            //CalMac(MACALG_EBC, pData8583, nDataLen);
            
            [self AlertMsg: @"卡片余额为：2000"];
        }
        return;
    }
    
    if (self.sessionType == SESSION_CALC_MAC) {
        ST_CALC_MAC *pstRet = CalcMacResp();
        [self AlertMsg: [NSString stringWithFormat: @"MAC=%02x%02x%02x%02x%02x%02x%02x%02x"
                         , pstRet->szMac[0], pstRet->szMac[1], pstRet->szMac[2], pstRet->szMac[3]
                         , pstRet->szMac[4], pstRet->szMac[5], pstRet->szMac[6], pstRet->szMac[7]] ];
    }
}

-(void) actionTestEmv
{
    // 开启读卡器
    if (self.sessionType == SESSION_OPEN_CARD) {
        EU_MSR_OPENCARD_RESP resp = OpenCardResp();
        NSLog(@"EU_MSR_OPENCARD_RESP = %d", resp);
        if (resp == RESP_OPENCARD_INSERT) {
            // IC卡插入
            //            [ProgressHUD show: @"正在读取IC卡信息"];
            StartEmv(1000, 0, FUNC_SALE, ECASH_FORBIT, PBOC_FULL, ONLINE_YES);
        } else {
            [self AlertMsg: @"请插入IC卡"];
        }
    }
    // START_EMV
    if (self.sessionType == SESSION_START_EMV) {
        ST_START_EMV *pstRet = StartEmvResp();
        if (pstRet->resp == RESP_EMV_SUCC) {
            //执行成功，打包55域显示
            /*
             unsigned char tagBuff[256];
             unsigned int tagLength = 0;
             GetEmvData(tagBuff, tagLength);
             */
        } else {
            [self AlertMsg: @"IC卡处理失败"];
        }
        return;
    }
    //
    if (self.sessionType == SESSION_SET_DATA) {
        unsigned int nLength = 0;
        char *data = GetEmvDataResp(&nLength);
        if (nLength > 0) {
            NSMutableString *hex = [NSMutableString string];
            char temp[3];
            int i = 0;
            
            for (i = 0; i < nLength; i++) {
                temp[0] = temp[1] = temp[2] = 0;
                (void)sprintf(temp, "%02x", data[i]);
                [hex appendString:[NSString stringWithUTF8String:temp]];
            }
            
            [self AlertMsg: hex];
        }
    }
}

- (NSString *)hexval: (const unsigned char *)bytes byteLength: (unsigned int)length strSize: (unsigned int) size
{
    NSMutableString *hex = [NSMutableString string];
    char temp[3];
    int i = 0;
    
    for (i = 0; i < length; i++) {
        temp[0] = temp[1] = temp[2] = 0;
        (void)sprintf(temp, "%02x", bytes[i]);
        [hex appendString:[NSString stringWithUTF8String:temp]];
    }
    //NSLog(@"hex(%d)=%@", [hex length], hex);
    if ([hex length] > size) {
        hex = [hex substringToIndex: size];
    }
    return hex;
}
-(void)alertOpenCardResp
{
    [self AlertMsg: [NSString stringWithFormat: @"EU_MSR_OPENCARD_RESP = 0x%02x", OpenCardResp()]];
}
-(void)alertReadCardResp
{
    ST_READ_CARD *pstRet = ReadMagcardResp();
    
    [self AlertMsg: [NSString stringWithFormat:@"Account: %s\nPeroid: %s\nServiceCode: %s\n\Track2Size: 0x%02x\nTrack3Size: 0x%02x\n\Track2Data: %@\nTrack3Data: %@\n"
                     , pstRet->szAccount, pstRet->szPeriod, pstRet->szServiceCode
                     , pstRet->cTrack2Size, pstRet->cTrack3Size
                     , [self hexval: pstRet->szTrack2data byteLength: pstRet->nTrack2Length strSize: pstRet->cTrack2Size]
                     , [self hexval: pstRet->szTrack3data byteLength: pstRet->nTrack3Length strSize: pstRet->cTrack3Size]]];
}
-(void)alertInputPinResp
{
    ST_INPUT_PIN *pstRet = InputPinResp();
    [self AlertMsg: [NSString stringWithFormat: @"keyType=0x%02x, pwdLen=0x%02x\n, block=%02x%02x%02x%02x%02x%02x%02x%02x"
                     , pstRet->keyType, pstRet->pwdLen
                     , pstRet->pPinblock[0], pstRet->pPinblock[1], pstRet->pPinblock[2], pstRet->pPinblock[3]
                     , pstRet->pPinblock[4], pstRet->pPinblock[5], pstRet->pPinblock[6], pstRet->pPinblock[7]] ];
}
-(void)alertCalcMacResp
{
    ST_CALC_MAC *pstRet = CalcMacResp();
    [self AlertMsg: [NSString stringWithFormat: @"MAC = %02x%02x%02x%02x%02x%02x%02x%02x"
                     , pstRet->szMac[0], pstRet->szMac[1], pstRet->szMac[2], pstRet->szMac[3]
                     , pstRet->szMac[4], pstRet->szMac[5], pstRet->szMac[6], pstRet->szMac[7]] ];
}
-(void)alertReadPosInfoResp
{
    ST_GET_DEVINFO *pstRet = ReadPosInfoResp();
    [self AlertMsg: [NSString stringWithFormat: @"SN = %s\nSTAT = 0x%02x\nVersion = %s\nCustomInfo = %s"
                     , pstRet->szSN, (unsigned char)pstRet->status, pstRet->szVer, pstRet->szInfo] ];
}
-(void)alertVersion
{
    ST_GET_DEVINFO *pstRet = ReadPosInfoResp();
    [self AlertMsg: [NSString stringWithFormat: @"SDK不支持当前POS版本号\n请升级 POS 程序版本\n\nSN = %s\nSTAT = 0x%02x\nVersion = %s\nCustomInfo = %s", pstRet->szSN, (unsigned char)pstRet->status, pstRet->szVer, pstRet->szInfo] ];
}
-(void)alertGetRandomNumResp
{
    ST_GET_RANDNUM *pstRet = GetRandomNumResp();
    [self AlertMsg: [NSString stringWithFormat: @"RandomNum = %02x%02x%02x%02x%02x%02x%02x%02x"
                     , pstRet->szRandNum[0], pstRet->szRandNum[1], pstRet->szRandNum[2], pstRet->szRandNum[3]
                     , pstRet->szRandNum[4], pstRet->szRandNum[5], pstRet->szRandNum[6], pstRet->szRandNum[7]] ];
}
-(void)alertGetDatetimeResp
{
    [self AlertMsg: [NSString stringWithFormat: @"Datetime = %s", GetDatetimeResp()->szDatetime] ];
}
-(void)alertUpgradeResp
{
    NSLog(@"Upgrade: %d / %d", PosLib_GetUpgradePos(), PosLib_GetUpgradeLength());
    if (self.responceCode == RET_UPGRADE) {
        //        [ProgressHUD show:
        //         [NSString stringWithFormat: @"正在升级(%d / %d)", PosLib_GetUpgradePos(), PosLib_GetUpgradeLength()]];
    } else if (self.responceCode == RET_UPGRADE_FINISH) {
        [self AlertMsg: @"升级完成"];
    }
}
-(void)alertSetICKey
{
    unsigned int nRet = 0;
    char *pRet = ICPublicKeyManageResp(&nRet);
    [self AlertMsg: @"设置成功"];
}
-(void)alertSetAIDParam
{
    unsigned int nRet = 0;
    char *pRet = ICAidManageResp(&nRet);
    [self AlertMsg: @"设置成功"];
}
-(void)alertLoadKek
{
    [self AlertMsg: [NSString stringWithFormat: @"EU_MSR_RESP = 0x%02x", LoadKekResp()]];
}
-(void)alertMainKey
{
    [self AlertMsg: [NSString stringWithFormat: @"EU_MSR_RESP = 0x%02x", LoadMainKeyResp()]];
}

-(void)showTableAlert
{
    //    [ProgressHUD dismiss];
    [HUD hide:YES];
    
    if (self.sessionType == SESSION_SCAN_STOP) {
        [m_arrayName removeAllObjects];
        [m_arrayUUID removeAllObjects];
        
        //NSString *lists = @"L-M35-117787, L-M35-654127, L-M35-000001";
        NSString *lists = [NSString stringWithFormat: @"%s", PosLib_GetDevList()];
        NSLog(@"%s: %@", __FUNCTION__, lists);
        
        if ([lists length] < 1) {
            UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未发现可见的蓝牙设备" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            return;
        }
        
        while (1) {
            NSRange range = [lists rangeOfString: @"; "];
            if (range.length > 0) {
                NSString *str = [lists substringToIndex: range.location];
                //NSLog(@"str: %@", str);
                NSRange rrr = [str rangeOfString: @","];
                if (rrr.length > 0) {
                    NSString *name = [str substringToIndex: rrr.location];
                    name = [name substringFromIndex: 1];
                    NSString *uuid = [str substringFromIndex: rrr.location + 1];
                    uuid = [uuid substringToIndex: [uuid length] - 1];
                    
                    NSLog(@"%@: %@", name, uuid);
                    
                    [m_arrayName addObject: name];
                    [m_arrayUUID addObject: uuid];
                }
                
                
                lists = [lists substringFromIndex: range.location + range.length];
                //NSLog(@"lists: %@", lists);
            } else {
                break;
            }
        }
        NSString *str = [NSString stringWithFormat:@"%@", lists];
        //NSLog(@"UUID: %@", name);
        NSRange rrr = [str rangeOfString: @","];
        if (rrr.length > 0) {
            NSString *name = [str substringToIndex: rrr.location];
            name = [name substringFromIndex: 1];
            NSString *uuid = [str substringFromIndex: rrr.location + 1];
            uuid = [uuid substringToIndex: [uuid length] - 1];
            
            NSLog(@"%@: %@", name, uuid);
            
            [m_arrayName addObject: name];
            [m_arrayUUID addObject: uuid];
        }
        
        // create the alert
        self.alert = [MLTableAlert tableAlertWithTitle:@"请选择设备" cancelButtonTitle:@"取消"
                                          numberOfRows:^NSInteger (NSInteger section) {
                                              return [m_arrayName count];
                                          }
                                              andCells:^UITableViewCell* (MLTableAlert *anAlert, NSIndexPath *indexPath) {
                                                  static NSString *CellIdentifier = @"CellIdentifier";
                                                  UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
                                                  if (cell == nil)
                                                      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                                                  
                                                  cell.textLabel.text = [NSString stringWithFormat:@"%@", [m_arrayName objectAtIndex: indexPath.row]];
                                                  
                                                  return cell;
                                              }];
        
        // Setting custom alert height
        self.alert.height = 300;
        
        // configure actions to perform
        [self.alert configureSelectionBlock:^(NSIndexPath *selectedIndex){
            connectPos([[m_arrayUUID objectAtIndex: selectedIndex.row] UTF8String]);
            //            [ProgressHUD show: @"正在连接设备"];
        } andCompletionBlock:^{
            //self.navigationItem.title = @"Cancel Button Pressed\nNo Cells Selected";
        }];
        
        // show the alert
        [self.alert show];
    }
}


static void PosLibResponce(void *userData,
                           EU_POS_SESSION sessionType,
                           EU_POS_RESULT responceCode)
{
    DeviceSettingViewController *self = (__bridge DeviceSettingViewController*)userData;
    
    self.sessionType=sessionType;
    self.responceCode=responceCode;
    
    [self performSelectorOnMainThread:@selector(deviceStatus) withObject:nil waitUntilDone:NO];
    
    NSLog(@"PosLib_Responce sessionType: %d responceCode: %d",sessionType,responceCode);
}
- (void) deviceStatus
{
    NSLog(@"deviceStatus sessionType: %d responceCode: %d",self.sessionType,self.responceCode);
    
    if (self.responceCode != RET_UPGRADE)
        //        [ProgressHUD dismiss];
        
        if (self.sessionType == SESSION_SCAN_STOP) {
            [self performSelectorOnMainThread:@selector(showTableAlert) withObject:nil waitUntilDone:NO];
        } else if (self.sessionType == SESSION_CONN_VALID) {
            
            ReadPosInfo();
        } else if (self.sessionType == SESSION_CONN_INVALID) {
            
        } else if (self.sessionType == SESSION_DISCONNECT) {
            
        }
    
    if (self.responceCode == RET_TIMEOUT) {
        [self AlertMsg: @"POS读取超时"];
    } else if (self.responceCode == RET_USER_CANCEL) {
        [self AlertMsg: @"用户取消"];
    } else if (self.responceCode == RET_VERSION_NULL) {
        [self AlertMsg: @"请先获取POS版本号"];
    } else if (self.responceCode == RET_VERSION_ERR) {
        [self alertVersion];
    } else if (self.responceCode == RET_FILE_NOT_FOUND) {
        [self AlertMsg: @"找不到文件"];
    } else if (self.responceCode < 0) {
        [self AlertMsg: [NSString stringWithFormat: @"操作处理错误: %d", self.responceCode] ];
    } else if (self.responceCode > RET_RESULT) {
        if (m_euAction == ACTION_UNKNOWN) {
            return;
        }
        if (m_euAction == ACTION_FLOW) {
            [self actionFlow];
            return;
        } else if (m_euAction == ACTION_TEST_EMV) {
            [self actionTestEmv];
            return;
        }
        if (self.sessionType == SESSION_OPEN_CARD) {
            [self alertOpenCardResp];
        } else if (self.sessionType == SESSION_READ_CARD) {
            [self alertReadCardResp];
        } else if (self.sessionType == SESSION_INPUT_PIN) {
            [self alertInputPinResp];
        } else if (self.sessionType == SESSION_CALC_MAC) {
            [self alertCalcMacResp];
        } else if (self.sessionType == SESSION_GET_DEVINFO) {
            [self alertReadPosInfoResp];
        } else if (self.sessionType == SESSION_GET_RANDNUM) {
            [self alertGetRandomNumResp];
        } else if (self.sessionType == SESSION_GET_DATETIME) {
            [self alertGetDatetimeResp];
        } else if (self.sessionType == SESSION_UPGRADE) {
            [self alertUpgradeResp];
        } else if (self.sessionType == SESSION_SET_ICKEY) {
            [self alertSetICKey];
        } else if (self.sessionType == SESSION_SET_AID) {
            [self alertSetAIDParam];
        } else if (self.sessionType == SESSION_KEK_DOWNLOAD) {
            [self alertLoadKek];
        } else if (self.sessionType == SESSION_MKEY_DOWNLOAD) {
            [self alertMainKey];
        }
    }
}

#endif

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



@end
