//
//  RequestManage+MsgList.h
//  youwo
//
//  Created by mygame on 15/1/15.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "RequestManage.h"
@class HomeOrderListReqData;
@class PublishDataModel;
@class MyOrderListReqData;
@class MyAppliedListReqData;
@class ConfirmCancelOrderReqData;
@class YWXSelectApplierReqData;
@class YWXHomeOrderInfoData;
@class YWXUserDetailInfo;
@class YWXHomeOrderListReqData;
@class YWXCreateOrderData;
@class YWXPublishOrderReqData;
@class YWXOrderInfoData;
@class YWXGetCommentReqData;
@class YWXSendCommentReqData;
@class YWXApplyOrConfirmFinishReqData;

@interface RequestManage (MsgList)
/**
 *  请求 - 获取主页订单
 *
 *  @param homeOrderListReqData homeOrderListReqData description
 */
- (void)requestHomeOrderWithHomeOrderListReqData:(YWXHomeOrderListReqData *)homeOrderListReqData;

/**
 *  返回 - 获取主页订单
 */
- (void)responseHomeOrder;

/**
 *  选择参与对象请求
 *
 *  @param selectApplyerReqData selectApplyerReqData
 */
- (void)requestSelectApplier:(YWXSelectApplierReqData *)selectApplyerReqData;

/**
 *  选择参与对象返回
 */
- (void)responseSelectApplyer;

/**
 *  请求订单详情
 *
 *  @param orderID 订单ID
 */
- (void)requestOrderDetail:(uint64_t)orderID;

/**
 *  订单详情返回
 */
- (void)responseOrderDetail;

/**
 *  查询我申请的订单
 *
 *  @param myAppliedListReq
 */
- (void)requestMyAppliedList:(MyAppliedListReqData *)myAppliedListReq;

/**
 *  我申请的订单返回
 */
- (void)responseMyAppliedList;

///**
// *  查询用户资料返回
// *
// *  @param uid 
// */
//- (void)requestUserBaseInfo:(uint64_t)uid;

///**
// *  用户资料返回
// */
//- (void)responseUserBaseInfo;

/**
 *  请求查询我的创建的订单
 *
 *  @param myCreateOrderListReq 查询参数
 */
- (void)requestMyOrderList:(MyOrderListReqData *)myCreateOrderListReq;

/**
 *  我的订单返回
 */
- (void)responseMyOrderList;

/**
 *  创建订单
 *
 *  @param publishData 发单数据
 */
- (void)requestCreateOrder:(YWXPublishOrderReqData *)publishData;


/**
 *  创建订单返回
 */
- (void)responseCreateOrder;

/**
 *  报名
 */
- (void)requestApplyWithApplyReqData:(YWXApplyOrConfirmFinishReqData *)reqData;

/**
 *  报名返回
 */
- (void)responseApply;

/**
 *  获取评论
 *
 *  @param reqData   评论参数
 */
- (void)requestCommentWith:(YWXGetCommentReqData *)reqData;

/**
 *  评论返回
 */
- (void)responseComment;

/// 发表评论请求
- (void)requestSendCommentWithReqData:(YWXSendCommentReqData *)reqData;

/// 发表评论响应
- (void)responseSendComment;

//关闭订单
- (void)requestCloseOrderWithOrderid:(int64_t)orderid;

//关闭订单响应
- (void)responseCloseOrder;

@end
