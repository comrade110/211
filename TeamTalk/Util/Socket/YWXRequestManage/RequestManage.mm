//
//  RequestManage.m
//  youwo
//
//  Created by zhuzx on 15/1/13.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "RequestManageHeader.h"

#import "YWXClientSocket.h"

#import "PublicFunction.h"
#import "YWXUserAccountInfo.h"

#import <stdlib.h>

#define YWXSuccessCallbackBlockKey  @"SuccessCallbackBlock"
#define YWXFailureCallbackBlockKey  @"FailureCallbackBlock"
//#define YWXObserverCallBackBlockKey @"ObserverCallBackBlock"
#define YWXTimeoutKey @"Timeout"

// 协议C++代码依赖
#import "client_protocol.h"
using namespace client;
ClientPkg g_clientPkg;
char g_pkgBuffer[SocketBufferSize];

@interface RequestManage ()
@property (strong, nonatomic) NSRecursiveLock *lock;

/// 常规协议block回调字典
@property (strong, nonatomic) NSMutableDictionary *responseBlocks;

@property (strong, nonatomic) NSData *tempData;
@end

@implementation RequestManage

#pragma mark - public fuction
static RequestManage *requestManageInstance = nil;
+ (RequestManage *)defaultRequestManage {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestManageInstance = [[RequestManage alloc] init];
    });
    
    return requestManageInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        memset(&g_clientPkg, 0, sizeof(g_clientPkg));
        memset(g_pkgBuffer, 0, SocketBufferSize);
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (self.lock) {
        [self.lock unlock];
        self.lock = nil;
    }
}

- (void)disconnentWithService {
    [ShareClientSocket disconnectSocket];
}


-(void)readySendData
{
    @synchronized(self){
        size_t aWDataSize = 0;
        //NSLog(@"readySendData-g_clientPkg.stHead.bMessageVer=%d", g_clientPkg.stHead.bMessageVer);
        g_clientPkg.stHead.bMessageVer = YWXServerProtocolVersion;
        int16_t errorCode = g_clientPkg.pack((char *)g_pkgBuffer, SocketBufferSize, &aWDataSize);
        if (TdrError::TDR_NO_ERROR == errorCode) {
            g_clientPkg.stHead.wDataSize  = aWDataSize;
            NSData *sendData = [NSData dataWithBytes:g_pkgBuffer length:aWDataSize];
            if ([self isNeedLoginCmd:g_clientPkg.stHead.dwCmdID] || SharePersonalInfo.uid > YWXMinUID) {
                [ShareClientSocket sendData:sendData];  // 无需登入的协议与登入后的协议
            }
            else {
                // 请求失败 取消回调block回调
                [self cancelRequestWithRequestProtocolID:g_clientPkg.stHead.wDataSize];
                
                //self.tempData = [sendData mutableCopy];       // 暂存断线前的最后一个协议数据
                NSString *loginToken = getUserDefaultsValue(kYWXLoginToken);
                if ([loginToken length] > 10) {
                    [self requestDataWithRequestProtocolID:CLIENT_REQUEST_ACCESS_TOKEN_LOGIN parameters:loginToken success:^(id responseObject) {
                        NSLog(@"重连成功");
                    } failure:^(id failureDes) {
                        NSLog(@"重连失败");
                    }];
                }
                else {
                    if (!SharePersonalInfo.isLoginControllerOnWindow) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginViewNotificationKey object:nil];
                    }
                }
            }
        }
        NSLog(@"socket 发送码=%u,aWDataSize=%zu 错误码=%d", g_clientPkg.stHead.dwCmdID, aWDataSize, errorCode);
    }
}

/**
 *  面登入协议
 *
 *  @param cmd 协议号
 *
 *  @return YES=是免登入协议 NO=需要登入
 */
