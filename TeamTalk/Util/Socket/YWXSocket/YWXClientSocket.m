//
//  ClientSocket.m
//  YHFDDZ
//
//  Created by mygame on 15/1/5.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "YWXClientSocket.h"
#import "RequestManageHeader.h"
#import "YWXSocketDataBufferManager.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>

@interface YWXClientSocket ()<GCDAsyncSocketDelegate>
@property (strong, nonatomic) AFNetworkReachabilityManager *sharedReachabilityManager;

@property (strong, nonatomic) NSRecursiveLock *lock;

/// 重连定时器
@property (strong, nonatomic) NSTimer *reconnectTimer;
@property (strong, nonatomic) GCDAsyncSocket *asycSocket;
@property (strong, nonatomic) YWXSocketDataBufferManager *dataBufferManager;
- (void)readDataFromServer;
@end

@implementation YWXClientSocket

#pragma mark - public function
- (void)sendData:(NSData *)aData
{
    [self connectToSever];
    [self.asycSocket writeData:aData withTimeout:30 tag:0];
}

+ (YWXClientSocket *)getClientSocketInstance
{
    static YWXClientSocket *clientSocketInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        clientSocketInstance = [[YWXClientSocket alloc] init];
        [clientSocketInstance monitNetWork];
    });
    return clientSocketInstance;
}

- (void)disconnectSocket {
    [self.asycSocket setDelegate:nil delegateQueue:NULL];
    [self.asycSocket disconnect];
    [self.dataBufferManager.dataBuffer setLength:0];
    self.dataBufferManager = nil;
    self.asycSocket = nil;
    SharePersonalInfo.uid = 0;
    [shareRequestManage cancelAllReqest];
}

- (void)dealloc
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (self.lock) {
        [self.lock unlock];
    }
}

