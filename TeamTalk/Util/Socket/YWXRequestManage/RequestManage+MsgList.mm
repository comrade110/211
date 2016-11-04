//
//  RequestManage+MsgList.m
//  youwo
//
//  Created by mygame on 15/1/15.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "RequestManage+MsgList.h"

#import "YWXUserAccountInfo.h"
#import "YWXHomeOrderListReqData.h"
#import "MyOrderListReqData.h"
#import "ConfirmCancelOrderReqData.h"
#import "YWXOrderDetailData.h"
#import "YWXSelectApplierReqData.h"
#import "YWXUserDetailInfo.h"
#import "YWXCreateOrderData.h"
#import "YWXPublishOrderReqData.h"
#import "YWXOrderInfoData.h"
#import "YWXSelectTypeData.h"
#import "YWXApplierStatusInfo.h"
#import "YWXPhotoData.h"
#import "YWXAudioInfo.h"
#import "YWXOrderDetailCommentData.h"
#import "YWXGetCommentReqData.h"
#import "YWXSendCommentReqData.h"
#import "YWXApplyOrConfirmFinishReqData.h"

#import "Utility+Map.h"

#import "client_protocol.h"
using namespace client;
extern ClientPkg g_clientPkg;
extern char g_pkgBuffer[SocketBufferSize];

@implementation RequestManage (MsgList)
/**
 *  请求 - 获取主页订单
 *
 *  @param homeOrderListReqData homeOrderListReqData description
 */
- (void)requestHomeOrderWithHomeOrderListReqData:(YWXHomeOrderListReqData *)homeOrderListReqData {
    memset(&g_clientPkg.stBody.stCT_HomeOrderInfo_Req, 0, sizeof(g_clientPkg.stBody.stCT_HomeOrderInfo_Req));
    g_clientPkg.stHead.dwCmdID                                  = CMD_CT_HOME_ORDER_INFO_REQ;
    g_clientPkg.stBody.stCT_HomeOrderInfo_Req.iPag              = homeOrderListReqData.page;
    g_clientPkg.stBody.stCT_HomeOrderInfo_Req.iSex              = homeOrderListReqData.gender; // 单主性别过滤， 0：不分男女， 1：只限男性，2:只限女性
    g_clientPkg.stBody.stCT_HomeOrderInfo_Req.llLongitude       = homeOrderListReqData.coordinate2D.longitude*YWXInt10E6;
    g_clientPkg.stBody.stCT_HomeOrderInfo_Req.llLatitude        = homeOrderListReqData.coordinate2D.latitude*YWXInt10E6;
    g_clientPkg.stBody.stCT_HomeOrderInfo_Req.iOrderMainType    = homeOrderListReqData.orderMainType;// 单主年龄上限，0为没有上限
    g_clientPkg.stBody.stCT_HomeOrderInfo_Req.iValidOrder       = homeOrderListReqData.validOrder;// 单主年龄下限，0为没有下限
    g_clientPkg.stBody.stCT_HomeOrderInfo_Req.iMoneyType        = homeOrderListReqData.moneyType;
    if (homeOrderListReqData.moneyType == 2) {
        g_clientPkg.stBody.stCT_HomeOrderInfo_Req.iMoneyNumUp       = homeOrderListReqData.moneyUp * 100; // 现金
        g_clientPkg.stBody.stCT_HomeOrderInfo_Req.iMoneyNumDown     = homeOrderListReqData.moneyDown * 100;
    }
    else {
        g_clientPkg.stBody.stCT_HomeOrderInfo_Req.iMoneyNumUp       = homeOrderListReqData.moneyUp;// 服务费（打赏钱）上限，0为没有上限
        g_clientPkg.stBody.stCT_HomeOrderInfo_Req.iMoneyNumDown     = homeOrderListReqData.moneyDown;// 服务费（打赏钱）下限，0为没有下限
    }
    
    g_clientPkg.stBody.stCT_HomeOrderInfo_Req.iAgeUp            = homeOrderListReqData.ageUp;
    g_clientPkg.stBody.stCT_HomeOrderInfo_Req.iAgeDown          = homeOrderListReqData.ageDown;
    g_clientPkg.stBody.stCT_HomeOrderInfo_Req.iTimeType         = homeOrderListReqData.timeType;
    g_clientPkg.stBody.stCT_HomeOrderInfo_Req.iDistanceType     = homeOrderListReqData.distanceType;
    g_clientPkg.stBody.stCT_HomeOrderInfo_Req.iOrderSortType    = homeOrderListReqData.orderSortType;// 请求订单个数
    
    [self readySendData];
}

/**
 *  返回 - 获取主页订单
 */
