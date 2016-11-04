//
//  RequestManage+Contacts.m
//  youwo
//
//  Created by mymac on 15/5/20.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "RequestManage+Contacts.h"
#import "AddressPhoneModel.h"
#import "NSString+ShortCut.h"
#import "YWXUserDetailInfo.h"

#import "client_protocol.h"
using namespace client;
extern ClientPkg g_clientPkg;
extern char g_pkgBuffer[SocketBufferSize];

@implementation RequestManage (Contacts)

- (void)requestNearByList:(int32_t)gender{
    memset(&g_clientPkg.stBody.stClientPlayersNearbyReq, 0, sizeof(g_clientPkg.stBody.stClientPlayersNearbyReq));
    g_clientPkg.stHead.dwCmdID = CMD_PLAYERS_NEARBY_REQ;
    g_clientPkg.stBody.stClientPlayersNearbyReq.iGender = gender;
    g_clientPkg.stBody.stClientPlayersNearbyReq.llLatitude = (int64_t)(SharePersonalInfo.coordinate.latitude * YWXInt10E6);
    g_clientPkg.stBody.stClientPlayersNearbyReq.llLongitude = (int64_t)(SharePersonalInfo.coordinate.longitude * YWXInt10E6);
    [self readySendData];
}

- (void)responseNearByList {
    int32_t result = g_clientPkg.stBody.stClientPlayersNearbyResp.iResult;
    int32_t count = g_clientPkg.stBody.stClientPlayersNearbyResp.iPlayersNearbyCount;
    NSMutableArray *nearbyList = [NSMutableArray array];
    for (NSUInteger i = 0; i < count; i++) {
        YWXUserDetailInfo *info = [[YWXUserDetailInfo alloc] init];
        info.uid = g_clientPkg.stBody.stClientPlayersNearbyResp.astPlayersNearbyInfo[i].llUid;
        info.gender = g_clientPkg.stBody.stClientPlayersNearbyResp.astPlayersNearbyInfo[i].iGender;
        info.nickName = [NSString strWithBytes:g_clientPkg.stBody.stClientPlayersNearbyResp.astPlayersNearbyInfo[i].szNickname length:g_clientPkg.stBody.stClientPlayersNearbyResp.astPlayersNearbyInfo[i].iNickNameLen];
        info.distance = g_clientPkg.stBody.stClientPlayersNearbyResp.astPlayersNearbyInfo[i].llDistance;
        info.signature = [NSString strWithBytes:g_clientPkg.stBody.stClientPlayersNearbyResp.astPlayersNearbyInfo[i].szSignature length:g_clientPkg.stBody.stClientPlayersNearbyResp.astPlayersNearbyInfo[i].iSignatureLen];
        info.birthday = g_clientPkg.stBody.stClientPlayersNearbyResp.astPlayersNearbyInfo[i].llBirthday;
        info.lastUpdateTime = g_clientPkg.stBody.stClientPlayersNearbyResp.astPlayersNearbyInfo[i].llLastUpdateTime;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(g_clientPkg.stBody.stClientPlayersNearbyResp.astPlayersNearbyInfo[i].llLatitude/YWXFloat10E6, g_clientPkg.stBody.stClientPlayersNearbyResp.astPlayersNearbyInfo[i].llLongitude/YWXFloat10E6);
        info.coordinate = coordinate;
        [nearbyList addObject:info];
    }
    
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:result == 0 ? nearbyList : @(result) result:result == 0 ?: NO];
    
}

/**
 *  批量请求手机号码对应uid
 *
 *  @param count 手机号码个数
 *
 *  @param addressPhones 手机号码
 *
 */
- (void)requestContactsPhoneList:(int32_t)count addressPhones:(NSArray *)addressPhones{
    memset(&g_clientPkg.stBody.stClientAddressPhoneQueryReq, 0, sizeof(g_clientPkg.stBody.stClientAddressPhoneQueryReq));
    g_clientPkg.stHead.dwCmdID = CMD_ADDRESS_PHONE_QUERY_REQ;
    g_clientPkg.stBody.stClientAddressPhoneQueryReq.iAddressPhoneCount = count;
    for (int i=0;i<count;i++)
        g_clientPkg.stBody.stClientAddressPhoneQueryReq.addressPhones[i] = [addressPhones[i] longLongValue];
    [self readySendData];
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

-(void)responseContactsPhoneList{
    int32_t result = g_clientPkg.stBody.stClientAddressPhoneQueryResp.iResult;
    int32_t count = g_clientPkg.stBody.stClientAddressPhoneQueryResp.iAddressPhoneInfoCount;
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    for (int i=0; i<count; i++) {
        AddressPhoneInfo address =  g_clientPkg.stBody.stClientAddressPhoneQueryResp.astAddressPhoneInfo[i];
        AddressPhoneModel *phoneInfo = [[AddressPhoneModel alloc]init];
        phoneInfo.phone = [NSString strFromllong:address.llPhone];
        phoneInfo.uid = address.llUid;
        phoneInfo.nickName = [NSString strWithBytes:address.szNickName length:address.iNickNameLen];
        if (address.iIsFriend)
            phoneInfo.friendType = FriendTypeYes;
        else
            phoneInfo.friendType = FriendTypeNo;
        [dataArray addObject:phoneInfo];
    }
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:result == 0 ? dataArray : nil result:result == 0 ? YES : NO];
}
@end
