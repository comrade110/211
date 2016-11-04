//
//  SocketDataBuffer.m
//  youwo
//
//  Created by mygame on 15/2/10.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import <arpa/inet.h>
#import "YWXSocketDataBufferManager.h"
@implementation YWXSocketDataBufferManager
#pragma mark - override

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataBuffer = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - public
- (NSData *)packageData:(NSUInteger)len {
    if (_dataBuffer.length < len) {
        NSLog(@"提取包数据错误：提取长度超长");
        [_dataBuffer setLength:0];
//        ZYAssert(@"提取包数据错误：提取长度超长");
        return nil;
    }
    return [_dataBuffer subdataWithRange:NSMakeRange(0, len)];
}

- (NSData *)getDataWithSize:(NSUInteger)dataSize {
    return [_dataBuffer subdataWithRange:NSMakeRange(0, dataSize)];
}

- (NSUInteger)packageDataSize {
    if (_dataBuffer.length <= 2) {
        return 0;
    }
    NSData *subdata = [_dataBuffer subdataWithRange:NSMakeRange(0, 2)];
    uint16_t temp = 0;
    memcpy(&temp, [subdata bytes], 2);
    uint16_t dataSize = ntohs(temp);
    //uint64_t dataSize = ((temp&0xff00)>>8)|((temp&0x00ff)<<8);
    if (dataSize > HeadSize && dataSize < DataBufferSize) {
        return (NSUInteger)dataSize;
    }
    else {
        NSLog(@"错误包：包数据过小");
        [_dataBuffer setLength:0];
        return 0;
    }
    return dataSize;
}

- (void)resetPositon:(NSUInteger)len {
    NSUInteger dataLength = _dataBuffer.length;
    if (dataLength == len) {
        [_dataBuffer setLength:0];
    }
    else {
        NSMutableData *subdata = [[_dataBuffer subdataWithRange:NSMakeRange(len, dataLength-len)] mutableCopy];
        [_dataBuffer setLength:0];
        [_dataBuffer appendData:subdata];
    }
    NSLog(@"剩余数据长度:%lu", (unsigned long)_dataBuffer.length);
}
@end
