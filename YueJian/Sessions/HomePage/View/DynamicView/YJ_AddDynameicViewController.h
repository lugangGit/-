//
//  YJ_AddDynameicViewController.h
//  YueJian
//
//  Created by Garry on 2018/7/15.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseViewController.h"

typedef void(^Callback)(void);

@interface YJ_AddDynameicViewController : YJ_BaseViewController

@property (nonatomic, copy) Callback callback;

@end
