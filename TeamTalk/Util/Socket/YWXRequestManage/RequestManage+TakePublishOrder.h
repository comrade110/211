//
//  RequestManage+TakePublishOrder.h
//  youwo
//
//  Created by mygame on 15/4/12.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "RequestManage.h"
@class YWXComplaintReqData;
@class ConfirmCancelOrderReqData;
@class YWXApplyOrConfirmFinishReqData;
@class YWXOrderEvaluateReqData;

@interface RequestManage (TakePublishOrder)

/**
 *  (接单人、发单人)确认完成请求-接单流程
 */
- (void)requestConfirmFinishWithApplyOrConfirmFinishReqData:(YWXApplyOrConfirmFinishReqData *)reqData;

/**
 *  (接单人、发单人)确认完成返回-接单流程
 *  @param responseProtocolID 返回协议ID
 */
- (void)responseConfirmFinishWithResponseProtocolID:(uint64_t)responseProtocolID;

/**
 *  订单评价-请求
 *  @param reqData YWXOrderEvaluateReqData 对象
 */
- (void)requestOrderEvaluateReqData:(YWXOrderEvaluateReqData *)reqData;

/**
 *  订单评价-响应
 */
- (void)responseOrderEvaluate;

/**
 *  投诉请求
 *
 *  @param complaintReqData 投诉数据-YWXComplaintReqData
 */
- (void)requestComplaint:(YWXComplaintReqData *)complaintReqData;

/**
 *  投诉返回结果
 */
- (void)responseComplaint;

/**
 *  接单人确认接单或者发单者取消订单 请求
 *
 *  @param ConfirmCancelOrderReqData ConfirmCancelOrderReqData description
 */
- (void)requestConfirmOrCancelOrder:(ConfirmCancelOrderReqData *)ConfirmCancelOrderReqData;

/**
 *  接单人确认接单或者发单者取消订单 返回
 */
- (void)responseConfirmOrCancelOrder;
@end
