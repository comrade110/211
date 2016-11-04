//
//  RequestManage+MyInfo.m
//  youwo
//
//  Created by mygame on 15/3/26.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "RequestManage+MyInfo.h"
#import "YWXUserAccountInfo.h"
#import "YWXUserDetailInfo.h"
#import "YWXDailyMissionData.h"
#import "YWXApplierStatusInfo.h"

#import "YWXReportReqData.h"

#import "client_protocol.h"
using namespace client;
extern ClientPkg g_clientPkg;
extern char g_pkgBuffer[SocketBufferSize];

@implementation RequestManage (MyInfo)
/**
 *  请求-举报某人某单
 *
 *  @param reqData YWXReportReqData实例
 */
- (void)requestReportWithReqData:(YWXReportReqData *)reqData {
    memset(&g_clientPkg.stBody.stCT_ReportInfo_Req, 0, sizeof(g_clientPkg.stBody.stCT_ReportInfo_Req));
    g_clientPkg.stHead.dwCmdID = CMD_CT_REPORT_INFO_REQ;
    g_clientPkg.stBody.stCT_ReportInfo_Req.llReporterUid = reqData.reporterUid;
    g_clientPkg.stBody.stCT_ReportInfo_Req.llObjectUid = reqData.objectUid;
    g_clientPkg.stBody.stCT_ReportInfo_Req.llObjectOrderId = reqData.objectOrderId;

    g_clientPkg.stBody.stCT_ReportInfo_Req.iReportDescLen = (int32_t)strlen([reqData.reportDes UTF8String]);
    memcpy(g_clientPkg.stBody.stCT_ReportInfo_Req.szReportDesc, [reqData.reportDes UTF8String], strlen([reqData.reportDes UTF8String]));
    [self readySendData];
}

/**
 *  返回-举报报某人某单
 */
- (void)responseReport {
    int32_t result = g_clientPkg.stBody.stTradeResponseAccessClientSelectApplyerUserInfoList.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];
}

/**
 *  请求-报名者管理列表 信息（一次最多取20条）
 *
 *  @param uidList 用户UID列表
 *
 *  @return NO-失败，YES-成功
 */
- (BOOL)requestApplierManagerListWithUidList:(NSArray *)uidList {
    NSArray *uidArray = [Utility checkUserIDArray:uidList];
    if (uidArray.count == 0 || uidArray == nil) {
        return NO;
    }
    
    memset(&g_clientPkg.stBody.stClientRequestAccessTradeSelectApplyerUserInfoList, 0, sizeof(g_clientPkg.stBody.stClientRequestAccessTradeSelectApplyerUserInfoList));
    g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_TRADE_SELECT_APPLYERUSERINFOLIST;
    g_clientPkg.stBody.stClientRequestAccessTradeSelectApplyerUserInfoList.iUidCount = (int32_t)uidList.count;
    for (NSUInteger i = 0; i < uidList.count; i++) {
        g_clientPkg.stBody.stClientRequestAccessTradeSelectApplyerUserInfoList.uidList[i] = [uidList[i] longLongValue];
    }

    [self readySendData];
    return YES;
}

/**
 *  返回-报名者管理列表 信息
 */
