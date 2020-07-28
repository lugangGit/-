//
//  YJ_MyTargetViewController.m
//  YueJian
//
//  Created by Garry on 2018/4/27.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_MyTargetViewController.h"
#import "YJ_MytargetViewModel.h"

@interface YJ_MyTargetViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) UIButton *targetBtn1;
@property (nonatomic, strong) UIButton *targetBtn2;
@property (nonatomic, strong) UIButton *targetBtn3;
@property (nonatomic, strong) UIButton *targetBtn4;
@property (nonatomic, strong) UIButton *targetBtn5;
@property (nonatomic, strong) UIButton *targetBtn6;
@property (nonatomic, strong) UITextField *tfOther;
@property (nonatomic, strong) UILabel *labMeter;
@property (nonatomic, strong) NSString *meter;
@property (nonatomic, strong) YJ_MytargetViewModel *viewModel;
@property (nonatomic, strong) UIButton *btnConfirm;
@end

@implementation YJ_MyTargetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //导航栏
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = NSLocalizedString(@"运动目标", nil);
    self.navigationController.navigationBar.tintColor = ThemeColor;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:ThemeColor, NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    //绘制视图
    [self drawUI];
    self.view.backgroundColor = [UIColor whiteColor];
    self.viewModel = [[YJ_MytargetViewModel alloc] init];
    self.meter = @"3000";
}

