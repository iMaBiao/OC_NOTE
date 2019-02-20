
//
//  NormalTableViewController.m
//  AsyncDisplayKitDemo
//
//  Created by teilt on 2019/1/22.
//  Copyright © 2019 teilt. All rights reserved.
//

#import "NormalTableViewController.h"
#import "YYFPSLabel.h"
#import "NormalTableViewCell.h"
#import "PhotoModel.h"

@interface NormalTableViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic ,strong) UITableView *tableView;

@end

@implementation NormalTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initViews];
}

- (void)initViews
{
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.frame = self.view.bounds;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[NormalTableViewCell class] forCellReuseIdentifier:@"NormalTableViewCell"];
    [self.view addSubview:_tableView];
    
    
    YYFPSLabel *fpsLabel = [YYFPSLabel new];
    fpsLabel.frame = CGRectMake(300, 100, 50, 30);
    [self.view addSubview:fpsLabel];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 380;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalTableViewCell"];
    
//    NSLog(@"%s cellForRowAtIndexPath = %p", __FUNCTION__,cell);
    return cell;
}

//先创建cell(调用cellForRowAtIndexPath)，再即将展示的时候（willDisplayCell）为cell设置数据
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NormalTableViewCell *normalCell = (NormalTableViewCell *)cell;
    PhotoModel *model = [[PhotoModel alloc] init];
    model.text = [NSString stringWithFormat:@"Row : %ld", indexPath.row];
    model.imgUrl = _dataArray[indexPath.row];
    normalCell.dataModel = model;
//    NSLog(@"%s willDisplayCell = %p", __FUNCTION__,cell);
}
@end
