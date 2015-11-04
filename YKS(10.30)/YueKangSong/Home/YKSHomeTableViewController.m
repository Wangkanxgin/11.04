//
//  YKSHomeTableViewController.m
//  YueKangSong
//
//  Created by gongliang on 15/5/12.
//  Copyright (c) 2015年 YKS. All rights reserved.
//
#import "UIAlertView+Block.h"
#import "YKSHomeTableViewController.h"
#import "GZBaseRequest.h"
#import "UIViewController+Common.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "YKSSpecialView.h"
#import "YKSSpecial.h"
#import <ImagePlayerView/ImagePlayerView.h>
#import "YKSSubSpecialListTableViewController.h"
#import "YKSAppDelegate.h"
#import <INTULocationManager/INTULocationManager.h>
#import "YKSSelectAddressView.h"
#import "YKSAddAddressVC.h"
#import "YKSQRCodeViewController.h"
#import "YKSDrugListViewController.h"
#import "YKSUserModel.h"
#import "YKSHomeListCell.h"
#import "YKSWebViewController.h"
#import "YKSAddAddressVC.h"
#import "YKSDrugDetailViewController.h"
#import "YKSMyAddressViewcontroller.h"
#import "YKSHomeTableViewCell1.h"
#import "YKSDrugCategoryListVC.h"
#import "YKSDrugListViewController.h"

@interface YKSHomeTableViewController () <ImagePlayerViewDelegate,UIAlertViewDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) ImagePlayerView *imagePlayview;

@property (assign, nonatomic) BOOL isShowAddressView;

@property (copy, nonatomic) NSArray *datas;
@property (strong, nonatomic) NSArray *imageURLStrings;
@property (strong, nonatomic) NSDictionary *myAddressInfo;

@property (strong, nonatomic) NSDictionary *info;
@property (assign, nonatomic) BOOL isCreat;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;

@property(nonatomic,strong)NSArray *drugDatas;

@property (weak, nonatomic) IBOutlet UIButton *addressBtn;

@end

@implementation YKSHomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.navigationController.navigationBarHidden = NO;

    NSArray *familyNames = [UIFont familyNames];
    for( NSString *familyName in familyNames ){
        printf( "Family: %s \n", [familyName UTF8String] );
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
        for( NSString *fontName in fontNames ){
            printf( "\tFont: %s \n", [fontName UTF8String] );
        }
    }

    
    
    self.navigationItem.title = @"";
    
    
    _addressButton.frame = CGRectMake(0, 0, SCREEN_WIDTH - 10, 25);
    
    //    _addressButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    //    _addressButton.titleLabel.minimumScaleFactor = 8/[UIFont labelFontSize];
    
    //    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 141, 25)];
    //    logoImageView.image = [UIImage imageNamed:@"logo"];
    //    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:logoImageView];
    //    self.navigationItem.leftBarButtonItem = leftBar;
    
    self.tableView.tableHeaderView = [self tableviewHeaderView];
    
    
    [self setAddressBtnFrame];
    
    
    [self requestDrugCategoryList];
    
   

}

//请求药品类别列表数据

