//
//  RequestManage+VisitList.h
//  youwo
//
//  Created by mymac on 15/5/15.
//  Copyright (c) 2015年 mygame. All rights reserved.
//

#import "RequestManage.h"

@interface RequestManage (VisitList)

/**
 *  请求客访列表
 *
 *  @param llUid 用户id
 */
- (void)requestCustomerVisitList:(int64_t)llUid;

-(void)responseCustomerVisitList;

@end
