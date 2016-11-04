//
//  NSString+ShortCut.m
//  youwo
//
//  Created by mygame on 15/1/22.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "NSString+ShortCut.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (ShortCut)
- (NSString *)MD5String {
    const char *str = [self UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    return filename;
}

+ (NSString *)strFrombool:(BOOL)aBoolen {
    return [NSString stringWithFormat:@"%d", aBoolen];
}

+ (NSString *)strFromInt:(NSUInteger)aInt {
    return [NSString stringWithFormat:@"%lu", (unsigned long)aInt];
}

+ (NSString *)strFromlong:(NSUInteger)alongInt {
    return [NSString stringWithFormat:@"%ld", (unsigned long)alongInt];
}

+ (NSString *)strFromllong:(long long int)allongInt {
    return [NSString stringWithFormat:@"%lld", allongInt];
}

+ (NSString *)strFromFloat:(CGFloat)aFloat {
    return [NSString stringWithFormat:@"%0.2f", aFloat];
}

+ (NSString *)strFromDouble:(double)adouble {
    return [NSString stringWithFormat:@"%0.2f", adouble];
}

+ (NSString *)strFromNumber:(NSNumber *)aNumber {
    return [NSString stringWithFormat:@"%@", aNumber];
}

+ (NSString *)strWithBytes:(const void *)bytes length:(NSUInteger)len {
    return [[NSString alloc] initWithBytes:bytes length:len encoding:NSUTF8StringEncoding];
}

/**
 *  对比当前版本与服务器版版本
 *
 *  @return YES=服务器版本大于当前版本，NO=服务器版本小于等于当前版本
 */
- (BOOL)compareVersion {
    NSString *curVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSArray *curArray = [curVersion componentsSeparatedByString:@"."];
    NSArray *serverArray = [self componentsSeparatedByString:@"."];
    BOOL flag = NO;
    for (NSUInteger i = 0; i < curArray.count; i++) {
        NSString *s1 = serverArray[i];
        NSString *s2 = curArray[i];
        if ([s1 intValue] > [s2 intValue]) {
            flag = YES;
            break;
        }
        else if ([s1 intValue] < [s2 intValue]) {
            break;
        }
    }
    return flag;
}

- (NSAttributedString *)attributedStr:(NSString *)str attributesbase:(NSDictionary *)attributesbase attributes:(NSDictionary *)attributes {
    if (str.length == 0) {
        return [[NSAttributedString alloc]  initWithString:self attributes:attributesbase];
    }
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:self attributes:attributesbase];
    [attr addAttributes:attributes range:[self rangeOfString:str]];
    return attr;
}


- (NSArray *)arrayFromString {
    NSString *str = [self stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    NSError *error = nil;
    NSData *data = [[NSData alloc] initWithBytes:[str UTF8String] length:strlen([str UTF8String])];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (array == nil || error) {
        return nil;
    }
    return array;
}
//- (void)compareVersion {
//    NSString *preV = @"2.0.0";
//    NSString *curV = @"1.12.1";
//    NSArray *preArray = [preV componentsSeparatedByString:@"."];
//    NSArray *curArray = [curV componentsSeparatedByString:@"."];
//    for (NSUInteger i = 0; preArray.count; i++) {
//        NSString *s1 = preArray[i];
//        NSString *s2 = curArray[i];
//        if ([s1 intValue] > [s2 intValue]) {
//            
//        }
//    }
//}
@end