-(void)requestDrugCategoryList{

    [GZBaseRequest drugCategoryListCallback:^(id responseObject, NSError *error) {
        if (error) {
            [self showToastMessage:@"网络加载失败"];
            return ;
        }
        if (ServerSuccess(responseObject)) {
            
            
            _drugDatas = responseObject[@"data"][@"categorylist"];
            
        } else {
            [self showToastMessage:responseObject[@"msg"]];
        }
        
    }];

    
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBar.hidden=NO;
    
    [self startSingleLocationRequest];
    
    [super viewWillAppear:animated];
    if (!_datas) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kHomeDatas"]) {
            _datas = [[NSUserDefaults standardUserDefaults] objectForKey:@"kHomeDatas"];
            [self.tableView reloadData];
        }
        [GZBaseRequest specialListCallback:^(id responseObject, NSError *error) {
            //        NSLog(@"responseObject = %@", responseObject);
            if (ServerSuccess(responseObject)) {
                _datas = responseObject[@"data"][@"list"];
                [self.tableView reloadData];
                [[NSUserDefaults standardUserDefaults] setObject:_datas forKey:@"kHomeDatas"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                [self showToastMessage:responseObject[@"msg"]];
            }
        }];
    }
    if (!_imageURLStrings) {
        
        [GZBaseRequest bannerListByMobilephone:@""
                                      callback:^(id responseObject, NSError *error) {
                                          if (error) {
                                              [self showToastMessage:@"网络加载失败"];
                                              return ;
                                          }
                                          if (ServerSuccess(responseObject)) {
                                              _imageURLStrings = responseObject[@"data"][@"data"];
                                              _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH*_imageURLStrings.count, 0);
                                              _pageControl.pageIndicatorTintColor= [UIColor colorWithRed:50.0/255 green:143.0/255 blue:250.0/255 alpha:1];
                                              _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
                                              _pageControl.numberOfPages = _imageURLStrings.count;
                                              _pageControl.currentPage = 0;
                                              for (int i = 0; i<_imageURLStrings.count; i++) {
                                                  UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(i*SCREEN_WIDTH, 0, SCREEN_WIDTH, _scrollView.bounds.size.height)];
                                                  [iv sd_setImageWithURL:_imageURLStrings[i][@"imgurl"]placeholderImage:[UIImage imageNamed:@"defatul320"]];
                                                  [_scrollView addSubview:iv];
                                              }
                                              
                                              
                                              
                                              //                                              [_imagePlayview reloadData];
                                          } else {
                                              [self showToastMessage:responseObject[@"msg"]];
                                          }
                                      }];
    }
    NSLog(@"will");
    
    
    
}




//为什么没执行就蹦了
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    
    
    
    
    
    
}

-(void)setAddressBtnFrame{

    NSString *address=_addressBtn.titleLabel.text;
    
    
    CGSize constraintSize = CGSizeMake(320, MAXFLOAT);
    
    // Creates a new font instance with the current font size
    UIFont *font = self.addressBtn.titleLabel.font;
    
    CGRect textRect = [address boundingRectWithSize:constraintSize options:0 attributes:@{NSFontAttributeName:font} context:nil];
    
    [_addressBtn setImageEdgeInsets:UIEdgeInsetsMake(0, textRect.size.width+20, 0, 0)];
}


//定位成功之后再设置地址按钮标题
-(void)setAddressBtnTitle{
    
   
    NSDictionary *dic=[UIViewController selectedMyLocation];
    
    NSString *str=dic[@"formatted_address"];
    if (str) {
        
        [self.addressBtn setTitle:[NSString stringWithFormat:@"配送至:%@",str] forState:UIControlStateNormal];
    }
    
   

    if ([YKSUserModel isLogin]) {
        
        NSDictionary *info = [YKSUserModel shareInstance].currentSelectAddress;
        
        
        if (!IS_EMPTY_STRING(info[@"community"]) ) {
            
             NSString *tempString = [NSString stringWithFormat:@"%@", info[@"community"] ? info[@"community"] : @""];
            
            if (info[@"sendable"] && ![info[@"sendable"] boolValue])
            {
                NSString *title = [NSString stringWithFormat:@"配送至:%@(暂不支持配送)", tempString];
                [self.addressButton setTitle:title
                                    forState:UIControlStateNormal];
            }
            else
            {
                [self.addressButton setTitle:[NSString stringWithFormat:@"配送至:%@",tempString]
                                    forState:UIControlStateNormal];
            }
        }
        
        else{
            if (str) {
                
                [self.addressBtn setTitle:[NSString stringWithFormat:@"配送至:%@",str] forState:UIControlStateNormal];
            }
            else{
               
            }

        
        }


      
        
//        if (_isShowAddressView) {
//            [self showAddressView];
//        }
        //首页显示,如果有标志,我们直接显示地址列表1=没标志    _addressInfos = [UIViewController selectedAddressUnArchiver];
//        if ([UIViewController selectedAddressButtonUnArchiver] == 1) {
//
//            [UIViewController selectedAddressButtonArchiver:1000];
//
//            [self showAddressView];
//        }
        
        
        
//        if ([YKSUserModel shareInstance].currentSelectAddress) {
//            
//            
//            NSDictionary *info = [YKSUserModel shareInstance].currentSelectAddress;
//            
//            NSString *tempString = [NSString stringWithFormat:@"%@", info[@"community"] ? info[@"community"] : @""];
//            
//            if (info[@"sendable"] && ![info[@"sendable"] boolValue])
//            {
//                NSString *title = [NSString stringWithFormat:@"%@(暂不支持配送)", tempString];
//                [self.addressButton setTitle:title
//                                    forState:UIControlStateNormal];
//            }
//            else
//            {
//                [self.addressButton setTitle:[NSString stringWithFormat:@"配送至:%@",tempString]
//                                    forState:UIControlStateNormal];
//            }
//        }
        
    }
    
    [self setAddressBtnFrame];
}



