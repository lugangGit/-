//
//  YJ_PlanViewController.m
//  YueJian
//
//  Created by LG on 2018/3/30.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_PlanViewController.h"
#import "YJ_EditPlanViewController.h"
#import "XLWaveProgress.h"
#import "FBShimmeringView.h"
#import "ZMFloatButton.h"
#import "YJ_AddPlanViewController.h"
#import "YJ_LoginViewController.h"
#import "YJ_PlanViewModel.h"
#import "YJ_PlanModel.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"

@interface YJ_PlanViewController ()<UITableViewDelegate, UITableViewDataSource, ZMFloatButtonDelegate, UIGestureRecognizerDelegate>
{
    XLWaveProgress *_waveProgress;
    FBShimmeringView *_shimmeringView;
    UILabel *_LabTarget;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL isShowPhoto;
@property (nonatomic, strong) YJ_PlanViewModel *viewModel;
@property (nonatomic, strong) UIImageView *beforeImageView;
@property (nonatomic, strong) UIImageView *afterImageView;
@property (nonatomic, strong) UILabel *labTimeType;
@property (nonatomic, strong) UILabel *labTitle;
@property (nonatomic, strong) UILabel *labTitleTime;
@property (nonatomic, strong) UILabel *labPlayType;
@property (nonatomic, strong) UILabel *labEat;
@property (nonatomic, strong) NSMutableArray *planArray;

@end

@implementation YJ_PlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel = [[YJ_PlanViewModel alloc] init];
    self.view.backgroundColor = TableViewBGColor;
    self.isShowPhoto = YES;
    
    //请求数据
    [self handlerGetData];

    //绘制视图
    [self drawUI];
}

#pragma mark - 列表header数据
- (void)handlerGetData {
    if ([[YJ_APIManager sharedInstance] isLoggedIn]) {
        [SVProgressHUD show];
        __weak typeof(self) weakSelf = self;
        //获取列表cell数据
        [self handlerGetPlanCellData];
        [weakSelf.viewModel handlerGetHeaderPlanWithSuccessBlock:^(id response) {
            [SVProgressHUD dismiss];
            NSLog(@"%@", response);
            YJ_PlanModel *planHeader = [[YJ_PlanModel alloc] initPlanHeaderWithDictionary:response[@"data"]];
            NSLog(@"%@", planHeader);
            _waveProgress.progress = [planHeader.countDownCurrent floatValue] / [planHeader.dateCount floatValue];
            
            NSLog(@"%@", planHeader.countDownCurrent);
            NSString *countDownCurrent = [NSString stringWithFormat:@"%@", planHeader.countDownCurrent];
            if (![countDownCurrent isEqualToString:@""] && ![countDownCurrent isEqualToString:@"(null)"]) {
                _waveProgress.progressText = planHeader.countDownCurrent;
            }
            
            NSLog(@"%@", planHeader.planContent);
            NSString *planContent = [NSString stringWithFormat:@"%@", planHeader.planContent];
            if (![planContent isEqualToString:@""] && ![planContent isEqualToString:@"(null)"]) {
                _LabTarget.text = planHeader.planContent;
            }else {
                _LabTarget.text = @"记录下你的运动计划与目标吧...";
            }
            
            NSString *currentPhoto = [NSString stringWithFormat:@"%@", planHeader.currentPhoto];
            if (![currentPhoto isEqualToString:@""] && ![currentPhoto isEqualToString:@"(null)"]) {
                [self.beforeImageView sd_setImageWithURL:[NSURL URLWithString:currentPhoto]];
            }else {
                self.beforeImageView.image = [UIImage imageNamed:@"img_userInfo_bg"];
            }
            
            NSString *finishPhoto = [NSString stringWithFormat:@"%@", planHeader.finishPhoto];
            if (![finishPhoto isEqualToString:@""] && ![finishPhoto isEqualToString:@"(null)"]) {
                [self.afterImageView sd_setImageWithURL:[NSURL URLWithString:finishPhoto]];
            }else {
                self.afterImageView.image = [UIImage imageNamed:@"img_userInfo_bg"];

            }
        } withFailureBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
        }];
    }
}

