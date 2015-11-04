//
//  YKSOrderDetailViewController.m
//  YueKangSong
//
//  Created by gongliang on 15/5/29.
//  Copyright (c) 2015年 YKS. All rights reserved.
//

#import "YKSOrderDetailViewController.h"
#import "YKSShoppingCartBuyCell.h"
#import "YKSOrderListCell.h"
#import "YKSTools.h"
#import "GZBaseRequest.h"
#import "TimeLineViewControl.h"

@interface YKSOrderDetailViewController ()

@property (strong, nonatomic) NSMutableArray *datas;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation YKSOrderDetailViewController




- (void)viewDidLoad {
[super viewDidLoad];
// Do any additional setup after loading the view.
if (!IS_EMPTY_STRING(_orderInfo[@"express_orderid"])) {
[GZBaseRequest expressInfo:_orderInfo[@"express_orderid"]
callback:^(id responseObject, NSError *error) {
  if (error) {
      [self showToastMessage:@"网络加载失败"];
      return ;
  }
  if (ServerSuccess(responseObject)) {
      NSDictionary *dic = responseObject[@"data"][@"orderDetail"];
      if (dic) {
          UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 250)];
          footView.backgroundColor = [UIColor clearColor];
          UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 100, 21)];
          label.text = @"配送状态";
          label.backgroundColor = [UIColor clearColor];
          [footView addSubview:label];
          NSArray *times = [dic valueForKeyPath:@"time"];
          NSMutableArray *descriptions = [[dic valueForKeyPath:@"content"] mutableCopy];
          if (responseObject[@"data"][@"courierName"] && descriptions.count > 1) {
              NSString *info = descriptions[1];
              info = [NSString stringWithFormat:@"%@ \n快递员：%@ 电话：%@", info, responseObject[@"data"][@"courierName"], responseObject[@"data"][@"courierPhone"]];
              descriptions[1] = info;
          }
          TimeLineViewControl *timeline = [[TimeLineViewControl alloc] initWithTimeArray:times
              andTimeDescriptionArray:descriptions
              andCurrentStatus:(int)times.count
             andFrame:CGRectMake(20, 50, self.view.frame.size.width - 30, times.count * 30)];
          timeline.viewheight = 160;
          footView.frame = CGRectMake(0, 0, SCREEN_WIDTH, timeline.frame.origin.y + timeline.frame.size.height + 20);
          [footView addSubview:timeline];
          self.tableView.tableFooterView = footView;
      }
      
      
      
  } else {
      //[self showToastMessage:responseObject[@"msg"]];
  }
}];
}



}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row > 0 && indexPath.row <= [_orderInfo[@"list"] count]) {
            return 90.0f;
        }
    }
    return 44.0f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 2 + [_orderInfo[@"list"] count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSArray *drugs = _orderInfo[@"list"];
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderTitleCell" forIndexPath:indexPath];
            cell.textLabel.text = [YKSTools titleByOrderStatus:_status];
            cell.detailTextLabel.text = _orderInfo[@"orderid"];
            return cell;
        } else if (indexPath.row <= drugs.count) {
            YKSShoppingBuyDrugCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderDrugCell" forIndexPath:indexPath];
            [cell.logoImageView sd_setImageWithURL:[NSURL URLWithString:drugs[indexPath.row - 1][@"glogo"]] placeholderImage:[UIImage imageNamed:@"default160"]];
            cell.titleLabel.text = drugs[indexPath.row - 1][@"gtitle"];
            cell.priceLabel.attributedText = [YKSTools priceString:[drugs[indexPath.row - 1][@"gprice"] floatValue]];
            cell.countLabel.text = [[NSString alloc] initWithFormat:@"x%@", drugs[indexPath.row - 1][@"gcount"]];
            return cell;
        } else {
            YKSShoppingBuyTotalInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"totalInfoCell" forIndexPath:indexPath];
            NSArray *gcounts = [drugs valueForKeyPath:@"gcount"];
            cell.countLabel.text = [[NSString alloc] initWithFormat:@"共%@件商品", [gcounts valueForKeyPath:@"@sum.integerValue"]];
            cell.freightLabel.text = [[NSString alloc] initWithFormat:@"运费：%0.2f", [_orderInfo[@"serviceMoney"] floatValue]];
            cell.priceLabel.text = [[NSString alloc] initWithFormat:@"实付：%0.2f", [_orderInfo[@"finallyPrice"] floatValue]];
            return cell;
        }
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderTimeCell" forIndexPath:indexPath];
        cell.detailTextLabel.text = [YKSTools formatterTimeStamp:[_orderInfo[@"nextExpireTime"] integerValue]];
        return cell;
    }
    
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