-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger offset = scrollView.contentOffset.x/SCREEN_WIDTH;
    _pageControl.currentPage = offset;
}



#pragma mark - custom
- (UIView *)tableviewHeaderView {
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH / 320 * kCycleHeight)];
    UIView *view = [[UIView alloc]initWithFrame:_scrollView.bounds];
    [view addSubview:_scrollView];
    _pageControl = [[UIPageControl alloc]init];
    [view addSubview:_pageControl];
    _pageControl.center = CGPointMake(SCREEN_WIDTH/2, _scrollView.bounds.size.height-10);
    
    _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:50.0/255 green:143.0/255 blue:250.0/255 alpha:1];

    
//    _pageControl.center = CGPointMake(SCREEN_WIDTH/2, _scrollView.bounds.size.height-50);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.bounces = NO;
    _scrollView.pagingEnabled = YES;
    return view;
    
    
    
//    _imagePlayview = [[ImagePlayerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH / 320 * kCycleHeight)];
//    _imagePlayview.imagePlayerViewDelegate = self;
//    _imagePlayview.scrollInterval = 99999;
//    _imagePlayview.pageControlPosition = ICPageControlPosition_BottomRight;
//    return _imagePlayview;
}

/**
 *  获取ios设备当前位置（GPS 定位）
 */
- (void)startSingleLocationRequest {
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyNeighborhood
                                       timeout:10.0f
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                             
                                             NSString *latLongString = [[NSString alloc] initWithFormat:@"%f,%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
                                             
                                             if ([YKSUserModel shareInstance].lat == 0) {
                                                 [YKSUserModel shareInstance].lat = currentLocation.coordinate.latitude;
                                                 [YKSUserModel shareInstance].lng = currentLocation.coordinate.longitude;
                                                 
                                    
                                             }
                                             
                                             if ([YKSUserModel isLogin]) {
                                                 [GZBaseRequest locationUploadLat:currentLocation.coordinate.latitude
                                                                              lng:currentLocation.coordinate.longitude
                                                                         callback:^(id responseObject, NSError *error) {
                                                                             
                                                                         }];
                                             }

                                             [[GZHTTPClient shareClient] GET:BaiduMapGeocoderApi
                                                                  parameters:@{@"location": latLongString,
                                                                               @"coordtype": @"wgs84ll",
                                                                               @"ak": BaiduMapAK,
                                                                               @"output": @"json"}
                                              
                                                                     success:^(NSURLSessionDataTask *task, id responseObject) {
                                                                         
                                                                         if (responseObject && [responseObject[@"status"] integerValue] == 0) {
                                                                             NSDictionary *dic = responseObject[@"result"];
                                                                             _myAddressInfo = dic;
                                                                            
                                                                             [UIViewController selectedCityArchiver:dic[@"addressComponent"]];
                                                                             
                                                                             
                                                                             
                                                                             [UIViewController setMyLocation:dic];
                                                                             
                                                                             [self.addressButton setTitle:[NSString stringWithFormat:@"配送至:%@",dic[@"formatted_address"] ]forState:UIControlStateNormal];
                                                               
                                                                             
                                                                             if ([YKSUserModel shareInstance].currentSelectAddress) {
                                                                                 NSDictionary *info = [YKSUserModel shareInstance].currentSelectAddress;
                                                                                 
                                                                                 
                                                                                 NSString *tempString = [NSString stringWithFormat:@"%@", info[@"community"] ? info[@"community"] : @""];
                                                                                 
                                                                                 if (info[@"sendable"] && ![info[@"sendable"] boolValue])
                                                                                 {
                                                                                     NSString *title = [NSString stringWithFormat:@"%@(暂不支持配送)", tempString];
                                                                                     [self.addressButton setTitle:title
                                                                                                         forState:UIControlStateNormal];
                                                                                 }
                                                                                 else
                                                                                 {
                                                                                     [self.addressButton setTitle:[NSString stringWithFormat:@"配送至:%@",tempString]
                                                                                                         forState:UIControlStateNormal];
                                                                                 }
                                                                             }
                                                                         }
                                                                         NSLog(@"responseObject %@", responseObject);
                                                                    
                                                                      [self setAddressBtnTitle];
                                                                     }
                                                                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                                         NSLog(@"error = %@", error);
                                                                     }];
                                             
                                            
                                         }];
}