#pragma mark - 列表cell数据
- (void)handlerGetPlanCellData {
    __weak typeof(self) weakSelf = self;
    [weakSelf.viewModel handlerGetCellPlanWithSuccessBlock:^(id response) {
        [SVProgressHUD dismiss];
        NSLog(@"response：%@", response);
        NSArray *dataArray = response[@"data"];
        NSLog(@"%@", dataArray);
        NSMutableArray *responsePlan= [NSMutableArray array];
        for (NSDictionary *dic in dataArray) {
            YJ_PlanModel *planCell = [[YJ_PlanModel alloc] initPlanContentWithDictionary:dic];
            [responsePlan addObject:planCell];
        }
        //weakSelf.planArray = [responsePlan copy];
        weakSelf.planArray = [[NSMutableArray alloc] initWithArray:responsePlan];
        NSLog(@"%lu",  (unsigned long)weakSelf.planArray.count);
        if (weakSelf.planArray.count != 0) {
            self.tableView.tableFooterView.hidden = YES;
        }else {
            self.tableView.tableFooterView.hidden = NO;
        }
        //刷新数据
        [weakSelf.tableView reloadData];
    } withFailureBlock:^(NSError *error) {
        [SVProgressHUD dismiss];
        [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    //设置导航栏
    [self setNavigation];
    //判断登录
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:KIsLogin];
    if (isLogin) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KIsLogin];
        [self handlerGetData];
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:app];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    //进入前台时调用此函数
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self handlerGetData];
}

#pragma mark - 设置导航栏
- (void)setNavigation {
    //导航栏
    [self.tabBarController.tabBar setHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = NSLocalizedString(@"运动计划", nil);
    self.navigationController.navigationBar.tintColor = ThemeColor;
}

#pragma mark - 绘制UI
- (void)drawUI {
    //初始化tableview
    self.tableView = [[UITableView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = BGColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = [self drawHeaderView];
    self.tableView.bounces = NO;
    //self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [self drawFooderView];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.offset(0);
    }];
    
    //悬浮按钮
    ZMFloatButton * floatBtn = [[ZMFloatButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60, SCREEN_HEIGHT-230, 50, 50)];
    floatBtn.delegate = self;
    //floatBtn.isMoving = NO;
    floatBtn.bannerIV.image = [UIImage imageNamed:@"publishAdd"];
    [self.tableView addSubview:floatBtn];
    [self.tableView bringSubviewToFront:floatBtn];
}

#pragma mark -ZMFloatButtonDelegate
- (void)floatTapAction:(ZMFloatButton *)sender{
    //点击执行事件
    if([[YJ_APIManager sharedInstance] isLoggedIn]) {
        YJ_AddPlanViewController *APVC = [[YJ_AddPlanViewController alloc] init];
        APVC.callback = ^{
            [self.navigationController popViewControllerAnimated:YES];
            [self handlerGetPlanCellData];
        };
        [self.navigationController pushViewController:APVC animated:YES];
    }else {
        UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
        YJ_LoginViewController *loginVC = [mainSB instantiateViewControllerWithIdentifier:@"LoginPage"];
        UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:navc animated:YES completion:nil];
        loginVC.callback = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:nil];
                if([[YJ_APIManager sharedInstance] isLoggedIn])
                {
                    YJ_AddPlanViewController *APVC = [[YJ_AddPlanViewController alloc] init];
                    APVC.callback = ^{
                        [self.navigationController popViewControllerAnimated:YES];
                        [self handlerGetPlanCellData];
                    };
                    [self.navigationController pushViewController:APVC animated:YES];                }
            });
        };
    }
}

