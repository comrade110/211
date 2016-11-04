//
//  RequestManage+Login.m
//  youwo
//
//  Created by mygame on 15/4/30.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "RequestManage+Login.h"
#import "YWXUserDetailInfo.h"
#import "YWXPolishReqData.h"

#import "client_protocol.h"
using namespace client;
extern ClientPkg g_clientPkg;
extern char g_pkgBuffer[SocketBufferSize];

@implementation RequestManage (Login)
/**
 *  请求-上传用户位置信息，用户获取附件订单、用户
 *
 *  @param coordinate 经纬度
 */
- (void)requestUploadLocation:(CLLocationCoordinate2D)coordinate {
    memset(&g_clientPkg.stBody.stClientNotifyTradeUserGisInfo, 0, sizeof(g_clientPkg.stBody.stClientNotifyTradeUserGisInfo));
    g_clientPkg.stHead.dwCmdID = CLIENT_NOTIFY_TRADE_USER_GIS_INFO;
    
    g_clientPkg.stBody.stClientNotifyTradeUserGisInfo.stGISInfo.llDimension = (int64_t)(coordinate.latitude * YWXInt10E6);
    g_clientPkg.stBody.stClientNotifyTradeUserGisInfo.stGISInfo.llLongitude = (int64_t)(coordinate.longitude * YWXInt10E6); // GPS经度
    [self readySendData];
    NSLog(@"000requestUploadLocation:%f-%f", coordinate.longitude, coordinate.latitude);
}

/**
 *  返回-上传用户位置信息
 */
- (void)responseUploadLocation {
    uint32_t result = g_clientPkg.stBody.stTradeResponseClientUserGisInfoResult.iResult;
        
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];
}

/**
 *  断线重连 token面密码登入 请求
 */
- (void)requestTokenLogon:(NSString *)loginToken {
    SharePersonalInfo.isTokenLogin = YES;
    
    memset(&g_clientPkg.stBody.stClientRequestAccessTokenLogin, 0, sizeof(g_clientPkg.stBody.stClientRequestAccessTokenLogin));
    g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_TOKEN_LOGIN;
    
    g_clientPkg.stBody.stClientRequestAccessTokenLogin.iLoginTokenLen = (int32_t)strlen([loginToken UTF8String]);
    memset(g_clientPkg.stBody.stClientRequestAccessTokenLogin.szLoginToken, 0, MAX_LOGIN_TOKEN_LEN);
    memcpy(g_clientPkg.stBody.stClientRequestAccessTokenLogin.szLoginToken, [loginToken UTF8String], strlen([loginToken UTF8String]));
    [self readySendData];
}

/**
 *  (用户名、token)登入 返回
 *
 *  @return YES-登入成功，NO-失败
 */