- (BOOL)isNeedLoginCmd:(uint64_t)cmd {
    // 心跳请求
    // 注册验证码请求
    // 注册验证码请求返回
    // 用户名登录请求
    // Token登陆请求
    // 获取修改密码手机验证码请求
    // 验证获取的手机验证码请求
    // 修改密码请求
    // 用户名密码登录请求 新协议
    // token登录请求 新协议
    if (cmd < CMD_UPDATE_BASE_INFO_REQ ||
        cmd == CMD_TOKEN_LOGON_REQ ||
        cmd == CMD_RETRIEVE_CODE_REQ ||
        cmd == CMD_VALIDATE_RETRIEVE_CODE_REQ ||
        cmd == CMD_MODIFY_PASSWORD_REQ ||
        cmd == CLIENT_REQUEST_ACCESS_NAME_LOGIN ||
        cmd == CLIENT_REQUEST_ACCESS_TOKEN_LOGIN) {
        return YES;
    }
    return NO;
}

#pragma mark - getter
- (NSRecursiveLock *)lock {
    if (_lock) {
        return _lock;
    }
    
    _lock = [[NSRecursiveLock alloc] init];
    return _lock;
}

- (NSMutableDictionary *)responseBlocks {
    if (_responseBlocks) {
        return _responseBlocks;
    }
    
    _responseBlocks = [[NSMutableDictionary alloc] init];
    
    return _responseBlocks;
}


#pragma mark - 协议回调、打包、超时处理
/**
 *  根据请求协议号，找到响应协议号
 *
 *  @param requestID: 请求的协议号
 */
-(uint64_t)getResponseProtocolIDWithRequestID:(uint64_t)requestID {
//    CLIENT_REQUEST_ACCESS_NAME_LOGIN = 1047, // 用户名密码登录请求
//    CLIENT_REQUEST_ACCESS_TOKEN_LOGIN = 1048, // token登录请求
//    ACCESS_RESPONSE_CLIENT_NAME_LOGIN = 1049, // 用户名密码登录应答
    if (requestID == CLIENT_REQUEST_ACCESS_NAME_LOGIN || requestID == CLIENT_REQUEST_ACCESS_TOKEN_LOGIN) {
        return ACCESS_RESPONSE_CLIENT_NAME_LOGIN;
    }
    else {
        return requestID + 1;
    }
}

/**
 *  超时回调
 *
 *  @param aTimer: 超时定时器
 */
- (void)timeoutResponse:(NSTimer *)aTimer {
    NSString *protocolNum = aTimer.userInfo;
    if (aTimer) {
        [aTimer invalidate];
        aTimer = nil;
    }
    
    [self responseCallBackWithResponseProtocolID:[protocolNum longLongValue] responseObject:SocketTimeOutDes result:NO];
}

