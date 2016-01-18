//
//  UIScrollView+PDHeaderRefreshView.h
//  PDPullToRefreshDemo
//
//  Created by Panda on 16/1/15.
//  Copyright © 2016年 v2panda. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ActionHandler)(void);

@class PDHeaderRefreshView;
@interface UIScrollView (PDHeaderRefreshView)
/**
 *  下拉滑动距离 - 下拉View的高
 *   Default is 80
 */
@property (nonatomic, assign) CGFloat pdHeaderRefreshViewHeight;

/**
 *  下拉刷新View
 */
@property (nonatomic, strong) PDHeaderRefreshView *pdHeaderRefreshView;

/**
 *  添加刷新
 *
 *  @param actionHandler 回调
 */
- (void)pd_addHeaderRefreshWithNavigationBar:(BOOL)navBar andActionHandler:(ActionHandler)actionHandler;

@end

@interface PDHeaderRefreshView : UIView

- (instancetype)initWithAssociatedScrollView:(UIScrollView *)scrollView withNavigationBar:(BOOL)navBar andRefreshViewHeight:(CGFloat)refreshViewHeight andActionHandler:(ActionHandler)actionHandler;
/**
 *  停止刷新
 */
- (void)stopRefreshing;
/**
 *  开始刷新
 */
- (void)startRefreshing;

@end