- (void)drawUI {
    self.targetBtn1 = [[UIButton alloc] init];
    self.targetBtn1.tag = 1;
    self.targetBtn1.backgroundColor = ThemeColor;
    self.targetBtn1.titleLabel.font = [UIFont systemFontOfSize:14];
    //边框宽度
    [self.targetBtn1.layer setMasksToBounds:YES];
    [self.targetBtn1.layer setCornerRadius:10.0];
    [self.targetBtn1.layer setBorderWidth:1.0];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){238/255, 238/255, 238/255, 0.1});
    [self.targetBtn1.layer setBorderColor:colorref];
    [self.targetBtn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.targetBtn1 setTitle:@"3000步" forState:UIControlStateNormal];
    [self.targetBtn1 addTarget:self action:@selector(clickTarget:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.targetBtn1];
    
    self.targetBtn2 = [[UIButton alloc] init];
    self.targetBtn2.tag = 2;
    //targetBtn.backgroundColor = [UIColor redColor];
    self.targetBtn2.titleLabel.font = [UIFont systemFontOfSize:14];
    //边框宽度
    [self.targetBtn2.layer setMasksToBounds:YES];
    [self.targetBtn2.layer setCornerRadius:10.0];
    [self.targetBtn2.layer setBorderWidth:1.0];
    [self.targetBtn2.layer setBorderColor:colorref];
    [self.targetBtn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.targetBtn2 setTitle:@"5000步" forState:UIControlStateNormal];
    [self.targetBtn2 addTarget:self action:@selector(clickTarget:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.targetBtn2];
    
    self.targetBtn3 = [[UIButton alloc] init];
    self.targetBtn3.tag = 3;
    //targetBtn.backgroundColor = [UIColor redColor];
    self.targetBtn3.titleLabel.font = [UIFont systemFontOfSize:14];
    //边框宽度
    [self.targetBtn3.layer setMasksToBounds:YES];
    [self.targetBtn3.layer setCornerRadius:10.0];
    [self.targetBtn3.layer setBorderWidth:1.0];
    [self.targetBtn3.layer setBorderColor:colorref];
    [self.targetBtn3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.targetBtn3 setTitle:@"8000步" forState:UIControlStateNormal];
    [self.targetBtn3 addTarget:self action:@selector(clickTarget:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.targetBtn3];
    
    [self.targetBtn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(200);
        make.right.equalTo(self.targetBtn2.mas_left).offset(-30);
        make.width.offset(80);
        make.height.offset(40);
    }];
    
    [self.targetBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(200);
        make.centerX.offset(0);
        make.width.offset(80);
        make.height.offset(40);
    }];
    
    [self.targetBtn3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(200);
        make.left.equalTo(self.targetBtn2.mas_right).offset(30);
        make.width.offset(80);
        make.height.offset(40);
    }];
    
    self.targetBtn4 = [[UIButton alloc] init];
    self.targetBtn4.tag = 4;
    //targetBtn.backgroundColor = [UIColor redColor];
    self.targetBtn4.titleLabel.font = [UIFont systemFontOfSize:14];
    //边框宽度
    [self.targetBtn4.layer setMasksToBounds:YES];
    [self.targetBtn4.layer setCornerRadius:10.0];
    [self.targetBtn4.layer setBorderWidth:1.0];
    [self.targetBtn4.layer setBorderColor:colorref];
    [self.targetBtn4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.targetBtn4 setTitle:@"10000步" forState:UIControlStateNormal];
    [self.targetBtn4 addTarget:self action:@selector(clickTarget:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.targetBtn4];
    
    self.targetBtn5 = [[UIButton alloc] init];
    self.targetBtn5.tag = 5;
    //targetBtn.backgroundColor = [UIColor redColor];
    self.targetBtn5.titleLabel.font = [UIFont systemFontOfSize:14];
    //边框宽度
    [self.targetBtn5.layer setMasksToBounds:YES];
    [self.targetBtn5.layer setCornerRadius:10.0];
    [self.targetBtn5.layer setBorderWidth:1.0];
    [self.targetBtn5.layer setBorderColor:colorref];
    [self.targetBtn5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.targetBtn5 setTitle:@"20000步" forState:UIControlStateNormal];
    [self.targetBtn5 addTarget:self action:@selector(clickTarget:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.targetBtn5];
    
    self.targetBtn6 = [[UIButton alloc] init];
    self.targetBtn6.tag = 6;
    //targetBtn.backgroundColor = [UIColor redColor];
    self.targetBtn6.titleLabel.font = [UIFont systemFontOfSize:14];
    //边框宽度
    [self.targetBtn6.layer setMasksToBounds:YES];
    [self.targetBtn6.layer setCornerRadius:10.0];
    [self.targetBtn6.layer setBorderWidth:1.0];
    [self.targetBtn6.layer setBorderColor:colorref];
    [self.targetBtn6 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.targetBtn6 setTitle:@"其他" forState:UIControlStateNormal];
    [self.targetBtn6 addTarget:self action:@selector(clickTarget:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.targetBtn6];
    
    self.tfOther = [[UITextField alloc] init];
    self.tfOther.delegate = self;
    self.tfOther.hidden = YES;
    self.tfOther.font = [UIFont systemFontOfSize:14];
    self.tfOther.textColor = [UIColor blackColor];
    self.tfOther.textAlignment = NSTextAlignmentCenter;
    self.tfOther.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:self.tfOther];
    
    self.labMeter = [[UILabel alloc] init];
    self.labMeter.hidden = YES;
    self.labMeter.text = @"步";
    self.labMeter.font = [UIFont systemFontOfSize:14];
    self.labMeter.textColor = [UIColor blackColor];
    [self.view addSubview:self.labMeter];
    
    [self.targetBtn4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.targetBtn2.mas_bottom).offset(30);
        make.right.equalTo(self.targetBtn5.mas_left).offset(-30);
        make.width.offset(80);
        make.height.offset(40);
    }];
    
    [self.targetBtn5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.targetBtn2.mas_bottom).offset(30);
        make.centerX.offset(0);
        make.width.offset(80);
        make.height.offset(40);
    }];
    
    [self.targetBtn6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.targetBtn2.mas_bottom).offset(30);
        make.left.equalTo(self.targetBtn5.mas_right).offset(30);
        make.width.offset(80);
        make.height.offset(40);
    }];
    
    [self.tfOther mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.targetBtn2.mas_bottom).offset(40);
        make.left.equalTo(self.targetBtn5.mas_right).offset(35);
        make.width.offset(50);
        make.height.offset(20);
    }];
    
    [self.labMeter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.targetBtn2.mas_bottom).offset(40);
        make.left.equalTo(self.tfOther.mas_right).offset(2);
        make.width.offset(15);
        make.height.offset(20);
    }];
    
    // 确定按钮
    self.btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnConfirm setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [self.btnConfirm setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateHighlighted];
    //[self.btnConfirm setBackgroundColor:ThemeColor];
    self.btnConfirm.layer.cornerRadius = 20;
    [self.view addSubview:self.btnConfirm];
    
    //添加约束
    [self.btnConfirm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.targetBtn5.mas_bottom).with.offset(50);
        make.height.offset(40);
        make.left.offset(60);
        make.right.offset(-60);
    }];
    
    RAC(self.btnConfirm, backgroundColor) = [RACObserve(self.btnConfirm, enabled) map:^id(NSNumber *value) {
        return value.boolValue ? ThemeColor : ButtonTitleNormal;
    }];
    
    __weak typeof(self) weakSelf = self;
    [[self.btnConfirm rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [weakSelf.view endEditing:YES];
        weakSelf.callback(weakSelf.meter);
        weakSelf.viewModel.step = weakSelf.meter;
        [SVProgressHUD show];
        [weakSelf.viewModel targetStepWithSuccessBlock:^(id response) {
            [SVProgressHUD dismiss];
            //返回首页
            self.callback(weakSelf.meter);
        } WithFailureBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
        }];
    }];
}