- (UIView *)drawFooderView {
    UIView *fooderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 125)];
    
    UIView *view = [[UIView alloc] init];
    view.layer.cornerRadius = 30;
    view.layer.masksToBounds = YES;
    view.backgroundColor = TableViewBGColor;
    //设置边框及边框颜色
    view.layer.borderWidth = 2;
    view.layer.borderColor = BGColor.CGColor;
    [fooderView addSubview:view];

    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.left.offset(5);
        make.right.offset(-5);
        make.bottom.offset(0);
    }];

    UIImageView *imgViewAddPlan = [[UIImageView alloc] init];
    [imgViewAddPlan setImage:[UIImage imageNamed:@"img_plan_add"]];
    imgViewAddPlan.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureAfter = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhotoAction:)];
    [imgViewAddPlan addGestureRecognizer:tapGestureAfter];
    [view addSubview:imgViewAddPlan];
    
    [imgViewAddPlan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.offset(0);
        make.width.offset(110);
        make.height.offset(90);
    }];
    
    UILabel *labAdd = [[UILabel alloc] init];
    labAdd.text = @"添加运动计划";
    labAdd.font = [UIFont systemFontOfSize:14];
    labAdd.textColor = [UIColor grayColor];
    labAdd.textAlignment = NSTextAlignmentCenter;
    [view addSubview:labAdd];
    
    [labAdd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgViewAddPlan.mas_bottom).offset(0);
        make.left.offset(50);
        make.right.offset(-50);
    }];
    
    return fooderView;
}