- (void)responseApplierManagerList {
    int32_t result = g_clientPkg.stBody.stTradeResponseAccessClientSelectApplyerUserInfoList.iResult;
    int32_t count = g_clientPkg.stBody.stTradeResponseAccessClientSelectApplyerUserInfoList.iApplyerUserInfoCount;
    NSMutableArray *applierList = [[NSMutableArray alloc] initWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++) {
        YWXApplierStatusInfo *applierInfo = [[YWXApplierStatusInfo alloc] init];
        applierInfo.applyUID              = g_clientPkg.stBody.stTradeResponseAccessClientSelectApplyerUserInfoList.astApplyerUserInfoList[i].llUid;
        applierInfo.nickName              = [NSString strWithBytes:g_clientPkg.stBody.stTradeResponseAccessClientSelectApplyerUserInfoList.astApplyerUserInfoList[i].szNickName length:g_clientPkg.stBody.stTradeResponseAccessClientSelectApplyerUserInfoList.astApplyerUserInfoList[i].iNickNameLen];
        applierInfo.birthday              = g_clientPkg.stBody.stTradeResponseAccessClientSelectApplyerUserInfoList.astApplyerUserInfoList[i].llBirthday;
        applierInfo.gender                = g_clientPkg.stBody.stTradeResponseAccessClientSelectApplyerUserInfoList.astApplyerUserInfoList[i].bGender;
        applierInfo.integrityLevel        = g_clientPkg.stBody.stTradeResponseAccessClientSelectApplyerUserInfoList.astApplyerUserInfoList[i].iIntegrity_level;
        applierInfo.coordinate            = CLLocationCoordinate2DMake(g_clientPkg.stBody.stTradeResponseAccessClientSelectApplyerUserInfoList.astApplyerUserInfoList[i].llDimension/YWXFloat10E6, g_clientPkg.stBody.stTradeResponseAccessClientSelectApplyerUserInfoList.astApplyerUserInfoList[i].llLongitude/YWXFloat10E6);
        applierInfo.isFriend              = eEMBuddyFollowState_NotFollowed; // 我们服务端数据暂时无效 g_clientPkg.stBody.stTradeResponseAccessClientSelectApplyerUserInfoList.astApplyerUserInfoList[i].iIsFriend;
        applierInfo.creditValue           = g_clientPkg.stBody.stTradeResponseAccessClientSelectApplyerUserInfoList.astApplyerUserInfoList[i].iSincerityValue;
        applierInfo.orderApplyFinishedCount = g_clientPkg.stBody.stTradeResponseAccessClientSelectApplyerUserInfoList.astApplyerUserInfoList[i].iOrderApplyFiniCount;
        [applierList addObject:applierInfo];
    }
 
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:result == 0 ? applierList : @(result) result:result == 0 ?: NO];
}


/**
 *  请求-领取每日任务奖励
 *
 *  @param taskID taskID 任务ID
 */
- (void)requestGetTaskAwardWithTaskID:(int32_t)taskID {
    memset(&g_clientPkg.stBody.stClientRequestAccessTradeGetTaskAward, 0, sizeof(g_clientPkg.stBody.stClientRequestAccessTradeGetTaskAward));
    g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_TRADE_GET_TASK_AWARD;
    g_clientPkg.stBody.stClientRequestAccessTradeGetTaskAward.iTaskId = taskID;
    [self readySendData];
}

/**
 *  返回-领取每日任务奖励
 */
- (void)responseGetTaskAward {
    int32_t result = g_clientPkg.stBody.stTradeResponseAccessClientGetTaskAward.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];
}

/**
 *  请求-每日任务信息
 */
- (void)requestDailyMission {
    memset(&g_clientPkg.stBody.stClientRequestAccessTradeSelectTaskInfo, 0, sizeof(g_clientPkg.stBody.stClientRequestAccessTradeSelectTaskInfo));
    g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_TRADE_SELECT_TASKINFO;
    g_clientPkg.stBody.stClientRequestAccessTradeSelectTaskInfo.llUid = SharePersonalInfo.uid;
    
    [self readySendData];
}

/**
 *  返回-每日任务信息
 */