// 注意这里的：“province”,目前加入了 city_name  这里不能只是11。
- (NSDictionary *)currentAddressInfo {
    
    NSString *district = _myAddressInfo[@"addressComponent"][@"district"];
    NSString *street = _myAddressInfo[@"addressComponent"][@"street"];
    NSString *street_number = _myAddressInfo[@"addressComponent"][@"street_number"];
    NSString *formatted_address = _myAddressInfo[@"formatted_address"];
    
    
   NSString  *a=(NSString *)_myAddressInfo[@"sendable"];
    if (IS_EMPTY_STRING(a)) {
        return @{@"province": @"11",
                 @"district": district ? district : @"",
                 @"street":  street ? street : @"",
                 @"street_number":  street_number ? street_number : @"",
                 @"express_username": @"我的位置",
                 @"express_mobilephone": @"",
                 @"express_detail_address":  formatted_address? formatted_address : @""
                 };
    }
    
    return @{@"province": @"11",
             @"district": district ? district : @"",
             @"street":  street ? street : @"",
             @"street_number":  street_number ? street_number : @"",
             @"express_username": @"我的位置",
             @"express_mobilephone": @"",
             @"express_detail_address":  formatted_address? formatted_address : @"",
             @"sendable":a
             };
}



- (void)gotoAddressVC:(NSDictionary *)addressInfo {
    _isShowAddressView = YES;
    if (![YKSUserModel isLogin]) {
        [YKSTools login:self];
        return;
    }
    
    UIStoryboard *mainBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YKSAddAddressVC *vc = [mainBoard instantiateViewControllerWithIdentifier:@"YKSAddAddressVC"];
    vc.addressInfo = [addressInfo mutableCopy];
    vc.isCurrentLocation = YES;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark alertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        __weak id bself = self;
        YKSSelectAddressView *selectAddressView = nil;
         {
           //新添
             NSDictionary *info = self.info;
             BOOL isCreate = self.isCreat;
                                                                   
//                                                                   if (![[[YKSUserModel shareInstance]currentSelectAddress][@"id"]isEqualToString:info[@"id"]]) {
//                                                                       UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"修改地址？" message:@"确认修改地址将清空购物车" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//                                                                       [alert show];
//                                                                       
//                                                                       
//                                                                   }
                                                                   if (info) {
                                                                       if (info[@"community_lat_lng"]) {
                                                                           NSArray *array = [info[@"community_lat_lng"] componentsSeparatedByString:@","];
                                                                           [YKSUserModel shareInstance].lat = [[array firstObject] floatValue];
                                                                           [YKSUserModel shareInstance].lng = [[array lastObject] floatValue];
                                                                       }
                                                                       if (![YKSUserModel shareInstance].currentSelectAddress) {
                                                                           [YKSUserModel shareInstance].currentSelectAddress = info;
                                                                           //                                                                       NSLog(@"当前经纬度 = %f %f \n %@", [YKSUserModel shareInstance].lat,
                                                                           //                                                                             [YKSUserModel shareInstance].lng,
                                                                           //                                                                             [YKSUserModel shareInstance].currentSelectAddress);
                                                                       }
                                                                       
                                                                   }
                                                                   if (isCreate) {
                                                                       [bself gotoAddressVC:[UIViewController selectedMyLocation]];
                                                                       
                                                                       return;
                                                                   } else {
                                                                       _isShowAddressView = NO;
                                                                       [YKSUserModel shareInstance].currentSelectAddress = info;
                                                                       //这里就是了,拿到地址,删除旧地址
                                                                       
                                                                       [UIViewController deleteFile];           [UIViewController selectedAddressArchiver:info];
                                                                       
                                                                       NSString *tempString = [NSString stringWithFormat:@"%@", info[@"community"] ? info[@"community"] : @""];
                                                                       if (info[@"sendable"] && ![info[@"sendable"] boolValue]) {
                                                                           NSString *title = [NSString stringWithFormat:@"%@(暂不支持配送)", tempString];
                                                                           [self.addressButton setTitle:title
                                                                                               forState:UIControlStateNormal];
                                                                       } else {
                                                                           [self.addressButton setTitle:[NSString stringWithFormat:@"配送至:%@",tempString]
                                                                                               forState:UIControlStateNormal];
                                                                       }
                                                                   }
                                                               };
        //    [selectAddressView reloadData];
        selectAddressView.removeViewCallBack = ^{
            _isShowAddressView = NO;
        };
        [GZBaseRequest addressListCallback:^(id responseObject, NSError *error) {
            if (ServerSuccess(responseObject)) {
                NSDictionary *dic = responseObject[@"data"];
                if ([dic isKindOfClass:[NSDictionary class]] && dic[@"addresslist"]) {
                    selectAddressView.datas = [dic[@"addresslist"] mutableCopy];
                    [YKSUserModel shareInstance].addressLists = selectAddressView.datas;
                    if (!selectAddressView.datas) {
                        selectAddressView.datas = [NSMutableArray array];
                    }
                    [selectAddressView.datas insertObject:[self currentAddressInfo] atIndex:0];
                    [selectAddressView reloadData];
                }
            }
        }];

        [self.navigationController popToRootViewControllerAnimated:YES];
        

    }
    
    
}