- (UIView *)drawHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 220)];
    headerView.backgroundColor = TableViewBGColor;

    //底部横线
    UIImageView *bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, headerView.bounds.size.height-5, SCREEN_WIDTH, 5)];
    bottomView.backgroundColor = BGColor;
    [headerView addSubview:bottomView];
    
    //我的计划
    UIImageView *planImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_plan_target"]];
    [headerView addSubview:planImageView];
    
    UILabel *labPlan = [[UILabel alloc] init];
    labPlan.text = @"我的计划";
    labPlan.textColor = ThemeColor;
    labPlan.font = [UIFont systemFontOfSize:16];
    [headerView addSubview:labPlan];
    
    [planImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(15);
        make.left.offset(25);
        make.width.height.offset(28);
    }];
    
    [labPlan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(19);
        make.left.equalTo(planImageView.mas_right).offset(5);
        make.width.offset(100);
    }];
    
    UIImageView *editImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_home_playrecord"]];
    [headerView addSubview:editImageView];
    
    UIButton *btnEdit = [[UIButton alloc] init];
    btnEdit.titleLabel.font = [UIFont systemFontOfSize:14];
    btnEdit.titleLabel.textAlignment = NSTextAlignmentRight;
    [btnEdit setTitle:NSLocalizedString(@"Edit >", nil) forState:UIControlStateNormal];
    [btnEdit setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [headerView addSubview:btnEdit];
    
    [editImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(20);
        make.right.offset(-10);
        make.width.height.offset(0);
    }];
    
    [btnEdit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(20);
        make.right.equalTo(editImageView.mas_left).offset(-5);
        make.width.offset(50);
        make.height.offset(20);
    }];
    
    [[btnEdit rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        if([[YJ_APIManager sharedInstance] isLoggedIn]) {
            YJ_EditPlanViewController *EPVC = [[YJ_EditPlanViewController alloc] init];
            EPVC.callback = ^(){
                [self.navigationController popViewControllerAnimated:YES];
                //更新头部数据
                [self handlerGetData];
            };
            [self.navigationController pushViewController:EPVC animated:YES];
        }else {
            UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
            YJ_LoginViewController *loginVC = [mainSB instantiateViewControllerWithIdentifier:@"LoginPage"];
            UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [self presentViewController:navc animated:YES completion:nil];
            loginVC.callback = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:NO completion:nil];
                    if([[YJ_APIManager sharedInstance] isLoggedIn])
                    {
                        YJ_EditPlanViewController *EPVC = [[YJ_EditPlanViewController alloc] init];
                        EPVC.callback = ^(){
                            [self.navigationController popViewControllerAnimated:YES];
                            //更新头部数据
                            [self handlerGetData];
                        };
                        [self.navigationController pushViewController:EPVC animated:YES];
                    }
                });
            };
        }
    }];
    
    //目标进度条
    _waveProgress = [[XLWaveProgress alloc] initWithFrame:CGRectMake(35, 60, 130, 130)];
    _waveProgress.progress = 0.5;
    _waveProgress.progressText = @"0";
    [headerView addSubview:_waveProgress];

    /*UILabel *labSelf = [[UILabel alloc] init];
    labSelf.text = @"留言:";
    labSelf.textColor = [UIColor blackColor];
    labSelf.font = [UIFont systemFontOfSize:16];
    [headerView addSubview:labSelf];
    
    [labSelf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(55);
        make.left.offset(190);
        make.width.offset(100);
    }];*/
    
    _shimmeringView = [[FBShimmeringView alloc] init];
    _shimmeringView.shimmering = YES;
    _shimmeringView.shimmeringBeginFadeDuration = 0.8;
    _shimmeringView.shimmeringOpacity = 1;
    [headerView addSubview:_shimmeringView];
    
    _LabTarget = [[UILabel alloc] init];
    _LabTarget.text = @"记录下你的运动计划与目标吧...";
    _LabTarget.numberOfLines = 0;
    _LabTarget.font = [UIFont systemFontOfSize:15];
    _LabTarget.textColor = SubThemeColor;
    _LabTarget.textAlignment = NSTextAlignmentLeft;
    _shimmeringView.contentView = _LabTarget;
    
    [_shimmeringView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(70);
        make.left.offset(190);
        make.right.offset(-20);
        make.height.offset(100);
        
    }];
    
    [_LabTarget mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(80);
        make.left.offset(190);
        make.right.offset(-20);
    }];
    
    //上传照片
    UIImageView *photoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_plan_myPhone"]];
    photoImageView.frame = CGRectMake(25, 210, 25, 0);
    [headerView addSubview:photoImageView];
    
    UILabel *labPhoto = [[UILabel alloc] initWithFrame:CGRectMake(60, 212, 100, 0)];
    labPhoto.text = @"我的剪影";
    labPhoto.textColor = ThemeColor;
    labPhoto.font = [UIFont systemFontOfSize:16];
    [headerView addSubview:labPhoto];
    
    //当前照片
    self.beforeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 255, 130, 0)];
    self.beforeImageView.image = [UIImage imageNamed:@"img_userInfo_bg"];
    //beforeImageView.backgroundColor = [UIColor redColor];
    [headerView addSubview:self.beforeImageView];
    
    //当前
    UILabel *labBefore = [[UILabel alloc] initWithFrame:CGRectMake(40, 390, 130, 0)];
    labBefore.font = [UIFont systemFontOfSize:14];
    labBefore.text = @"这一刻";
    labBefore.textAlignment = NSTextAlignmentCenter;
    labBefore.textColor = [UIColor grayColor];
    [headerView addSubview:labBefore];
    
    //之后照片
    self.afterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40 - 130, 255, 130, 0)];
    self.afterImageView.image = [UIImage imageNamed:@"img_userInfo_bg"];
    //self.afterImageView.backgroundColor = [UIColor redColor];
    [headerView addSubview:self.afterImageView];
    
    //之后
    UILabel *labAfter = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40 - 130, 390, 130, 0)];
    labAfter.font = [UIFont systemFontOfSize:14];
    labAfter.text = @"完成后";
    labAfter.textAlignment = NSTextAlignmentCenter;
    labAfter.textColor = [UIColor grayColor];
    [headerView addSubview:labAfter];

    //展开按钮
    UIButton *btnScreen = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-15, headerView.bounds.size.height-40, 30, 30)];
    //[btnScreen setTitle:@"展开" forState:UIControlStateNormal];
    [btnScreen setTitleColor:ThemeColor forState:UIControlStateNormal];
    [btnScreen setImage:[UIImage imageNamed:@"icon_plan_qi"] forState:UIControlStateNormal];
    [headerView addSubview:btnScreen];
    
    [[btnScreen rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        if (_isShowPhoto) {
            _isShowPhoto = NO;
            [btnScreen setImage:[UIImage imageNamed:@"icon_plan_shou"] forState:UIControlStateNormal];

            //设置动画的名字
            [UIView beginAnimations:@"Animation" context:nil];
            //设置动画的间隔时间
            [UIView setAnimationDuration:0.50];
            //使用当前正在运行的状态开始下一段动画
            [UIView setAnimationBeginsFromCurrentState: YES];
            //设置视图移动的位移
            headerView.frame = CGRectMake(headerView.frame.origin.x, headerView.frame.origin.y, headerView.frame.size.width, headerView.frame.size.height + 220);
            self.beforeImageView.frame = CGRectMake(self.beforeImageView.frame.origin.x, self.beforeImageView.frame.origin.y, self.beforeImageView.frame.size.width, self.beforeImageView.frame.size.height + 130);
            self.afterImageView.frame = CGRectMake(self.afterImageView.frame.origin.x, self.afterImageView.frame.origin.y, self.afterImageView.frame.size.width, self.afterImageView.frame.size.height + 130);
            bottomView.frame = CGRectMake(0, headerView.bounds.size.height-5, SCREEN_WIDTH, 5);
            btnScreen.frame = CGRectMake(SCREEN_WIDTH/2-15, headerView.bounds.size.height-40, 30, 30);
            photoImageView.frame = CGRectMake(photoImageView.frame.origin.x, photoImageView.frame.origin.y, photoImageView.frame.size.width, photoImageView.frame.size.height + 25);
            labPhoto.frame = CGRectMake(labPhoto.frame.origin.x, labPhoto.frame.origin.y, labPhoto.frame.size.width, labPhoto.frame.size.height + 20);
            labBefore.frame = CGRectMake(labBefore.frame.origin.x, labBefore.frame.origin.y, labBefore.frame.size.width, labBefore.frame.size.height + 20);
            labAfter.frame = CGRectMake(labAfter.frame.origin.x, labAfter.frame.origin.y, labAfter.frame.size.width, labAfter.frame.size.height + 20);
            //设置动画结束
             [UIView commitAnimations];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //beforeImageView.hidden = NO;
                [self.tableView reloadData];
            });

        }else {
            _isShowPhoto = YES;
            [btnScreen setImage:[UIImage imageNamed:@"icon_plan_qi"] forState:UIControlStateNormal];
            //设置动画的名字
            [UIView beginAnimations:@"Animation" context:nil];
            //设置动画的间隔时间
            [UIView setAnimationDuration:0.50];
            //使用当前正在运行的状态开始下一段动画
            [UIView setAnimationBeginsFromCurrentState: YES];
            //设置视图移动的位移
            headerView.frame = CGRectMake(headerView.frame.origin.x, headerView.frame.origin.y, headerView.frame.size.width, headerView.frame.size.height - 220);
            self.beforeImageView.frame = CGRectMake(self.beforeImageView.frame.origin.x, self.beforeImageView.frame.origin.y, self.beforeImageView.frame.size.width, self.beforeImageView.frame.size.height - 130);
            self.afterImageView.frame = CGRectMake(self.afterImageView.frame.origin.x, self.afterImageView.frame.origin.y, self.afterImageView.frame.size.width, self.afterImageView.frame.size.height - 130);
            bottomView.frame = CGRectMake(0, headerView.bounds.size.height-5, SCREEN_WIDTH, 5);
            btnScreen.frame = CGRectMake(SCREEN_WIDTH/2-15, headerView.bounds.size.height-40, 30, 30);
            photoImageView.frame = CGRectMake(photoImageView.frame.origin.x, photoImageView.frame.origin.y, photoImageView.frame.size.width, photoImageView.frame.size.height - 25);
            labPhoto.frame = CGRectMake(labPhoto.frame.origin.x, labPhoto.frame.origin.y, labPhoto.frame.size.width, labPhoto.frame.size.height - 20);
            labBefore.frame = CGRectMake(labBefore.frame.origin.x, labBefore.frame.origin.y, labBefore.frame.size.width, labBefore.frame.size.height - 20);
            labAfter.frame = CGRectMake(labAfter.frame.origin.x, labAfter.frame.origin.y, labAfter.frame.size.width, labAfter.frame.size.height - 20);
            //设置动画结束
            [UIView commitAnimations];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //beforeImageView.hidden = YES;
                [self.tableView reloadData];
            });
        }
    }];
    
    return headerView;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (self.planArray.count == 0) {
//        return 1;
//    }
    return self.planArray.count;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
#pragma mark - 删除
    //此处是iOS8.0以后UITableViewRowAction、Style是划出的标签颜色等状态的定义，可自行定义
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        //title可自已定义
        NSLog(@"点击删除");
        // 1.创建弹框控制器, UIAlertControllerStyleAlert这个样式代表弹框显示在屏幕中央
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"友情提示", nil) message:NSLocalizedString(@"确认删除运动计划？", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        // 2.添加取消按钮，block中存放点击了“取消”按钮要执行的操作
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"点击了确定按钮");
            [SVProgressHUD show];
            YJ_PlanModel *plan = [[YJ_PlanModel alloc] init];
            plan = self.planArray[indexPath.row];
            //删除数据
            __weak typeof(self) weakSelf = self;
            [weakSelf.viewModel deletePlanWithPlanId:plan.planId  withSuccessBlock:^(id response) {
                //移除数据
                [weakSelf.planArray removeAllObjects];
                //再次请求
                [weakSelf handlerGetPlanCellData];
            } withFailureBlock:^(NSError *error) {
                [SVProgressHUD dismiss];
                [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
            }];
        }];
        
        // 3.将“取消”和“确定”按钮加入到弹框控制器中
        [alertVc addAction:cancle];
        [alertVc addAction:confirm];
        
        // 4.控制器 展示弹框控件，完成时不做操作
        [self presentViewController:alertVc animated:YES completion:nil];
    }];
    
    deleteRoWAction.backgroundColor = [UIColor redColor];;
    return @[deleteRoWAction];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    cell.backgroundColor = BGColor;
    
    YJ_PlanModel *plan = self.planArray[indexPath.row];

    if (self.planArray.count == 0) {
        [self drawEmptyCellUI:cell];
    }else {
        [self drawCellUI:cell withPlan:plan];
    }

    return cell;
}

