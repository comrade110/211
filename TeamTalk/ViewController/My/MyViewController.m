//
//  MyViewController.m
//  TeamTalk
//
//  Created by chx on 16/10/18.
//  Copyright © 2016年 MoguIM. All rights reserved.
//

#import "MyViewController.h"
#import "MTTUserInfoCell.h"
#import "MTTBaseCell.h"
#import <Masonry/Masonry.h>

@interface MyViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak) IBOutlet UITableView *tableView;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - tableview datasource && delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 16;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section != 0){
        return 20;
    }else{
        return 0.1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 16)];
    UILabel *detail = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, SCREEN_WIDTH-40, 16)];
    [detail setFont:systemFont(12)];
    [detail setTextColor:TTGRAY];
    if(section == 1){
        [detail setText:@"开启后,在22:00-8:00时间段收到消息不会有推送."];
        [footerView addSubview:detail];
        return footerView;
    }else if(section == 2){
        //        [detail setText:[NSString stringWithFormat:@"版本：%@",MTTVerison]];
        [detail setText:@""];
        [detail setTextAlignment:NSTextAlignmentCenter];
        [footerView addSubview:detail];
        return footerView;
    }else{
        return footerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return 100;
    }else{
        return 43;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 4;
    }else{
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        static NSString* identifier = @"section1Identifier";
        MTTBaseCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        cell.textLabel.text = @[@"关于俱乐部",@"入会申请",@"俱乐部会费",@"推荐新会员"][indexPath.row];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        return cell;
        
    }else if(indexPath.section == 1){
        static NSString* identifier = @"section2Identifier";
        MTTBaseCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        cell.textLabel.text = @[@"个人照片",@"基本资料",@"私密资料"][indexPath.row];
        return cell;
    }else if(indexPath.section == 2){
        static NSString* identifier = @"logoutIdentifier";
        MTTBaseCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        cell.textLabel.text = @[@"缘分匹配开关",@"缘分星空开关",@"VIP服务"][indexPath.row];
        switch (indexPath.row) {
            case 0:
            case 1:
                [cell showSwitch];
                break;
            default:
                break;
        }
        return cell;
    }else{
        static NSString* identifier = @"extraIdentifier";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

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