#pragma  mark - UITextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * currentString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.meter = currentString;
    self.viewModel.step = self.meter;//步数
    self.btnConfirm.rac_command = self.viewModel.confirmCommand;
    return YES;
}

- (void)clickTarget:(UIButton *)sender {
    self.tfOther.hidden = YES;
    self.labMeter.hidden = YES;
    [self.view endEditing:YES];
    [self.targetBtn6 setTitle:@"其他" forState:UIControlStateNormal];
    switch (sender.tag) {
        case 1:
        {
            self.meter = @"3000";
            self.targetBtn1.backgroundColor = ThemeColor;
            self.targetBtn2.backgroundColor = [UIColor whiteColor];
            self.targetBtn3.backgroundColor = [UIColor whiteColor];
            self.targetBtn4.backgroundColor = [UIColor whiteColor];
            self.targetBtn5.backgroundColor = [UIColor whiteColor];
            self.targetBtn6.backgroundColor = [UIColor whiteColor];
        }
            break;
        case 2:
        {
            self.meter = @"5000";
            self.targetBtn2.backgroundColor = ThemeColor;
            self.targetBtn1.backgroundColor = [UIColor whiteColor];
            self.targetBtn3.backgroundColor = [UIColor whiteColor];
            self.targetBtn4.backgroundColor = [UIColor whiteColor];
            self.targetBtn5.backgroundColor = [UIColor whiteColor];
            self.targetBtn6.backgroundColor = [UIColor whiteColor];
        }
            break;
        case 3:
        {
            self.meter = @"8000";
            self.targetBtn3.backgroundColor = ThemeColor;
            self.targetBtn1.backgroundColor = [UIColor whiteColor];
            self.targetBtn2.backgroundColor = [UIColor whiteColor];
            self.targetBtn4.backgroundColor = [UIColor whiteColor];
            self.targetBtn5.backgroundColor = [UIColor whiteColor];
            self.targetBtn6.backgroundColor = [UIColor whiteColor];
        }
            break;
        case 4:
        {
            self.meter = @"10000";
            self.targetBtn4.backgroundColor = ThemeColor;
            self.targetBtn1.backgroundColor = [UIColor whiteColor];
            self.targetBtn2.backgroundColor = [UIColor whiteColor];
            self.targetBtn3.backgroundColor = [UIColor whiteColor];
            self.targetBtn5.backgroundColor = [UIColor whiteColor];
            self.targetBtn6.backgroundColor = [UIColor whiteColor];
        }
            break;
        case 5:
        {
            self.meter = @"20000";
            self.targetBtn5.backgroundColor = ThemeColor;
            self.targetBtn1.backgroundColor = [UIColor whiteColor];
            self.targetBtn2.backgroundColor = [UIColor whiteColor];
            self.targetBtn3.backgroundColor = [UIColor whiteColor];
            self.targetBtn4.backgroundColor = [UIColor whiteColor];
            self.targetBtn6.backgroundColor = [UIColor whiteColor];
            [self.targetBtn6 setTitle:@"其他" forState:UIControlStateNormal];
        }
            break;
        case 6:
        {
            self.meter = @"0";
            self.tfOther.hidden = NO;
            self.labMeter.hidden = NO;
            [self.tfOther becomeFirstResponder];
            self.targetBtn6.backgroundColor = ThemeColor;
            self.targetBtn1.backgroundColor = [UIColor whiteColor];
            self.targetBtn2.backgroundColor = [UIColor whiteColor];
            self.targetBtn3.backgroundColor = [UIColor whiteColor];
            self.targetBtn4.backgroundColor = [UIColor whiteColor];
            self.targetBtn5.backgroundColor = [UIColor whiteColor];
            [self.targetBtn6 setTitle:@"" forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)clickBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