/// 取消所有请求的block回调
- (void)cancelAllReqest {
    if (self.responseBlocks.count == 0) {
        return;
    }
    
    NSArray *allKeysResponseIDs = [self.responseBlocks allKeys];
    for (NSString *responseID in allKeysResponseIDs) {
        [self responseCallBackWithResponseProtocolID:[responseID longLongValue] responseObject:nil result:NO];
    }
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

/**
 *  取消请求的block回调
 *
 *  @param responseProtocolID: 响应的协议号
 */
- (void)cancelRequestWithResponseProtocolID:(uint64_t)responseProtocolID {
    NSString *PID = [NSString strFromllong:responseProtocolID];
    NSMutableArray *blocks = [self.responseBlocks objectForKey:PID];
    // 获取当前
    if (blocks.count && [blocks isKindOfClass:[NSMutableArray class]]) {
        // 获取最后一个回调Dictionary
        NSDictionary *responseDictionary = blocks[blocks.count-1];
        
        // 清除超时回调
        NSTimer *timeoutTimer = [responseDictionary objectForKey:YWXTimeoutKey];
        if (timeoutTimer && [timeoutTimer isKindOfClass:[NSTimer class]]) {
            [timeoutTimer invalidate];
            timeoutTimer = nil;
        }
        
        // 置空block回调
        void (^success)(id responseObject) = [responseDictionary objectForKey:YWXSuccessCallbackBlockKey];
        if (success) {
            success = nil;
        }
        void (^failure)(id failureDes) = [responseDictionary objectForKey:YWXFailureCallbackBlockKey];
        if (failure) {
            failure = nil;
        }
        
        [self.lock lock];
        // 移除回调Dictionary
        if (blocks.count == 1) {
            NSLog(@"000成功取消回调协议=%@", PID);
            [self.responseBlocks removeObjectForKey:PID];
        }
        else {
            NSLog(@"111成功取消回调协议=%@", PID);
            [blocks removeObjectAtIndex:blocks.count-1];
        }
        [self.lock unlock];
    }
    else {
         NSLog(@"222取消回调失败协议=%@", PID);
    }
}

/**
 *  取消请求的block回调
 *
 *  @param responseProtocolID: 请求的协议号
 */
- (void)cancelRequestWithRequestProtocolID:(uint64_t)requestProtocolID {
    [self cancelRequestWithResponseProtocolID:[self getResponseProtocolIDWithRequestID:requestProtocolID]];
}


/**
 *  设置协议响应的block回调
 *
 *  @param responseProtocolID: 返回的协议号
 *  @param success: 成功回调
 *  @param failure: 失败回调
 */
- (void)requestDataWithResponseProtocolID:(uint64_t)responseProtocolID success:(void (^)(id responseObject))success failure:(void (^)(id failureDes))failure {
    [self.lock lock];
    NSString *PID = [NSString strFromllong:responseProtocolID];
    // 字典中是否有已经存在此block回调
    NSMutableArray *blocks = [self.responseBlocks objectForKey:PID];
    if (blocks == nil) {
        blocks = [[NSMutableArray alloc] init];
    }
//    NSLog(@"PID=%@-保存回调blocks=%d", PID, (int)blocks.count);
    // 装载block回调
    NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc] init];
    [responseDictionary setObject:success forKey:YWXSuccessCallbackBlockKey]; // 成功回调
    [responseDictionary setObject:failure forKey:YWXFailureCallbackBlockKey]; // 失败回调
    [responseDictionary setObject:[NSTimer scheduledTimerWithTimeInterval:SocketTimeOutDuration target:self selector:@selector(timeoutResponse:) userInfo:PID repeats:NO] forKey:YWXTimeoutKey]; // 超时回调
    [blocks addObject:responseDictionary];
    
    // 保存到字典中
    [self.responseBlocks setObject:blocks forKey:PID];

#if defined DEBUG && ZHOUYONG
    NSLog(@"PID=%@-保存回调=%@", PID, self.responseBlocks);
#else
    NSLog(@"PID=%@-保存回调=%d", PID, (int)self.responseBlocks.count);
#endif
    [self.lock unlock];
}

/**
 *  协议响应
 *
 *  @param responseProtocolID: （必填参数）返回协议号
 *  @param responseObject: 返回数据（成功/失败数据）
 *  @param result: （必填参数）请求结果状态（YES-成功， NO-失败）
 */
