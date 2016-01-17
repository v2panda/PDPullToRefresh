//
//  UIScrollView+PDFooterRefreshView.h
//  PDPullToRefreshDemo
//
//  Created by Panda on 16/1/15.
//  Copyright © 2016年 v2panda. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ActionHandler)(void);

@class PDFooterRefreshView;
@interface UIScrollView (PDFooterRefreshView)
/**
 *  下拉滑动距离 - 下拉View的高
 *   Default is 80
 */
@property (nonatomic, assign) CGFloat pdFooterRefreshViewHeight;
/**
 *  上拉刷新View
 */
@property (nonatomic, strong) PDFooterRefreshView *pdFooterRefreshView;

/**
 *  添加刷新
 *
 *  @param actionHandler 回调
 */
- (void)pd_addFooterRefreshWithNavigationBar:(BOOL)navBar andActionHandler:(ActionHandler)actionHandler;

@end

@interface PDFooterRefreshView : UIView

- (instancetype)initWithAssociatedScrollView:(UIScrollView *)scrollView withNavigationBar:(BOOL)navBar andRefreshViewHeight:(CGFloat)refreshViewHeight andActionHandler:(ActionHandler)actionHandler;
/**
 *  停止刷新
 */
- (void)stopRefreshing;

@end
