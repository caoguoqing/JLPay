//
//  WisePadController.h
//  WisePadAPI
//
//  Created by Alex Wong on 2015-01-02.
//  Copyright 2015 BBPOS LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef enum {
    WisePadControllerState_CommLinkUninitialized,
    WisePadControllerState_Idle,
    WisePadControllerState_WaitingForResponse,
    WisePadControllerState_Printing //Added in 2.1.0
} WisePadControllerState;

typedef enum {
    WisePadBatteryStatus_Low,
    WisePadBatteryStatus_CriticallyLow
} WisePadBatteryStatus;

typedef enum {
    WisePadEmvOption_Start,
    WisePadEmvOption_StartWithForceOnline
} WisePadEmvOption;

typedef enum {
    WisePadCheckCardResult_NoCard,
    WisePadCheckCardResult_InsertedCard,
    WisePadCheckCardResult_NotIccCard,
    WisePadCheckCardResult_BadSwipe,
    WisePadCheckCardResult_SwipedCard,
    WisePadCheckCardResult_MagHeadFail,
    WisePadCheckCardResult_NoResponse,
    WisePadCheckCardResult_OnlyTrack2
} WisePadCheckCardResult;

typedef enum {
    WisePadErrorType_InvalidInput,
    WisePadErrorType_InvalidInput_NotNumeric,
    WisePadErrorType_InvalidInput_InputValueOutOfRange,
    WisePadErrorType_InvalidInput_InvalidDataFormat,
    WisePadErrorType_InvalidInput_NoAcceptAmountForThisTransactionType,
    WisePadErrorType_InvalidInput_NotAcceptCashbackForThisTransactionType,
    
    WisePadErrorType_DeviceReset,
    WisePadErrorType_CommandNotAvailable,
    WisePadErrorType_CommError,
    WisePadErrorType_Unknown,
    WisePadErrorType_IllegalStateException,
    
    WisePadErrorType_BTv2FailToStart,
    WisePadErrorType_BTv4FailToStart,
    
    WisePadErrorType_InvalidFunctionInBTv2Mode,
    WisePadErrorType_InvalidFunctionInBTv4Mode,
    
    WisePadErrorType_CommLinkUninitialized,
    WisePadErrorType_BTv4Unsupported,       //Added in 1.1.0
    WisePadErrorType_DeviceError,           //Added in 1.1.0
    
    WisePadErrorType_InvalidFunctionInAudioMode, //Added in 2.1.0
    WisePadErrorType_BTv4AlreadyConnected,  //Added in 2.4.0
    
    WisePadErrorType_DeviceBusy             //Added in 2.7.0-Beta3
} WisePadErrorType;

typedef enum {
    WisePadTransactionResult_Approved,
    WisePadTransactionResult_Terminated,
    WisePadTransactionResult_Declined,
    WisePadTransactionResult_SetAmountCancelOrTimeout,
    WisePadTransactionResult_CapkFail,
    WisePadTransactionResult_NotIcc,
    WisePadTransactionResult_SelectApplicationFail,
    WisePadTransactionResult_TdkError,
    WisePadTransactionResult_ApplicationBlocked,    //Added in 2.2.0
    WisePadTransactionResult_IccCardRemoved         //Added in 2.4.3
} WisePadTransactionResult;

typedef enum {
    WisePadTransactionType_Goods,
    WisePadTransactionType_Services,
    WisePadTransactionType_Cashback,
    WisePadTransactionType_Inquiry,
    WisePadTransactionType_Transfer,
    WisePadTransactionType_Payment,
    WisePadTransactionType_Refund   //Added in 2.4.3
} WisePadTransactionType;

typedef enum {
    WisePadReferProcessResult_Approved,
    WisePadReferProcessResult_Declined
} WisePadReferProcessResult;

