//
//  RequestManage+ChatList.h
//  youwo
//
//  Created by zhuzx on 15/4/9.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "RequestManage.h"

@interface RequestManage (ChatList)

/**
 *  // 根据手机号码获取uid请求
 *
 *  @param iphoneCode 手机号
 */
- (void)requestClientPhoneQueryUserId:(NSString *)iphoneCode;

/**
 *  // 根据手机号码获取uid响应
 */
- (void)responseClientPhoneQueryUserId;

/**
 *  客户端请求网关交易服务器获取当前火热聊天室信息列表
 *
 *  @param llUid 用户id
 */
- (void)requestClientAccessTradeGetChatRoomInfoList:(NSString *)uid;

/**
 *  交易服务器回应网关客户端获取当前火热聊天室信息列表
 */
- (void)responseClientAccessTradeGetChatRoomInfoList;
@end
