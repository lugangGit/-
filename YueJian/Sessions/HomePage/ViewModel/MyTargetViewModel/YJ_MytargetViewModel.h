//
//  YJ_MytargetViewModel.h
//  YueJian
//
//  Created by Garry on 2018/4/27.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseModel.h"

@interface YJ_MytargetViewModel : YJ_BaseModel

@property(nonatomic, copy) NSString *step;
@property(readonly, strong) RACCommand *confirmCommand;

- (void)targetStepWithSuccessBlock:(YJ_ResponseSuccess)successBlock
             WithFailureBlock:(YJ_ResponseFail)failureBlock;

-(void)handlerSignDataWithSuccessBlock:(YJ_ResponseSuccess)successBlock
                                   withFailureBlock:(YJ_ResponseFail)failureBlock;
@end