- (void)responseHomeOrder {
    uint8_t result = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.iResult;
    uint8_t homeOrderNum = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.dwInfoCount;
    NSMutableArray *homeOrderList = [NSMutableArray array];
    if (result == 0) {
        for (NSUInteger i = 0; i < homeOrderNum; i++) {
            YWXOrderInfoData *orderInfoData = [[YWXOrderInfoData alloc] init];
            //orderInfoData.orderType             = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].iType;
            orderInfoData.orderID               = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].llOrderid;
            orderInfoData.orderStatus           = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].iStatus;
            orderInfoData.orderCreaterUid       = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].llCreaterUid;
            orderInfoData.orderCreatTime        = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].iCreateTime;
            orderInfoData.orderZoneInfo         = [NSString strWithBytes:g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].szPosInfo length:g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].iPosInfoLen];
            
            
            orderInfoData.orderDetailDescrption = [NSString strWithBytes:g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].szParticulars length:g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].iParticularsLen];
            orderInfoData.orderDetailDescrption = [Utility orderDetailDes:orderInfoData.orderDetailDescrption orderType:orderInfoData.orderType];
            
            orderInfoData.orderMoneyType        = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].iMoneyType;
            int32_t orderMoneyNum               = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].iMoneyNum;
            orderInfoData.orderMoneyNum         = orderInfoData.orderMoneyType == 2 ? orderMoneyNum/100.0 : orderMoneyNum;
            orderInfoData.orderGenderFilter     = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].iGender;
            orderInfoData.orderApplyStatus      = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].iApplyStata;
            orderInfoData.orderCommentNum       = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].iDiscussNum;
            orderInfoData.orderLocation         = CLLocationCoordinate2DMake(g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].llLatitude/YWXFloat10E6, g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].llLongitude/YWXFloat10E6);
            orderInfoData.orderApplierNum       = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].iApplyNum;
            orderInfoData.orderCreaterNickName  = [NSString strWithBytes:g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].szCreaterNickname length:g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].iCreaterNickNameLen];
            orderInfoData.orderCreaterBirthday  = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].llCreaterBirth;
            orderInfoData.orderCreaterGender    = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].iCreaterGender;
            
            // 图片
            NSUInteger pictureNum = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].iPictureNum;
            for (NSUInteger j = 0; j < pictureNum; j++) {
                YWXPhotoData *photoData = [[YWXPhotoData alloc] init];
                photoData.uid = orderInfoData.orderCreaterUid;
                photoData.photoID = [NSString strFromllong:g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].pictureidList[j]];
                photoData.photoUrl = [NSString publishOrderPhotoImageURLStringWithUserID:photoData.uid photoID:photoData.photoID];
                [orderInfoData.picturelist addObject:photoData];
            }
            
            // 语音
            NSUInteger audioNum = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].iAudioNum; // 最大为 CREATE_ORDER_AUDIO_MAX_NUM
            if (audioNum > 0 && audioNum < CREATE_ORDER_AUDIO_MAX_NUM) {
                for (NSUInteger j = 0; j < audioNum; j++) {
                    YWXAudioInfo *audioInfo = [[YWXAudioInfo alloc] init];
                    audioInfo.audioId = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].astAudioInfo[j].llAudioId;
                    audioInfo.seconds = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].astAudioInfo[j].iSeconds;
                    audioInfo.audioUrl = [NSString publishOrderRecordURLStringWithUserID:orderInfoData.orderCreaterUid recordID:[NSString strFromllong:audioInfo.audioId]];
                    [orderInfoData.audioList addObject:audioInfo];
                }
            }
            
            orderInfoData.orderCreaterIntegrityLevel    = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].iCreaterIntegrity_level;
            orderInfoData.orderCreaterCreditLevel       = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].iCreaterCreditLevel;
            orderInfoData.orderCreaterCreditValue       = g_clientPkg.stBody.stTC_HomeOrderInfo_Resp.astHomeOrderInfos[i].iCreaterCreditValue;
            
            CGFloat textH = 0;
            if (orderInfoData.orderDetailDescrption.length) {
                textH = [orderInfoData.orderDetailDescrption boundingRectWithSize:CGSizeMake(YWXScreenWidth-20, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size.height;
            }
            if (textH > 36) {
                textH = 36;
            }
            //orderInfoData.homeCellHeight = 90 + (textH>0 ? ceil(textH)+10 : 0) + (orderInfoData.audioList.count > 0 ? 35 : 0) + (orderInfoData.picturelist.count > 0 ? 185 : 0);
            
            if (orderInfoData.picturelist.count > 0 && orderInfoData.audioList.count > 0) {
                orderInfoData.homeCellType = YWXHomeCellTextAudioPhoto;
                orderInfoData.homeCellHeight = 328-18+textH;
            }
            else if (orderInfoData.picturelist.count > 0) {
                orderInfoData.homeCellType = YWXHomeCellTextPhoto;
                orderInfoData.homeCellHeight = 288-18+textH;
            }
            else if (orderInfoData.audioList.count > 0) {
                orderInfoData.homeCellType = YWXHomeCellTextAudio;
                orderInfoData.homeCellHeight = 152-18+textH;
            }
            else {
                orderInfoData.homeCellType = YWXHomeCellText;
                orderInfoData.homeCellHeight = 118-18+textH;
            }
            [homeOrderList addObject:orderInfoData];
        }
    }
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:result == 0 ? homeOrderList : @(result) result:result == 0 ?: NO];
}

