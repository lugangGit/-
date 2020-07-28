//
//  YJ_AddDynameicViewController.m
//  YueJian
//
//  Created by Garry on 2018/7/15.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_AddDynameicViewController.h"
#import "TZImagePickerController.h"
#import "YJ_CollectionViewCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "YJ_AddDynameicViewModel.h"

@interface YJ_AddDynameicViewController ()<TZImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AMapLocationManagerDelegate>
{
    CGFloat _itemWH;
    CGFloat _margin;
    CGFloat _collectionY;
    CGFloat _collectionH;
}
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *labPlaceHolder;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *photosArray;
@property (nonatomic, strong) NSMutableArray *assestArray;
@property (nonatomic, strong) NSMutableArray *imageBase64Array;
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (nonatomic, strong) UIView *locationView;
@property (nonatomic, strong) UIButton *btnLocation;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, strong) YJ_AddDynameicViewModel *viewModel;
@property (nonatomic, strong) AMapLocationManager *locationManager;

@end

@implementation YJ_AddDynameicViewController
//懒加载
- (NSMutableArray *)photosArray{
    if (!_photosArray) {
        self.photosArray = [NSMutableArray array];
    }
    return _photosArray;
}

- (NSMutableArray *)assestArray{
    if (!_assestArray) {
        self.assestArray = [NSMutableArray array];
    }
    return _assestArray;
}

- (NSMutableArray *)imageBase64Array {
    if (!_imageBase64Array) {
        self.imageBase64Array = [NSMutableArray array];
    }
    return _imageBase64Array;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        _margin = 4;
        _itemWH = (self.view.bounds.size.width - 2 * _margin - 4) / 3 - _margin;
        UICollectionViewFlowLayout *flowLayOut = [[UICollectionViewFlowLayout alloc] init];
        flowLayOut.itemSize = CGSizeMake((SCREEN_WIDTH - 60)/ 3, (SCREEN_WIDTH - 60)/ 3);
        flowLayOut.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 164, SCREEN_WIDTH-20, SCREEN_WIDTH/3) collectionViewLayout:flowLayOut];
        
        _collectionView.backgroundColor = [UIColor whiteColor];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = NO;
    }
    return _collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.viewModel = [[YJ_AddDynameicViewModel alloc] init];
    self.city = @"";
    
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
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(clickBack)];
    [backItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Helvetica" size:16.0], NSFontAttributeName, [UIColor grayColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = backItem;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStyleDone target:self action:@selector(addDynamic)];
    [rightItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Helvetica" size:16.0], NSFontAttributeName, ThemeColor, NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark - 绘制UI
- (void)drawUI {
    self.textView = [[UITextView alloc] init];
    // textView.backgroundColor = ThemeColor;
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.returnKeyType = UIReturnKeyDefault;
    self.textView.keyboardType = UIKeyboardTypeDefault;
    [self.view addSubview:self.textView];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(84);
        make.left.offset(15);
        make.right.offset(-15);
        make.height.offset(40);
    }];
    
    self.labPlaceHolder = [[UILabel alloc] init];
    self.labPlaceHolder.textAlignment = NSTextAlignmentLeft;
    self.labPlaceHolder.font = [UIFont systemFontOfSize:16];
    self.labPlaceHolder.text = @"这一刻的想法...";
    self.labPlaceHolder.textColor = [UIColor grayColor];
    [self.view addSubview:self.labPlaceHolder];
    
    [self.labPlaceHolder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(92);
        make.left.offset(22);
        make.right.offset(-20);
        make.height.offset(25);
    }];
    
    _collectionY = 164;
    [self.collectionView registerClass:[YJ_CollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:self.collectionView];
    
    self.locationView = [[UIView alloc] init];
    self.locationView.layer.cornerRadius = 15;
    self.locationView.layer.masksToBounds = YES;
    //设置边框及边框颜色
    self.locationView.layer.borderWidth = 1.2;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){238/255, 238/255, 238/255, 0.1});
    self.locationView.layer.borderColor = colorref;
    [self.view addSubview:self.locationView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_dynamic_location"]];
    [self.locationView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.height.width.offset(22);
        make.left.offset(10);
    }];
    
    self.btnLocation = [[UIButton alloc] initWithFrame:CGRectMake(35, 5, 83, 20)];
    self.btnLocation.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.btnLocation setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.btnLocation setTitle:@"显示位置" forState:UIControlStateNormal];
    self.btnLocation.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.btnLocation.titleLabel  sizeToFit];
    self.btnLocation.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.locationView addSubview:self.btnLocation];
    
    self.locationView.frame = CGRectMake(20, 164+SCREEN_WIDTH/3+60, self.btnLocation.frame.size.width + 20 +10, 30);
    
    [[self.btnLocation rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self singlelocationManager];
    }];
}

