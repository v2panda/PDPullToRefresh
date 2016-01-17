//
//  UIScrollView+PDFooterRefreshView.m
//  PDPullToRefreshDemo
//
//  Created by Panda on 16/1/15.
//  Copyright © 2016年 v2panda. All rights reserved.
//

#import "UIScrollView+PDFooterRefreshView.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>


static char UIScrollViewPDFooterRefreshView;
static char PDFooterRefreshViewHeight;

@implementation UIScrollView (PDFooterRefreshView)
- (void)setPdFooterRefreshView:(PDFooterRefreshView *)pdFooterRefreshView
{
    objc_setAssociatedObject(self, &UIScrollViewPDFooterRefreshView, pdFooterRefreshView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PDFooterRefreshView *)pdFooterRefreshView
{
    return objc_getAssociatedObject(self, &UIScrollViewPDFooterRefreshView);
}

- (void)setPdFooterRefreshViewHeight:(CGFloat)pdFooterRefreshViewHeight
{
    objc_setAssociatedObject(self, &PDFooterRefreshViewHeight, @(MAX(0, pdFooterRefreshViewHeight)), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)pdFooterRefreshViewHeight
{
#if CGFLOAT_IS_DOUBLE
    return [objc_getAssociatedObject(self, &PDFooterRefreshViewHeight) doubleValue];
#else
    return [objc_getAssociatedObject(self, &PDFooterRefreshViewHeight) floatValue];
#endif
}

- (void)pd_addFooterRefreshWithNavigationBar:(BOOL)navBar andActionHandler:(ActionHandler)actionHandler
{
    if (!self.pdFooterRefreshViewHeight) {
        self.pdFooterRefreshViewHeight = 80;
    }
    
    self.pdFooterRefreshView = [[PDFooterRefreshView alloc]initWithAssociatedScrollView:self withNavigationBar:navBar andRefreshViewHeight:self.pdFooterRefreshViewHeight andActionHandler:actionHandler];
    [self insertSubview:self.pdFooterRefreshView atIndex:0];
}

@end

@interface PDFooterRefreshView ()

@property (nonatomic, retain) CALayer *animationLayer;
@property (nonatomic, retain) CAShapeLayer *pathLayer;
@property (nonatomic, weak)UIScrollView *associatedScrollView;
@property (nonatomic, assign)CGFloat progress;
@property (nonatomic, copy) ActionHandler handleBlock;
@property (nonatomic, assign) BOOL isFlash;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, copy) NSString *animationPacing;

@end

/** 默认光晕循环一次的持续时间 */
static const NSTimeInterval pHaloDuration = 1.5f;

/** 默认光晕宽度 */
static const CGFloat pHaloWidth = 2.5f;

/** 默认字体大小 */
static const double pFontSize = 26.0f;

#define pColor [[UIColor colorWithRed:234.0/255 green:84.0/255 blue:87.0/255 alpha:1] CGColor]

/** 光晕动画ID */
static NSString *const kAnimationKey = @"PDFooterRefreshViewAnimationKey";

@implementation PDFooterRefreshView
{
    CGFloat originOffset;
    CGSize contentSize;
    CGFloat PDPullToRefreshViewHeight;
    BOOL isShow;
}

- (instancetype)initWithAssociatedScrollView:(UIScrollView *)scrollView withNavigationBar:(BOOL)navBar andRefreshViewHeight:(CGFloat)refreshViewHeight andActionHandler:(ActionHandler)actionHandler
{
    self = [super initWithFrame:CGRectMake(0, scrollView.frame.size.height, scrollView.frame.size.width, refreshViewHeight)];
    if (self) {
        if (navBar) {
            originOffset = 64.0f;
        }else{
            originOffset = 0.0f;
        }
        self.associatedScrollView = scrollView;
        self.handleBlock = actionHandler;
        PDPullToRefreshViewHeight = refreshViewHeight;
        
        [self.associatedScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [self.associatedScrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        self.hidden = YES;
        self.animationLayer = [CALayer layer];
        self.animationLayer.frame = CGRectMake(0.0f, 0.0f,
                                               scrollView.frame.size.width,
                                               refreshViewHeight);
        [self.layer addSublayer:self.animationLayer];
        isShow = NO;
        [self addPullAnimation];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    
    CGFloat diff =  self.associatedScrollView.contentOffset.y - (self.associatedScrollView.contentSize.height - self.associatedScrollView.bounds.size.height) - PDPullToRefreshViewHeight;
    self.pathLayer.strokeEnd = progress;
    if (diff > 0) {
        if (!self.associatedScrollView.tracking && !self.hidden)
        {
            if (self.isFlash) {
                [self addRefreshAnimation];
                self.isFlash = NO;
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.associatedScrollView.contentInset = UIEdgeInsetsMake(originOffset, 0, PDPullToRefreshViewHeight , 0);
                    
                } completion:^(BOOL finished) {
                    self.handleBlock();
                }];
            }
            
        }
    }else {
        if (isShow) {
            self.pathLayer.strokeEnd = 1.0;
        }
    }
}

- (void)stopRefreshing
{
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0f;
        self.associatedScrollView.contentInset = UIEdgeInsetsMake(originOffset, 0, 0, 0);
    } completion:^(BOOL finished) {
        self.alpha = 1.0f;
        [self addPullAnimation];
        if (!isShow) {
            self.pathLayer.strokeEnd = 0.0;
        }
        [self stopAnimating];
    }];
}