/**
 *  选择参与对象请求
 *
 *  @param selectApplyerReqData selectApplyerReqData
 */
- (void)requestSelectApplier:(YWXSelectApplierReqData *)selectApplyerReqData {
    memset(&g_clientPkg.stBody.stClientRequestAccessTradeSelectApplyer, 0, sizeof(g_clientPkg.stBody.stClientRequestAccessTradeSelectApplyer));
    g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_TRADE_SELECT_APPLYER;
    
    g_clientPkg.stBody.stClientRequestAccessTradeSelectApplyer.llOrderid = selectApplyerReqData.orderid;
    g_clientPkg.stBody.stClientRequestAccessTradeSelectApplyer.llApplyerid = selectApplyerReqData.applyerUID;
    [self readySendData];
}

/**
 *  选择参与对象返回
 */
- (void)responseSelectApplyer {
    uint8_t result = g_clientPkg.stBody.stTradeResponseAccessClientSelectApplyer.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:result == 0 ? @"发送成功" : @(result) result:result == 0 ?: NO];}


/**
 *  请求订单详情
 *
 *  @param orderID 订单ID
 */
- (void)requestOrderDetail:(uint64_t)orderID {
    memset(&g_clientPkg.stBody.stClientRequestAccessTradeSelectOrderDetailsInfo, 0, sizeof(g_clientPkg.stBody.stClientRequestAccessTradeSelectOrderDetailsInfo));
    g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_TRADE_SELECT_ORDER_DETAILS_INFO;
    g_clientPkg.stBody.stClientRequestAccessTradeSelectOrderDetailsInfo.llOrderid = orderID;
    
    [self readySendData];
}

/**
 *  订单详情返回
 */
