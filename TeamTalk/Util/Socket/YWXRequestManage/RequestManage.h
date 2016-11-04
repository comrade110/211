//
//  RequestManage.h
//  youwo
//
//  Created by zhuzx on 15/1/13.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import <Foundation/Foundation.h>
#define SocketBufferSize 1024*1024
#define shareRequestManage [RequestManage defaultRequestManage]


@interface RequestManage : NSObject
/// 当前返回协议号
@property (nonatomic) UInt64 responseProtocolID;

//@property(nonatomic, assign) id delegate;
+ (RequestManage *)defaultRequestManage;

/**
 *  package char data and send socket
 */
- (void)readySendData;

/**
 *  断开socket
 */
- (void)disconnentWithService;

/**
 *  接收到完整的协议包
 *
 *  @return 解包是否成功
 */
- (NSUInteger)didFinishGetData:(NSData *)aData;

#pragma mark - 协议请求、block回调方法
/// 取消所有请求的block回调
- (void)cancelAllReqest;

/**
 *  取消请求的block回调
 *
 *  @param responseProtocolID: 响应的协议号
 */
- (void)cancelRequestWithResponseProtocolID:(uint64_t)responseProtocolID;

/**
 *  取消请求的block回调
 *
 *  @param responseProtocolID: 请求的协议号
 */
- (void)cancelRequestWithRequestProtocolID:(uint64_t)requestProtocolID;

/**
 *  请求协议数据
 *
 *  @param requestProtocolID: 请求的协议号
 *  @param parameters: 请求参数
 *  @param success: 成功回调
 *  @param failure: 失败回调
 */
- (void)requestDataWithRequestProtocolID:(uint64_t)requestProtocolID parameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(id failureDes))failure;

/**
 *  协议响应
 *
 *  @param responseProtocolID: 返回协议号
 *  @param responseObject: 返回数据（成功/失败数据）
 *  @param result: 请求结果状态（YES-成功， NO-失败）
 */
- (void)responseCallBackWithResponseProtocolID:(uint64_t)responseProtocolID responseObject:(id)responseObject result:(BOOL)result;
@end