//显示地址
- (void)showAddressView {
    
   // 不允许
    if (![YKSUserModel isLogin]) {
        [YKSTools login:self];
        return ;
    }
    __weak id bself = self;
    YKSSelectAddressView *selectAddressView = nil;
    
    YKSMyAddressViewcontroller *myVC=[[YKSMyAddressViewcontroller alloc]init];
    
    myVC.hidesBottomBarWhenPushed=YES;
    
    [self.navigationController pushViewController:myVC animated:YES];
    
    selectAddressView = [YKSSelectAddressView showAddressViewToView:myVC.view
                                                              datas:@[[self currentAddressInfo]]
                                                           callback:^(NSDictionary *info, BOOL isCreate) {
                                                            //新添
                                                               self.info = info;
                                                               self.isCreat = isCreate;
                                                               
                                                               [UIViewController selectedAddressArchiver:info];
                                                               
                                                               if (![[[YKSUserModel shareInstance]currentSelectAddress][@"id"]isEqualToString:info[@"id"]]) {
                                                                   UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"修改地址？" message:@"确认修改地址将清空购物车" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                                                                   [alert show];
                                                                   return ;
//                                                              [alert callBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                                                                  if (buttonIndex == 1) {
//                                                                      
//                                                                  }
//                                                              }];
                                                               }
                                                               if (info) {
                                                                   if (info[@"community_lat_lng"]) {
                                                                       NSArray *array = [info[@"community_lat_lng"] componentsSeparatedByString:@","];
                                                                       [YKSUserModel shareInstance].lat = [[array firstObject] floatValue];
                                                                       [YKSUserModel shareInstance].lng = [[array lastObject] floatValue];
                                                                   }
                                                                   if (![YKSUserModel shareInstance].currentSelectAddress) {
                                                                       [YKSUserModel shareInstance].currentSelectAddress = info;
                                                                   }
                                                                   
                                                               }
                                                               if (isCreate) {
                                                                   [bself gotoAddressVC:info];
                                                               } else {
                                                                   _isShowAddressView = NO;
                                                                   [YKSUserModel shareInstance].currentSelectAddress = info;
                                                                   //这里就是了,拿到地址,删除旧地址
                                                                   
                                                                   [UIViewController deleteFile];           [UIViewController selectedAddressArchiver:info];
                                                                   
                                                                   NSString *tempString = [NSString stringWithFormat:@"%@", info[@"community"] ? info[@"community"] : @""];
                                                                   if (info[@"sendable"] && ![info[@"sendable"] boolValue]) {
                                                                       NSString *title = [NSString stringWithFormat:@"%@(暂不支持配送)", tempString];
                                                                       [self.addressButton setTitle:title
                                                                                           forState:UIControlStateNormal];
                                                                   } else {
                                                                       [self.addressButton setTitle:[NSString stringWithFormat:@"配送至:%@",tempString]
                                                                                           forState:UIControlStateNormal];
                                                                   }
                                                               }
                                                           }];
    //    [selectAddressView reloadData];
    selectAddressView.removeViewCallBack = ^{
        
        
        
        _isShowAddressView = NO;
    };
    [GZBaseRequest addressListCallback:^(id responseObject, NSError *error) {
        if (ServerSuccess(responseObject)) {
            NSDictionary *dic = responseObject[@"data"];
            if ([dic isKindOfClass:[NSDictionary class]] && dic[@"addresslist"]) {
                selectAddressView.datas = [dic[@"addresslist"] mutableCopy];
                [YKSUserModel shareInstance].addressLists = selectAddressView.datas;
                if (!selectAddressView.datas) {
                    selectAddressView.datas = [NSMutableArray array];
                }
                
                [selectAddressView.datas insertObject:[self currentAddressInfo] atIndex:0];
                [selectAddressView reloadData];
            }
        }
    }];

}