- (void)responseOrderDetail {
    int32_t result = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iResult;

    YWXOrderDetailData *orderDetailData     = [[YWXOrderDetailData alloc] init];
    orderDetailData.detailCellHeight        = 311;
    orderDetailData.detailCellRealHeight    = 311;
    orderDetailData.orderID                 = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.llOrderid;
    orderDetailData.orderCreaterUid         = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.llCreater_uid;
    orderDetailData.orderCreaterPhoneNumber = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.llCreater_phone;
    orderDetailData.orderApplierPhoneNumber = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.llApplyer_phone;
    orderDetailData.orderStatus             = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iStatus;
    orderDetailData.orderType               = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iType;
    orderDetailData.orderGenderFilter       = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iGender; // 此单面向的对象的性别
    orderDetailData.orderCreatTime          = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iCreate_time;
    orderDetailData.orderMoneyType          = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iMoney_type;
    orderDetailData.orderMoneyNum           = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iMoney_num;
    orderDetailData.orderMoneyNum           = orderDetailData.orderMoneyType == 2 ? orderDetailData.orderMoneyNum/100.0 : orderDetailData.orderMoneyNum;
    orderDetailData.orderLocation           = CLLocationCoordinate2DMake(g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.llDimension/YWXFloat10E6, g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.llLongitude/YWXFloat10E6);
    
    orderDetailData.orderDetailDescrption   = [NSString strWithBytes:g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.szParticulars length:g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iParticulars_len];
    orderDetailData.orderDetailDescrption   = [Utility orderDetailDes:orderDetailData.orderDetailDescrption orderType:orderDetailData.orderType];
    //[[Utility orderMianTypeWithIndex:orderDetailData.orderType] stringByAppendingString:orderDetailData.orderDetailDescrption];
    
    orderDetailData.orderZoneInfo           = [NSString strWithBytes:g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.szPos_info length:g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iPos_info_len];
    
    // 报名人数
    int32_t orderApplierNum = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iApply_num;
    for (NSUInteger i = 0; i < orderApplierNum; i++) {
        YWXApplierStatusInfo *applierInfo = [[YWXApplierStatusInfo alloc] init];
        applierInfo.applyUID         = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.astApply_info_list[i].llUid;
        applierInfo.applyStatus      = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.astApply_info_list[i].iStatus;
        applierInfo.applyTime        = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.astApply_info_list[i].iApply_time;
        applierInfo.applyOrderID     = orderDetailData.orderID;
        [orderDetailData.orderApplierInfoList addObject:applierInfo];
    }
    
    // 语音
    NSUInteger audioNum = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iAudio_num; // 最大为 CREATE_ORDER_AUDIO_MAX_NUM
    if (audioNum > 0 && audioNum < CREATE_ORDER_AUDIO_MAX_NUM) {
        for (NSUInteger j = 0; j < audioNum; j++) {
            YWXAudioInfo *audioInfo = [[YWXAudioInfo alloc] init];
            audioInfo.audioId  = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.astAudio_info_list[j].llAudio_id;
            audioInfo.seconds  = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.astAudio_info_list[j].iSeconds;
            audioInfo.audioUrl = [NSString publishOrderRecordURLStringWithUserID:orderDetailData.orderCreaterUid recordID:[NSString strFromllong:audioInfo.audioId]];
            [orderDetailData.audioList addObject:audioInfo];
        }
    }
    
    // 图片
    int32_t photoNum = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iPicture_num;
    for (NSUInteger j = 0; j < photoNum; j++) {
        YWXPhotoData *photoData = [[YWXPhotoData alloc] init];
        photoData.uid = orderDetailData.orderCreaterUid;
        photoData.photoID = [NSString strFromllong:g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.pictureid_list[j]];
        photoData.photoUrl = [NSString publishOrderPhotoImageURLStringWithUserID:photoData.uid photoID:photoData.photoID];
        [orderDetailData.picturelist addObject:photoData];
    }
    
    if (orderDetailData.orderDetailDescrption.length == 0) {
        // 没有文字
        orderDetailData.detailCellHeight -= 18+10+33;
        orderDetailData.detailCellRealHeight -= 18+10+33;
    }
    else {
        CGSize size = YWXGetStrSizeWithFontSize(orderDetailData.orderDetailDescrption, CGSizeMake(YWXScreenWidth-20, 3000), 15);
        if (ceilf(size.height) >= 36) {
            // 文字大于两行，同时要显示：全部按钮
            orderDetailData.detailCellHeight += 18;
            
            orderDetailData.detailCellRealHeight += ceilf(size.height)-18;
        }
        else {
            // 文字只有行，不要显示：全部按钮
            orderDetailData.detailCellHeight -= 33;
            
            orderDetailData.detailCellRealHeight -= 33;
        }
    }
    if (audioNum == 0) {
        // 没有语音
        orderDetailData.detailCellHeight -= 30;
        
        orderDetailData.detailCellRealHeight -= 30;
    }
    if (photoNum == 0) {
        // 没有图片
        orderDetailData.detailCellHeight -= 125;
        
        orderDetailData.detailCellRealHeight -= 125;
    }

    orderDetailData.firstCommentator = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.llDiscuss_head_id;
    orderDetailData.lastCommentator = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.llDiscuss_tail_id;
    orderDetailData.orderScore = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iScore;
    orderDetailData.orderCreaterCreditValue = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iSincerity_value;
    orderDetailData.applyFinishNum = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iO_apply_fini_num;
    
    orderDetailData.orderApplierUID = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.llApplyer_uid;
    orderDetailData.orderCreaterGender = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iCreater_gender;
    orderDetailData.orderApplierGender = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iApplyer_gender;
    orderDetailData.orderCreaterBirthday = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.llCreater_birth;
    orderDetailData.orderApplierBirthday = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.llApplyer_birth;
    orderDetailData.orderCreaterNickName     = [NSString strWithBytes:g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.szCreater_nickname length:g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iCreater_nickname_len];
    orderDetailData.orderApplierNickname = [NSString strWithBytes:g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.szApplyer_nickname length:g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iApplyer_nickname_len];
    orderDetailData.orderApplyStatus = g_clientPkg.stBody.stTradeResponseAccessClientSelectOrderDetailsInfo.iApply_status;
    
    // 回调
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:result == 0 ? orderDetailData : @(result) result:result == 0 ?: NO];
}


/**
 *  请求-查询我申请的订单
 *
 *  @param myAppliedListReq
 */
