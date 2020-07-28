//
//  YJ_FeedbackViewModel.h
//  YueJian
//
//  Created by Garry on 2018/8/2.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseModel.h"

@interface YJ_FeedbackViewModel : YJ_BaseModel
@property(nonatomic, copy) NSString *feedBack;
@property(readonly, strong) RACCommand *ConfirmCommand;

- (void)postFeedbackWithSuccessBlock:(YJ_ResponseSuccess)successBlock
                  WithFailureBlock:(YJ_ResponseFail)failureBlock;
@end
