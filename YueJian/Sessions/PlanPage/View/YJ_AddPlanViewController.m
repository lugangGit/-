//
//  YJ_AddPlanViewController.m
//  YueJian
//
//  Created by Garry on 2018/8/1.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_AddPlanViewController.h"
#import "YJ_AddPlanViewModel.h"

#define MAX_STARWORDS_LENGTH 15

@interface YJ_AddPlanViewController ()<UITextViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UITextField *tfStartDate;
@property (nonatomic, strong) UITextField *tfEndDate;
@property (nonatomic, strong) UITextField *tfPlayType;
@property (nonatomic, strong) UITextView *textEatContent;
@property (nonatomic, strong) UILabel *labTextCount;
@property (nonatomic, strong) YJ_AddPlanViewModel *viewModel;

@end

@implementation YJ_AddPlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.viewModel = [[YJ_AddPlanViewModel alloc] init];

    //设置导航栏
    [self setNavigation];
    
    //绘制视图
    [self drawUI];
}

#pragma mark - 设置导航栏
- (void)setNavigation {
    //导航栏
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = NSLocalizedString(@"新建计划", nil);
    self.navigationController.navigationBar.tintColor = ThemeColor;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:ThemeColor, NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - 绘制视图
- (void)drawUI {
    UITableView *tableView = [[UITableView alloc] init];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.offset(0);
    }];
    
    //UIDatePicker
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    self.datePicker.minuteInterval = 30;
    self.datePicker.backgroundColor = [UIColor whiteColor];
    [self.datePicker addTarget:self action:@selector(chooseDate:) forControlEvents:UIControlEventValueChanged];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignActive)];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

