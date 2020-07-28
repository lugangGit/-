//
//  YJ_FeedbackViewController.h
//  YueJian
//
//  Created by Garry on 2018/8/2.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseViewController.h"

typedef void(^Callback)(void);

@interface YJ_FeedbackViewController : YJ_BaseViewController

@property (nonatomic, copy) Callback callback;

@end
