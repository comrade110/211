//
//  RequestManage+VisitList.m
//  youwo
//
//  Created by mymac on 15/5/15.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "RequestManage+VisitList.h"

#import "client_protocol.h"
using namespace client;
extern ClientPkg g_clientPkg;
extern char g_pkgBuffer[SocketBufferSize];

@implementation RequestManage (VisitList)

/**
 *  请求客访列表
 *
 *  @param llUid 用户id
 */
- (void)requestCustomerVisitList:(int64_t)llUid {
    memset(&g_clientPkg.stBody.stClientRequestAccessTradeSelectVisitorsList, 0, sizeof(g_clientPkg.stBody.stClientRequestAccessTradeSelectVisitorsList));
    g_clientPkg.stHead.dwCmdID = CLIENT_REQUEST_ACCESS_TRADE_SELECT_VISITORSLIST;
    g_clientPkg.stBody.stClientRequestAccessTradeSelectVisitorsList.llUid = llUid;

    [self readySendData];
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

-(void)responseCustomerVisitList{
    int32_t result = g_clientPkg.stBody.stTradeResponseAccessClientSelectVisitorsList.iResult;
    int32_t count = g_clientPkg.stBody.stTradeResponseAccessClientSelectVisitorsList.iVisitor_count;
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    for (int i=0; i<count; i++) {
        [dataArray addObject:[NSString strFromllong:g_clientPkg.stBody.stTradeResponseAccessClientSelectVisitorsList.visitors[i]]];
    }
    [self responseCallBackWithResponseProtocolID:g_clientPkg.stHead.dwCmdID responseObject:result == 0 ? dataArray : nil result:result == 0 ? YES : NO];
}
@end
