//
//  YJ_LoginViewController.h
//  YueJian
//
//  Created by Garry on 2018/4/11.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseViewController.h"

typedef void(^Callback)(void);

@interface YJ_LoginViewController : YJ_BaseViewController

@property (nonatomic, copy) Callback callback;


@end
