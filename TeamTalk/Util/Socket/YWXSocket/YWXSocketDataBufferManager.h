//
//  SocketDataBuffer.h
//  youwo
//
//  Created by mygame on 15/2/10.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DataBufferSize 60*1024
#define HeadSize 8

@interface YWXSocketDataBufferManager : NSObject
@property (strong, nonatomic) NSMutableData *dataBuffer;

/**
 *  获取包数据
 *
 *  @param len 包长度
 *
 *  @return 包 data
 */
- (NSData *)packageData:(NSUInteger)len;

/**
 *  获取包数据大小
 *
 *  @return 包数据大小
 */
- (NSUInteger)packageDataSize;

/**
 *  获取数据大小
 *
 *  @param dataSize dataSize
 *
 *  @return NSData
 */
- (NSData *)getDataWithSize:(NSUInteger)dataSize;

/**
 *  复位buffer
 *
 *  @param len 复位长度
 */
- (void)resetPositon:(NSUInteger)len;
@end
