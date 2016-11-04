//
//  RequestManage+Purchase.m
//  youwo
//
//  Created by mygame on 15/4/18.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "RequestManage+Purchase.h"
#import "YWXWithdrawIntegrityCurrencyReqData.h"
#import "YWXYouwoCurrencyExchangeOtherReqData.h"
#import "YWXChargeReqData.h"

#import "client_protocol.h"

using namespace client;
extern ClientPkg g_clientPkg;
extern char g_pkgBuffer[SocketBufferSize];

#define kiPayChargeTokenKey              @"iPayChargeTokenKey"
#define kiPayGenerateTokenTimeKey        @"iPayGenerateTokenTimeKey"
#define kiPayChargeTokenValidDurationKey @"iPayChargeTokenValidDurationKey"

@implementation RequestManage (Purchase)
/**
 *  返回-充值token
 */
- (void)requestPayToken {
    memset(&g_clientPkg.stBody.stClientGetThirdPartyPayTokenReq, 0, sizeof(g_clientPkg.stBody.stClientGetThirdPartyPayTokenReq));
    g_clientPkg.stHead.dwCmdID = CLIENT_GET_THIRDPARTY_PAY_TOKEN_REQ;

    g_clientPkg.stBody.stClientGetThirdPartyPayTokenReq.nThirdPartyPayTokenIndex = 2; // 1=微信支付token 2=支付宝token
    [self readySendData];
}

/**
 *  返回-充值token
 */
- (void)responsePayToken {
    if (g_clientPkg.stBody.stClientGetThirdPartyPayTokenResp.iResult != 0) {
        NSLog(@"支付token获取失败");
        return;
    }
    
    NSString *payChargeToken              = [NSString strWithBytes:g_clientPkg.stBody.stClientGetThirdPartyPayTokenResp.szTokenValue length:g_clientPkg.stBody.stClientGetThirdPartyPayTokenResp.iTokenValueLen];
    NSString *payChargeTokenValidTime     = [NSString strFromllong:g_clientPkg.stBody.stClientGetThirdPartyPayTokenResp.llTokenValidTime];
    NSString *payChargeTokenValidDuration = [NSString strFromllong:g_clientPkg.stBody.stClientGetThirdPartyPayTokenResp.llTokenCreateTime];
    
    setUserDefaultsValue(payChargeToken, kiPayChargeTokenKey);
    setUserDefaultsValue(payChargeTokenValidTime, kiPayGenerateTokenTimeKey);
    setUserDefaultsValue(payChargeTokenValidDuration, kiPayChargeTokenValidDurationKey);
    
    NSLog(@"支付token信息=%@", NSDictionaryOfVariableBindings(payChargeToken, payChargeTokenValidTime, payChargeTokenValidDuration));
}

/**
 *  请求-创建充值订单
 */
- (void)requestCreatePayOrderWith:(YWXChargeReqData *)chargeReqData {
    memset(&g_clientPkg.stBody.stClientGeneratePayOrderReq, 0, sizeof(g_clientPkg.stBody.stClientGeneratePayOrderReq));
    g_clientPkg.stHead.dwCmdID = CLIENT_GENERATE_PAY_ORDER_REQ;

    g_clientPkg.stBody.stClientGeneratePayOrderReq.iPrice          = chargeReqData.unitPrice;// 单价
    g_clientPkg.stBody.stClientGeneratePayOrderReq.iQuantity       = chargeReqData.quantity;
    g_clientPkg.stBody.stClientGeneratePayOrderReq.chItemType      = chargeReqData.productCategory;// 物品类型 1=诚信金(支付用), 2=有我币(支付用), 3=游戏币, 4=试金石
    g_clientPkg.stBody.stClientGeneratePayOrderReq.nItemNameLen    = strlen([chargeReqData.productName UTF8String]);
    memcpy(g_clientPkg.stBody.stClientGeneratePayOrderReq.szItemName, [chargeReqData.productName UTF8String], strlen([chargeReqData.productName UTF8String]));
    g_clientPkg.stBody.stClientGeneratePayOrderReq.chChannelId     = chargeReqData.channelId;
    g_clientPkg.stBody.stClientGeneratePayOrderReq.chPayWay        = chargeReqData.chargeType;// 支付方式 1，// 微信支付  2, // 支付宝支付
    g_clientPkg.stBody.stClientGeneratePayOrderReq.chPaymentType   = chargeReqData.oprationType;// 支付类型(购买、提取) 1, // 购买商品 2, // 提取商品
    g_clientPkg.stBody.stClientGeneratePayOrderReq.chAppVersionLen = strlen([chargeReqData.appVersion UTF8String]);// 应用 版本号
    memcpy(g_clientPkg.stBody.stClientGeneratePayOrderReq.szAppVersion, [chargeReqData.appVersion UTF8String], strlen([chargeReqData.appVersion UTF8String]));
    [self readySendData];
}