- (void)responseCallBackWithResponseProtocolID:(uint64_t)responseProtocolID responseObject:(id)responseObject result:(BOOL)result {
    NSString *PID = [NSString strFromllong:responseProtocolID];
    // 获取回调列表
    NSMutableArray *blocks = [self.responseBlocks objectForKey:PID];
//    NSLog(@"回调协议号：%@", PID);
    
    if (blocks.count && [blocks isKindOfClass:[NSMutableArray class]]) {
        // 获取当前回调
        NSDictionary *responseDictionary = blocks[0];
        // 移除超时回调
        NSTimer *timeoutTimer = [responseDictionary objectForKey:YWXTimeoutKey];
        if (timeoutTimer && [timeoutTimer isKindOfClass:[NSTimer class]]) {
            [timeoutTimer invalidate];
            timeoutTimer = nil;
        }
        
        // 回调
        void (^success)(id responseObject) = [responseDictionary objectForKey:YWXSuccessCallbackBlockKey];
        void (^failure)(id failureDes) = [responseDictionary objectForKey:YWXFailureCallbackBlockKey];
        if (result && success) {
            success(responseObject);
            success = nil; // 置空
        }
        else {
            if (failure) {
                NSLog(@"请求失败回调协议号=%@", PID);
                failure(responseObject);
                failure = nil; // 置空
            }
            else {
                NSLog(@"请求失败回调协议号=%@, success=%@", PID, success);
            }
        }
        
        [self.lock lock];
        // 回调结束，移除回调
        if (blocks.count == 1) {
            [self.responseBlocks removeObjectForKey:PID];
//#if defined DEBUG && ZHOUYONG
//            NSLog(@"000回调成功移除协议号=%@, 剩余回调=%@", PID, self.responseBlocks);
//#else
//            NSLog(@"000回调成功移除协议号=%@, 剩余回调=%d", PID, (int)self.responseBlocks.count);
//#endif
        }
        else {
            [blocks removeObjectAtIndex:0];
//#if defined DEBUG && ZHOUYONG
//            NSLog(@"111回调成功移除协议号=%@, 剩余回调=%@", PID, self.responseBlocks);
//#else
//            NSLog(@"111回调成功移除协议号=%@, 剩余回调=%d", PID, (int)self.responseBlocks.count);
//#endif
        }
        [self.lock unlock];
    }
    else {
        NSLog(@"222回调失败协议号=%@", PID);
    }
}

#pragma mark - 所有发送协议请求（打包发送协议请求）
/**
 *  请求协议数据
 *
 *  @param requestProtocolID: （必填参数）请求的协议号
 *  @param parameters: （必填参数）请求参数
 *  @param success: （必填参数）成功回调
 *  @param failure: （必填参数）失败回调
 */