typedef enum {
    WisePadDisplayText_AMOUNT_OK_OR_NOT,
    WisePadDisplayText_APPROVED,
    WisePadDisplayText_CALL_YOUR_BANK,
    WisePadDisplayText_CANCEL_OR_ENTER,
    WisePadDisplayText_CARD_ERROR,
    WisePadDisplayText_DECLINED,
    WisePadDisplayText_ENTER_PIN,
    WisePadDisplayText_INCORRECT_PIN,
    WisePadDisplayText_INSERT_CARD,
    WisePadDisplayText_NOT_ACCEPTED,
    WisePadDisplayText_PIN_OK,
    WisePadDisplayText_PLEASE_WAIT,
    WisePadDisplayText_PROCESSING_ERROR,
    WisePadDisplayText_REMOVE_CARD,
    WisePadDisplayText_USE_CHIP_READER,
    WisePadDisplayText_USE_MAG_STRIPE,
    WisePadDisplayText_TRY_AGAIN,
    WisePadDisplayText_REFER_TO_YOUR_PAYMENT_DEVICE,
    WisePadDisplayText_TRANSACTION_TERMINATED,
    WisePadDisplayText_TRY_ANOTHER_INTERFACE,
    WisePadDisplayText_ONLINE_REQUIRED,
    WisePadDisplayText_PROCESSING,
    WisePadDisplayText_WELCOME,
    WisePadDisplayText_PRESENT_ONLY_ONE_CARD,
    WisePadDisplayText_LAST_PIN_TRY,
    WisePadDisplayText_CAPK_LOADING_FAILED,
    WisePadDisplayText_SELECT_ACCOUNT //Added in 2.4.5
} WisePadDisplayText;

typedef enum {
    WisePadPinEntryResult_PinEntered,               //For both EMV and SwipeCard
    WisePadPinEntryResult_Cancel,                   //For both EMV and SwipeCard
    WisePadPinEntryResult_Timeout,                  //For both EMV and SwipeCard
    WisePadPinEntryResult_KeyError,                 //For SwipeCard only
    WisePadPinEntryResult_ByPass,                   //For EMV only
    WisePadPinEntryResult_NoPin,                    //For SwipeCard only            //Added in 1.4.0-Beta3
    WisePadPinEntryResult_WrongPinLength,           //For SwipeCard only            //Added in 1.4.0-Beta3
    WisePadPinEntryResult_IncorrectPin              //For EMV only                  //Added in 2.1.0
    //WisePadPinEntryResult_NoPinOrWrongPinLength   //Deprecated in 1.4.0-Beta3
} WisePadPinEntryResult;

typedef enum {
    CurrencyCharacter_A, CurrencyCharacter_B, CurrencyCharacter_C, CurrencyCharacter_D, CurrencyCharacter_E,
    CurrencyCharacter_F, CurrencyCharacter_G, CurrencyCharacter_H, CurrencyCharacter_I, CurrencyCharacter_J,
    CurrencyCharacter_K, CurrencyCharacter_L, CurrencyCharacter_M, CurrencyCharacter_N, CurrencyCharacter_O,
    CurrencyCharacter_P, CurrencyCharacter_Q, CurrencyCharacter_R, CurrencyCharacter_S, CurrencyCharacter_T,
    CurrencyCharacter_U, CurrencyCharacter_V, CurrencyCharacter_W, CurrencyCharacter_X, CurrencyCharacter_Y,
    CurrencyCharacter_Z,
    CurrencyCharacter_Space,
    
    CurrencyCharacter_Dirham,
    CurrencyCharacter_Dollar,
    CurrencyCharacter_Euro,
    CurrencyCharacter_IndianRupee,
    CurrencyCharacter_Pound,
    CurrencyCharacter_SaudiRiyal,
    CurrencyCharacter_SaudiRiyal2,
    CurrencyCharacter_Won,
    CurrencyCharacter_Yen,
    
    CurrencyCharacter_SlashAndDot,  //Added in 2.1.0
    CurrencyCharacter_Dot,          //Added in 2.4.4
    CurrencyCharacter_Yuan          //Added in 2.6.0-Beta22
} CurrencyCharacter;                //Added in 1.4.0-Beta3

typedef enum {
    WisePadPrinterResult_Success,
    WisePadPrinterResult_NoPaperOrCoverOpened,
    WisePadPrinterResult_WrongPrinterCommand
}WisePadPrinterResult; //Added in 2.1.0

typedef enum {
    WisePadPhoneEntryResult_Entered,
    WisePadPhoneEntryResult_Timeout,
    WisePadPhoneEntryResult_WrongLength,
    WisePadPhoneEntryResult_Cancel,
    WisePadPhoneEntryResult_Bypass
}WisePadPhoneEntryResult; //Added in 2.1.0

