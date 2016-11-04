//
//  RequestManage+Login.h
//  youwo
//
//  Created by mygame on 15/4/30.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "RequestManage.h"

@class YWXPolishReqData;

@interface RequestManage (Login)
/**
 *  请求-上传用户位置信息，用户获取附件订单、用户
 *
 *  @param coordinate 经纬度
 */
- (void)requestUploadLocation:(CLLocationCoordinate2D)coordinate;

/**
 *  返回-上传用户位置信息
 */
- (void)responseUploadLocation;

/**
 *  断线重连 token面密码登入 请求
 */
- (void)requestTokenLogon:(NSString *)loginToken;

/**
 *  (用户名、token)登入 返回
 *
 *  @return YES-登入成功，NO-失败
 */
- (BOOL)responseLogon;

#pragma mark - <#mark description#>
//注册
-(void)RegisterUsername:(NSString *)username password:(NSString *)password  phone:(NSString *)phone vcode:(NSString *)vcode;
-(void)RegisterResponse;

//获取验证码
-(void)GetVerificationCodePhone:(NSString *)phone;
- (void)GetVerificationCodePhoneResponse;

//获取更改密码验证码
-(void)GetChangePasswordVeriCode:(NSString *)phone;

// 获取修改密码验证码
-(void)GetChangePasswordVeriCodeResponse;

// 验证获取的手机验证码请求
-(void)GetValidatePhoneReceiveVeriCode:(NSString *)phone  ValiCode:(NSString *)ValiCode;

// 验证获取的手机验证码请求响应
-(void)GetValidatePhoneReceiveVeriCodeResponse;

// 修改密码
-(void)ChangePassword:(NSString *)phone  password:(NSString *)password;

// 修改密码响应 CMD_MODIFY_PASSWORD_RESP
-(void)ChangePasswordResponse;

// 登陆
-(void)LoginUsername:(NSString *)username password:(NSString *)password;
//-(void)LoginResponse;

// 用户更新基本信息请求
- (void)requestPolishUserInfoWithPolishReqData:(YWXPolishReqData *)reqData;

// 响应 用户更新基本信息请求
- (void)responsePolishUserInfo;
@end