- (BOOL)responseLogon {
    int32_t result = g_clientPkg.stBody.stAccessResponseClientNameLogin.iResult;
    NSLog(@"登入结果=%d", (int)result);
    if (result == 0) {
        SharePersonalInfo.accountStatus                 = YWXAccountAllowAutoLogin;
        
        SharePersonalInfo.registerChannel               = g_clientPkg.stBody.stAccessResponseClientNameLogin.iRegister_channel;
        SharePersonalInfo.portraitID                    = g_clientPkg.stBody.stAccessResponseClientNameLogin.llPortrait;
        SharePersonalInfo.birthday                      = g_clientPkg.stBody.stAccessResponseClientNameLogin.llBirthday;
        SharePersonalInfo.gender                        = g_clientPkg.stBody.stAccessResponseClientNameLogin.bGender;
        SharePersonalInfo.nickName                      = [NSString strWithBytes:g_clientPkg.stBody.stAccessResponseClientNameLogin.szNickname length:g_clientPkg.stBody.stAccessResponseClientNameLogin.iNickNameLen];
        
        // kvo 主页检测完善用户信息需要uid在昵称和性别后赋值
        SharePersonalInfo.uid                           = g_clientPkg.stBody.stAccessResponseClientNameLogin.llUid;
        
        SharePersonalInfo.thirdPartyPassword            = [NSString strWithBytes:g_clientPkg.stBody.stAccessResponseClientNameLogin.szThirdPartyPassword length:g_clientPkg.stBody.stAccessResponseClientNameLogin.iThirdPartyPwLen];
        SharePersonalInfo.age                           = (int32_t)[Utility ageWithYearMonthDay:SharePersonalInfo.birthday];//g_clientPkg.stBody.stAccessResponseClientNameLogin.iAge;
        SharePersonalInfo.occupation                    = g_clientPkg.stBody.stAccessResponseClientNameLogin.iOccupation;
        SharePersonalInfo.constellation                 = g_clientPkg.stBody.stAccessResponseClientNameLogin.iConstellation;
        SharePersonalInfo.signature                     = [NSString strWithBytes:g_clientPkg.stBody.stAccessResponseClientNameLogin.szSignature length:g_clientPkg.stBody.stAccessResponseClientNameLogin.iSignatureLen];
        SharePersonalInfo.residentionID                 = g_clientPkg.stBody.stAccessResponseClientNameLogin.iResidence;
        SharePersonalInfo.residentionDetail             = [NSString strWithBytes:g_clientPkg.stBody.stAccessResponseClientNameLogin.szResidence_detail length:g_clientPkg.stBody.stAccessResponseClientNameLogin.iResidence_detailLen];
        SharePersonalInfo.promoterUid                   = g_clientPkg.stBody.stAccessResponseClientNameLogin.llPromoter;
        SharePersonalInfo.promoteCount                  = g_clientPkg.stBody.stAccessResponseClientNameLogin.iPromote_count;
        SharePersonalInfo.promoteLevel                  = g_clientPkg.stBody.stAccessResponseClientNameLogin.iPromote_level;
        SharePersonalInfo.loginToken                    = [NSString strWithBytes:g_clientPkg.stBody.stAccessResponseClientNameLogin.szLoginToken length:g_clientPkg.stBody.stAccessResponseClientNameLogin.iLoginTokenLen];
        SharePersonalInfo.integrityCurrency             = g_clientPkg.stBody.stAccessResponseClientNameLogin.iGold_integrity;
        SharePersonalInfo.integrityLevel                = g_clientPkg.stBody.stAccessResponseClientNameLogin.iIntegrity_level;
        SharePersonalInfo.youwoCurrency                 = g_clientPkg.stBody.stAccessResponseClientNameLogin.iGold_youwo;
        SharePersonalInfo.gameCurrency                  = g_clientPkg.stBody.stAccessResponseClientNameLogin.iGold_game;
        SharePersonalInfo.tryMoney                      = g_clientPkg.stBody.stAccessResponseClientNameLogin.iGold_validate;
        SharePersonalInfo.vipLevel                      = g_clientPkg.stBody.stAccessResponseClientNameLogin.iVip_level;
        SharePersonalInfo.vipBuyTime                    = g_clientPkg.stBody.stAccessResponseClientNameLogin.iVip_buy_time;
        SharePersonalInfo.vipExpireTime                 = g_clientPkg.stBody.stAccessResponseClientNameLogin.iVip_deadline;
        SharePersonalInfo.photoCount                    = g_clientPkg.stBody.stAccessResponseClientNameLogin.iPhoto_count;
        SharePersonalInfo.certificationFlag             = g_clientPkg.stBody.stAccessResponseClientNameLogin.llCert_flags;
        SharePersonalInfo.integrityValue                = g_clientPkg.stBody.stAccessResponseClientNameLogin.iSincerity_value;
        SharePersonalInfo.businessValue                 = g_clientPkg.stBody.stAccessResponseClientNameLogin.iBusiness_value;
        SharePersonalInfo.recentVisitorCount            = g_clientPkg.stBody.stAccessResponseClientNameLogin.iVisitor_count;
        SharePersonalInfo.experienceValue               = g_clientPkg.stBody.stAccessResponseClientNameLogin.llExp;
        SharePersonalInfo.playerLevel                   = g_clientPkg.stBody.stAccessResponseClientNameLogin.iLevel;
        SharePersonalInfo.rechargeNum                   = g_clientPkg.stBody.stAccessResponseClientNameLogin.iRecharge;
        SharePersonalInfo.depositLevel                  = g_clientPkg.stBody.stAccessResponseClientNameLogin.iDeposit_level;
        SharePersonalInfo.depositLimite                 = g_clientPkg.stBody.stAccessResponseClientNameLogin.iDeposit_limit;
        SharePersonalInfo.offlineDepositLimite          = g_clientPkg.stBody.stAccessResponseClientNameLogin.iOffline_deposit_limit;
        SharePersonalInfo.orderCreatNum                 = g_clientPkg.stBody.stAccessResponseClientNameLogin.iOrder_create_fnum;
        SharePersonalInfo.orderTakeNum                  = g_clientPkg.stBody.stAccessResponseClientNameLogin.iOrder_apply_fnum;
        SharePersonalInfo.interest                      = g_clientPkg.stBody.stAccessResponseClientNameLogin.llInterest;
        SharePersonalInfo.showLoginTips                 = g_clientPkg.stBody.stAccessResponseClientNameLogin.iShowLoginTips;
        SharePersonalInfo.loginTips                     = [NSString strWithBytes:g_clientPkg.stBody.stAccessResponseClientNameLogin.szLoginTips length:g_clientPkg.stBody.stAccessResponseClientNameLogin.iLoginTipsLen];
        SharePersonalInfo.nowTime                       = g_clientPkg.stBody.stAccessResponseClientNameLogin.iNow_time;
        
        NSLog(@"showLoginTips=%d, loginTips=%@", SharePersonalInfo.showLoginTips,  SharePersonalInfo.loginTips);
        // 保存token
        setUserDefaultsValue(SharePersonalInfo.loginToken, kYWXLoginToken);
        
        int32_t waitEvaluateNum = g_clientPkg.stBody.stAccessResponseClientNameLogin.iDueOrderCount;
        for (NSUInteger i =0 ; i < waitEvaluateNum; i++) {
            [SharePersonalInfo.waitEvaluateOrderIDList addObject:[NSString strFromllong:g_clientPkg.stBody.stAccessResponseClientNameLogin.dueOrderList[i]]];
        }
        SharePersonalInfo.waitEvaluateNum = waitEvaluateNum; // KVO 监听
        
        NSLog(@"SharePersonalInfo.thirdPartyPassword11 = %@",SharePersonalInfo.thirdPartyPassword);
        // 环信登录
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotificationKey object:nil];
    }
    else {
        setUserDefaultsValue(nil, kYWXLoginToken);
        
        // 账号被封
        if (result == 8) {
            SharePersonalInfo.accountStatus = YWXAccountClosed;
        }
    }

    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];
    return (result == 0 ?: NO);
}