- (void)requestMyAppliedList:(MyAppliedListReqData *)myAppliedListReq {
    memset(&g_clientPkg.stBody.stClientAppliedOrderBriefReq, 0, sizeof(g_clientPkg.stBody.stClientAppliedOrderBriefReq));
    g_clientPkg.stHead.dwCmdID = CT_APPLY_ORDER_BRIEF_REQ;
    
    g_clientPkg.stBody.stClientAppliedOrderBriefReq.llUid = myAppliedListReq.uid;
    g_clientPkg.stBody.stClientAppliedOrderBriefReq.llOrderId = myAppliedListReq.lastOrderId;
    g_clientPkg.stBody.stClientAppliedOrderBriefReq.iRecordCount = myAppliedListReq.recordCount;
    g_clientPkg.stBody.stClientAppliedOrderBriefReq.chStatus = myAppliedListReq.status;
    [self readySendData];
}

/**
 *  返回-我申请的订单
 */
- (void)responseMyAppliedList {
    uint32_t result = g_clientPkg.stBody.stClientAppliedOrderBriefResp.iResult;
    int32_t totalCount = g_clientPkg.stBody.stClientAppliedOrderBriefResp.iTotalCount; // 当前记录的总条数
    int32_t orderCount = g_clientPkg.stBody.stClientAppliedOrderBriefResp.iOrderCount; // 查询到的简要订单信息个数
    YWXMyOrderDetailListData *myOrderDetailListData = [[YWXMyOrderDetailListData alloc]init];
    myOrderDetailListData.infoCount = orderCount;
    myOrderDetailListData.totalCount = totalCount;
    for (NSUInteger i = 0; i < orderCount; i++) {
        YWXOrderInfoData *orderInfoData = [[YWXOrderInfoData alloc] init];
        orderInfoData.orderID                    = g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].llOrderid;
        orderInfoData.orderCreaterUid            = g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].llCreaterUid;
        orderInfoData.orderStatus                = g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].iStatus;
        orderInfoData.orderMoneyType                  = g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].iMoneyType;
        orderInfoData.orderMoneyNum               = g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].iMoneyNum;
        
        orderInfoData.orderApplyStatus           = g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].iApplyStata;
        orderInfoData.orderCommentNum            = g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].iDiscussNum;
        orderInfoData.orderCreatTime             = g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].llCreateTime;
        
        orderInfoData.orderApplierNum            = g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].iApplyNum;
        orderInfoData.orderCreaterNickName       = [NSString strWithBytes:g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].szCreaterNickname length:g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].iCreaterNickNameLen];
        orderInfoData.orderCreaterBirthday       = g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].llCreaterBirth;
        orderInfoData.orderCreaterGender         = g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].iCreaterGender;
        orderInfoData.orderCreaterIntegrityLevel = g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].iCreaterIntegrityLevel;
        orderInfoData.orderCreaterCreditLevel    = g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].iCreaterCreditLevel;
        orderInfoData.orderCreaterCreditValue    = g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].iCreaterCreditValue;
        orderInfoData.orderDetailDescrption       = [NSString strWithBytes:g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].szParticulars length:g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].iParticularsLen];
        int32_t iPictureNum = g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].iPictureNum;
        
        for (int j=0; j<iPictureNum; j++) {
            int64_t pictureId = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].pictureidList[j];
            YWXPhotoData *photoData = [[YWXPhotoData alloc]init];
            photoData.uid = orderInfoData.orderCreaterUid;
            photoData.photoID = [NSString stringWithFormat:@"%llu",pictureId];
            photoData.photoUrl = [NSString publishOrderPhotoImageURLStringWithUserID:photoData.uid photoID:photoData.photoID];
            [orderInfoData.picturelist addObject:photoData];
        }
        
        int32_t iAudioNum = g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].iPictureNum;
        for (int k=0; k<iAudioNum; k++) {
            YWXAudioInfo *audioInfo = [[YWXAudioInfo alloc]init];
            audioInfo.audioId = g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].astAudioInfo[k].llAudioId;
            audioInfo.seconds = g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].astAudioInfo[k].iSeconds;
            [orderInfoData.audioList addObject:audioInfo];
        }
        [myOrderDetailListData.myOrderDetailList addObject:orderInfoData];
    }
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:result == 0 ? myOrderDetailListData : nil result:result == 0 ? YES : NO];
}

/**
 *  请求-查询我的创建的订单
 *
 *  @param myCreateOrderListReq 查询参数
 */
- (void)requestMyOrderList:(MyOrderListReqData *)myCreateOrderListReq {
    memset(&g_clientPkg.stBody.stClientCreatedOrderBriefReq, 0, sizeof(g_clientPkg.stBody.stClientCreatedOrderBriefReq));
    g_clientPkg.stHead.dwCmdID = CLIENT_CREATED_ORDER_BRIEF_REQ;
    
    g_clientPkg.stBody.stClientCreatedOrderBriefReq.llUid = myCreateOrderListReq.uid;
    g_clientPkg.stBody.stClientCreatedOrderBriefReq.llOrderId = myCreateOrderListReq.lastOrderId;
    g_clientPkg.stBody.stClientCreatedOrderBriefReq.iRecordCount = myCreateOrderListReq.recordCount;
    
    [self readySendData];
}

