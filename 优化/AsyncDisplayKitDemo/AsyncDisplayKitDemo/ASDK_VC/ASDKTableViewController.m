//
//  ASDKTableViewController.m
//  AsyncDisplayKitDemo
//
//  Created by teilt on 2019/1/21.
//  Copyright © 2019 teilt. All rights reserved.
//

#import "ASDKTableViewController.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "TableCellNode.h"
#import "PhotoModel.h"

#import "YYFPSLabel.h"

@interface ASDKTableViewController ()<ASTableDelegate,ASTableDataSource>

@property(nonatomic ,strong) ASTableNode *tableNode;

@end

@implementation ASDKTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initViews];
}
- (void)initViews
{
    _tableNode = [[ASTableNode alloc]initWithStyle:UITableViewStylePlain];
    _tableNode.dataSource = self;
    _tableNode.delegate = self;
    _tableNode.frame = self.view.bounds;
    [self.view addSubnode:_tableNode];
    
    _tableNode.view.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //无限滚动需要
    //将 leadingScreensForBatching 设置为 1.0 表示当用户滚动还剩 1 个全屏就到达页尾时，开始抓取新的一批数据。default of 2.0
    _tableNode.view.leadingScreensForBatching = 1.0;
    
    YYFPSLabel *fpsLabel = [YYFPSLabel new];
    fpsLabel.frame = CGRectMake(300, 100, 50, 30);
    [self.view addSubview:fpsLabel];
}

#pragma mark - TableNode Delegate
- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode
{
    return 1;
}
- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

/**
 *  不支持复用
 *  该方法优先于 tableNode:nodeForRowAtIndexPath:
 */
- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PhotoModel *model = [[PhotoModel alloc] init];
    model.text = [NSString stringWithFormat:@"Row : %ld", indexPath.row];
    model.imgUrl = _dataArray[indexPath.row];
    
    ASCellNode *(^cellBlock)(void) = ^ASCellNode *(){
        TableCellNode *cellNode = [[TableCellNode alloc]initWithData:model];
        
        return cellNode;
    };
    return cellBlock;
}

- (ASSizeRange)tableNode:(ASTableNode *)tableNode constrainedSizeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGSize min = CGSizeMake(width, 380);
    CGSize max = CGSizeMake(width, MAXFLOAT);
    return ASSizeRangeMake(min, max);
}
- (void)tableNode:(ASTableNode *)tableNode didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableNode deselectRowAtIndexPath:indexPath animated:YES];
}
@end
