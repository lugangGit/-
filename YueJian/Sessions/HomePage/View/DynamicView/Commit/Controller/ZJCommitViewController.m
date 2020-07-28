//
//  ZJCommitViewController.m
//  ZJUIKit
//
//  Created by dzj on 2018/1/23.
//  Copyright © 2018年 kapokcloud. All rights reserved.
//

#import "ZJCommitViewController.h"
#import "ZJCommitFrame.h"
#import "ZJCommitCell.h"
#import "ZJCommit.h"
#import "MJRefresh.h"
#import "ZJImgLeftBtn.h"
#import "YJ_AddDynameicViewController.h"
#import "YJ_AddDynameicViewModel.h"
#import "YJ_LoginViewController.h"

@interface ZJCommitViewController ()<UITableViewDelegate,UITableViewDataSource,ZJCommitCellDelegate>

@property(nonatomic ,strong) UITableView        *mainTable;
// 数据源
@property(nonatomic ,strong) NSMutableArray     *dataArray;
// 索引
@property(nonatomic ,assign) NSInteger          pageNum;
@property(nonatomic ,assign) NSInteger          dataCount;

@property (nonatomic, strong) YJ_AddDynameicViewModel *viewModel;
@end

@implementation ZJCommitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.viewModel = [[YJ_AddDynameicViewModel alloc] init];
    self.pageNum = 1;
    self.dataCount = 0;
    [self setUpAllView];
    //[self getCommitsData];
    [self handlerLoadData];
    [self setNavigation];
}

#pragma mark - 设置导航栏
- (void)setNavigation {
    //导航栏
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = NSLocalizedString(@"热门动态", nil);
    self.navigationController.navigationBar.tintColor = ThemeColor;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:ThemeColor, NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = backItem;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_nav_camera"] style:UIBarButtonItemStyleDone target:self action:@selector(addDynamic)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark - 发布动态
- (void)addDynamic
{
    if([[YJ_APIManager sharedInstance] isLoggedIn])
    {
        YJ_AddDynameicViewController *AdVC = [[YJ_AddDynameicViewController alloc] init];
        kWeakObject(self)
        AdVC.callback = ^{
            [weakObject dismissViewControllerAnimated:YES completion:nil];
            weakObject.pageNum = 1;
            [weakObject handlerLoadData];
        };
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:AdVC];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else
    {
        NSLog(@"登录后->跳转发布");
        UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
        YJ_LoginViewController *loginVC = [mainSB instantiateViewControllerWithIdentifier:@"LoginPage"];
        UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:navc animated:YES completion:nil];
        loginVC.callback = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:nil];
                if([[YJ_APIManager sharedInstance] isLoggedIn])
                {
                    YJ_AddDynameicViewController *AdVC = [[YJ_AddDynameicViewController alloc] init];
                    kWeakObject(self)
                    AdVC.callback = ^{
                        [weakObject dismissViewControllerAnimated:YES completion:nil];
                        weakObject.pageNum = 1;
                        [weakObject handlerLoadData];
                    };
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:AdVC];
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                }
            });
        };
    }
}

#pragma mark - 返回
- (void)clickBack {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setUpAllView{
    _mainTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    _mainTable.delegate = self;
    _mainTable.dataSource = self;
    _mainTable.backgroundColor = [UIColor whiteColor];
    _mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_mainTable];
    
    kWeakObject(self);
    self.mainTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakObject.pageNum = 1;
        [weakObject handlerLoadData];
    }];
    
    self.mainTable.mj_footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
        weakObject.pageNum += 1;
        [weakObject handlerLoadData];
    }];
}