#pragma mark - Animation Method

- (CAShapeLayer *)setupDefaultLayer:(NSString *)animationString
{
    if (self.pathLayer != nil) {
        [self.pathLayer removeFromSuperlayer];
        self.pathLayer = nil;
    }

    CGMutablePathRef letters = CGPathCreateMutable();
    
    CTFontRef font = CTFontCreateWithName(CFSTR("HelveticaNeue-UltraLight"), pFontSize, NULL);
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)font, kCTFontAttributeName,
                           nil];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:animationString
                                                                     attributes:attrs];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    
    // for each RUN
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
    {
        // Get FONT for this run
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        // for each GLYPH in run
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
        {
            // get Glyph & Glyph-data
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            // Get PATH of outline
            {
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                //                CGAffineTransform t = CGAffineTransformIdentity;
                CGPathAddPath(letters, &t, letter);
                CGPathRelease(letter);
            }
        }
    }
    CFRelease(line);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path appendPath:[UIBezierPath bezierPathWithCGPath:letters]];
    
    CGPathRelease(letters);
    CFRelease(font);
    
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.frame = self.animationLayer.bounds;
    pathLayer.bounds = CGPathGetBoundingBox(path.CGPath);
    pathLayer.geometryFlipped = YES;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = [UIColor colorWithRed:234.0/255 green:84.0/255 blue:87.0/255 alpha:1].CGColor;
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = 1.0f;
    pathLayer.lineJoin = kCALineJoinBevel;
    
    return pathLayer;
}

- (void)addPullAnimation
{
    // 这就是生活
    CAShapeLayer *pathLayer = [self setupDefaultLayer:@"C'est La Vie"];
    [self.animationLayer addSublayer:pathLayer];
    self.pathLayer = pathLayer;
    self.isFlash = YES;
}

- (void)addRefreshAnimation
{
    _animationPacing = kCAMediaTimingFunctionEaseIn;
    
    // 设置渐变层参数
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.animationLayer.bounds;
    gradientLayer.startPoint       = CGPointMake(- pHaloWidth, 0);
    gradientLayer.endPoint         = CGPointMake(0, 0);
    gradientLayer.colors           = @[(id)pColor,
                                       (id)[[UIColor whiteColor] CGColor],
                                       (id)pColor];
    
    [self.animationLayer addSublayer:gradientLayer];
    self.gradientLayer = gradientLayer;
    
    // 生活是美好的
    CAShapeLayer *pathLayer = [self setupDefaultLayer:@"La Vie est belle"];
    self.gradientLayer.mask = pathLayer;
    [self startAnimating];
}

/** 开启动画 */
- (void)startAnimating
{
    static NSString *gradientStartPointKey = @"startPoint";
    static NSString *gradientEndPointKey = @"endPoint";
    
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.gradientLayer;
    if([gradientLayer animationForKey:kAnimationKey] == nil)
    {
        // 通过不断改变渐变的起止范围，来实现光晕效果
        CABasicAnimation *startPointAnimation = [CABasicAnimation animationWithKeyPath:gradientStartPointKey];
        startPointAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 0)];
        startPointAnimation.timingFunction = [CAMediaTimingFunction functionWithName:_animationPacing];
        
        CABasicAnimation *endPointAnimation = [CABasicAnimation animationWithKeyPath:gradientEndPointKey];
        endPointAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1 + pHaloWidth, 0)];
        endPointAnimation.timingFunction = [CAMediaTimingFunction functionWithName:_animationPacing];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[startPointAnimation, endPointAnimation];
        group.duration = pHaloDuration;
        group.timingFunction = [CAMediaTimingFunction functionWithName:_animationPacing];
        group.repeatCount = HUGE_VALF;
        
        [gradientLayer addAnimation:group forKey:kAnimationKey];
    }
}

/** 结束动画 */
- (void)stopAnimating
{
    [self.gradientLayer removeFromSuperlayer];
//    [self.gradientLayer removeAnimationForKey:kAnimationKey];
    self.gradientLayer = nil;
}

#pragma mark -- KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        contentSize = [[change valueForKey:NSKeyValueChangeNewKey]CGSizeValue];
        if (contentSize.height > 0.0) {
            self.hidden = NO;
        }
        self.frame = CGRectMake(0, contentSize.height, self.associatedScrollView.frame.size.width, PDPullToRefreshViewHeight);
    }
    if (contentSize.height + PDPullToRefreshViewHeight <= self.associatedScrollView.frame.size.height) {
        isShow = YES;
    }else{
        isShow = NO;
    }

    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        CGPoint contentOffset = [[change objectForKey:NSKeyValueChangeNewKey]CGPointValue];
        
        if (contentOffset.y >= (contentSize.height - self.associatedScrollView.bounds.size.height)) {
            
            self.center = CGPointMake(self.center.x, contentSize.height + (contentOffset.y - (contentSize.height - self.associatedScrollView.frame.size.height))/2);
            self.progress = MAX(0.0, MIN((contentOffset.y - (contentSize.height - self.associatedScrollView.frame.size.height)) / PDPullToRefreshViewHeight, 1.0));
        }
    }
}

#pragma dealloc
-(void)dealloc{
    
    [self.associatedScrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.associatedScrollView removeObserver:self forKeyPath:@"contentSize"];
}
@end