- (void)requestDataWithRequestProtocolID:(uint64_t)requestProtocolID parameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(id failureDes))failure {
    // 设置回调
    [self requestDataWithResponseProtocolID:[self getResponseProtocolIDWithRequestID:requestProtocolID] success:success failure:failure];
    
    NSLog(@"请求协议号：%llu", (unsigned long long)requestProtocolID);
    // 在这里打包请求参数，要求每个case下都有一对大括号{}，要求每个case下都有一对大括号{}，要求每个case下都有一对大括号{}，重要的事情说三遍
    switch (requestProtocolID) {
        case CMD_PLAYERS_NEARBY_REQ:
        {
            [self requestNearByList:[parameters integerValue]]; // 请求附近的人
            break;
        }
        case CMD_CT_REPORT_INFO_REQ:
        {
            // 举报-某人或某单
            [self requestReportWithReqData:parameters];
            break;
        }
        case CLIENT_REQUEST_ACCESS_TRADE_UPDATE_ARGUE:
        {
            // 订单评价
            [self requestOrderEvaluateReqData:parameters];
            break;
        }
        case CLIENT_REQUEST_ACCESS_TRADE_ORDER_DONE_APPLYER:
        {   // 接单人确认完成请求
            [self requestConfirmFinishWithApplyOrConfirmFinishReqData:parameters];
            break;
        }
        case CLIENT_REQUEST_ACCESS_TRADE_ORDER_DONE_CREATER:
        {   // 发单人确认完成请求
            [self requestConfirmFinishWithApplyOrConfirmFinishReqData:parameters];
            break;
        }
        case CMD_CT_DISCUSS_ORDER_REQ:
        {
            // 发评论
            [self requestSendCommentWithReqData:parameters];
            break;
        }
        case CLIENT_REQUEST_ACCESS_TRADE_SELECT_ORDER_DETAILS_INFO:
        {
            // 订单详情
            [self requestOrderDetail:[(NSString *)parameters longLongValue]];
            break;
        }
        case CLIENT_REQUEST_ACCESS_TRADE_GET_CHATROOMINFOLIST:
        {
            // 获取当前火热聊天室信息列表
            [self requestClientAccessTradeGetChatRoomInfoList:(NSString *)parameters];
            break;
        }
        case CMD_UPDATE_BASE_INFO_REQ:
        {
            // 完善用户信息
            [self requestPolishUserInfoWithPolishReqData:(YWXPolishReqData *)parameters];
            break;
        }
        case CLIENT_REQUEST_ACCESS_TRADE_APPLY_ORDER:
        {
            // 报名请求 orderid  applyType
            [self requestApplyWithApplyReqData:parameters];
            break;
        }
        case CMD_CT_HOME_ORDER_INFO_REQ:
        {
            // 请求主页订单
            [self requestHomeOrderWithHomeOrderListReqData:parameters];
            break;
        }
        case CLIENT_NOTIFY_TRADE_USER_GIS_INFO:
        {
            // 上传用户位置信息
            [self requestUploadLocation:[(CLLocation *)parameters coordinate]];
            break;
        }
        case CLIENT_REQUEST_ACCESS_NAME_LOGIN:
        {
            // 用户名密码登录请求
            NSMutableDictionary *dic = (NSMutableDictionary *)parameters;
            NSString *telephone = [dic objectForKey:@"telephone"];
            NSString *password = [dic objectForKey:@"password"];
            [self LoginUsername:telephone password:password];
            break;
        }
        case CLIENT_REQUEST_ACCESS_TOKEN_LOGIN:
        {
            NSLog(@"token登录请求");
            // token登录请求
            [self requestTokenLogon:(NSString *)parameters];
            break;
        }
        case CLIENT_REQUEST_ACCESS_TRADE_CREATE_ORDER:
        {
            // 创建订单
            [self requestCreateOrder:(id)parameters];
            break;
        }
        case CMD_CT_GLOBAL_USER_INFO_REQ:
        {
            // 全局用户信息请求
            [self requestBatchUserInfoWithIdList:(id)parameters];
            break;
        }
        case CMD_ADDRESS_PHONE_QUERY_REQ:
        {
            // 用户批量请求手机号码对应的uid
            [self requestContactsPhoneList:(int32_t)[(NSArray *)parameters count] addressPhones:parameters];
            break;
        }
        case CLIENT_REQUEST_ACCESS_TRADE_SELECT_VISITORSLIST:
        {
            // 请求客访列表
            [self requestCustomerVisitList:[parameters longLongValue]];
            break;
        }
        case CMD_REGISTER_REQ:
        {
            // 注册
            NSMutableDictionary *dic = (NSMutableDictionary *)parameters;
            NSString *telephone = [dic objectForKey:@"telephone"];
            NSString *pwd = [dic objectForKey:@"password"];
            NSString *verCode = [dic objectForKey:@"verCode"];
            
            [self RegisterUsername:telephone password:pwd phone:telephone vcode:verCode];
            break;
        }
        case CMD_VC_CODE_REQ:
        {
            //获取验证码
            [self GetVerificationCodePhone:parameters];
            break;
        }
        case CLIENT_REQUEST_ACCESS_TRADE_SELECT_PHOTO_WALL:
        {
            //获取照片墙
            [self requestUserPhotoWallWithUID:(NSString *)parameters];
            break;
        }
        case CLIENT_REQUEST_ACCESS_TRADE_UPDATE_PHOTO_WALL:
        {
            //请求更新照片墙
            [self requestUpdatePhotoWallWithPhotosID:(NSArray *)parameters];
            break;
        }
        case CLIENT_REQUEST_ACCESS_TRADE_COMPILE_USER_INFO:
        {
            [self requestAccessTradeCompileUserInfo:(YWXUserDetailInfo *)parameters];
            break;
        }
        case kCLIENT_REQUEST_ACCESS_TRADE_SELECT_APPLYER:
        {
            //选择参与对象请求
            [self requestSelectApplier:parameters];
            break;
        }
        case kCMD_CT_QUERY_DISCUSS_DETAIL_REQ:
        {
            //查询评论信息
            [self requestCommentWith:(YWXGetCommentReqData *)parameters];
            break;
        }
        case kCMD_CT_USER_COMPLAINT_REQ:
        {
            //投诉请求
            [self requestComplaint:(YWXComplaintReqData *)parameters];
            break;
        }
        case kCLIENT_CREATED_ORDER_BRIEF_REQ:
        {
            //查询创建过的订单请求
            [self requestMyOrderList:(MyOrderListReqData *)parameters];
            break;
        }
        case kCT_APPLY_ORDER_BRIEF_REQ:
        {
            //查询申请过的订单
            [self requestMyAppliedList:(MyAppliedListReqData *)parameters];
            break;
        }
        case kCLIENT_REQUEST_ACCESS_TRADE_ORDER_CLOSEDOWN:
        {
            //关闭订单
            [self requestCloseOrderWithOrderid:[parameters longLongValue]];
            break;
        }
        case kCLIENT_GENERATE_PAY_ORDER_REQ:
        {
            //生成支付订单
            [self requestCreatePayOrderWith:parameters];
            break;
        }
        case kCLIENT_WITHDRAW_HONESTY_GOLD_REQ:
        {
            //请求提现
            [self requestWithdrawIntegrityCurrency:parameters];
            break;
        }
        case kCLIENT_REQUEST_ACCESS_TRADE_SELECT_APPLYERUSERINFOLIST:
        {
            //查询报名者列表
            [self requestApplierManagerListWithUidList:parameters];
            break;
        }
        case kCMD_VALIDATE_RETRIEVE_CODE_REQ:
        {
            // 找回密码
            NSMutableDictionary *dic = (NSMutableDictionary *)parameters;
            [self GetValidatePhoneReceiveVeriCode:[dic objectForKey:@"telephone"] ValiCode:[dic objectForKey:@"verificationCode"]];
            break;
        }
        case CMD_RETRIEVE_CODE_REQ:
        {
            // 获取验证码
            [self GetChangePasswordVeriCode:parameters];
            break;
        }
        case CMD_MODIFY_PASSWORD_REQ:
        {
            // 设置新密码
            NSMutableDictionary *dic = (NSMutableDictionary *)parameters;
            [self ChangePassword:[dic objectForKey:@"telephone"] password:[dic objectForKey:@"password"]];
            break;
        }
        case CLIENT_EXCHANGE_STONE_OR_CURRENCY_REQ:
        {
            // 兑换钻石
            [self requestExchangeGameCurrencyOrtryMoneyByYouWoCurrency:parameters];
            break;
        }
        case CLIENT_REQUEST_ACCESS_TRADE_MAKE_REPUTATION:
        {
            //点赞
            [self requestAccessTradeMakeReputation:(int64_t)parameters];
            break;
        }
        default:
            break;
    }
}


