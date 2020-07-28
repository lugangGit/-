//
//  YJ_BodyProfile.h
//  YueJian
//
//  Created by LG on 2018/5/15.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YJ_BodyProfile : NSObject

@property(nonatomic, copy) NSString *height;
@property(nonatomic, copy) NSString *weight;
@property(nonatomic, copy) NSString *bust;
@property(nonatomic, copy) NSString *waist;
@property(nonatomic, copy) NSString *hip;
@property(nonatomic, copy) NSString *fatRate;
@property(nonatomic, copy) NSString *targetStep;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