typedef enum {
    WisePadTerminalSettingStatus_Success,
    WisePadTerminalSettingStatus_InvalidTlvFormat,
    WisePadTerminalSettingStatus_TagNotFound,
    WisePadTerminalSettingStatus_IncorrectLength,
    WisePadTerminalSettingStatus_BootLoaderNotSupported
}WisePadTerminalSettingStatus;

typedef enum {
    WisePadCheckCardMode_Swipe,
    WisePadCheckCardMode_Insert,
    WisePadCheckCardMode_Tap,
    WisePadCheckCardMode_SwipeOrInsert
}WisePadCheckCardMode; //Added in 2.4.2, Updated in 2.6.0-Beta16

typedef enum {
    WisePadAmountInputType_AmountOnly,
    WisePadAmountInputType_AmountAndCashback,
    WisePadAmountInputType_CashbackOnly
}WisePadAmountInputType; //Added in 2.6.0

typedef enum {
    WisePadEncryptionMethod_TDES_ECB,
    WisePadEncryptionMethod_TDES_CBC,
    WisePadEncryptionMethod_AES_ECB,
    WisePadEncryptionMethod_AES_CBC,
    WisePadEncryptionMethod_MAC_ANSI_X9_9,
    WisePadEncryptionMethod_MAC_ANSI_X9_19,
    WisePadEncryptionMethod_MAC_METHOD_1,
    WisePadEncryptionMethod_MAC_METHOD_2
} WisePadEncryptionMethod; //Added in 2.7.0-Beta4

typedef enum {
    WisePadEncryptionKeySource_BY_DEVICE_16_BYTES_RANDOM_NUMBER,
    WisePadEncryptionKeySource_BY_DEVICE_8_BYTES_RANDOM_NUMBER,
    WisePadEncryptionKeySource_BOTH,
    WisePadEncryptionKeySource_BY_SERVER_16_BYTES_WORKING_KEY,
    WisePadEncryptionKeySource_BY_SERVER_8_BYTES_WORKING_KEY,
    WisePadEncryptionKeySource_STORED_IN_DEVICE_16_BYTES_KEY
} WisePadEncryptionKeySource; //Added in 2.7.0-Beta4

typedef enum {
    WisePadEncryptionPaddingMethod_ZERO_PADDING,
    WisePadEncryptionPaddingMethod_PKCS7
} WisePadEncryptionPaddingMethod; //Added in 2.7.0-Beta4

typedef enum {
    WisePadEncryptionKeyUsage_TEK,
    WisePadEncryptionKeyUsage_TAK,
    WisePadEncryptionKeyUsage_TPK
} WisePadEncryptionKeyUsage; //Added in 2.7.0-Beta4

typedef enum {
    WisePadPinEntrySource_Phone,
    WisePadPinEntrySource_Keypad
}WisePadPinEntrySource; //Added in 2.7.0-Beta5

/*
 typedef enum {
 WisePadStartEmvResult_Success,
 WisePadStartEmvResult_Fail
 } WisePadStartEmvResult; //Deprecated in 2.1.0
 */

@protocol WisePadControllerDelegate;

@interface WisePadController : NSObject {
//    NSObject <WisePadControllerDelegate>* delegate;
}

@property (nonatomic, strong) NSObject <WisePadControllerDelegate>* delegate;

- (NSString *)getApiVersion;
- (NSString *)getApiBuildNumber;

- (NSDictionary *)getIntegratedApiVersion;
- (NSDictionary *)getIntegratedApiBuildNumber;

+ (WisePadController *)sharedController;
- (WisePadControllerState)getWisePadControllerState;
- (void)releaseWisePadController;   //Added in 1.4.0 for both ARC and non-ARC
- (BOOL)isDevicePresent;

// --- Function of Transaction Flow ---
- (void)getDeviceInfo;
- (BOOL)setAmount:(NSString *)amount
   cashbackAmount:(NSString *)cashbackAmount
     currencyCode:(NSString *)currencyCode
  transactionType:(WisePadTransactionType)transactionType
currencyCharacters:(NSArray *)currencyCharacters;           //Updated in 1.4.0-Beta3
- (void)checkCard;
- (void)checkCard:(NSDictionary *)data; //Added in 2.4.2, checkCardMode require firmware 3.06.x.x.x
- (void)startSwipe;                     //Added in 2.2.0
- (void)startEmv:(WisePadEmvOption)WisePadEmvOption;
- (void)startEmvWithData:(NSDictionary *)data;
- (void)startPinEntry;                      //Added in 1.2.0
- (void)startPinEntry:(NSDictionary *)data; //Added in 2.6.0-Beta18
- (void)selectApplication:(int)applicationIndex;
- (void)sendFinalConfirmResult:(BOOL)isConfirmed;
- (void)sendServerConnectivity:(BOOL)isConnected;
- (void)sendOnlineProcessResult:(NSString *)tlv;

