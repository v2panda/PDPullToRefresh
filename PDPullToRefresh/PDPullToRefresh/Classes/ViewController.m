//
//  ViewController.m
//  PDPullToRefresh
//
//  Created by Panda on 16/1/17.
//  Copyright © 2016年 v2panda. All rights reserved.
//

#import "ViewController.h"
#import "PDPullToRefresh.h"

@interface ViewController () <UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTableView];
    
    [self addPDRefresh];
}

- (void)addPDRefresh
{
    [self.tableView pd_addHeaderRefreshWithNavigationBar:YES andActionHandler:^{
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSLog(@"Header - ActionHandler");
            [self.tableView.pdHeaderRefreshView stopRefreshing];
        });
    }];
//    [self.tableView.pdHeaderRefreshView startRefreshing];
    
    [self.tableView pd_addFooterRefreshWithNavigationBar:YES andActionHandler:^{
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSLog(@"Footer - ActionHandler");
            [self.tableView.pdFooterRefreshView stopRefreshing];
        });
    }];
}

- (void)initTableView
{
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TableViewCell"];
    [self.view addSubview:self.tableView];
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 15;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld条",(long)indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