-(void)resignActive
{
    [self.datePicker removeFromSuperview];
    [self.view endEditing:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

//然后在设置cell的高度(controller)
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 650;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [self drawCellUI:cell];
    
    return cell;
}

- (void)drawCellUI:(UITableViewCell *)cell {
    UILabel *labPlay = [[UILabel alloc] init];
    labPlay.font = [UIFont systemFontOfSize:18];
    labPlay.textColor = [UIColor blackColor];
    labPlay.text = @"运动时间";
    [cell addSubview:labPlay];
    
    UILabel *labSubPlay = [[UILabel alloc] init];
    labSubPlay.font = [UIFont systemFontOfSize:12];
    labSubPlay.textColor = [UIColor grayColor];
    labSubPlay.text = @"每天计划的开始与结束时间";
    [cell addSubview:labSubPlay];
    
    [labPlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(30);
        make.left.offset(45);
        make.width.offset(100);
        make.height.offset(20);
    }];
    
    [labSubPlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labPlay.mas_bottom).offset(10);
        make.left.offset(45);
        make.width.offset(250);
        make.height.offset(15);
    }];
    
    UILabel *labMid = [[UILabel alloc] init];
    labMid.text = @"~";
    labMid.textAlignment = NSTextAlignmentCenter;
    labMid.textColor = ThemeColor;
    labMid.font = [UIFont systemFontOfSize:25];
    [cell addSubview:labMid];
    
    [labMid mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labSubPlay.mas_bottom).offset(15);
        make.centerX.offset(0);
        make.height.width.offset(25);
    }];

    //输入框
    self.tfStartDate = [[UITextField alloc] init];
    self.tfStartDate.tag = 0;
    self.tfStartDate.delegate = self;
    self.tfStartDate.textAlignment = NSTextAlignmentCenter;
    self.tfStartDate.placeholder = NSLocalizedString(@"Start",nil);
    //修改占位文字的颜色
    [self.tfStartDate setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.tfStartDate.font = [UIFont systemFontOfSize:16];
    self.tfStartDate.textColor = [UIColor blackColor];
    [cell.contentView addSubview:self.tfStartDate];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = ThemeColor;
    [cell addSubview:lineView];
    
    [self.tfStartDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labSubPlay.mas_bottom).offset(15);
        make.left.offset(45);
        make.right.equalTo(labMid.mas_left).offset(-10);
        make.height.offset(25);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tfStartDate.mas_bottom).offset(0);
        make.left.offset(45);
        make.right.equalTo(labMid.mas_left).offset(-10);
        make.height.offset(2);
    }];
    
    //输入框
    self.tfEndDate = [[UITextField alloc] init];
    self.tfEndDate.tag = 1;
    self.tfEndDate.delegate = self;
    self.tfEndDate.textAlignment = NSTextAlignmentCenter;
    self.tfEndDate.placeholder = NSLocalizedString(@"End",nil);
    //修改占位文字的颜色
    [self.tfEndDate setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.tfEndDate.font = [UIFont systemFontOfSize:16];
    self.tfEndDate.textColor = [UIColor blackColor];
    [cell addSubview:self.tfEndDate];
    
    UIView *lineEndView = [[UIView alloc] init];
    lineEndView.backgroundColor = ThemeColor;
    [cell addSubview:lineEndView];

    [self.tfEndDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labSubPlay.mas_bottom).offset(15);
        make.right.offset(-45);
        make.left.equalTo(labMid.mas_right).offset(10);
        make.height.offset(25);
    }];
    
    [lineEndView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tfStartDate.mas_bottom).offset(0);
        make.right.offset(-45);
        make.left.equalTo(labMid.mas_right).offset(10);
        make.height.offset(2);
    }];
    
    UILabel *labPlayType = [[UILabel alloc] init];
    labPlayType.font = [UIFont systemFontOfSize:18];
    labPlayType.textColor = [UIColor blackColor];
    labPlayType.text = @"运动类型";
    [cell addSubview:labPlayType];
    
    UILabel *labSubPlayType = [[UILabel alloc] init];
    labSubPlayType.font = [UIFont systemFontOfSize:12];
    labSubPlayType.textColor = [UIColor grayColor];
    labSubPlayType.text = @"记录每天计划的运动";
    [cell addSubview:labSubPlayType];
    
    [labPlayType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineEndView.mas_bottom).offset(30);
        make.left.offset(45);
        make.width.offset(100);
        make.height.offset(20);
    }];
    
    [labSubPlayType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labPlayType.mas_bottom).offset(10);
        make.left.offset(45);
        make.width.offset(250);
        make.height.offset(15);
    }];
    
    //输入框
    self.tfPlayType = [[UITextField alloc] init];
    self.tfPlayType.textAlignment = NSTextAlignmentLeft;
    self.tfPlayType.placeholder = NSLocalizedString(@"如:游泳",nil);
    //修改占位文字的颜色
    [self.tfPlayType setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.tfPlayType.font = [UIFont systemFontOfSize:16];
    self.tfPlayType.textColor = [UIColor blackColor];
    [self.tfPlayType addTarget:self action:@selector(textFieldNickEditChanged:) forControlEvents:UIControlEventEditingChanged];
    self.tfPlayType.clearButtonMode = UITextFieldViewModeWhileEditing;
    [cell addSubview:self.tfPlayType];
    
    UIView *lineTypeView = [[UIView alloc] init];
    lineTypeView.backgroundColor = ThemeColor;
    [cell addSubview:lineTypeView];
    
    [self.tfPlayType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labSubPlayType.mas_bottom).offset(15);
        make.right.offset(-60);
        make.left.offset(60);
        make.height.offset(25);
    }];
    
    [lineTypeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tfPlayType.mas_bottom).offset(0);
        make.right.offset(-45);
        make.left.offset(45);
        make.height.offset(2);
    }];
    
    UILabel *labEat = [[UILabel alloc] init];
    labEat.font = [UIFont systemFontOfSize:18];
    labEat.textColor = [UIColor blackColor];
    labEat.text = @"饮食计划";
    [cell addSubview:labEat];
    
    UILabel *labSubEat = [[UILabel alloc] init];
    labSubEat.font = [UIFont systemFontOfSize:12];
    labSubEat.textColor = [UIColor grayColor];
    labSubEat.text = @"合理搭配饮食有助于健康";
    [cell addSubview:labSubEat];
    
    [labEat mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineTypeView.mas_bottom).offset(30);
        make.left.offset(45);
        make.width.offset(100);
        make.height.offset(20);
    }];
    
    [labSubEat mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labEat.mas_bottom).offset(10);
        make.left.offset(45);
        make.width.offset(250);
        make.height.offset(15);
    }];
    
    self.textEatContent = [[UITextView alloc]init];
    self.textEatContent.delegate = self;
    self.textEatContent.textColor = [UIColor blackColor];
    self.textEatContent.font = [UIFont systemFontOfSize:16];
    self.textEatContent.layer.borderColor = BGColor.CGColor;
    self.textEatContent.layer.borderWidth = 1.0;
    self.textEatContent.layer.cornerRadius = 10;
    self.textEatContent.backgroundColor = BGColor;
    [cell addSubview:self.textEatContent];
    
    [self.textEatContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labSubEat.mas_bottom).offset(15);
        make.left.offset(45);
        make.right.offset(-45);
        make.height.offset(80);
    }];
    
    self.labTextCount = [[UILabel alloc] init];
    self.labTextCount.font = [UIFont systemFontOfSize:14];
    self.labTextCount.textColor = [UIColor grayColor];
    self.labTextCount.text = @"0/15";
    self.labTextCount.textAlignment = NSTextAlignmentRight;
    [self.textEatContent addSubview:self.labTextCount];
    
    [self.labTextCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.right.offset(-10);
        make.top.offset(55);
        make.height.offset(15);
    }];
    
    //确定按钮
    UIButton *btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnConfirm setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [btnConfirm setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateHighlighted];
    //[btnConfirm setBackgroundColor:ThemeColor];
    btnConfirm.layer.cornerRadius = 20;
    [cell addSubview:btnConfirm];
    
    //添加约束
    [btnConfirm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textEatContent.mas_bottom).with.offset(30);
        make.height.offset(40);
        make.left.offset(60);
        make.right.offset(-60);
    }];
    
    RAC(self.viewModel, playType) = self.tfPlayType.rac_textSignal;
    
    btnConfirm.rac_command = self.viewModel.ConfirmCommand;
    
    RAC(btnConfirm, backgroundColor) = [RACObserve(btnConfirm, enabled) map:^id(NSNumber *value) {
        return value.boolValue ? ThemeColor : ButtonTitleNormal;
    }];
    
    __weak typeof(self) weakSelf = self;
    [[btnConfirm rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [SVProgressHUD show];
        [weakSelf.viewModel addPlanWithSuccessBlock:^(id response) {
            self.callback();
        } WithFailureBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
        }];
    }];
}