// Cancel
- (void)cancelCheckCard; //Added in 1.1.0
- (void)cancelSetAmount;
- (void)cancelSelectApplication;

// Enable Input Amount Mode
- (void)enableInputAmount:(NSString *)currencyCode
       currencyCharacters:(NSArray *)currencyCharacters;    //Added in 2.1.0
- (void)enableInputAmount:(NSDictionary *)data;             //Added in 2.6.0, Require Firmware 3.34.xxxxxx or above to support amountInputType
- (void)disableInputAmount;                                 //Added in 2.1.0

// PIN Entry (for M188 product only)
- (void)sendPinEntryResult:(NSString *)pin; //Added in 2.7.0-Beta5
- (void)bypassPinEntry;                     //Added in 2.7.0-Beta5
- (void)cancelPinEntry;                     //Added in 2.7.0-Beta2

// Printer function (for WisePad+ product only)
- (void)startPrinting:(int)numOfData
 printNextDataTimeout:(int)printNextDataTimeout
       noPaperTimeout:(int)noPaperTimeout; //Added in 2.1.0
- (void)sendPrinterData:(NSData *)data;    //Added in 2.1.0

// Phone Number
- (void)startGetPhoneNumber; //Added in 2.1.0
- (void)cancelGetPhoneNumber; //Added in 2.1.0

// Encrypt Data
- (void)encryptData:(NSString *)data; //Added in 2.1.0
- (void)encryptDataWithSettings:(NSDictionary *)data; //Added in 2.7.0-Beta4

// Other
- (void)getEmvCardData;                             //Added in 2.1.0
- (void)getEmvCardNumber;                           //Added in 2.6.0
- (void)getEmvCardBalance:(NSDictionary *)data;     //Added in 2.6.0-Beta19
- (void)getEmvTransactionLog:(NSDictionary *)data;  //Added in 2.6.0-Beta19
- (void)getEmvLoadLog:(NSDictionary *)data;         //Added in 2.6.0-Beta21
- (void)getMagStripeCardNumber;                     //Added in 2.6.0

// Communication Channel - Audio (For WisePad+ only)
- (BOOL)startAudio; //Added in 2.1.0
- (void)stopAudio; //Added in 2.1.0

// Communication Channel - BTv4
- (void)scanBTv4:(NSArray *)deviceNameArray;
- (void)scanBTv4:(NSArray *)deviceNameArray scanTimeout:(int)scanTimeout; //Addded in 2.1.0
- (void)stopScanBTv4;
- (void)connectBTv4:(CBPeripheral *)peripheral connectTimeout:(int)connectTimeout;
- (void)connectBTv4withUUID:(NSString *)UUID connectTimeout:(int)connectTimeout;   //Added in 2.1.0
- (void)disconnectBTv4;
- (NSString *)getPeripheralUUID:(CBPeripheral *)peripheral; //Added in 2.1.0

// Terminal Setting
- (void)readTerminalSetting:(NSString *)tag;
- (void)updateTerminalSetting:(NSString *)tlv;

//ViPOS
- (NSString *)viposGetIccData:(NSString *)tlv;                  //Added in 2.6.0-Beta20
- (void)viposExchangeApdu:(NSString *)apdu;                     //Added in 2.6.0-Beta20
- (void)viposBatchExchangeApdu:(NSDictionary *)apduCommands;    //Added in 2.6.0-Beta20

// Key Injection
- (void)injectSessionKey:(NSDictionary *)data; //Added in 2.5.0

//Utility
- (NSDictionary *)decodeTlv:(NSString *)tlv;

//--- Deprecated Function ---

// Communication Channel - BTv2
//- (void)scanBTv2:(NSArray *)deviceNameArray protocolStringArray:(NSArray *)protocolStringArray; //Deprecated in 2.1.0
//- (void)stopScanBTv2;                         //Deprecated in 2.1.0
//- (void)connectBTv2:(EAAccessory *)accessory; //Deprecated in 2.1.0
//- (void)disconnectBTv2;                       //Deprecated in 2.1.0