#pragma mark - IBOutlets
- (IBAction)qrCodeAction:(UIButton *)sender {
    
}

- (IBAction)addressAction:(id)sender {
    //这里会显示地址,我们跟踪拿到选择的地址
    
  
    
    
    
    [self showAddressView];
}

#pragma mark - UITableViewdelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0&&indexPath.row==0) {
//        
//        return 170;
//    }
//    
//    else if (indexPath.section==0&&indexPath.row==1){
//        
//        return 50;
//    }
//    else {
//        return 84;
//    }
    
    if (indexPath.section == 0) {
        if (indexPath.row==2) {
            return 50;
        }
        
        return 76;
    } else if (indexPath.section == 1) {
        return 56*4;
    } else {
        return 76;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0||section==1) {
        UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        aView.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH - 30, 20)];
        if (section == 0) {
            label.text = @"常见症状解决方案";
        }
          if (section==1){
              label.text = @"药品分类";
            }
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor darkGrayColor];
        [aView addSubview:label];
        return aView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
   
        return 26.0f;
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
                return _datas.count < 1 ? 2 : _datas.count+1;
        
    }
    
   
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    
//        if (indexPath.section == 0) {
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homeCell1" forIndexPath:indexPath];
//            return cell;
//        } else if (indexPath.section == 1) {
//            NSDictionary *dic;
//            if (_datas.count > indexPath.row) {
//                dic = _datas[indexPath.row];
//            }
//            NSString *displaylayout = dic[@"displaylayout"];
//            NSString *identifier = [NSString stringWithFormat:@"homeSpecial%@", displaylayout ? displaylayout : @"1"];
//            YKSHomeListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
//            if (dic) {
//                [cell setHomeListInfo:dic];
//            }
//            cell.tapAction = ^(YKSSpecial *special){
//                [self performSegueWithIdentifier:@"gotoSplecialList" sender:special];
//            };
//            return cell;
//        } else {
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homeCell2" forIndexPath:indexPath];
//            return cell;
//        }
     if (indexPath.section == 0) {
         if (indexPath.row==2) {
             UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homeCell1" forIndexPath:indexPath];
                         return cell;
         }
         else{
        NSDictionary *dic;
        if (_datas.count > indexPath.row) {
            dic = _datas[indexPath.row];
        }
        NSString *displaylayout = dic[@"displaylayout"];
        NSString *identifier = [NSString stringWithFormat:@"homeSpecial%@", displaylayout ? displaylayout : @"1"];
        YKSHomeListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        if (dic) {
            [cell setHomeListInfo:dic];
        }
        cell.tapAction = ^(YKSSpecial *special){
            [self performSegueWithIdentifier:@"gotoSplecialList" sender:special];
        };
         
        return cell;
             
         }
    } else if(indexPath.section==1){
        
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"secondCell"];
        
        if (!cell) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"secondCell"];
            }

    for (int i=0; i<8; i++) {
        
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setImage:[UIImage imageNamed:@"default_icon_logo"] forState:UIControlStateNormal];
        
        btn.frame=CGRectMake(15+i%2*(SCREEN_WIDTH/2), 10+(i/2)*56, 35, 35);
        
        [btn addTarget:self action:@selector(sectionTwoClick:) forControlEvents:UIControlEventTouchUpInside];
        
        btn.tag=777+i;
        
        [cell.contentView addSubview:btn];

    }
        return cell;
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homeCell2" forIndexPath:indexPath];
        cell.contentView.backgroundColor=[UIColor whiteColor];
        return cell;
    }  
}
//药品分类点击事件
-(void)sectionTwoClick:(UIButton *)btn{
    
    NSInteger a=btn.tag-777;
    
    UIStoryboard *story=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    YKSDrugListViewController *vc=[story instantiateViewControllerWithIdentifier:@"YKSDrugListViewController"];
    
    
    
    NSDictionary *dic = _drugDatas[a];
    vc.specialId = dic[@"id"];
    vc.drugListType = YKSDrugListTypeCategory;
    vc.title = dic[@"title"];
    
    [self.navigationController pushViewController:vc animated:YES];


}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        [YKSTools call:kServerPhone inView:self.view];
       
    }
    
   
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (section==1) {
        return 32;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

    if (section==1) {
        
        UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 32)];
        
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setTitle:@"更多药品分类" forState:UIControlStateNormal];
        
        btn.frame=CGRectMake((SCREEN_WIDTH-160)/2, 5, 160,22 );
        
        btn.titleLabel.font=[UIFont systemFontOfSize:11];
        
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

        [view addSubview:btn];
        
        [btn addTarget:self action:@selector(gotoGrugListViewController) forControlEvents:UIControlEventTouchUpInside];
        
        view.backgroundColor=[UIColor whiteColor];
        
        return view;
    }
    return nil;
}