/**
 *  返回-查询我的创建的订单
 */

- (void)responseMyOrderList {
    uint32_t result = g_clientPkg.stBody.stClientCreatedOrderBriefResp.iResult;
    int32_t totalCount = g_clientPkg.stBody.stClientCreatedOrderBriefResp.iTotalCount; // 当前记录的总条数
    int32_t orderCount = g_clientPkg.stBody.stClientCreatedOrderBriefResp.iOrderCount; // 查询到的简要订单信息个数
    YWXMyOrderDetailListData *myOrderDetailListData = [[YWXMyOrderDetailListData alloc]init];
    myOrderDetailListData.infoCount = orderCount;
    myOrderDetailListData.totalCount = totalCount;

    for (NSUInteger i = 0; i < orderCount; i++) {
        YWXOrderInfoData *orderInfoData = [[YWXOrderInfoData alloc] init];
        orderInfoData.orderID                    = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].llOrderid;
        orderInfoData.orderCreaterUid            = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].llCreaterUid;
        orderInfoData.orderStatus                = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].iStatus;
        orderInfoData.orderMoneyType                  = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].iMoneyType;
        orderInfoData.orderMoneyNum              = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].iMoneyNum;

        orderInfoData.orderApplyStatus           = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].iApplyStata;
        orderInfoData.orderCommentNum            = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].iDiscussNum;
        orderInfoData.orderCreatTime             = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].llCreateTime;

        orderInfoData.orderApplierNum            = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].iApplyNum;
        orderInfoData.orderCreaterNickName       = [NSString strWithBytes:g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].szCreaterNickname length:g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].iCreaterNickNameLen];
        orderInfoData.orderCreaterBirthday       = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].llCreaterBirth;
        orderInfoData.orderCreaterGender         = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].iCreaterGender;
        orderInfoData.orderCreaterIntegrityLevel = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].iCreaterIntegrityLevel;
        orderInfoData.orderCreaterCreditLevel    = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].iCreaterCreditLevel;
        orderInfoData.orderCreaterCreditValue    = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].iCreaterCreditValue;
        orderInfoData.orderDetailDescrption      = [NSString strWithBytes:g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].szParticulars length:g_clientPkg.stBody.stClientAppliedOrderBriefResp.astOrderCombineInfoList[i].iParticularsLen];
        int32_t iPictureNum = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].iPictureNum;
        
        for (int j=0; j<iPictureNum; j++) {
            int64_t pictureId = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].pictureidList[j];
            YWXPhotoData *photoData = [[YWXPhotoData alloc]init];
            photoData.uid = orderInfoData.orderCreaterUid;
            photoData.photoID = [NSString stringWithFormat:@"%llu",pictureId];
            photoData.photoUrl = [NSString publishOrderPhotoImageURLStringWithUserID:photoData.uid photoID:photoData.photoID];
            [orderInfoData.picturelist addObject:photoData];
        }
        
        int32_t iAudioNum = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].iPictureNum;
        for (int k=0; k<iAudioNum; k++) {
            YWXAudioInfo *audioInfo = [[YWXAudioInfo alloc]init];
            audioInfo.audioId = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].astAudioInfo[k].llAudioId;
            audioInfo.seconds = g_clientPkg.stBody.stClientCreatedOrderBriefResp.astOrderCombineInfoList[i].astAudioInfo[k].iSeconds;
            [orderInfoData.audioList addObject:audioInfo];
        }
        [myOrderDetailListData.myOrderDetailList addObject:orderInfoData];
    }
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:result == 0 ? myOrderDetailListData : nil result:result == 0 ? YES : NO];
}

/**
 *  创建订单
 *
 *  @param publishData 发单数据
 */