#pragma mark - 所有协议回调
- (NSUInteger)didFinishGetData:(NSData *)aData {
    int16_t errorCode = g_clientPkg.unpack((const char *)[aData bytes], aData.length); // 收到完整的协议包-解析
    self.responseProtocolID = g_clientPkg.stHead.dwCmdID;
    NSLog(@"socket 接收码=%llu,aWDataSize=%ld 错误码=%lld", (unsigned long long)self.responseProtocolID, (unsigned long)aData.length, (long long)errorCode);
    if (TdrError::TDR_NO_ERROR == errorCode) {
        switch (self.responseProtocolID) {
                
            case CMD_PLAYERS_NEARBY_RESP:
            {
                // 附近的人
                [self responseNearByList];
                break;
            }
            case CMD_TC_REPORT_INFO_RESP:
            {
                // 举报-某人或某单
                [self responseReport];
                break;
            }
            case TRADE_RESPONSE_ACCESS_CLIENT_ORDER_DONE_APPLYER:
            {
                // 接单人确认完成-响应
                [self responseConfirmFinishWithResponseProtocolID:TRADE_RESPONSE_ACCESS_CLIENT_ORDER_DONE_APPLYER];
                break;
            }
            case TRADE_RESPONSE_ACCESS_CLIENT_ORDER_DONE_CREATER:
            {
                // 发单人确认完成-响应
                [self responseConfirmFinishWithResponseProtocolID:TRADE_RESPONSE_ACCESS_CLIENT_ORDER_DONE_CREATER];
                break;
            }
            case CMD_TC_DISCUSS_ORDER_RESP:
            {
                 // 发表评论
                [self responseSendComment];
                break;
            }
            case TRADE_RSPONSE_ACCESS_CLIENT_SELECT_APPLYERUSERINFOLIST:
            {
                // 报名者管理列表
                [self responseApplierManagerList];
                break;
            }
            case TRADE_RESPONSE_ACCESS_CLIENT_GET_TASK_AWARD:
            {
                // 领取每日任务奖励
                [self responseGetTaskAward];
                break;
            }
            case TRADE_RSPONSE_ACCESS_CLIENT_SELECT_TASKINFO:
            {
                // 获取每日任务
                [self responseDailyMission];
                break;
            }
            case ACCESS_RESPONSE_CLIENT_NAME_LOGIN:
            {
                //登入响应
                [self responseLogon];
                break;
            }
            case CMD_TC_GLOBAL_USER_INFO_RESP:
            {
                // 返回-批量用户信息（个人信息与业务信息）
                [self responseBatchUserInfo];
                break;
            }
            case TRADE_RESPONSE_ACCESS_CLIENT_SELECT_ORDER_DETAILS_INFO:
            {
                // 订单详情返回
                [self responseOrderDetail];
                break;
            }
            case CMD_TC_HOME_ORDER_INFO_RESP:
            {
                // 首页订单信息响应
                [self responseHomeOrder];
                break;
            }
            case TRADE_RSPONSE_CLIENT_USER_GIS_INFO:
            {
                // 交易服务器回应客户端更新用户的地理位置信息结果
                [self responseUploadLocation];
                break;
            }
            case TRADE_RSPONSE_ACCESS_CLIENT_UPDATE_PHOTO_WALL:
            {
                // 交易服务器回应网关客户端更新照片墙信息
                [self responseUpdatePhotoWall];
                break;
            }
            case CLIENT_EXCHANGE_STONE_OR_CURRENCY_RESP:
            {
                // 有我币兑换其他币
                [self responseExchangeGameCurrencyOrtryMoneyByYouWoCurrency];
                break;
            }
            case CLIENT_WITHDRAW_HONESTY_GOLD_RESP:
            {
                // 客户端请求提取诚信金 响应
                [self responseWithdrawIntegrityCurrency];
                break;
            }
            case TRADE_NOTIFY_CLIENT_PAY_RESULT:
            {
                // 充值结果
                [self responseChargeResult];
                break;
            }
            case CLIENT_GENERATE_PAY_ORDER_RESP :
            {
                // 创建充值单号
                [self responseCreatePayOrder];
                break;
            }
            case CLIENT_GET_THIRDPARTY_PAY_TOKEN_RESP:
            {
                // 获取支付token
                [self responsePayToken];
                break;
            }
            case kCMD_TC_USER_COMPLAINT_RESP:
            {
                // 投诉请求响应
                [self responseComplaint];
                break;
            }
            case CMD_KICKOFF_USER_NOTIFY:
            {
                SharePersonalInfo.accountStatus = YWXAccountKicked;
                NSLog(@"服务器踢掉用户通知给客户端");
                // 服务器踢掉用户通知给客户端
                [[NSNotificationCenter defaultCenter] postNotificationName:kKickOffUserNotificationKey object:nil];
                break;
            }
            case TRADE_RSPONSE_ACCESS_CLIENT_UPDATE_ARGUE:
            {
                // 订单评价-响应
                [self responseOrderEvaluate];
                break;
            }
            case TRADE_RSPONSE_ACCESS_CLIENT_SELECT_APPLYER:
            {
                // 选择参与对象
                [self responseSelectApplyer];
                break;
            }
            case CLIENT_CONFIRM_OR_CANCEL_ORDER_RESP:
            {
                // 取消或确认订单
                [self responseConfirmOrCancelOrder];
                break;
            }
            case TC_APPLY_ORDER_BRIEF_RESP:
            {
                // 已报名订单列表
                [self responseMyAppliedList];
                break;
            }
            case CLIENT_CREATED_ORDER_BRIEF_RESP:
            {
                // 已创建订单列表
                [self responseMyOrderList];
                break;
            }
            case TRADE_RSPONSE_ACCESS_CLIENT_CREATE_ORDER:
            {
                // 订单创建成功
                [self responseCreateOrder];
                break;
            }
            case TRADE_RSPONSE_ACCESS_CLIENT_APPLY_ORDER: {
                // 报名成功
                [self responseApply];
                break;
            }
            case CMD_VC_CODE_RESP:
            {
                // 注册验证码请求返回
                [self GetVerificationCodePhoneResponse];
                break;
            }
            case CMD_REGISTER_RESP:
            {
                // 注册账号返回
                [self RegisterResponse];
                break;
            }
            case CMD_UPDATE_BASE_INFO_RESP:
            {
                // 完善资料
                [self responsePolishUserInfo];
                break;
            }
            case   TRADE_RSPONSE_ACCESS_CLIENT_SELECT_PHOTO_WALL:
            {
                [self responseUserPhotoWall];
                break;
            }
            case CMD_RETRIEVE_CODE_RESP:
            {
                // 获取修改密码手机验证码响应
                [self GetChangePasswordVeriCodeResponse];
                break;
            }
            case CMD_VALIDATE_RETRIEVE_CODE_RESP:
            {
                [self GetValidatePhoneReceiveVeriCodeResponse];
                break;
            }
            case CMD_MODIFY_PASSWORD_RESP:
            {
                [self ChangePasswordResponse];
                break;
            }
            case CMD_CLIENT_PHONE_QUERY_USERID_RESP:{
                [self responseClientPhoneQueryUserId];
                break;
            }
            case TRADE_RSPONSE_ACCESS_CLIENT_GET_CHATROOMINFOLIST:{
                [self responseClientAccessTradeGetChatRoomInfoList];
                break;
            }
            case CMD_UPDATE_BIRTHDAY_RESP:{
                [self responseUpdateBirthday];
                break;
            }
            case CMD_UPDATE_NICKNAME_RESP:{
                //[self responseUpdateNickName];
                break;
            }
            case CMD_UPDATE_OCCUPATION_RESP:{
                [self responseUpdateOccupation];
                break;
            }
            case CMD_UPDATE_RESIDENTION_RESP:{
                [self responseUpdateResidention];
                break;
            }
            case CMD_UPDATE_PORTRAIT_RESP:{
                [self responseUpdatePortrait];
                break;
            }
            case CMD_GC_UPDATE_RESIDENTION_DETAIL_RESP:{
                [self responseUpdateResidentionDetail];
                break;
            }
            case TRADE_RSPONSE_ACCESS_CLIENT_SELECT_VISITORSLIST:{
                [self responseCustomerVisitList];
                break;
            }
            case TRADE_RESPONSE_ACCESS_CLIENT_COMPILE_USER_INFO:{
                // 交易服务器回应网关客户端编辑资料
                [self responseAccessClientCompileUserInfo];
                break;
            }
            case CMD_ADDRESS_PHONE_QUERY_RESP:{
                [self responseContactsPhoneList];
                break;
            }
            case CMD_TC_QUERY_DISCUSS_DETAIL_RESP:{
                [self responseComment];
                break;
            }
            case TRADE_RSPONSE_ACCESS_CLIENT_ORDER_CLOSEDOWN:{
                //关闭订单
                [self responseCloseOrder];
                break;
            }
            case TRADE_RESPONSE_ACCESS_CLIENT_MAKE_REPUTATION:{
                // 点赞返回
                [self responseAccessTradeMakeReputation];
                break;
            }
            default:
                NSLog(@"解析到没有回调的协议号");
                break;
        }
    }
    else {
        [self responseCallBackWithResponseProtocolID:g_clientPkg.stHead.dwCmdID  responseObject:nil result:NO];
        NSLog(@"%@",[NSString stringWithFormat:@"socket数据解析失败,失败码:%hd", errorCode]);
    }
    
    if (g_clientPkg.stHead.dwCmdID == 0) {
        errorCode = -1;
    }
    
    return errorCode;
}
@end