- (void)responseDailyMission {
    int32_t result = g_clientPkg.stBody.stTradeResponseAccessClientSelectTaskInfo.iResult;
    NSMutableArray *dailyMissionArray = nil;
    if (!result) {
        int32_t count = g_clientPkg.stBody.stTradeResponseAccessClientSelectTaskInfo.iTaskInfoNum;
        dailyMissionArray = [NSMutableArray array];
        for (NSUInteger i = 0; i < count; i++) {
            YWXDailyMissionData *dailyMissionInfo = [[YWXDailyMissionData alloc] init];
            
            dailyMissionInfo.taskType = g_clientPkg.stBody.stTradeResponseAccessClientSelectTaskInfo.astTaskInfoList[i].stTaskDynaInfo.iTasktype;
            dailyMissionInfo.taskProgress = g_clientPkg.stBody.stTradeResponseAccessClientSelectTaskInfo.astTaskInfoList[i].stTaskDynaInfo.iAccomplish;
            dailyMissionInfo.taskStatus = g_clientPkg.stBody.stTradeResponseAccessClientSelectTaskInfo.astTaskInfoList[i].stTaskDynaInfo.iStatus;
            dailyMissionInfo.taskId = g_clientPkg.stBody.stTradeResponseAccessClientSelectTaskInfo.astTaskInfoList[i].stTaskStaticInfo.iTasktype;
            dailyMissionInfo.taskName = [NSString strWithBytes:g_clientPkg.stBody.stTradeResponseAccessClientSelectTaskInfo.astTaskInfoList[i].stTaskStaticInfo.szTaskName length:g_clientPkg.stBody.stTradeResponseAccessClientSelectTaskInfo.astTaskInfoList[i].stTaskStaticInfo.iTaskNameLen];
            dailyMissionInfo.taskCompleteCondition = g_clientPkg.stBody.stTradeResponseAccessClientSelectTaskInfo.astTaskInfoList[i].stTaskStaticInfo.iTaskCondition;
            dailyMissionInfo.taskCompleteCount = g_clientPkg.stBody.stTradeResponseAccessClientSelectTaskInfo.astTaskInfoList[i].stTaskStaticInfo.iTaskCompleteLimit;
            dailyMissionInfo.taskAwardType = g_clientPkg.stBody.stTradeResponseAccessClientSelectTaskInfo.astTaskInfoList[i].stTaskStaticInfo.iTaskAwardType;
            dailyMissionInfo.taskAwardAmount = g_clientPkg.stBody.stTradeResponseAccessClientSelectTaskInfo.astTaskInfoList[i].stTaskStaticInfo.iTaskAwardAmount;
            
            [dailyMissionArray addObject:dailyMissionInfo];
        }
    }
    
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:result == 0 ? dailyMissionArray : @(result) result:result == 0 ?: NO];
}



/**
 *  请求-批量用户信息（个人信息与业务信息）
 *
 *  @param uidArray 用户UID列表(NSString对象)
 *
 *  @return YES=UID列表信息可用，NO=UID列表不可用
 */
- (BOOL)requestBatchUserInfoWithIdList:(NSArray *)idList {
    NSArray *uidArray = [Utility checkUserIDArray:idList];
    if (uidArray.count == 0 || uidArray == nil) {
        return NO;
    }
    NSLog(@"000-全局个人信息请求：%@", uidArray);
    memset(&g_clientPkg.stBody.stCT_GlobalUserInfoList_Req, 0, sizeof(g_clientPkg.stBody.stCT_GlobalUserInfoList_Req));
    g_clientPkg.stHead.dwCmdID = CMD_CT_GLOBAL_USER_INFO_REQ;
    g_clientPkg.stBody.stCT_GlobalUserInfoList_Req.iUidCount = (int32_t)uidArray.count;
    for (NSUInteger i = 0; i < uidArray.count; i++) {
        g_clientPkg.stBody.stCT_GlobalUserInfoList_Req.uids[i] = [uidArray[i] longLongValue];
    }
    [self readySendData];
    return YES;
}

/**
 *  返回-批量用户信息（个人信息与业务信息）
 */
