//
//  RequestManage+TakePublishOrder.m
//  youwo
//
//  Created by mygame on 15/4/12.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "RequestManage+TakePublishOrder.h"
#import "YWXComplaintReqData.h"
#import "ConfirmCancelOrderReqData.h"
#import "YWXApplyOrConfirmFinishReqData.h"
#import "YWXOrderEvaluateReqData.h"

#import "client_protocol.h"
using namespace client;
extern ClientPkg g_clientPkg;
extern char g_pkgBuffer[SocketBufferSize];

@implementation RequestManage (TakePublishOrder)

//CLIENT_REQUEST_ACCESS_TRADE_ORDER_DONE_APPLYER = 2111, // 客户端请求网关交易服务器接单人完成订单
//TRADE_RESPONSE_ACCESS_CLIENT_ORDER_DONE_APPLYER = 2112, // 交易服务器回应网关客户端接单人完成订单
//CLIENT_REQUEST_ACCESS_TRADE_ORDER_DONE_CREATER = 2113, // 客户端请求网关交易服务器发单人完成订单
//TRADE_RESPONSE_ACCESS_CLIENT_ORDER_DONE_CREATER = 2114, // 交易服务器回应网关客户端发单人完成订单
/**
 *  (接单人、发单人)确认完成请求-接单流程
 */
- (void)requestConfirmFinishWithApplyOrConfirmFinishReqData:(YWXApplyOrConfirmFinishReqData *)reqData {
    if (reqData.confirmFinishType == 1) {
        // 接单人请求完成
        memset(&g_clientPkg.stBody.stClientRequestAccessTradeOrderDoneApplyer, 0, sizeof(g_clientPkg.stBody.stClientRequestAccessTradeOrderDoneApplyer));
        g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_TRADE_ORDER_DONE_APPLYER;
        g_clientPkg.stBody.stClientRequestAccessTradeOrderDoneApplyer.llOrderid = reqData.orderID;
        [self readySendData];
    }
    else if (reqData.confirmFinishType == 2) {
        // 发单人请求完成
        memset(&g_clientPkg.stBody.stClientRequestAccessTradeOrderDoneCreater, 0, sizeof(g_clientPkg.stBody.stClientRequestAccessTradeOrderDoneCreater));
        g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_TRADE_ORDER_DONE_CREATER;
        g_clientPkg.stBody.stClientRequestAccessTradeOrderDoneCreater.llOrderid = reqData.orderID;
        [self readySendData];
    }
    
}

/**
 *  (接单人、发单人)确认完成返回-接单流程
 *  @param responseProtocolID 返回协议ID
 */
- (void)responseConfirmFinishWithResponseProtocolID:(uint64_t)responseProtocolID {
    if (responseProtocolID == TRADE_RESPONSE_ACCESS_CLIENT_ORDER_DONE_APPLYER) {
        uint32_t result = g_clientPkg.stBody.stTradeResponseAccessClientOrderDoneApplyer.iResult;
        [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];
    }
    else if (responseProtocolID == TRADE_RESPONSE_ACCESS_CLIENT_ORDER_DONE_CREATER){
        uint32_t result = g_clientPkg.stBody.stTradeResponseAccessClientOrderDoneCreater.iResult;
        [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];
    }
}

/**
 *  订单评价-请求
*  @param reqData YWXOrderEvaluateReqData 对象
 */
- (void)requestOrderEvaluateReqData:(YWXOrderEvaluateReqData *)reqData {
    memset(&g_clientPkg.stBody.stClientRequestAccessTradeUpdateArgue, 0, sizeof(g_clientPkg.stBody.stClientRequestAccessTradeUpdateArgue));
    g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_TRADE_UPDATE_ARGUE;
    
    g_clientPkg.stBody.stClientRequestAccessTradeUpdateArgue.llOrderid = reqData.orderID;
    g_clientPkg.stBody.stClientRequestAccessTradeUpdateArgue.iScore = reqData.score; // int32_t iScore; // 评价分数[1,5]
    
    [self readySendData];
}

/**
 *  订单评价-响应
 */
- (void)responseOrderEvaluate {
    int result = g_clientPkg.stBody.stTradeResponseAccessClientUpdateArgue.iResult;
    
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];
}

/**
 *  投诉请求
 *
 *  @param complaintReqData 投诉数据-YWXComplaintReqData
 */
- (void)requestComplaint:(YWXComplaintReqData *)complaintReqData {
    memset(&g_clientPkg.stBody.stCT_UserComplaint_Req, 0, sizeof(g_clientPkg.stBody.stCT_UserComplaint_Req));
    g_clientPkg.stHead.dwCmdID = CMD_CT_USER_COMPLAINT_REQ;
    
    g_clientPkg.stBody.stCT_UserComplaint_Req.llCom_uid = complaintReqData.complainantUID;
    g_clientPkg.stBody.stCT_UserComplaint_Req.llCom_phone = complaintReqData.complainantPhoneNum;
    g_clientPkg.stBody.stCT_UserComplaint_Req.llTo_uid = complaintReqData.respondentUID;
    g_clientPkg.stBody.stCT_UserComplaint_Req.llTo_phone = complaintReqData.respondentPhoneNum;
    g_clientPkg.stBody.stCT_UserComplaint_Req.llOrder_id = complaintReqData.orderID;
    g_clientPkg.stBody.stCT_UserComplaint_Req.iDescLen = (int32_t)strlen([complaintReqData.complainantContent UTF8String]);
    memcpy(g_clientPkg.stBody.stCT_UserComplaint_Req.szDesc, [complaintReqData.complainantContent UTF8String], strlen([complaintReqData.complainantContent UTF8String]));
    [self readySendData];
}

/**
 *  投诉返回结果
 */
- (void)responseComplaint {
    int result = g_clientPkg.stBody.stTC_UserComplaint_Resp.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];
}

/**
 *  接单人确认接单或者发单者取消订单 请求
 *
 *  @param ConfirmCancelOrderReqData ConfirmCancelOrderReqData description
 */
- (void)requestConfirmOrCancelOrder:(ConfirmCancelOrderReqData *)ConfirmCancelOrderReqData {
    memset(&g_clientPkg.stBody.stClientConfirmOrCancelOrderReq, 0, sizeof(g_clientPkg.stBody.stClientConfirmOrCancelOrderReq));
    g_clientPkg.stHead.dwCmdID = CLIENT_CONFIRM_OR_CANCEL_ORDER_REQ;

    g_clientPkg.stBody.stClientConfirmOrCancelOrderReq.llOrderid = ConfirmCancelOrderReqData.orderID;
    g_clientPkg.stBody.stClientConfirmOrCancelOrderReq.bConfirmOrCancel = ConfirmCancelOrderReqData.orderOperation;
    [self readySendData];
}

/**
 *  接单人确认接单或者发单者取消订单 返回
 */
- (void)responseConfirmOrCancelOrder {
    int result = g_clientPkg.stBody.stClientConfirmOrCancelOrderResp.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];
}
@end
