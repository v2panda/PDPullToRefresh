# PDPullToRefresh

* An easy way to use pull-to-refresh

![Gif](http://7xnmlk.com1.z0.glb.clouddn.com/PDPullToRefresh.gif)

## Installation

### From CocoaPods

Add `pod 'PDPullToRefresh'` to your Podfile or `pod 'PDPullToRefresh', :head `if you're feeling adventurous.

### Manually

_**Important note if your project doesn't use ARC**: you must add the `-fobjc-arc` compiler flag to `UIScrollView+PDHeaderRefreshView.m` and `UIScrollView+PDFooterRefreshView.m` in Target Settings > Build Phases > Compile Sources._

Drag the PDPullToRefresh/PDPullToRefresh folder into your project.
Import PDPullToRefresh.h

## Usage

(see sample Xcode project in `/PDPullToRefresh`)

### Adding Pull to Refresh

```objective-c
[tableView pd_addHeaderRefreshWithNavigationBar:YES andActionHandler:^{
    // prepend data to dataSource, insert cells at top of table view
    // call [tableView.pdHeaderRefreshView stopRefreshing] when done
 }];
```
or if you want pull to refresh from the bottom

```objective-c
[tableView pd_addFooterRefreshWithNavigationBar:YES andActionHandler:^{
    // prepend data to dataSource, insert cells at top of table view
    // call [tableView.pdFooterRefreshView stopRefreshing] when done
 }];
```

If you’d like to programmatically trigger the refresh (for instance in `viewDidAppear:`), you can do so with:

```objective-c
[tableView.pdHeaderRefreshView startRefreshing];
```

#### Customization

The pull to refresh view can be customized using the following properties/methods:

```objective-c
@property (nonatomic, assign) CGFloat pdHeaderRefreshViewHeight;
@property (nonatomic, assign) CGFloat pdFooterRefreshViewHeight;
```

For instance, you would set the `pdHeaderRefreshViewHeight ` property using:

```objective-c
// Default is 80
tableView.pdHeaderRefreshViewHeight = 100;
```


## Special Thanks

PDPullToRefresh is Inspired by [半糖App](https://itunes.apple.com/cn/app/ban-tang/id955357564?mt=8)、[SVPullToRefresh](https://github.com/samvermette/SVPullToRefresh)



## License
PDPullToRefresh is available under the MIT license. See the LICENSE file for more info.