- (void)responseBatchUserInfo {
    NSMutableArray *userInfoList = nil;
    int32_t result = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.iResult;
    //NSLog(@"111-全局个人信息返回：result=%d", (int)result);
    if (result == 0) {
        int32_t count = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.iInfoCount;
        //NSLog(@"222-全局个人信息请求：result=%d, count=%d", (int)result, (int)count);
        userInfoList = [NSMutableArray array];
        for (NSUInteger i = 0; i < count; i++) {
            YWXUserDetailInfo *userInfo           = [[YWXUserDetailInfo alloc] init];
            userInfo.uid                          = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].llUid;
            userInfo.phoneNum                     = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].llPhone_num;
            userInfo.integrityCurrency            = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iGold_integrity;// 诚信金
            userInfo.integrityLevel               = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iIntegrity_level;// 诚信金等级
            userInfo.youwoCurrency                = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iGold_youwo;// 有我币
            userInfo.gameCurrency                 = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iGold_game;// 游戏币
            userInfo.tryMoney                     = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iGold_validate;// 试金石
            userInfo.vipLevel                     = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iVip_level;// vip等级
            userInfo.vipBuyTime                   = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iVip_buy_time;// vip购买时间
            userInfo.vipExpireTime                = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iVip_deadline;// vip过期时间
            userInfo.photoCount                   = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iPhoto_count;// 照片数
            userInfo.certificationFlag            = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].llCert_flags;// 认证标志
            userInfo.integrityValue               = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iSincerity_value;// 诚信值
            userInfo.businessValue                = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iBusiness_value;// 业务值
            userInfo.recentVisitorCount           = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iVisitor_count;// 最近访问人数
            userInfo.experienceValue              = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].llExp;// 经验值
            userInfo.playerLevel                  = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iLevel;// 玩家等级
            userInfo.rechargeNum                  = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iRecharge;// 充值数
            userInfo.warrantorCount               = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iGuarantee_count;// 担保的人数
            userInfo.warrantMeCount               = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iPromise_count;// 担保我的人数
            userInfo.depositLevel                 = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iDeposit_level;// 押金等级
            userInfo.depositLimite                = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iDeposit_limit;// 押金上限
            userInfo.orderCreatNum                = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iOrder_create_fnum;// 发单完成数
            userInfo.orderTakeNum                 = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iOrder_apply_fnum;// 接单完成数
            userInfo.interest                     = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].llInterest;// 兴趣
            userInfo.gender                       = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].chGender;
            userInfo.birthday                     = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].llBirthday;
            userInfo.age                          = (int32_t)[Utility ageWithYearMonthDay:g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].llBirthday];
            userInfo.portraitID                   = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].llPortrait;
            userInfo.nickName                     = [Utility checkStringData:[NSString strWithBytes:g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].szNickName  length:g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iNickNameLen]] ;// ACCESS_NICK_NAME_LEN = 32, // 用户昵称最大长度
            userInfo.occupation                   = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iOccupation;
            userInfo.signature                    = [Utility checkStringData:[NSString strWithBytes:g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].szSignature length:g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iSignatureLen]];// ACCESS_USER_SIGNATURE_MAX_LEN = 128, // 个性签名最大长度
            userInfo.residentionID                = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iResidention;
            userInfo.residentionDetail            = [Utility checkStringData:[NSString strWithBytes:g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].szResidentionDetail length:g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iResidentionDetailLen]];// ACCESS_RESIDENTION_DETAIL_MAX_LEN = 64, // 详细居住地最大字节数
            userInfo.height = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iHeight;
            userInfo.school = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iSchool;
            userInfo.loveStatus = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iLove_status;
            userInfo.inSchoolYear = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iInSchoolYear;
            userInfo.colleageName = [Utility checkStringData:[NSString strWithBytes:g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].szColleageName length:g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iColleageNameLen]];
            userInfo.profession = [Utility checkStringData:[NSString strWithBytes:g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].szProfession length:g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iProfessionLen]];
            
            userInfo.occupationName = [Utility checkStringData:[NSString strWithBytes:g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].szOccupationName length:g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].iOccupationNameLen]];
            userInfo.goodReputation = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].llGood_reputation;
            userInfo.reputationTime = g_clientPkg.stBody.stTC_GlobalUserInfoList_Resp.astGlobalUserInfos[i].llReputation_time;
            
            if (SharePersonalInfo.uid == userInfo.uid) {
                [SharePersonalInfo updateWithUserDetailInfo:userInfo];
            }
            
            [userInfoList addObject:userInfo];
        }
    }
    
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:result == 0 ? userInfoList : @(result) result:result == 0 ?: NO ];
}

/**
 *  请求 获取照片墙信息
 *
 *  @param uid NSNumber
 */
-(void)requestUserPhotoWallWithUID:(NSString *)uid
{
    NSLog(@"000---UserPhotoWallWithUID=%@", uid);
    
    memset(&g_clientPkg.stBody.stClientRequestAccessTradeSelectPhotoWall, 0, sizeof(g_clientPkg.stBody.stClientRequestAccessTradeSelectPhotoWall));
    g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_TRADE_SELECT_PHOTO_WALL;
    g_clientPkg.stBody.stClientRequestAccessTradeSelectPhotoWall.llUid= [uid longLongValue];
    
    [self readySendData];
}

