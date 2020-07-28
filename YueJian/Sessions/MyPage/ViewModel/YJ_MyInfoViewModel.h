//
//  YJ_MyInfoViewModel.h
//  YueJian
//
//  Created by Garry on 2018/8/3.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseModel.h"

@interface YJ_MyInfoViewModel : YJ_BaseModel
@property(nonatomic, copy) NSString *nickname;
@property(nonatomic, copy) NSString *birth;

@property(readonly, strong) RACCommand *NicknameConfirmCommand;
@property(readonly, strong) RACCommand *BirthConfirmCommand;

//获取用户信息
- (void)getUserInfoWithSuccessBlock:(YJ_ResponseSuccess)successBlock
                   withFailureBlock:(YJ_ResponseFail)failureBlock;
//修改头像
- (void)submitChangeWithAvatar:(NSString *)avatar withSuccessBlock:(YJ_ResponseSuccess)successBlock withFailureBlock:(YJ_ResponseFail)failureBlock;

//修改昵称
- (void)submitChangeWithNickname:(NSString *)nickname
               withSuccessBlock:(YJ_ResponseSuccess)successBlock
               withFailureBlock:(YJ_ResponseFail)failureBlock;

//修改性别
- (void)submitChangeWithSex:(NSString *)sex
                withSuccessBlock:(YJ_ResponseSuccess)successBlock
                withFailureBlock:(YJ_ResponseFail)failureBlock;

//修改生日
- (void)submitChangeWithBirth:(NSString *)birth
           withSuccessBlock:(YJ_ResponseSuccess)successBlock
           withFailureBlock:(YJ_ResponseFail)failureBlock;

//退出登陆
- (void)logoutWithSuccessBlock:(YJ_ResponseSuccess)successBlock
              withFailureBlock:(YJ_ResponseFail)failureBlock;

@end