-(void)handlerLoadData
{
    [SVProgressHUD show];
    kWeakObject(self);
    NSLog(@"firstPageNumber:%ld", (long)self.pageNum);
    [weakObject.viewModel getDynameicDataWithPageNumber:[NSString stringWithFormat:@"%ld", (long)weakObject.pageNum]
                          withSuccessBlock:^(id response) {
                              [SVProgressHUD dismiss];
                              NSArray *array = response[@"data"];
                              NSLog(@"%@", array);
                              NSMutableArray *responseArray= [NSMutableArray array];
                              for (NSDictionary *dic in array) {
                                  ZJCommitFrame *cFrame = [[ZJCommitFrame alloc]init];
                                  cFrame.commit = [ZJCommit commitWithDict:dic];
                                  [responseArray addObject:cFrame];
                              }
                              weakObject.dataArray = [responseArray copy];
                              
                              //上拉加载
                              //weakObject.mainTable.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:weakObject refreshingAction:@selector(setNewsMorePageNumber)];
                              
                              //如果没有数据
                              if (weakObject.dataArray.count == 0) {
                                  //隐藏mj_footer
                                  [weakObject noDataHiddinMjfooder:weakObject.mainTable];
                              }
                              else
                              {
                                  weakObject.mainTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
                              }
                              
                              //刷新数据
                              [weakObject.mainTable reloadData];
                              weakObject.mainTable.separatorStyle = YES;
                              
                              //停止动画
                              [weakObject.mainTable.mj_header endRefreshing];
                              [weakObject.mainTable.mj_footer endRefreshing];
                              
                              //修改底部为:已经全部加载完毕
                              [weakObject setMjfooterState:self.dataArray.count];
                              
                          } withFailureBlock:^(NSError *error) {
                              [SVProgressHUD dismiss];
                              //停止动画
                              [weakObject.mainTable.mj_header endRefreshing];
                              [weakObject.mainTable.mj_footer endRefreshing];
                              
                              [weakObject showStatusWithError:[weakObject returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];

                              //如果没有数据
                              if (self.dataArray.count == 0) {
                                  //隐藏mj_footer
                                  [self noDataHiddinMjfooder:weakObject.mainTable];
                              }
                          }];
}

//修改Mjfooter为:已经全部加载完毕
- (void)setMjfooterState:(NSInteger)arrayCount {
    __weak typeof(self) weakSelf = self;
    NSLog(@"arrayCount:%ld, dataCount:%ld", arrayCount, (unsigned long)weakSelf.dataCount);
    if (arrayCount - weakSelf.dataCount == 10) {
        self.dataCount = arrayCount;
        NSLog(@"dataCount:%ld", (long)self.dataCount);
    }
    else {
        [self.mainTable.mj_footer endRefreshingWithNoMoreData];
    }
}

//隐藏mj_footer
- (void)noDataHiddinMjfooder:(UITableView *)tableView {
    tableView.mj_footer.hidden = YES;
    tableView.backgroundColor = TableViewBGColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //添加tableFooterView
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 120)];
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor whiteColor];
    [footerView addSubview:bgView];
    
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.right.offset(0);
        make.top.offset(10);
        make.height.offset(240);
    }];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_my_noData"]];
    [bgView addSubview:imageView];
    
    //添加约束
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.centerY.offset(0);
    }];
    
    tableView.tableFooterView = footerView;
}

/*- (void)getCommitsData {
    [self.mainTable.mj_header endRefreshing];
    [self.mainTable.mj_footer endRefreshing];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"CommitsData" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSArray *commitsList = [rootDict objectForKey:@"comments_list"];
        NSMutableArray *arrM = [NSMutableArray array];
        
        for (NSDictionary *dictDict in commitsList) {
            ZJCommitFrame *cFrame = [[ZJCommitFrame alloc]init];
            cFrame.commit = [ZJCommit commitWithDict:dictDict];
            [arrM addObject:cFrame];
        }
        self.dataArray = arrM;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainTable reloadData];
        });
    });
}*/

#pragma mark - ZJCommitCellDelegate
// 点赞
- (void)likeBtnClickAction:(ZJImgLeftBtn *)sender{
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [sender setImage:kImageName(@"new_organize_like") forState:UIControlStateNormal];
    }else{
        [sender setImage:kImageName(@"new_organize_dislike") forState:UIControlStateNormal];
    }
}
// 差评
- (void)disLikeBtnClickAction:(ZJImgLeftBtn *)sender{
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [sender setImage:kImageName(@"new_unlike_sele") forState:UIControlStateNormal];
    }else{
        [sender setImage:kImageName(@"new_unlike_unsele") forState:UIControlStateNormal];
    }
}

// 删除评论
-(void)deleteBtnClickAction:(UIButton *)sender{
    NSLog(@"删除%ld", (long)sender.tag);
    [SVProgressHUD show];
    ZJCommitFrame *cFrame = self.dataArray[sender.tag];
    kWeakObject(self);
    [weakObject.viewModel deleteDynameicWithDynameicId:[NSString stringWithFormat:@"%@", cFrame.commit.dynameicId] withSuccessBlock:^(id response) {
        [SVProgressHUD dismiss];
        weakObject.pageNum = 1;
        [weakObject handlerLoadData];
    } withFailureBlock:^(NSError *error) {
        [SVProgressHUD dismiss];
        [weakObject showStatusWithError:[weakObject returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    _mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    ZJCommitCell *cell = [ZJCommitCell cellWithTableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.selfVc = self;
    ZJCommitFrame *cFrame = self.dataArray[indexPath.row];
    cell.commitFrame = cFrame;
    [cell setChildBtnTag:indexPath.row];
    cell.delegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZJCommitFrame *cFrame = self.dataArray[indexPath.row];
    return cFrame.cellHeight;
}

-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    //[self.dataArray removeAllObjects];
    self.dataArray = nil;
    NSLog(@"销毁ZJCommitViewController");
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