/**
 *  返回 获取照片墙信息
 */
-(void)responseUserPhotoWall
{
    NSString *failedMsg = nil;
    NSInteger result = g_clientPkg.stBody.stTradeResponseAccessClientSelectPhotoWall.iResult;
    if (result != 0) {
        failedMsg = [NSString stringWithFormat:@"get photo wall error:%d", (int)result];
    }
    
    NSMutableArray *photoes = [NSMutableArray array];
    NSUInteger photoNum = g_clientPkg.stBody.stTradeResponseAccessClientSelectPhotoWall.iPhotoCount;
    for (NSUInteger i = 0; i < photoNum; i++) {
        [photoes addObject:@(g_clientPkg.stBody.stTradeResponseAccessClientSelectPhotoWall.photoWall[i])];
    }

    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:result == 0 ? photoes : nil result:result == 0 ? YES : NO ];
}

/**
 *  请求-跟新照片墙
 *
 *  @param photosID 照片墙ID
 */
-(void)requestUpdatePhotoWallWithPhotosID:(NSArray *)photosID
{
    /*if (photosID.count == 0) {
        return;
    }*/
    
    memset(&g_clientPkg.stBody.stClientRequestAccessTradeUpdatePhotoWall, 0, sizeof(g_clientPkg.stBody.stClientRequestAccessTradeUpdatePhotoWall));
    g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_TRADE_UPDATE_PHOTO_WALL;
    g_clientPkg.stBody.stClientRequestAccessTradeUpdatePhotoWall.iPhotoCount= (int)photosID.count;
    [photosID enumerateObjectsUsingBlock:^(NSNumber *photoID, NSUInteger idx, BOOL *stop) {
        NSLog(@"%f", [photoID doubleValue]);
        g_clientPkg.stBody.stClientRequestAccessTradeUpdatePhotoWall.photoWall[idx] = [photoID doubleValue];
    }];
    
    [self readySendData];
}

/**
 *  返回-跟新照片墙
 *
 *  @return YES-成功 NO-失败
 */
-(BOOL)responseUpdatePhotoWall {
    NSInteger result = g_clientPkg.stBody.stTradeResponseAccessClientUpdatePhotoWall.iResult;
    
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:result == 0 ? nil : nil result:result == 0 ? YES : NO ];
    return (result == 0 ? YES : NO);
}


/**
 *  从UserBaseInfo中获取信息返回 YWXUserAccountInfo
 *
 *  @param userBaseInfo UserBaseInfo
 *
 *  @return YWXUserAccountInfo
 */
- (YWXUserAccountInfo *)userAcountInfoFromUserBaseInfo:(UserBaseInfo)userBaseInfo {
    YWXUserAccountInfo *userAcountInfo = [[YWXUserAccountInfo alloc] init];
    userAcountInfo.adapted           = userBaseInfo.chAdapted;
    userAcountInfo.uid               = userBaseInfo.llUid;
    userAcountInfo.gender            = userBaseInfo.chGender;

    userAcountInfo.birthday          =  [NSString strFromllong:userBaseInfo.llBirthday];
    //[Utility stringDateWithStringFormat:kDateFormatYearMothDay Sec:userBaseInfo.llBirthday];
    userAcountInfo.portrait          = userBaseInfo.llPortrait;
    userAcountInfo.nickName          = [NSString strWithBytes:userBaseInfo.szNickName length:userBaseInfo.iNickNameLen];
    userAcountInfo.occupation        = userBaseInfo.iOccupation;
    userAcountInfo.signature         = [NSString strWithBytes:userBaseInfo.szSignature length:userBaseInfo.iSignatureLen];
    userAcountInfo.residention       = userBaseInfo.iResidention;
    userAcountInfo.residentionDetail = [NSString strWithBytes:userBaseInfo.szResidentionDetail length:userBaseInfo.iResidentionDetailLen];
    userAcountInfo.age               = (int)[Utility ageWithYearMonthDay:userBaseInfo.llBirthday];

    
    return userAcountInfo;
}


