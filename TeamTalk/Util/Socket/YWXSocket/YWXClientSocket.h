//
//  ClientSocket.h
//  YHFDDZ
//
//  Created by mygame on 15/1/5.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

#define ShareClientSocket [YWXClientSocket getClientSocketInstance]

@interface YWXClientSocket : NSObject

/**
 *  socket singleton
 *
 *  @return ClientSocket Instance
 */
+ (YWXClientSocket *)getClientSocketInstance;


/**
 *  send data to server
 *
 *  @param aData send data
 */
- (void)sendData:(NSData *)aData;

/**
 *  与服务断开连接
 */
- (void)disconnectSocket;

/// 尝试开启重新登入定时器
- (void)startReconnectTimer;

- (void)stopReconnectTimer;
@end
