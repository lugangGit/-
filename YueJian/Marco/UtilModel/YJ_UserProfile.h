//
//  YJ_UserProfile.h
//  YueJian
//
//  Created by LG on 2018/4/10.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YJ_UserProfile : NSObject

@property(nonatomic, copy) NSString *userID;
@property(nonatomic, copy) NSString *nickName;
@property(nonatomic, copy) NSString *userAvatar;
@property(nonatomic, copy) NSString *sex;
@property(nonatomic, copy) NSString *birth;
@property(nonatomic, copy) NSString *phoneNum;
@property(nonatomic, copy) NSString *token;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