//更新生日
- (void)requestUpdateBirthday:(int64_t)birthday
{
    memset(&g_clientPkg.stBody.stClientUpdateBirthdayReq, 0, sizeof(g_clientPkg.stBody.stClientUpdateBirthdayReq));
    g_clientPkg.stHead.dwCmdID = CMD_UPDATE_BIRTHDAY_REQ;

    g_clientPkg.stBody.stClientUpdateBirthdayReq.llBirthday = birthday;
    
    [self readySendData];
}

- (void)responseUpdateBirthday
{
    int32_t result = g_clientPkg.stBody.stClientUpdateBirthdayResp.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];
}


//更新昵称
- (void)requestUpdateNickName:(NSString *)nickname
{
    memset(&g_clientPkg.stBody.stClientUpdateNickNameReq, 0, sizeof(g_clientPkg.stBody.stClientUpdateNickNameReq));
    g_clientPkg.stHead.dwCmdID = CMD_UPDATE_NICKNAME_REQ;
    
    int32_t nicknameLen = strlen([nickname UTF8String]);
    g_clientPkg.stBody.stClientUpdateNickNameReq.iNickNameLen = nicknameLen;
    memset(g_clientPkg.stBody.stClientUpdateNickNameReq.szNickName, 0, ACCESS_NICK_NAME_LEN);
    memcpy(g_clientPkg.stBody.stClientUpdateNickNameReq.szNickName, [nickname UTF8String], nicknameLen);
    
    [self readySendData];
}

- (void)responseUpdateNickName
{
    int32_t result = g_clientPkg.stBody.stClientUpdateNickNameResp.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];
}


//更新职业
- (void)requestUpdateOccupation:(int32_t)occupation
{
    memset(&g_clientPkg.stBody.stClientUpdateOccupationReq, 0, sizeof(g_clientPkg.stBody.stClientUpdateOccupationReq));
    g_clientPkg.stHead.dwCmdID = CMD_UPDATE_OCCUPATION_REQ;
    
    g_clientPkg.stBody.stClientUpdateOccupationReq.iOccupation = occupation;
    [self readySendData];
}

- (void)responseUpdateOccupation
{
    int32_t result = g_clientPkg.stBody.stClientUpdateOccupationResp.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];
}

//更新居住地
- (void)requestUpdateResidention:(int32_t)residention
{
    memset(&g_clientPkg.stBody.stClientUpdateResidentionReq, 0, sizeof(g_clientPkg.stBody.stClientUpdateResidentionReq));
    g_clientPkg.stHead.dwCmdID = CMD_UPDATE_RESIDENTION_REQ;

    g_clientPkg.stBody.stClientUpdateResidentionReq.iResidention = residention;
    [self readySendData];

}

- (void)responseUpdateResidention
{
    int32_t result = g_clientPkg.stBody.stClientUpdateResidentionResp.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];
}

- (void)requestUpdatePortrait:(int64_t)llPortrait
{
    memset(&g_clientPkg.stBody.stClientUpdatePortraitReq, 0, sizeof(g_clientPkg.stBody.stClientUpdatePortraitReq));
    g_clientPkg.stHead.dwCmdID = CMD_UPDATE_PORTRAIT_REQ;
    
    g_clientPkg.stBody.stClientUpdatePortraitReq.llPortrait = llPortrait;
    [self readySendData];
}

- (void)responseUpdatePortrait
{
    int32_t result = g_clientPkg.stBody.stClientUpdatePortraitResp.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];
}

- (void)requestUpdateResidentionDetail:(NSString *)residentionDetail
{
    memset(&g_clientPkg.stBody.stCG_UpdateResidentionDetail_Req, 0, sizeof(g_clientPkg.stBody.stCG_UpdateResidentionDetail_Req));
    g_clientPkg.stHead.dwCmdID = CMD_CG_UPDATE_RESIDENTION_DETAIL_REQ;
    int32_t len = (int32_t)strlen([residentionDetail UTF8String]);
    g_clientPkg.stBody.stCG_UpdateResidentionDetail_Req.iResidentionDetailLen = len;
    memset(g_clientPkg.stBody.stCG_UpdateResidentionDetail_Req.szResidentionDetail, 0, ACCESS_RESIDENTION_DETAIL_MAX_LEN);
    memcpy(g_clientPkg.stBody.stCG_UpdateResidentionDetail_Req.szResidentionDetail, [residentionDetail UTF8String], len);
    [self readySendData];
}