//- (void)resetWisePadController;                                   //Deprecated in 1.1.0
//- (BOOL)isBluetoothEnabled;                                       //Deprecated in 1.1.0
//- (void)sendReferProcessResult:(WisePadReferProcessResult)result; //Deprecated in 1.2.0
//- (void)cancelReferProcess;                                       //Deprecated in 1.2.0
//- (void)sendTerminalTime:(NSString *)terminalTime;                //Deprecated in 1.2.0
//- (void)startBTv2:(NSArray *)deviceNameArray protocolStringArray:(NSArray *)protocolStringArray; //Deprecated in 1.3.0
//- (void)stopBTv2;                                                 //Deprecated in 1.4.0
//- (void)stopBTv4;                                                 //Deprecated in 1.4.0

@end

@protocol WisePadControllerDelegate <NSObject>

@optional

- (void)onWisePadBatteryLow:(WisePadBatteryStatus)batteryStatus;

// Callback of onWaitingForCard
//- (void)onWisePadWaitingForCard;    //Deprecated in 2.6.0-Beta16, please use onWisePadWaitingForCard:checkCardMode
//- (void)onWisePadRequestInsertCard; //Deprecated in 2.6.0-Beta16, please use onWisePadWaitingForCard:checkCardMode
- (void)onWisePadWaitingForCard:(WisePadCheckCardMode)checkCardMode; //Added in 2.6.0-Beta16

// Callback of Result
- (void)onWisePadReturnDeviceInfo:(NSDictionary *)deviceInfoDict;
- (void)onWisePadReturnCheckCardResult:(WisePadCheckCardResult)result cardDataDict:(NSDictionary *)cardDataDict;
- (void)onWisePadReturnCancelCheckCardResult:(BOOL)isSuccess;  //Added in 2.0.0
- (void)onWisePadReturnBatchData:(NSString *)tlv;
- (void)onWisePadReturnTransactionResult:(WisePadTransactionResult)result data:(NSDictionary *)data; //Updated in 2.4.0
- (void)onWisePadReturnReversalData:(NSString *)tlv;
- (void)onWisePadReturnPinEntryResult:(WisePadPinEntryResult)result data:(NSDictionary *)data; //Added in 2.6.0-Beta18
- (void)onWisePadReturnPinEntryResult:(WisePadPinEntryResult)result
                                  epb:(NSString *)epb
                                  ksn:(NSString *)ksn;

// Callback of Request
- (void)onWisePadRequestSelectApplication:(NSArray *)applicationArray;
- (void)onWisePadRequestPinEntry;
- (void)onWisePadRequestPinEntry:(WisePadPinEntrySource)pinEntrySource; //Added in 2.7.0-Beta5
- (void)onWisePadRequestCheckServerConnectivity;
- (void)onWisePadRequestOnlineProcess:(NSString *)tlv;
- (void)onWisePadRequestFinalConfirm;
- (void)onWisePadRequestDisplayText:(WisePadDisplayText)displayMessage;
- (void)onWisePadRequestClearDisplay;

// Callback of Error
- (void)onWisePadError:(WisePadErrorType)WisePadErrorType errorMessage:(NSString *)errorMessage;

// Amount
- (void)onWisePadRequestSetAmount;
- (void)onWisePadReturnAmountConfirmResult:(BOOL)isConfirmed;
- (void)onWisePadReturnAmount:(NSString *)amount currencyCode:(NSString *)currencyCode;      //Added in 2.1.0
- (void)onWisePadReturnAmount:(NSDictionary *)data;
- (void)onWisePadReturnEnableInputAmountResult:(BOOL)isSuccess;     //Added in 2.1.0
- (void)onWisePadReturnDisableInputAmountResult:(BOOL)isSuccess;    //Added in 2.1.0

// Printer (For WisePad+ only)
- (void)onWisePadRequestPrinterData:(int)index isReprint:(BOOL)isReprint; //Added in 2.1.0
- (void)onWisePadReturnPrinterResult:(WisePadPrinterResult)result; //Added in 2.1.0
- (void)onWisePadPrinterOperationEnd; //Added in 2.1.0

// Phone Number
- (void)onWisePadReturnPhoneNumber:(WisePadPhoneEntryResult)result phoneNumber:(NSString *)phoneNumber;  //Added in 2.1.0