- (void)checkLocalPhoto{
    TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    [imagePicker setSortAscendingByModificationDate:NO];
    imagePicker.delegate = self;
    imagePicker.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    imagePicker.selectedAssets = _assestArray;
    imagePicker.allowPickingVideo = NO;
    imagePicker.showSelectedIndex = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    NSLog(@"photos%@, assets%@", photos, assets);
    self.photosArray = [NSMutableArray arrayWithArray:photos];
    self.assestArray = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    [_collectionView reloadData];
    //转成base64
    [self imageBase64EncodedData:_photosArray];
}

#pragma mark - collectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == _photosArray.count) {
        //[self checkLocalPhoto];
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册中选择", nil];
        [sheet showInView:self.view];
    }else{
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:_assestArray selectedPhotos:_photosArray index:indexPath.row];
        imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            _photosArray = [NSMutableArray arrayWithArray:photos];
            _assestArray = [NSMutableArray arrayWithArray:assets];
            _isSelectOriginalPhoto = isSelectOriginalPhoto;
            [_collectionView reloadData];
            _collectionView.contentSize = CGSizeMake(0, ((_photosArray.count + 2) / 3 ) * (_margin + _itemWH));
        }];
        [self presentViewController:imagePickerVc animated:YES completion:nil];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    //return _photosArray.count !=  9? _photosArray.count+1 : _photosArray.count;
    return _photosArray.count+1;
}

//每个单元格的大小size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == (_photosArray.count+1)) {
        return CGSizeMake(0, 0);

    }
    return CGSizeMake((SCREEN_WIDTH - 60)/3, (SCREEN_WIDTH - 60)/3);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    YJ_CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    if (indexPath.row == _photosArray.count) {
        cell.imagev.image = [UIImage imageNamed:@"img_dynamic_AlbumAdd"];
        cell.deleteButton.hidden = YES;
        
    }else{
        cell.imagev.image = _photosArray[indexPath.row];
        cell.deleteButton.hidden = NO;
    }
    cell.deleteButton.tag = 100 + indexPath.row;
    [cell.deleteButton addTarget:self action:@selector(deletePhotos:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)deletePhotos:(UIButton *)sender{
    [_photosArray removeObjectAtIndex:sender.tag - 100];
    [_assestArray removeObjectAtIndex:sender.tag - 100];
    NSLog(@"deleteArray:%@", _photosArray);
    if (self.photosArray.count <= 2) {
        self.collectionView.frame = CGRectMake(10, _collectionY, SCREEN_WIDTH-20, SCREEN_WIDTH/3);
        _collectionH = SCREEN_WIDTH/3;
        self.locationView.frame = CGRectMake(20, 164+_collectionH+60, 110, 30);
    }else if (3 <= self.photosArray.count && self.photosArray.count <= 5) {
        self.collectionView.frame = CGRectMake(10, _collectionY, SCREEN_WIDTH-20, SCREEN_WIDTH/3*2);
        _collectionH = SCREEN_WIDTH/3*2;
        self.locationView.frame = CGRectMake(20, 164+_collectionH+60, 110, 30);
    }else if(self.photosArray.count > 5) {
        self.collectionView.frame = CGRectMake(10, _collectionY, SCREEN_WIDTH-20, SCREEN_WIDTH-20);
        _collectionH = SCREEN_WIDTH;
        self.locationView.frame = CGRectMake(20, 164+_collectionH+60, 110, 30);
    }
    [_collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag-100 inSection:0];
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [_collectionView reloadData];
    }];
    [self imageBase64EncodedData:_photosArray];
}

- (void)imageBase64EncodedData:(NSArray *)imageArray {
    [self.imageBase64Array removeAllObjects];
    for (int i = 0; i < imageArray.count; i++) {
        //1、image转data
        NSData *data = UIImageJPEGRepresentation(imageArray[i], 0.7);
        //2、Base64加密
        NSData *encodeData = [data base64EncodedDataWithOptions:0];
        //3、Data转字符串
        NSString *decodeStr = [[NSString alloc] initWithData:encodeData encoding:NSUTF8StringEncoding];
        [self.imageBase64Array addObject:decodeStr];;
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length == 0 )
    {
        self.labPlaceHolder.text = @"这一刻的想法...";
    }else {
        self.labPlaceHolder.text = @"";
    }
    CGSize constraintSize;
    constraintSize.width = textView.frame.size.width - 16;
    constraintSize.height = 150;
    CGSize sizeFrame = [textView.text sizeWithFont:textView.font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    if (sizeFrame.height < 20) {
        textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, 40);
    }else {
        textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, sizeFrame.height + 10);
    }
    if (sizeFrame.height > 45) {
        //self.button.frame = CGRectMake(20, 104 + sizeFrame.height, 50, 50);
        _collectionY = 104 + sizeFrame.height;
        if (_collectionH == 0) {
            _collectionH = SCREEN_WIDTH/3;
        }
        self.collectionView.frame = CGRectMake(10, 104 + sizeFrame.height, SCREEN_WIDTH-20, _collectionH);
    }
}

