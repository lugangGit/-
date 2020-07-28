//
//  YJ_FeedbackViewController.m
//  YueJian
//
//  Created by Garry on 2018/8/2.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_FeedbackViewController.h"
#import "YJ_FeedbackViewModel.h"

#define MAX_STARWORDS_LENGTH 100

@interface YJ_FeedbackViewController ()<UITableViewDelegate,UITableViewDataSource, UITextViewDelegate>
@property (nonatomic, strong) UILabel *labPlaceHolder;
@property (nonatomic, strong) UITextView *textPlanContent;
@property (nonatomic, strong) UILabel *labTextCount;
@property (nonatomic, strong) YJ_FeedbackViewModel *viewModel;

@end

@implementation YJ_FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BGColor;
    self.viewModel = [[YJ_FeedbackViewModel alloc] init];
    //设置导航栏
    [self setNavigation];
    //绘制视图
    [self drawUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - 设置导航栏
- (void)setNavigation {
    //导航栏
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = NSLocalizedString(@"意见反馈", nil);
    self.navigationController.navigationBar.tintColor = ThemeColor;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:ThemeColor, NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - 绘制视图
- (void)drawUI {
    UITableView *tableView = [[UITableView alloc] init];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = BGColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.offset(0);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.backgroundColor = BGColor;
    [self drawCellUI:cell];
    
    return cell;
}

//然后在设置cell的高度(controller)
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 500;
}

- (void)drawCellUI:(UITableViewCell *)cell {
    /*UILabel *labPlan = [[UILabel alloc] init];
    labPlan.font = [UIFont systemFontOfSize:18];
    labPlan.textColor = [UIColor blackColor];
    labPlan.text = @"意见与建议";
    [cell addSubview:labPlan];
    
    UILabel *labSubPlan = [[UILabel alloc] init];
    labSubPlan.font = [UIFont systemFontOfSize:12];
    labSubPlan.textColor = [UIColor grayColor];
    labSubPlan.text = @"帮助我们完善乐健";
    [cell addSubview:labSubPlan];*/
    
    self.textPlanContent = [[UITextView alloc]init];
    self.textPlanContent.delegate = self;
    self.textPlanContent.textColor = [UIColor blackColor];
    self.textPlanContent.font = [UIFont systemFontOfSize:14];
    //self.textPlanContent.layer.borderColor = BGColor.CGColor;
    //self.textPlanContent.layer.borderWidth = 1.0;
    //self.textPlanContent.layer.cornerRadius = 10;
    self.textPlanContent.backgroundColor = [UIColor whiteColor];
    [cell addSubview:self.textPlanContent];
    
    self.labPlaceHolder = [[UILabel alloc] init];
    self.labPlaceHolder.textColor = [UIColor grayColor];
    self.labPlaceHolder.text = @"意见与建议...";
    self.labPlaceHolder.font = [UIFont systemFontOfSize:14];
    self.labPlaceHolder.preferredMaxLayoutWidth = SCREEN_WIDTH - 32.0;
    [self.textPlanContent addSubview:self.labPlaceHolder];
    
    self.labTextCount = [[UILabel alloc] init];
    self.labTextCount.font = [UIFont systemFontOfSize:14];
    self.labTextCount.textColor = [UIColor grayColor];
    self.labTextCount.text = @"0/100";
    self.labTextCount.textAlignment = NSTextAlignmentRight;
    [cell addSubview:self.labTextCount];
    
    //确定按钮
    UIButton *btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnConfirm setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [btnConfirm setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateHighlighted];
    [btnConfirm setBackgroundColor:ThemeColor];
    btnConfirm.layer.cornerRadius = 20;
    [cell addSubview:btnConfirm];
    
    
    /*[labPlan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(30);
        make.left.offset(45);
        make.width.offset(100);
        make.height.offset(20);
    }];
    
    [labSubPlan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labPlan.mas_bottom).offset(10);
        make.left.offset(45);
        make.width.offset(200);
        make.height.offset(15);
    }];*/
    
    [self.textPlanContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(8);
        make.left.offset(0);
        make.right.offset(0);
        make.height.offset(140);
    }];
    
    [self.labPlaceHolder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(5);
        make.top.offset(8);
        make.right.offset(-4);
    }];
    
    [self.labTextCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.right.offset(-10);
        make.top.offset(130);
        make.height.offset(15);
    }];
   
    //添加约束
    [btnConfirm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textPlanContent.mas_bottom).with.offset(30);
        make.height.offset(40);
        make.left.offset(60);
        make.right.offset(-60);
    }];
    
    //RAC(self.viewModel, feedBack) = self.textPlanContent.rac_textSignal;
    
    btnConfirm.rac_command = self.viewModel.ConfirmCommand;
    
    RAC(btnConfirm, backgroundColor) = [RACObserve(btnConfirm, enabled) map:^id(NSNumber *value) {
        return value.boolValue ? ThemeColor : ButtonTitleNormal;
    }];
    
    __weak typeof(self) weakSelf = self;
    [[btnConfirm rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [SVProgressHUD show];
        [weakSelf.viewModel postFeedbackWithSuccessBlock:^(id response) {
            [SVProgressHUD showSuccessWithStatus:@"反馈成功"];
            self.callback();
        } WithFailureBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
        }];
    }];
}

#pragma mark - 返回
- (void)clickBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma - UITextView Delegate
- (void)textViewDidChange:(UITextView *)textView
{
    //统计字数
    NSInteger length = textView.text.length;
    if (length > 0) {
        self.labPlaceHolder.hidden = YES;
    }
    else
    {
        self.labPlaceHolder.hidden = NO;
    }
    
    //限制最大字数
    NSString *toBeString = textView.text;
    NSArray *current = [UITextInputMode activeInputModes];
    UITextInputMode *currentInputMode = [current firstObject];
    NSString *lang = [currentInputMode primaryLanguage]; // 键盘输入模式
    
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        //获取高亮部分
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position)
        {
            if (toBeString.length > MAX_STARWORDS_LENGTH)
            {
                NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:MAX_STARWORDS_LENGTH];
                if (rangeIndex.length == 1)
                {
                    textView.text = [toBeString substringToIndex:MAX_STARWORDS_LENGTH];
                }
                else
                {
                    NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, MAX_STARWORDS_LENGTH)];
                    textView.text = [toBeString substringWithRange:rangeRange];
                }
            }
            
        }
        
    }
    else
    {   // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > MAX_STARWORDS_LENGTH){
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:MAX_STARWORDS_LENGTH];
            if (rangeIndex.length == 1){
                textView.text = [toBeString substringToIndex:MAX_STARWORDS_LENGTH];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, MAX_STARWORDS_LENGTH)];
                textView.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
    NSNumber *lengthNum = [[NSNumber alloc] initWithInteger:textView.text.length];
    self.labTextCount.text = [lengthNum.stringValue stringByAppendingString:@"/100"];
    self.viewModel.feedBack = textView.text;
}

#pragma mark - 处理手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
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
