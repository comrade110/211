//
//  RequestManage+ChatList.m
//  youwo
//
//  Created by zhuzx on 15/4/9.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "RequestManage+ChatList.h"
#import "ClientGetChatRoomInfoListData.h"
#import "ApplyManage.h"

#import "client_protocol.h"
using namespace client;
extern ClientPkg g_clientPkg;
extern char g_pkgBuffer[SocketBufferSize];
@implementation RequestManage (ChatList)


- (void)requestClientPhoneQueryUserId:(NSString *)iphoneCode
{
    memset(&g_clientPkg.stBody.stClientPhoneQueryUserIdReq, 0, sizeof(g_clientPkg.stBody.stClientPhoneQueryUserIdReq));
    g_clientPkg.stHead.dwCmdID = CMD_CLIENT_PHONE_QUERY_USERID_REQ;
    
    int32_t iPhoneCodeLen = (int32_t)iphoneCode.length;
    memset(g_clientPkg.stBody.stClientPhoneQueryUserIdReq.szPhoneCode, 0, PHONE_CODE_MAX_LEN);
    g_clientPkg.stBody.stClientPhoneQueryUserIdReq.iPhoneCodeLen = iPhoneCodeLen;
    memcpy(g_clientPkg.stBody.stClientPhoneQueryUserIdReq.szPhoneCode, [iphoneCode UTF8String], iPhoneCodeLen);
    
    [self readySendData];
}

- (void)responseClientPhoneQueryUserId
{
    int32_t result = g_clientPkg.stBody.stClientPhoneQueryUserIdResp.iResult;
    int64_t lluid = g_clientPkg.stBody.stClientPhoneQueryUserIdResp.llUid;
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:result == 0 ? [NSString strFromllong:lluid] : @"client Phone Query false!" result:result == 0 ?: NO];
}

- (void)requestClientAccessTradeGetChatRoomInfoList:(NSString *)uid
{
    memset(&g_clientPkg.stBody.stClientRequestAccessTradeGetChatRoomInfoList, 0, sizeof(g_clientPkg.stBody.stClientRequestAccessTradeGetChatRoomInfoList));
    g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_TRADE_GET_CHATROOMINFOLIST;

    g_clientPkg.stBody.stClientRequestAccessTradeGetChatRoomInfoList.llUid = (int64_t)[uid longLongValue];
    [self readySendData];
}

- (void)responseClientAccessTradeGetChatRoomInfoList
{
    int32_t result = g_clientPkg.stBody.stTradeResponseAccessClientGetChatRoomInfoList.iResult;
    int32_t iChatRoomCount = g_clientPkg.stBody.stTradeResponseAccessClientGetChatRoomInfoList.iChatRoomCount;
    ClientGetChatRoomInfoListData *data = [[ClientGetChatRoomInfoListData alloc] init];
    data.iResult = result;
    
    if (iChatRoomCount > 0){
        [[ApplyManage shareInstance].clientGetChatRoomInfoList removeAllObjects];
        for (int i = 0; i < iChatRoomCount; i++) {
            chatRoomInfoList *roomInfolist = [[chatRoomInfoList alloc] init];
            roomInfolist.iIndex = g_clientPkg.stBody.stTradeResponseAccessClientGetChatRoomInfoList.astChatRoomInfoList[i].iIndex;
            NSString *roomID = [NSString strWithBytes:g_clientPkg.stBody.stTradeResponseAccessClientGetChatRoomInfoList.astChatRoomInfoList[i].stRoomid.sz_value length:g_clientPkg.stBody.stTradeResponseAccessClientGetChatRoomInfoList.astChatRoomInfoList[i].stRoomid.i_size];
            roomInfolist.roomID = roomID;
            NSString *name = [NSString strWithBytes:g_clientPkg.stBody.stTradeResponseAccessClientGetChatRoomInfoList.astChatRoomInfoList[i].stName.sz_value length:g_clientPkg.stBody.stTradeResponseAccessClientGetChatRoomInfoList.astChatRoomInfoList[i].stName.i_size];
            roomInfolist.name = name;
            roomInfolist.iconID = g_clientPkg.stBody.stTradeResponseAccessClientGetChatRoomInfoList.astChatRoomInfoList[i].llIconid;
            [data.chatRoomInfoList insertObject:roomInfolist atIndex:roomInfolist.iIndex];
            [[ApplyManage shareInstance].clientGetChatRoomInfoList insertObject:roomInfolist atIndex:roomInfolist.iIndex];
        }
    }
    
    [self responseCallBackWithResponseProtocolID:self.responseProtocolID responseObject:data result:result == 0 ?: NO];
}

@end