- (void)requestCreateOrder:(YWXPublishOrderReqData *)publishData {
    memset(&g_clientPkg.stBody.stClientRequestAccessTradeCreateOrder, 0, sizeof(g_clientPkg.stBody.stClientRequestAccessTradeCreateOrder));
    g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_TRADE_CREATE_ORDER;
    
    NSString *address                                                              = publishData.orderAddress;
    g_clientPkg.stBody.stClientRequestAccessTradeCreateOrder.iType                 = publishData.orderMainType;
    g_clientPkg.stBody.stClientRequestAccessTradeCreateOrder.iMoneyType            = publishData.orderMoneyType;

    g_clientPkg.stBody.stClientRequestAccessTradeCreateOrder.dwPosInfoLen          = (uint32_t)strlen([address UTF8String]);
    memcpy(g_clientPkg.stBody.stClientRequestAccessTradeCreateOrder.szPosInfo, [address UTF8String], strlen([address UTF8String]));

    g_clientPkg.stBody.stClientRequestAccessTradeCreateOrder.iMoneyNum             = publishData.orderMoneyType == 2 ? (int32_t)[publishData.orderServiceFee integerValue] * 100 : (int32_t)[publishData.orderTryMoney integerValue];

    g_clientPkg.stBody.stClientRequestAccessTradeCreateOrder.stGISInfo.llLongitude = publishData.orderCoordinate.longitude*YWXInt10E6;
    g_clientPkg.stBody.stClientRequestAccessTradeCreateOrder.stGISInfo.llDimension = publishData.orderCoordinate.latitude*YWXInt10E6;

    g_clientPkg.stBody.stClientRequestAccessTradeCreateOrder.dwParticularsLen      = (uint32_t)strlen([publishData.orderDescription UTF8String]);
    memcpy(g_clientPkg.stBody.stClientRequestAccessTradeCreateOrder.szParticulars, [publishData.orderDescription UTF8String], strlen([publishData.orderDescription UTF8String]));
    
    g_clientPkg.stBody.stClientRequestAccessTradeCreateOrder.iGender               = publishData.orderGender;

    g_clientPkg.stBody.stClientRequestAccessTradeCreateOrder.iPictureNum           = (int32_t)publishData.orderPhotoNum;
    for (int i=0; i<publishData.orderPhotosID.count; i++) {
        g_clientPkg.stBody.stClientRequestAccessTradeCreateOrder.pictureidList[i] = [publishData.orderPhotosID[i] longLongValue];
    }
    
    g_clientPkg.stBody.stClientRequestAccessTradeCreateOrder.iAudioNum              = (int32_t)publishData.orderRecordNum;
    for (int i=0; i<publishData.orderRecordNum; i++) {
        g_clientPkg.stBody.stClientRequestAccessTradeCreateOrder.astAudioInfo[i].llAudioId = [publishData.orderRocordID longLongValue];
        g_clientPkg.stBody.stClientRequestAccessTradeCreateOrder.astAudioInfo[i].iSeconds = (int32_t)publishData.orderRecordDuration;
    }
    [self readySendData];
}

/**
 *  创建订单返回
 */
- (void)responseCreateOrder {
    int32_t result = g_clientPkg.stBody.stTradeResponseAccessClientCreateOrder.iResult;
    YWXCreateOrderData *creatOrderData = nil;
    if (!result) {
        creatOrderData = [[YWXCreateOrderData alloc] init];
        creatOrderData.orderID = g_clientPkg.stBody.stTradeResponseAccessClientCreateOrder.llOrderid;
    }
    
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:result == 0 ? creatOrderData : nil result:result == 0 ? YES : NO];
}

/**
 *  报名
 */
- (void)requestApplyWithApplyReqData:(YWXApplyOrConfirmFinishReqData *)reqData {
    memset(&g_clientPkg.stBody.stClientRequestAccessTradeApplyOrder, 0, sizeof(g_clientPkg.stBody.stClientRequestAccessTradeApplyOrder));
    g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_TRADE_APPLY_ORDER;
    
    g_clientPkg.stBody.stClientRequestAccessTradeApplyOrder.llOrderid = reqData.orderID;
    g_clientPkg.stBody.stClientRequestAccessTradeApplyOrder.iApplyRequestType = reqData.applyType;

    [self readySendData];
}

/**
 *  报名返回
 */
- (void)responseApply {
    int result = g_clientPkg.stBody.stTradeResponseAccessClientApplyOrder.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];
}

/**
 *  评论
 *
 *  @param reqData  评论参数
 */
- (void)requestCommentWith:(YWXGetCommentReqData *)reqData{
    memset(&g_clientPkg.stBody.stCT_QueryDiscussDetail_Req, 0, sizeof(g_clientPkg.stBody.stCT_QueryDiscussDetail_Req));
    g_clientPkg.stHead.dwCmdID = CMD_CT_QUERY_DISCUSS_DETAIL_REQ;
    
    g_clientPkg.stBody.stCT_QueryDiscussDetail_Req.llOrderId = reqData.orderID;
    g_clientPkg.stBody.stCT_QueryDiscussDetail_Req.llCurDiscussId = reqData.curDiscussId;
    g_clientPkg.stBody.stCT_QueryDiscussDetail_Req.iExpectedCount = reqData.expectedCount;
    
    [self readySendData];
}

/**
 *  评论返回
 */