/**
 *  返回-创建充值订单
 */
- (void)responseCreatePayOrder {
    int32_t result = g_clientPkg.stBody.stClientGeneratePayOrderResp.iResult;
    NSString *rechargeID = [NSString strFromllong:g_clientPkg.stBody.stClientGeneratePayOrderResp.llPayOrderId];
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:result == 0 ? rechargeID : @(result) result:result == 0 ?: NO];
    
    
//    NSString *securityInfo = [NSString strWithBytes:g_clientPkg.stBody.stClientGeneratePayOrderResp.szSecurityInfo length:g_clientPkg.stBody.stClientGeneratePayOrderResp.iSecurityInfoLen];
//    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[securityInfo jsonDictionary]]; // 支付宝支付信息
//    [dic setValue:rechargeID forKey:@"rechargeID"];
//
//    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:result == 0 ? dic : @(result) result:result == 0 ?: NO];
}

/**
 *  返回-充值结果
 */
- (void)responseChargeResult {
    int32_t result = g_clientPkg.stBody.stTradeNotifyClientPayResult.iResult;

    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];

}

/**
 * 请求-有我币兑换其他币
 */
- (void)requestExchangeGameCurrencyOrtryMoneyByYouWoCurrency:(YWXYouwoCurrencyExchangeOtherReqData *)exchangeReqData {
    memset(&g_clientPkg.stBody.stClientExchangeStoneOrCurrencyReq, 0, sizeof(g_clientPkg.stBody.stClientExchangeStoneOrCurrencyReq));
    g_clientPkg.stHead.dwCmdID = CLIENT_EXCHANGE_STONE_OR_CURRENCY_REQ;
    
    g_clientPkg.stBody.stClientExchangeStoneOrCurrencyReq.llUid              = exchangeReqData.uid;
    g_clientPkg.stBody.stClientExchangeStoneOrCurrencyReq.chItemType         = exchangeReqData.exchangeType;// 要兑换的物品类型(已经定义客户端和服务端公用的枚举值)
    g_clientPkg.stBody.stClientExchangeStoneOrCurrencyReq.iQuantity          = exchangeReqData.quantity;// 要兑换的物品数量
    g_clientPkg.stBody.stClientExchangeStoneOrCurrencyReq.iYouWoCoinQuantity = exchangeReqData.youwoCurrencyNeedQuantity;// 所需要的有我币的数量
    [self readySendData];
}

/**
 * 返回-有我币兑换其他币
 */
- (void)responseExchangeGameCurrencyOrtryMoneyByYouWoCurrency {
    NSUInteger result = g_clientPkg.stBody.stClientExchangeStoneOrCurrencyResp.iResult;

    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];

    NSLog(@"兑换%@", result==0?@"成功":@"失败");
}

/**
 *  请求-提起诚信金
 */
- (void)requestWithdrawIntegrityCurrency:(YWXWithdrawIntegrityCurrencyReqData *)withDrawReqData {
    memset(&g_clientPkg.stBody.stClientWithdrawHonestyGoldReq, 0, sizeof(g_clientPkg.stBody.stClientWithdrawHonestyGoldReq));
    g_clientPkg.stHead.dwCmdID = CLIENT_WITHDRAW_HONESTY_GOLD_REQ;

    g_clientPkg.stBody.stClientWithdrawHonestyGoldReq.llUid               = withDrawReqData.uid;
    g_clientPkg.stBody.stClientWithdrawHonestyGoldReq.iQuantity           = withDrawReqData.quantity;// 要提取的诚信金数量
    g_clientPkg.stBody.stClientWithdrawHonestyGoldReq.iCurrencyType       = withDrawReqData.currencyType;
    g_clientPkg.stBody.stClientWithdrawHonestyGoldReq.iAccountType        = withDrawReqData.accountType;
    g_clientPkg.stBody.stClientWithdrawHonestyGoldReq.nBuyerPayAccountLen = strlen([withDrawReqData.withdrawALiPayAccount UTF8String]);
    memcpy(g_clientPkg.stBody.stClientWithdrawHonestyGoldReq.szBuyerPayAccount, [withDrawReqData.withdrawALiPayAccount UTF8String], strlen([withDrawReqData.withdrawALiPayAccount UTF8String])); // 买家用户的支付宝或者微信账号
    [self readySendData];
}

/*
 *  返回-提起诚信金
 */
- (void)responseWithdrawIntegrityCurrency {
    NSUInteger result = g_clientPkg.stBody.stClientWithdrawHonestyGoldResp.iResult;

    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];

}
@end