- (void)drawEmptyCellUI:(UITableViewCell *)cell {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = 30;
    view.layer.masksToBounds = YES;
    //设置边框及边框颜色
    view.layer.borderWidth = 2;
    view.layer.borderColor = BGColor.CGColor;
    [cell.contentView addSubview:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.left.offset(5);
        make.right.offset(-5);
        make.bottom.offset(-5);
    }];
    
    UIImageView *imgViewAddPlan = [[UIImageView alloc] init];
    [imgViewAddPlan setImage:[UIImage imageNamed:@"img_plan_add"]];
    imgViewAddPlan.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureAfter = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhotoAction:)];
    [imgViewAddPlan addGestureRecognizer:tapGestureAfter];
    [view addSubview:imgViewAddPlan];
    
    [imgViewAddPlan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.offset(0);
        make.width.offset(110);
        make.height.offset(90);

    }];
    
    UILabel *labAdd = [[UILabel alloc] init];
    labAdd.text = @"添加运动计划";
    labAdd.font = [UIFont systemFontOfSize:14];
    labAdd.textColor = [UIColor grayColor];
    labAdd.textAlignment = NSTextAlignmentCenter;
    [view addSubview:labAdd];
    
    [labAdd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgViewAddPlan.mas_bottom).offset(0);
        make.left.offset(50);
        make.right.offset(-50);
    }];
}