- (void)responseComment {
    int result = g_clientPkg.stBody.stTC_QueryDiscussDetail_Resp.iResult;
    int32_t totalCount = g_clientPkg.stBody.stTC_QueryDiscussDetail_Resp.iTotalCount; // 记录总条数
    int32_t infoCount = g_clientPkg.stBody.stTC_QueryDiscussDetail_Resp.iInfoCount; // 返回记录条数
    YWXOrderDetailCommentListData *commentListData = [[YWXOrderDetailCommentListData alloc]init];
    commentListData.totalCount = totalCount;
    commentListData.infoCount = infoCount;
    
    for (int i=0; i<infoCount; i++) {
        YWXOrderDetailCommentData *commentData = [[YWXOrderDetailCommentData alloc]init];
        commentData.commentId = g_clientPkg.stBody.stTC_QueryDiscussDetail_Resp.astDiscussDetailInfos[i].llDiscussId;
        commentData.orderId = g_clientPkg.stBody.stTC_QueryDiscussDetail_Resp.astDiscussDetailInfos[i].llOrderId;
        commentData.uid = [NSString stringWithFormat:@"%llu",g_clientPkg.stBody.stTC_QueryDiscussDetail_Resp.astDiscussDetailInfos[i].llFromUid];
        commentData.fid = [NSString stringWithFormat:@"%llu",g_clientPkg.stBody.stTC_QueryDiscussDetail_Resp.astDiscussDetailInfos[i].llToUid];
        commentData.integrityLevel = g_clientPkg.stBody.stTC_QueryDiscussDetail_Resp.astDiscussDetailInfos[i].iIntegrityLevel;
        commentData.gender = g_clientPkg.stBody.stTC_QueryDiscussDetail_Resp.astDiscussDetailInfos[i].iGender;
        commentData.commentStatus = g_clientPkg.stBody.stTC_QueryDiscussDetail_Resp.astDiscussDetailInfos[i].iDiscussStatus;
        commentData.commentTime = g_clientPkg.stBody.stTC_QueryDiscussDetail_Resp.astDiscussDetailInfos[i].llDiscussTime;
        commentData.commentContent = [NSString strWithBytes:g_clientPkg.stBody.stTC_QueryDiscussDetail_Resp.astDiscussDetailInfos[i].szDiscussContent length:g_clientPkg.stBody.stTC_QueryDiscussDetail_Resp.astDiscussDetailInfos[i].iDiscussContentLen];
        commentData.nickName = [NSString strWithBytes:g_clientPkg.stBody.stTC_QueryDiscussDetail_Resp.astDiscussDetailInfos[i].szNickName length:g_clientPkg.stBody.stTC_QueryDiscussDetail_Resp.astDiscussDetailInfos[i].iNickNameLen];
        [commentListData.commentDataList addObject:commentData];
    }
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:result == 0 ?commentListData: nil result:result == 0 ?: NO];
}

/// 发表评论请求
- (void)requestSendCommentWithReqData:(YWXSendCommentReqData *)reqData {
    memset(&g_clientPkg.stBody.stCT_DiscussOrder_Req, 0, sizeof(g_clientPkg.stBody.stCT_DiscussOrder_Req));
    g_clientPkg.stHead.dwCmdID = CMD_CT_DISCUSS_ORDER_REQ;
    
    g_clientPkg.stBody.stCT_DiscussOrder_Req.llUid = reqData.commentatorUID;
    g_clientPkg.stBody.stCT_DiscussOrder_Req.llToUid = reqData.orderCreaterUID;
    g_clientPkg.stBody.stCT_DiscussOrder_Req.llOrderId = reqData.orderID;
    g_clientPkg.stBody.stCT_DiscussOrder_Req.iDiscussContentLen = strlen([reqData.commentContent UTF8String]);
    memcpy(g_clientPkg.stBody.stCT_DiscussOrder_Req.szDiscussContent, [reqData.commentContent UTF8String], strlen([reqData.commentContent UTF8String]));
    
    [self readySendData];
}

/// 发表评论响应
- (void)responseSendComment {
    int32_t result = g_clientPkg.stBody.stTC_DiscussOrder_Resp.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];
}

/// 关闭订单
- (void)requestCloseOrderWithOrderid:(int64_t)orderid {
    memset(&g_clientPkg.stBody.stClientRequestAccessTradeOrderClosedown, 0, sizeof(g_clientPkg.stBody.stClientRequestAccessTradeOrderClosedown));
    g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_TRADE_ORDER_CLOSEDOWN;
    
    g_clientPkg.stBody.stClientRequestAccessTradeOrderClosedown.llOrderid = orderid;
    
    [self readySendData];
}

/// 关闭订单响应
- (void)responseCloseOrder{
    int32_t result = g_clientPkg.stBody.stTradeRsponseAccessClientOrderClosedown.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];
}
@end
