//
//  NSString+ShortCut.h
//  youwo
//
//  Created by mygame on 15/1/22.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ShortCut)
- (NSString *)MD5String;

+ (NSString *)strFrombool:(BOOL)aBoolen;

/**
 *  int to string
 *
 *  @param aInt a int
 *
 *  @return NSString
 */
+ (NSString *)strFromInt:(NSUInteger)aInt;

/**
 *  long int to string
 *
 *  @param alongInt a long int
 *
 *  @return NSString
 */
+ (NSString *)strFromlong:(NSUInteger)alongInt;

/**
 *  long long int to string
 *
 *  @param allongInt a long long int
 *
 *  @return NSString
 */
+ (NSString *)strFromllong:(long long int)allongInt;

/**
 *  CGFloat to string
 *
 *  @param aFloat a Float
 *
 *  @return NSString
 */
+ (NSString *)strFromFloat:(CGFloat)aFloat;

/**
 *  double to string
 *
 *  @param adouble a double
 *
 *  @return NSString
 */
+ (NSString *)strFromDouble:(double)adouble;

/**
 *  NSNumber to string
 *
 *  @param aNumber a Number
 *
 *  @return NSString
 */
+ (NSString *)strFromNumber:(NSNumber *)aNumber;

/**
 *  用bytes与长度生成NSString
 *
 *  @param bytes bytes
 *  @param len   len
 *
 *  @return NSString
 */
+ (NSString *)strWithBytes:(const void *)bytes length:(NSUInteger)len;

/**
 *  对比当前版本与服务器版版本
 *
 *  @return YES=服务器版本大于当前版本，NO=服务器版本小于等于当前版本
 */
- (BOOL)compareVersion;

/// 字符串转化array
- (NSArray *)arrayFromString;

/**
 *  生成属性字符串
 *
 *  @param attributesbase 基础属性
 *  @param attributes 特殊属性
 *
 *  @return NSAttributedString
 */
- (NSAttributedString *)attributedStr:(NSString *)str attributesbase:(NSDictionary *)attributesbase attributes:(NSDictionary *)attributes;
@end