#pragma mark - 选择日期
- (void)chooseDate:(UIDatePicker *)sender {
    NSDate *selectedDate = sender.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    NSString *dateString = [formatter stringFromDate:selectedDate];
    if (self.datePicker.tag == 0) {
        self.tfStartDate.text = dateString;
        self.viewModel.startTime = dateString;
    }else {
        self.tfEndDate.text = dateString;
        self.viewModel.endTime = dateString;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 0) {
        self.datePicker.tag = 0;
        //UIDatePicker以及在当前视图上就不用再显示
        if (self.datePicker.superview == nil) {
            //close all keyboard or data picker visible currently
            [self.view endEditing:YES];
            //此处将Y坐标设在最底下，为了一会动画的展示
            self.datePicker.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 200);
            [self.view addSubview:self.datePicker];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3f];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            self.datePicker.frame = CGRectMake(0, SCREEN_HEIGHT-200, SCREEN_WIDTH, 200);
            [UIView commitAnimations];
        }
    }else if(textField.tag == 1){
        self.datePicker.tag = 1;
        //UIDatePicker以及在当前视图上就不用再显示
        if (self.datePicker.superview == nil) {
            //close all keyboard or data picker visible currently
            [self.view endEditing:YES];
            //此处将Y坐标设在最底下，为了一会动画的展示
            self.datePicker.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 200);
            [self.view addSubview:self.datePicker];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3f];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            self.datePicker.frame = CGRectMake(0, SCREEN_HEIGHT-200, SCREEN_WIDTH, 200);
            [UIView commitAnimations];
        }
    }
    
    //获取当前时间日期
//    if (_isFirstChoose) {
//        NSDate *date=[NSDate date];
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        formatter.dateFormat = @"yyyy-MM-dd";
//        NSString *dateStr;
//        dateStr=[formatter stringFromDate:date];
//        NSLog(@"%@",dateStr);
//        self.tfFinishDate.text = dateStr;
//        _isFirstChoose = NO;
//    }
    

    return NO;
}

#pragma mark - UITextFieldNotifiaction
//限制输入字数
- (void)textFieldNickEditChanged:(UITextField*)textField
{
    NSString *toBeString = self.tfPlayType.text;
    NSString *lang = self.textInputMode.primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"])//简体中文输入，包括简体拼音，五笔，手写
    {
        UITextRange *selectedRange = [self.tfPlayType markedTextRange];
        //获取高亮部分
        if (!selectedRange) {
            if (toBeString.length > 8) {
                textField.text = [toBeString substringToIndex:8];
            }
        }
        //有高亮字符串暂不限制
        else
        {
        }
    }
    //中文以外输入法，直接统计
    else
    {
        if (toBeString.length > 8)
        {
            textField.text = [toBeString substringToIndex:8];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.length == 1 && string.length == 0) {
        return YES;
    }
    else if (textField == self.tfPlayType) {
        if (self.tfPlayType.text.length >= 8) {
            return NO;
        }
    }
    
    return YES;
}

#pragma - UITextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.datePicker removeFromSuperview];
}

- (void)textViewDidChange:(UITextView *)textView
{
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
    self.labTextCount.text = [lengthNum.stringValue stringByAppendingString:@"/15"];
    self.viewModel.eatPlan = textView.text;
}

#pragma mark - 返回
- (void)clickBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 处理手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSLog(@"%@", touch.view);
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] || [NSStringFromClass([touch.view class]) isEqualToString:@"UITableView"]) {
        [self.datePicker removeFromSuperview];
        [self.view endEditing:YES];
        return NO;
    }

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