- (void)responseUpdateResidentionDetail
{
    int32_t result = g_clientPkg.stBody.stGC_UpdateResidentionDetail_Resp.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:@(result) result:result == 0 ?: NO];
}

// 客户端请求网关交易服务器编辑资料
- (void)requestAccessTradeCompileUserInfo:(YWXUserDetailInfo *)detailInfo
{
    memset(&g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo, 0, sizeof(g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo));
    g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_TRADE_COMPILE_USER_INFO;
    g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.llPortrait = detailInfo.portraitID;
    int32_t len = 0;
    if (detailInfo.nickName.length > 0){
        len = (int32_t)strlen([detailInfo.nickName UTF8String]);
    }
    g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.iNickNameLen = len;
    memset(g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.szNickName, 0, ACCESS_LOGON_NAME_LEN);
    memcpy(g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.szNickName, [detailInfo.nickName UTF8String], len);
    g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.chGender = detailInfo.gender;
    g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.iResidention = detailInfo.residentionID;
    g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.llBirthday = detailInfo.birthday;
    g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.iOccupation = detailInfo.occupation;
    g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.llInterest = detailInfo.interest;
    g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.iHeight = detailInfo.height;
    g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.iSchool = detailInfo.school;
    g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.iLove_status = detailInfo.loveStatus;
    g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.llHobby = detailInfo.hobby;
    // 签名
    len = 0;
    if (detailInfo.signature.length > 0){
        len = (int32_t)strlen([detailInfo.signature UTF8String]);
    }
    g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.iSignatureLen = len;
    memset(g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.szSignature, 0, ACCESS_USER_SIGNATURE_MAX_LEN);
    memcpy(g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.szSignature, [detailInfo.signature UTF8String], len);
    // 常居住地
    len = 0;
    if (detailInfo.residentionDetail.length > 0){
        len = (int32_t)strlen([detailInfo.residentionDetail UTF8String]);
    }
    g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.iResidentionDetailLen = len;
    memset(g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.szResidentionDetail, 0, ACCESS_RESIDENTION_DETAIL_MAX_LEN);
    memcpy(g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.szResidentionDetail, [detailInfo.residentionDetail UTF8String], len);
    g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.iInSchool = detailInfo.inSchoolYear;
    // 学校
    len = 0;
    if (detailInfo.colleageName.length > 0){
        len = (int32_t)strlen([detailInfo.colleageName UTF8String]);
    }
    g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.iColleageNameLen = len;
    memset(g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.szColleageName, 0, MAX_COLLEGE_NAME_LEN);
    memcpy(g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.szColleageName, [detailInfo.colleageName UTF8String], len);
    // 专业
    len = 0;
    if (detailInfo.profession.length > 0){
        len = (int32_t)strlen([detailInfo.profession UTF8String]);
    }
    g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.iProfessionLen = len;
    memset(g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.szProfession, 0, MAX_PROFESSION_NAME_LEN);
    memcpy(g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.szProfession, [detailInfo.profession UTF8String], len);
    
    //g_clientPkg.stBody.stClientRequestAccessTradeCompileUserInfo.iFirstComplie = detailInfo.firstComplie;
    [self readySendData];
}

- (void)responseAccessClientCompileUserInfo
{
    int32_t iResult = g_clientPkg.stBody.stTradeResponseAccessClientCompileUserInfo.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:iResult == 0 ? nil : nil result:iResult == 0 ? YES : NO ];
}

- (void)requestAccessTradeMakeReputation:(int64_t)receiveUid
{
    g_clientPkg.stBody.stClientRequestAccessTradeMakeReputation.llReceive_uid = receiveUid;
    g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_TRADE_MAKE_REPUTATION;
    [self readySendData];
}

- (void)responseAccessTradeMakeReputation
{
    int32_t iResult = g_clientPkg.stBody.stTradeResponseAccessClientMakeReputation.iResult;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:iResult == 0 ? nil : nil result:iResult == 0 ? YES : NO ];
}
@end