- (void)tapPhotoAction:(UITapGestureRecognizer *)tap {
    if([[YJ_APIManager sharedInstance] isLoggedIn]) {
        YJ_AddPlanViewController *APVC = [[YJ_AddPlanViewController alloc] init];
        APVC.callback = ^{
            [self.navigationController popViewControllerAnimated:YES];
            [self handlerGetPlanCellData];
        };
        [self.navigationController pushViewController:APVC animated:nil];
    }else {
        UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
        YJ_LoginViewController *loginVC = [mainSB instantiateViewControllerWithIdentifier:@"LoginPage"];
        UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:navc animated:YES completion:nil];
        loginVC.callback = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:nil];
                if([[YJ_APIManager sharedInstance] isLoggedIn])
                {
                    YJ_AddPlanViewController *APVC = [[YJ_AddPlanViewController alloc] init];
                    APVC.callback = ^{
                        [self.navigationController popViewControllerAnimated:YES];
                        [self handlerGetPlanCellData];
                    };
                    [self.navigationController pushViewController:APVC animated:nil];                }
            });
        };
    }
}

- (void)drawCellUI:(UITableViewCell *)cell withPlan:(YJ_PlanModel *)plan {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = 30;
    view.layer.masksToBounds = YES;
    //设置边框及边框颜色
    view.layer.borderWidth = 2;
    view.layer.borderColor = BGColor.CGColor;
    [cell.contentView addSubview:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.left.offset(5);
        make.right.offset(-5);
        make.bottom.offset(-5);
    }];
    
    self.labTimeType = [[UILabel alloc] init];
    self.labTimeType.backgroundColor = ThemeColor;
    self.labTimeType.text = [plan.playTimeType substringToIndex:1];
    self.labTimeType.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:20];
    self.labTimeType.textColor = [UIColor whiteColor];
    self.labTimeType.layer.cornerRadius = 26;
    self.labTimeType.layer.masksToBounds = YES;
    self.labTimeType.textAlignment = NSTextAlignmentCenter;
    [view addSubview:self.labTimeType];
    
    [self.labTimeType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.offset(25);
        make.height.width.offset(52);
    }];
    
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_home_time"]];
    [view addSubview:titleImageView];
    
    [titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(25);
        make.left.equalTo(self.labTimeType.mas_right).offset(25);
        make.width.height.offset(22);
    }];
    
    self.labTitle = [[UILabel alloc] init];
    self.labTitle.text = plan.playTimeType;
    self.labTitle.textColor = [UIColor blackColor];
    self.labTitle.font = [UIFont systemFontOfSize:17];
    [view addSubview:self.labTitle];
    
    [self.labTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(25);
        make.left.equalTo(titleImageView.mas_right).offset(5);
        make.width.offset(40);
    }];

    self.labTitleTime = [[UILabel alloc] init];
    self.labTitleTime.text = plan.playTime;
    self.labTitleTime.textColor = SubThemeColor;
    self.labTitleTime.textAlignment = NSTextAlignmentRight;
    self.labTitleTime.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    [view addSubview:self.labTitleTime];
    
    [self.labTitleTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(25);
        make.right.offset(-40);
        make.width.offset(150);
    }];
    
    self.labPlayType = [[UILabel alloc] init];
    self.labPlayType.text = [NSString stringWithFormat:@"运动类型：%@", plan.playType];//6个字
    self.labPlayType.textColor = [UIColor jk_colorWithHexString:@"#ff7200"];
    self.labPlayType.font = [UIFont systemFontOfSize:16];
    [view addSubview:self.labPlayType];
    
    [self.labPlayType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.labTitle.mas_bottom).offset(15);
        make.left.equalTo(self.labTimeType.mas_right).offset(25);
        //make.width.offset(140);
    }];
    
    /*UILabel *labPlaytime = [[UILabel alloc] init];
    labPlaytime.text = @"";
    labPlaytime.textColor = SubThemeColor;
    labPlaytime.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    labPlaytime.textAlignment = NSTextAlignmentRight;
    [view addSubview:labPlaytime];
    
    [labPlaytime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.labTitle.mas_bottom).offset(15);
        make.right.offset(-40);
        make.left.equalTo(labPlayType.mas_right).offset(0);
    }];*/
    
    UIImageView *eatImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_home_time"]];
    [view addSubview:eatImageView];
    
    [eatImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.labPlayType.mas_bottom).offset(20);
        make.left.equalTo(self.labTimeType.mas_right).offset(25);
        make.width.height.offset(22);
    }];
    
    UILabel *labEatPlan = [[UILabel alloc] init];
    labEatPlan.text = @"饮食计划：";//15字以内
    labEatPlan.textColor = [UIColor blackColor];
    labEatPlan.font = [UIFont systemFontOfSize:17];
    [view addSubview:labEatPlan];
    
    [labEatPlan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.labPlayType.mas_bottom).offset(20);
        make.left.equalTo(eatImageView.mas_right).offset(5);
        make.right.offset(100);
    }];
    
    self.labEat = [[UILabel alloc] init];
    self.labEat.text = plan.eatPlan;//15字以内 
    self.labEat.numberOfLines = 2;
    self.labEat.textColor = [UIColor jk_colorWithHexString:@"#ff7200"];
    self.labEat.font = [UIFont systemFontOfSize:16];
    [view addSubview:self.labEat];
    
    [self.labEat mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labEatPlan.mas_bottom).offset(15);
        make.left.equalTo(self.labTimeType.mas_right).offset(25);
        make.right.offset(100);
    }];
}

//选择cell跳转
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.planArray.count == 0) {
//        return 125;
//    }
    return 180;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