#pragma mark - UIImagePickerController
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
        //UIImagePickerControllerOriginalImage = "<UIImage: 0x6000002b7460> size {4288, 2848} orientation 0 scale 1.000000";
    NSLog(@"photosArrayCount:%ld", self.photosArray.count);
    if (2 < self.photosArray.count && self.photosArray.count <= 5) {
        self.collectionView.frame = CGRectMake(10, _collectionY, SCREEN_WIDTH-20, SCREEN_WIDTH/3*2);
        _collectionH = SCREEN_WIDTH/3*2;
        self.locationView.frame = CGRectMake(20, 164+_collectionH+60, 110, 30);
    }else if(self.photosArray.count > 5) {
        self.collectionView.frame = CGRectMake(10, _collectionY, SCREEN_WIDTH-20, SCREEN_WIDTH-20);
        _collectionH = SCREEN_WIDTH;
        self.locationView.frame = CGRectMake(20, 164+_collectionH+60, 110, 30);
    }

    NSLog(@"infos:%@====photos:%@====assets:%@", infos, photos, assets);
}

- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && iOS7Later) {
        // 无相机权限 做一个友好的提示
        if (iOS8Later) {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
            [alert show];
        } else {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        if (iOS7Later) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self takePhoto];
                    });
                }
            }];
        } else {
            [self takePhoto];
        }
        // 拍照之前还需要检查相册权限
    } else if ([TZImageManager authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        if (iOS8Later) {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
            [alert show];
        } else {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
    } else if ([TZImageManager authorizationStatus] == 0) { // 未请求过相册权限
        [[TZImageManager manager] requestAuthorizationWithCompletion:^{
            [self takePhoto];
        }];
    } else {
        [self pushImagePickerController];
    }
}

// 调用相机
- (void)pushImagePickerController {
    // 提前定位
    /*__weak typeof(self) weakSelf = self;
    [[TZLocationManager manager] startLocationWithSuccessBlock:^(NSArray<CLLocation *> *locations) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.location = [locations firstObject];
    } failureBlock:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.location = nil;
    }];*/
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVc.sourceType = sourceType;
        NSMutableArray *mediaTypes = [NSMutableArray array];
        //[mediaTypes addObject:(NSString *)kUTTypeMovie];
        [mediaTypes addObject:(NSString *)kUTTypeImage];
        if (mediaTypes.count) {
            _imagePickerVc.mediaTypes = mediaTypes;
        }
        if (iOS8Later) {
            _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:_imagePickerVc animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { // take photo / 去拍照
        [self takePhoto];
    } else if (buttonIndex == 1) {
        [self checkLocalPhoto];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        if (iOS8Later) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}

#pragma mark - 定位请求
- (void)singlelocationManager
{
    [SVProgressHUD show];
    self.locationManager = [[AMapLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    //带逆地理信息的一次定位（返回坐标和地址信息）
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    //[self.locationManager setAllowsBackgroundLocationUpdates:YES];
    [self.locationManager setLocationTimeout:10];
    [self.locationManager setReGeocodeTimeout:5];
    //带逆地理（返回坐标和地址信息）。将下面代码中的 YES改成 NO，则不会返回地址信息。
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (error)
        {
            [SVProgressHUD dismiss];
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            [SVProgressHUD showInfoWithStatus:@"获取位置失败"];
            self.city = @"";
            return;
            
        }
        NSLog(@"location:%@", location);
        if (regeocode)
        {
            [SVProgressHUD dismiss];
            //获取位置信息
            NSLog(@"location:%@", regeocode.city);
            self.city = regeocode.city;
            [self.btnLocation setTitle:regeocode.city forState:UIControlStateNormal];
        }
    }];
}

#pragma mark - 发布
- (void)addDynamic {
    if (![self.textView.text isEqual:@""]) {
        [SVProgressHUD show];
        __weak typeof(self) weakSelf = self;
        [weakSelf.viewModel postDynameicWithContent:weakSelf.textView.text withImage:weakSelf.imageBase64Array withCity:weakSelf.city withSuccessBlock:^(id response) {
            [SVProgressHUD dismiss];
            weakSelf.callback();
        } withFailureBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
        }];
    }else {
        [SVProgressHUD showInfoWithStatus: @"请填写发布内容"];
    }
}

#pragma mark - 返回
- (void)clickBack {
    [SVProgressHUD dismiss];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