#pragma mark - 重连
- (void)startReconnectTimer {
    if (_reconnectTimer) {
        return;
    }
    
    _reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(reconnect) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_reconnectTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopReconnectTimer {
    if (self.reconnectTimer) {
        [self.reconnectTimer invalidate];
        self.reconnectTimer = nil;
    }
}

- (void)reconnect {
    NSString *loginToken = getUserDefaultsValue(kYWXLoginToken);
    
    // 判断是否可以断线重连
    if (SharePersonalInfo.accountStatus > YWXAccountProhibitionAutoLoginMinEnum && loginToken.length > 10) {
        if (SharePersonalInfo.reachability) {
            [shareRequestManage requestDataWithRequestProtocolID:kCLIENT_REQUEST_ACCESS_TOKEN_LOGIN parameters:loginToken success:^(id responseObject) {
                NSLog(@"断线重连成功");
                [self stopReconnectTimer];
            } failure:^(id failureDes) {
                [self stopReconnectTimer];
                NSLog(@"断线重连失败");
            }];
        }
    }
    else {
        [self stopReconnectTimer];
    }
}

#pragma mark - getter
- (NSRecursiveLock *)lock {
    if (_lock) {
        return _lock;
    }
    
    _lock = [[NSRecursiveLock alloc] init];
    
    return _lock;
}

#pragma mark - private function
- (void)readDataFromServer
{
    [self.asycSocket readDataWithTimeout:-1 tag:0];
}

- (void)didReceivedData:(NSData *)data {
    [self.lock lock];
    [_dataBufferManager.dataBuffer appendData:data];
    [self.lock unlock];
    
    while ((_dataBufferManager.dataBuffer.length >= [_dataBufferManager packageDataSize]) && [_dataBufferManager packageDataSize] > 0) {
        // 获取协议大小
        NSUInteger dataSize = [_dataBufferManager packageDataSize];
        //NSLog(@"协议包大小=%d", (uint16_t)dataSize);
        // 获取协议数据
        NSData *packageData = [_dataBufferManager getDataWithSize:dataSize];
        // 解包
        NSUInteger errorCode = [shareRequestManage didFinishGetData:packageData];
        
        [self.lock lock];
        if (!errorCode) {
            // 协议解析成功
            [_dataBufferManager resetPositon:dataSize];
        }
        else {
            // 协议解析错误 清空data缓存
            [_dataBufferManager.dataBuffer setLength:0];
            NSLog(@"协议解析错误---000");
        }
        [self.lock unlock];
    }
}

- (void)connectToSever {
#if defined (DEBUG) && (IPPort6100 || IPPort7100 || IPPort8100 || IPPort9100 || ProductIPPort1 || ProductIPPort2 || ProductIPPort3)
    /* ------ DEBUG ------ */
    #ifdef IPPort6100
        NSString *currentIP = @"192.168.20.61";
        NSUInteger currentPort = 6100;
    #endif
        
    #ifdef IPPort7100
        NSString *currentIP = @"192.168.20.61";
        NSUInteger currentPort = 7100;
    #endif
        
    #ifdef IPPort8100
        NSString *currentIP = @"192.168.20.61";
        NSUInteger currentPort = 8100;
    #endif
        
    #ifdef IPPort9100
        NSString *currentIP = @"192.168.20.60";
        NSUInteger currentPort = 9100;
    #endif
    
    #ifdef ProductIPPort3
        // 121.41.86.53:30053--当前生产环境
        //NSString *currentIP = @"121.41.86.53";
        //NSUInteger currentPort = 30053;
        NSString *currentIP = [SharePersonalInfo loginIP];
        NSUInteger currentPort = [SharePersonalInfo loginPort];
    #endif
    
    #ifdef ProductIPPort1
        NSString *currentIP = @"121.41.86.53";
        NSUInteger currentPort = 30050;
    #endif
    
    #ifdef ProductIPPort2
        NSString *currentIP = @"121.41.86.53";
        NSUInteger currentPort = 30052;
    #endif
    
#else
    
    /* ------ release ------ */
    #ifdef IPPort6100
        NSString *currentIP = @"192.168.20.61";
        NSUInteger currentPort = 6100;
    #endif
        
    #ifdef IPPort7100
        NSString *currentIP = @"192.168.20.61";
        NSUInteger currentPort = 7100;
    #endif
        
    #ifdef IPPort8100
        NSString *currentIP = @"192.168.20.61";
        NSUInteger currentPort = 8100;
    #endif
        
    #ifdef IPPort9100
        NSString *currentIP = @"192.168.20.60";
        NSUInteger currentPort = 9100;
    #endif
    
    #ifdef ProductIPPort3
        NSString *currentIP = [SharePersonalInfo loginIP];
        NSUInteger currentPort = [SharePersonalInfo loginPort];
    #endif
    
#endif
    
    NSError *error = nil;
    if (self.asycSocket == nil)
    {
        self.dataBufferManager = [[YWXSocketDataBufferManager alloc] init];
        self.asycSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        BOOL flag = [self.asycSocket connectToHost:currentIP onPort:currentPort error:&error];
        if (error != nil && !flag) {
            NSLog(@"000-socket connect host error:%@", [error userInfo]);
        }
    }
    else
    {
        if (self.asycSocket.isConnected) {
            [self readDataFromServer];
        }
        else {
            BOOL flag = [self.asycSocket connectToHost:currentIP onPort:currentPort error:&error];
            if (error != nil && !flag) {
                NSLog(@"111-socket connect host error:%@", [error userInfo]);
            }
        }
    }
}


#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port  {
    NSLog(@"|socket connect success!|");
    [self.asycSocket performBlock:^{
        [self.asycSocket enableBackgroundingOnSocket];
    }];
    [self readDataFromServer];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"|---协议数据已经接收---%d|", (int)[data length]);
    [self didReceivedData:data];
    
    [self readDataFromServer];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"|协议数据已经发送|");
    [self readDataFromServer];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socket 已经断开");
    [self disconnectSocket];
    
    [self startReconnectTimer];
    
    NSString *localizedDescription = [err localizedDescription];
//    NSString *errorMsg = localizedDescription;
//    int64_t errorCommandID = 0;
    
    if ([localizedDescription rangeOfString:@"Network is unreachable"].location != NSNotFound || [localizedDescription rangeOfString:@"Socket is not connected"].location != NSNotFound) {
//        errorMsg = @"网络不给力";
//        errorCommandID = kNetworkIsUnreachable;
        
        SharePersonalInfo.reachability = NO;
        YWXPostNotificationName(kNetworkIsUnreachableNotificationKey); // 网络不给力
    }
    else if ([localizedDescription rangeOfString:@"Operation timed out"].location != NSNotFound) {
//        errorMsg = @"网络超时";
//        errorCommandID = kOperationTimeout;
        YWXPostNotificationName(kOperationTimedOutNotificationKey);
    }
//    else if ([localizedDescription rangeOfString:@"Socket closed by remote peer"].location != NSNotFound) {
//        errorMsg = @"被服务器主动断开";
//        errorCommandID = kReconnectServer;
//    }
//    else {
//        NSLog(@"0000-socketDidDisconnect error=%@,", errorMsg);
//    }
//    NSLog(@"111-socketDidDisconnect error=%@,", errorMsg);
}

#pragma mark - AFNetworkReachability

- (void)monitNetWork {
    self.sharedReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [self.sharedReachabilityManager startMonitoring];
    [self.sharedReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        SharePersonalInfo.reachability = status > AFNetworkReachabilityStatusNotReachable ?: NO;
        
        NSLog(@"%@", status > AFNetworkReachabilityStatusNotReachable ? @"有网络咯": @"没网络了");
    }];
}
@end