#pragma mark -
// 注册
-(void)RegisterUsername:(NSString *)username password:(NSString *)password  phone:(NSString *)phone vcode:(NSString *)vcode
{
    NSString *md5Password = [Utility getMD5String:password];
    g_clientPkg.stHead.dwCmdID = CMD_REGISTER_REQ;
    g_clientPkg.stBody.stClientRegisterReq.llPhoneNum=[phone longLongValue];
    g_clientPkg.stBody.stClientRegisterReq.iVcCode=[vcode intValue];
    //g_clientPkg.stBody.stClientRegisterReq.llPromotionCode=0;
    int32_t nameLen=(int32_t)strlen([username UTF8String]);
    g_clientPkg.stBody.stClientRegisterReq.iNameLen=nameLen;
    memcpy(g_clientPkg.stBody.stClientRegisterReq.szName,[username UTF8String], (size_t)nameLen);
    
    int32_t pwdLen=(int32_t)strlen([md5Password UTF8String]);
    g_clientPkg.stBody.stClientRegisterReq.iPwLen=pwdLen;
    memcpy(g_clientPkg.stBody.stClientRegisterReq.szPassWord,[md5Password  UTF8String], (size_t)pwdLen);
    g_clientPkg.stBody.stClientRegisterReq.llPromotionCode = 0;
    g_clientPkg.stBody.stClientRegisterReq.iRegister_channel = kRegisterChannel;
    NSLog(@"nameLen=%d pwdLen=%d",nameLen,pwdLen);
    
    [self readySendData];
}

-(void)RegisterResponse
{
    int64_t uid=   g_clientPkg.stBody.stClientRegisterResp.llUid;
    int32_t result = g_clientPkg.stBody.stClientRegisterResp.iResult;
    
    NSLog(@"uid=%lld result=%d",uid,result);
    
    if (result == 0)
    {
        SharePersonalInfo.isOnRegister = YES;
        SharePersonalInfo.uid = uid; // 注册成功
        [PublicFunction showMessage:@"注册成功"];
        [PublicFunction saveUserId:[NSString stringWithFormat:@"%lld",uid]];
    }

    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:result == 0 ? nil : nil result:result == 0 ? YES: NO];
}

// 获取验证码
-(void)GetVerificationCodePhone:(NSString *)phone
{
    
    g_clientPkg.stHead.dwCmdID = CMD_VC_CODE_REQ;
    g_clientPkg.stBody.stClientVcCodeReq.llPhoneNum=[phone longLongValue];
    
    [self readySendData];
}

- (void)GetVerificationCodePhoneResponse
{
    int32_t result = g_clientPkg.stBody.stClientVcCodeResp.iResult;
    int32_t isRegister = g_clientPkg.stBody.stClientVcCodeResp.iIsRegister;
    NSLog(@"result=%d isRegister=%d",result,isRegister);
    
    //当已经注册过进行提示
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(isRegister) result:result == 0 ? YES: NO];

}


//获取更改密码验证码
-(void)GetChangePasswordVeriCode:(NSString *)phone
{
    g_clientPkg.stHead.dwCmdID = CMD_RETRIEVE_CODE_REQ;
    g_clientPkg.stBody.stClientRetrieveCodeReq.llPhoneNum=[phone longLongValue];
    [self readySendData];
}

// 获取修改密码验证码
-(void)GetChangePasswordVeriCodeResponse
{
    int32_t ret= g_clientPkg.stBody.stClientRetrieveCodeResp.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(ret) result:ret == 0 ?: NO];
}