//点击更多药品分类
-(void)gotoGrugListViewController{
    
    UIStoryboard *story=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    YKSDrugCategoryListVC *list=[story instantiateViewControllerWithIdentifier:@"YKSDrugCategoryListVC"];
    
    [self.navigationController pushViewController:list animated:YES];
}
#pragma mark - imagePlayViewDelegate
- (NSInteger)numberOfItems {
    return _imageURLStrings.count;
}
- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView loadImageForImageView:(UIImageView *)imageView index:(NSInteger)index {
    [imageView sd_setImageWithURL:[NSURL URLWithString:_imageURLStrings[index][@"imgurl"]] placeholderImage:[UIImage imageNamed:@"defatul320"]];
}
- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView didTapAtIndex:(NSInteger)index {
    
    if (![YKSUserModel isLogin]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"未登录"
                                                        message:@"请登录后查看"
                                                       delegate:nil
                                              cancelButtonTitle:@"随便看看"
                                              otherButtonTitles:@"登录", nil];
        [alert show];
        [alert callBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                self.tabBarController.selectedIndex = 0;
            } else {
                [YKSTools login:self];
            }
        }];
        return ;
    } else {
        if (IS_NULL(_imageURLStrings[index][@"actiontarget"])) {
            return ;
        }
        [self performSegueWithIdentifier:@"gotoYKSWebViewController" sender:_imageURLStrings[index]];
    }
}
//#pragma mark - UITableViewDelegate
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *aa = segue.destinationViewController;
    aa.hidesBottomBarWhenPushed = YES;
    
    if ([segue.identifier isEqualToString:@"gotoSplecialList"]) {
        YKSSubSpecialListTableViewController *vc = segue.destinationViewController;
        vc.special = sender;
    } else if ([segue.identifier isEqualToString:@"gotoYKSQRCodeViewController"]) {
        YKSQRCodeViewController *vc = segue.destinationViewController;
        vc.qrUrlBlock = ^(NSString *stringValue){
            [self showProgress];
            [GZBaseRequest searchByKey:stringValue
                                  page:1
                              callback:^(id responseObject, NSError *error) {
                                  [self hideProgress];
                                  if (error) {
                                      [self showToastMessage:@"网络加载失败"];
                                      return ;
                                  }
                                  if (ServerSuccess(responseObject)) {
                                      NSLog(@"responseObject %@", responseObject);
                                      if ([responseObject[@"data"] count] == 0) {
                                          [self showToastMessage:@"没有相关的药品"];
                                      } else {
                                          UIStoryboard *mainBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                                          YKSDrugDetailViewController *vc = [mainBoard instantiateViewControllerWithIdentifier:@"YKSDrugDetailViewController"];
                                          
                                          // 扫码 跳转 详情界面
                                          vc.drugInfo=responseObject[@"data"][@"glist"][0];
                                          //                                          vc.datas = responseObject[@"data"][@"glist"];
                                          vc.hidesBottomBarWhenPushed = YES;
                                          //                                          vc.drugListType = YKSDrugListTypeSearchKey;
                                          //                                          vc.title = @"药品";
                                          [self.navigationController pushViewController:vc animated:YES];
                                      }
                                  } else {
                                      [self showToastMessage:responseObject[@"msg"]];
                                  }
                              }];
        };
    } else if ([segue.identifier isEqualToString:@"gotoYKSWebViewController"]) {
        YKSWebViewController *webVC = segue.destinationViewController;
        webVC.webURLString = sender[@"actiontarget"];
    }
    
}
@end