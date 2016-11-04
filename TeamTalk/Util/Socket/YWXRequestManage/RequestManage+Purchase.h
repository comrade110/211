//
//  RequestManage+Purchase.h
//  youwo
//
//  Created by mygame on 15/4/18.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "RequestManageHeader.h"
@class YWXChargeReqData;
@class YWXWithdrawIntegrityCurrencyReqData;
@class YWXYouwoCurrencyExchangeOtherReqData;

/**
 *  关于购买、提现、兑换等协议
 */
@interface RequestManage (Purchase)
/**
 *  请求-充值token
 */
- (void)requestPayToken;

/**
 *  返回-充值token
 */
- (void)responsePayToken;

/**
 *  请求-创建充值订单
 */
- (void)requestCreatePayOrderWith:(YWXChargeReqData *)chargeReqData;

/**
 *  返回-创建充值订单
 */
- (void)responseCreatePayOrder;

/**
 *  返回-充值结果
 */
- (void)responseChargeResult;

/**
 * 请求-有我币兑换其他币
 */
- (void)requestExchangeGameCurrencyOrtryMoneyByYouWoCurrency:(YWXYouwoCurrencyExchangeOtherReqData *)exchangeReqData;

/**
 * 返回-有我币兑换其他币
 */
- (void)responseExchangeGameCurrencyOrtryMoneyByYouWoCurrency;

/**
 *  请求-提起诚信金
 */
- (void)requestWithdrawIntegrityCurrency:(YWXWithdrawIntegrityCurrencyReqData *)withDrawReqData;

/**
 *  返回-提起诚信金
 */
- (void)responseWithdrawIntegrityCurrency;
@end
