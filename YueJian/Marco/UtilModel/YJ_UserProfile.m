//
//  YJ_UserProfile.m
//  YueJian
//
//  Created by LG on 2018/4/10.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_UserProfile.h"

@implementation YJ_UserProfile

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        if (dictionary[@"userId"])
        {
            _userID = [NSString stringWithFormat:@"%@", dictionary[@"userId"]];
        }
        _userAvatar = dictionary[@"userAvatar"];
        _phoneNum = dictionary[@"phoneNum"];
        _nickName = dictionary[@"nickName"];
        _sex = dictionary[@"sex"];
        _birth = dictionary[@"birth"];
        //_token = dictionary[@"token"];
    }
    
    return self;
}
@end