// Encrypt Data
- (void)onWisePadReturnEncryptDataResult:(NSDictionary *)data; //Added in 2.7.0-Beta4
- (void)onWisePadReturnEncryptDataResult:(NSString *)encryptedData ksn:(NSString *)ksn; //Added in 2.1.0

// For China PBOC only
- (void)onWisePadRequestVerifyID:(NSString *)tlv;       //Added in 2.4.0

// Terminal Setting
- (void)onWisePadReturnReadTerminalSettingResult:(WisePadTerminalSettingStatus)status tagValue:(NSString *)tagValue;
- (void)onWisePadReturnUpdateTerminalSettingResult:(WisePadTerminalSettingStatus)status;

// ViPOS
- (void)onWisePadReturnViposExchangeApduResult:(NSString *)apdu;            //Added in 2.6.0-Beta20
- (void)onWisePadReturnViposBatchExchangeApduResult:(NSDictionary *)data;   //Added in 2.6.0-Beta20

// Key Injection (For MK/SK encryption)
- (void)onWisePadReturnInjectSessionKeyResult:(BOOL)isSuccess; //Added in 2.5.0

// Other
- (void)onWisePadReturnEmvCardDataResult:(NSString *)tlv;                   //Added in 2.1.0
- (void)onWisePadReturnEmvCardNumber:(NSString *)cardNumber;                //Added in 2.6.0
- (void)onWisePadReturnEmvCardBalance:(NSString *)tlv;                      //Added in 2.6.0-Beta19
- (void)onWisePadReturnEmvTransactionLog:(NSArray *)transactionLogArray;    //Added in 2.6.0-Beta19
- (void)onWisePadReturnEmvLoadLog:(NSArray *)dataArray;                     //Added in 2.6.0-Beta21
- (void)onWisePadReturnMagStripeCardNumber:(WisePadCheckCardResult)result cardNumber:(NSString *)cardNumber; //Added in 2.6.0

// Communication Channel - Audio (For WisePad+ only)
- (void)onWisePadDevicePlugged;     //Added in 2.1.0
- (void)onWisePadDeviceUnplugged;   //Added in 2.1.0
- (void)onWisePadAudioInterrupted;      //Updated in 2.5.1, Renamed from onWisePadInterrupted to onWisePadAudioInterrupted
- (void)onWisePadNoAudioDeviceDetected; //Updated in 2.5.1, Renamed from onWisePadNoDeviceDetected to onWisePadNoAudioDeviceDetected

// Communication Channel - BTv4
- (void)onWisePadBTv4DeviceListRefresh:(NSArray *)foundDevices; //Updated in 1.3.0
- (void)onWisePadBTv4Connected;
- (void)onWisePadBTv4Connected:(CBPeripheral *)connectedPeripheral; //Added in 2.1.0
- (void)onWisePadBTv4Disconnected;
- (void)onWisePadBTv4ScanTimeout;
- (void)onWisePadBTv4ConnectTimeout;
- (void)onWisePadRequestEnableBluetoothInSettings;

//--- Deprecated Callback ---

// Communication Channel - BTv2
//- (void)onWisePadBTv2DeviceListRefresh:(NSArray *)foundDevices; //Deprecated in 2.1.0
//- (void)onWisePadBTv2Connected;       //Deprecated in 2.1.0
//- (void)onWisePadBTv2Disconnected;    //Deprecated in 2.1.0
//- (void)onWisePadBTv2ScanTimeout;     //Deprecated in 2.1.0

//- (void)onWisePadRequestSwipeOrInsertCard;              //Deprecated in 1.1.0, Replaced by onWisePadWaitingForCard
//- (void)onWisePadReturnTransactionLog:(NSString *)tlv;  //Deprecated in 1.2.0
//- (void)onWisePadRequestAdviceProcess:(NSString *)tlv;  //Deprecated in 1.2.0
//- (void)onWisePadRequestReferProcess:(NSString *)pan;   //Deprecated in 1.2.0
//- (void)onWisePadRequestTerminalTime;                   //Deprecated in 1.2.0
//- (void)onWisePadBTv2Detected;                          //Deprecated in 1.3.0
//- (void)onWisePadReturnStartEmvResult:(WisePadStartEmvResult)result ksn:(NSString *)ksn; //Deprecated in 2.1.0
//- (void)onWisePadReturnFailureMessage:(NSString *)tlv;  //Deprecated in 2.5.1

@end
