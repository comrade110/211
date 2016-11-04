//
//  RequestManage+MyInfo.h
//  youwo
//
//  Created by mygame on 15/3/26.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "RequestManage.h"
@class YWXReportReqData;

@interface RequestManage (MyInfo)
/**
 *  请求-举报某人某单
 *
 *  @param reqData YWXReportReqData实例
 */
- (void)requestReportWithReqData:(YWXReportReqData *)reqData;

/**
 *  返回-举报报某人某单
 */
- (void)responseReport;


/**
 *  请求-报名者管理列表 信息（一次最多取20条）
 *
 *  @param uidList 用户UID列表
 *
 *  @return NO-失败，YES-成功
 */
- (BOOL)requestApplierManagerListWithUidList:(NSArray *)uidList;

/**
 *  返回-报名者管理列表 信息
 */
- (void)responseApplierManagerList;

/**
 *  请求-领取每日任务奖励
 *
 *  @param taskID taskID 任务ID
 */
- (void)requestGetTaskAwardWithTaskID:(int32_t)taskID;

/**
 *  返回-领取每日任务奖励
 */
- (void)responseGetTaskAward;

/**
 *  请求-每日任务信息
 */
- (void)requestDailyMission;

/**
 *  返回-每日任务信息
 */
- (void)responseDailyMission;

/**
 *  请求-批量用户信息（个人信息与业务信息）
 *
 *  @param uidArray 用户UID列表(NSString对象)
 *
 *  @return YES=UID列表信息可用，NO=UID列表不可用
 */
- (BOOL)requestBatchUserInfoWithIdList:(NSArray *)idList;

/**
 *  返回-批量用户信息（个人信息与业务信息）
 */
- (void)responseBatchUserInfo;

/**
 *  请求 获取照片墙信息
 *
 *  @param uid NSNumber
 */
-(void)requestUserPhotoWallWithUID:(NSString *)uid;

/**
 *  返回 获取照片墙信息
 */
-(void)responseUserPhotoWall;

/**
 *  请求 更新生日
 *
 *  @param birthday 生日以19900101格式
 */
- (void)requestUpdateBirthday:(int64_t)birthday;

/**
 *  返回 更新生日
 */
- (void)responseUpdateBirthday;

/**
 *  请求 更新昵称
 *
 *  @param nickname 昵称
 */
- (void)requestUpdateNickName:(NSString *)nickname;

/**
 *  放回 更新昵称
 */
- (void)responseUpdateNickName;

/**
 *  请求 更新职业
 *
 *  @param occupation 职业
 */
- (void)requestUpdateOccupation:(int32_t)occupation;

/**
 *  返回 更新职业
 */
- (void)responseUpdateOccupation;

/**
 *  请求 更新居住地
 *
 *  @param residention 居住地
 */
- (void)requestUpdateResidention:(int32_t)residention;

/**
 *  返回更新居住地
 */
- (void)responseUpdateResidention;

/**
 *  请求 更新头像
 */
- (void)requestUpdatePortrait:(int64_t)llPortrait;

/**
 *  返回更新头像
 */
- (void)responseUpdatePortrait;

/**
 *  请求-跟新照片墙
 *
 *  @param photosID 照片墙ID
 */
-(void)requestUpdatePhotoWallWithPhotosID:(NSArray *)photosID;

/**
 *  返回-跟新照片墙
 *
 *  @return YES-成功 NO-失败
 */
-(BOOL)responseUpdatePhotoWall;

/**
 *  请求 更新详细地址
 */
- (void)requestUpdateResidentionDetail:(NSString *)residentionDetail;

/**
 *  返回详细地址
 */
- (void)responseUpdateResidentionDetail;

/**
 *  请求网关交易服务器编辑资料
 */
//- (void)requestAccessTradeCompileUserInfo:(YWXUserDetailInfo *)detailInfo;

/**
 *  回应网关客户端编辑资料
 */
- (void)responseAccessClientCompileUserInfo;

/**
 *   客户端请求网关交易服务器给某人点赞
 */
- (void)requestAccessTradeMakeReputation:(int64_t)receiveUid;

/**
 *  交易服务器回应网关客户端给某人点赞
 */
- (void)responseAccessTradeMakeReputation;
@end
