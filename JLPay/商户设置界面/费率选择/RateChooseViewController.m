//
//  RateChooseViewController.m
//  JLPay
//
//  Created by jielian on 16/3/2.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "RateChooseViewController.h"
#import "SegRateVCTypes.h"
#import "Define_Header.h"
#import "Masonry.h"
#import <objc/runtime.h>
#import "CustomSegmentView.h"



@interface RateChooseViewController ()
@property (nonatomic, strong) CustomSegmentView* segmentedControl;
@property (nonatomic, strong) SegRateVCTypes* segVCTypes;
@property (nonatomic, strong) NSArray* childrenViewControllers;

@end

@implementation RateChooseViewController

#pragma mask 0 VC LIFE TIME
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"费率选择";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadSubViews];
    [self loadSubViewControllers];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self relayoutSubViews];
    [self.segmentedControl addObserver:self forKeyPath:kKeyPathSegSelectedItem options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    self.tabBarController.tabBar.hidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    [self.segmentedControl removeObserver:self forKeyPath:kKeyPathSegSelectedItem];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) loadSubViews {
    [self.view addSubview:self.segmentedControl];
}

- (void) loadSubViewControllers {
    for (UIViewController* childVC in self.childrenViewControllers) {
        [self addChildViewController:childVC];
    }
    UIViewController* firstVC = [self.childrenViewControllers objectAtIndex:0];
    [self.view addSubview:firstVC.view];
}

- (void) relayoutSubViews {
    CGRect frame = self.view.bounds;
    CGFloat heightNavigation = self.navigationController.navigationBar.frame.size.height;
    CGFloat heightStatusBar = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat heightTabBar = self.tabBarController.tabBar.frame.size.height;
    CGFloat heightSegment = 45;
    CGFloat inset = 15;
    frame.origin.x = 15;
    frame.size.width -= inset*2;
    frame.origin.y = heightNavigation + heightStatusBar + inset;
    frame.size.height = heightSegment;
    self.segmentedControl.frame = frame;
    
    frame.origin.x = 0;
    frame.size.width += inset*2;
    CGFloat childVCFrameY = frame.origin.y + frame.size.height;
    CGFloat childVCFrameH = self.view.bounds.size.height - childVCFrameY - heightTabBar;
    CGRect normalFrame = CGRectMake(0, childVCFrameY, frame.size.width, childVCFrameH);
    
    for (UIViewController* viewC in self.childrenViewControllers) {
        [viewC.view setFrame:normalFrame];
    }
}


#pragma mask 1 KVO
// -- segment的切换事件
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kKeyPathSegSelectedItem]) {
        NSInteger newValue = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        NSInteger oldValue = [[change objectForKey:NSKeyValueChangeOldKey] integerValue];
        if (newValue == oldValue) {
            return;
        }
        [self transitionViewControllerFromIndex:oldValue toIndex:newValue];
    }
}

#pragma mask 2 PRIVATE INTERFACE
// -- 切换子控制器的显示
- (void) transitionViewControllerFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    UIViewController* fromVC = [self.childrenViewControllers objectAtIndex:fromIndex];
    UIViewController* toVC = [self.childrenViewControllers objectAtIndex:toIndex];
    self.canChangeViewController = NO;
    [self transitionFromViewController:fromVC toViewController:toVC
                              duration:1
                               options:UIViewAnimationOptionCurveEaseInOut
                            animations:^{
                            }
                            completion:^(BOOL finished) {
                            }];
}


#pragma mask 4 getter 
- (CustomSegmentView *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[CustomSegmentView alloc] initWithItems:self.segVCTypes.segRateTypesInfo.allKeys];
        _segmentedControl.tintColor = [PublicInformation returnCommonAppColor:@"red"];
        _segmentedControl.textColor = [PublicInformation returnCommonAppColor:@"red"];
        _segmentedControl.textSelectedColor = [UIColor whiteColor];
        _segmentedControl.selectedType = CustSegSelectedTypeSingleRect;
        _segmentedControl.layer.borderColor = [PublicInformation returnCommonAppColor:@"red"].CGColor;
        _segmentedControl.layer.borderWidth = 1.f;
        _segmentedControl.layer.cornerRadius = 7.f;
        if (self.segVCTypes.segRateTypesInfo.count == 1) {
            _segmentedControl.hidden = YES;
        }
    }
    return _segmentedControl;
}
- (SegRateVCTypes *)segVCTypes {
    if (!_segVCTypes) {
        _segVCTypes = [[SegRateVCTypes alloc] init];
    }
    return _segVCTypes;
}
- (NSArray *)childrenViewControllers {
    if (!_childrenViewControllers) {
        NSMutableArray* viewControllers = [NSMutableArray array];
        for (NSString* vcNameKey in self.segVCTypes.segRateTypesInfo.allKeys) {
            Class vcClass = objc_getClass([[self.segVCTypes.segRateTypesInfo objectForKey:vcNameKey] UTF8String]);
            UIViewController* viewController = [[vcClass alloc] init];
            [viewControllers addObject:viewController];
        }
        _childrenViewControllers = [NSArray arrayWithArray:viewControllers];
    }
    return _childrenViewControllers;
}
#pragma mask 4 setter
- (void)setCanChangeViewController:(BOOL)canChangeViewController {
    _canChangeViewController = canChangeViewController;
    _segmentedControl.canTurnOnSegment = canChangeViewController;
    if (!canChangeViewController) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}
@end