// 验证获取的手机验证码请求
-(void)GetValidatePhoneReceiveVeriCode:(NSString *)phone  ValiCode:(NSString *)ValiCode
{
    g_clientPkg.stHead.dwCmdID = CMD_VALIDATE_RETRIEVE_CODE_REQ;
    g_clientPkg.stBody.stClientValidateRetrieveCodeReq.llPhoneNum=[phone longLongValue];
    g_clientPkg.stBody.stClientValidateRetrieveCodeReq.iCode=[ValiCode intValue];
    [self readySendData];
}

// 验证获取的手机验证码请求响应
-(void)GetValidatePhoneReceiveVeriCodeResponse
{
    int32_t ret= g_clientPkg.stBody.stClientValidateRetrieveCodeResp.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(ret) result:ret == 0 ?: NO];
}

// 修改密码
-(void)ChangePassword:(NSString *)phone  password:(NSString *)password
{
    NSString *md5Password = [Utility getMD5String:password];
    g_clientPkg.stHead.dwCmdID =CMD_MODIFY_PASSWORD_REQ;
    g_clientPkg.stBody.stClientModifyPasswordReq.llPhoneNum=[phone longLongValue];
    int32_t pwdLen=(int32_t)strlen([md5Password UTF8String]);
    g_clientPkg.stBody.stClientModifyPasswordReq.iPwdLen=pwdLen;
    memcpy(g_clientPkg.stBody.stClientModifyPasswordReq.szPassWord,[md5Password UTF8String], pwdLen);
    
    [self readySendData];
}

// 修改密码响应 CMD_MODIFY_PASSWORD_RESP
-(void)ChangePasswordResponse
{
    int32_t ret= g_clientPkg.stBody.stClientModifyPasswordResp.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(ret) result:ret == 0 ?: NO];
}


// 登陆
-(void)LoginUsername:(NSString *)username password:(NSString *)password
{
    SharePersonalInfo.isTokenLogin = NO;
    NSString *md5Password = [Utility getMD5String:password];
    NSLog(@"111-username=%@, password=%@", username, password);
    //memset(&g_clientPkg.stBody.stClientRequestAccessNameLogin, 0, sizeof(g_clientPkg.stBody.stClientRequestAccessNameLogin));
    g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_NAME_LOGIN;
    
    g_clientPkg.stBody.stClientRequestAccessNameLogin.iNameLen = (int32_t)strlen([username UTF8String]);
    memset(g_clientPkg.stBody.stClientRequestAccessNameLogin.szName, 0, ACCESS_LOGON_NAME_LEN);
    memcpy(g_clientPkg.stBody.stClientRequestAccessNameLogin.szName,[username UTF8String], strlen([username UTF8String]));
    
    g_clientPkg.stBody.stClientRequestAccessNameLogin.iPwLen = (int32_t)strlen([md5Password UTF8String]);
    memset(g_clientPkg.stBody.stClientRequestAccessNameLogin.szPassword, 0, ACCESS_PASSWORD_LEN);
    memcpy(g_clientPkg.stBody.stClientRequestAccessNameLogin.szPassword,[md5Password  UTF8String], strlen([md5Password UTF8String]));

    [self readySendData];
}

// 请求 用户更新基本信息请求
- (void)requestPolishUserInfoWithPolishReqData:(YWXPolishReqData *)reqData
{
    memset(&g_clientPkg.stBody.stClientUpdateBaseInfoReq, 0, sizeof(g_clientPkg.stBody.stClientUpdateBaseInfoReq));
    
    g_clientPkg.stHead.dwCmdID = CMD_UPDATE_BASE_INFO_REQ;
    g_clientPkg.stBody.stClientUpdateBaseInfoReq.chGender = reqData.gender;
    g_clientPkg.stBody.stClientUpdateBaseInfoReq.llBirthday = reqData.birthday;
    g_clientPkg.stBody.stClientUpdateBaseInfoReq.llPortrait = reqData.portrait;
    g_clientPkg.stBody.stClientUpdateBaseInfoReq.llInterest = reqData.interest;
    g_clientPkg.stBody.stClientUpdateBaseInfoReq.iNickNameLen = (int32_t)strlen([reqData.nickName UTF8String]);
    memset(g_clientPkg.stBody.stClientUpdateBaseInfoReq.szNickName, 0, ACCESS_NICK_NAME_LEN);
    memcpy(g_clientPkg.stBody.stClientUpdateBaseInfoReq.szNickName, [reqData.nickName UTF8String], strlen([reqData.nickName UTF8String]));
    
    [self readySendData];
}

// 响应 用户更新基本信息请求
- (void)responsePolishUserInfo
{
    int32_t iResult = g_clientPkg.stBody.stClientUpdateBaseInfoResp.iResult;

    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(iResult) result:iResult == 0 ? YES: NO];
}
@end





