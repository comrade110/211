//
//  RequestManage+Contacts.h
//  youwo
//
//  Created by mymac on 15/5/20.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "RequestManage.h"

@interface RequestManage (Contacts)
- (void)requestNearByList:(int32_t)gender;

/**
 *  批量请求手机号码对应uid
 *
 *  @param count 手机号码个数
 *
 *  @param addressPhones 手机号码
 *
 */
- (void)requestContactsPhoneList:(int32_t)count addressPhones:(NSArray *)addressPhones;

-(void)responseContactsPhoneList;
-(void)responseNearByList;
@end
