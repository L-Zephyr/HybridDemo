//
//  HybridNavigator.m
//  Hybrid
//
//  Created by LZephyr on 2017/4/18.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "HybridNavigator.h"
#import "Hybrid-Swift.h"

@interface HybridNavigator()

@end

@implementation HybridNavigator

- (void)push:(NSString *)url params:(NSDictionary *)params {
    WebViewController *vc = [[Router shared] webViewControllerWithUrl:url params:params];
    UINavigationController *nv = [self currentNavigationController];
    if (nv) {
        [nv pushViewController:vc animated:YES];
    } else {
        Hybrid_LogWarning(@"Current NavigationController not found!");
    }
}

- (void)present:(NSString *)url params:(NSDictionary *)params {
    
}

- (void)pop {
    
}

- (void)popToRoot {
    
}

- (UIViewController *)currentViewController {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self findTopMostViewController:rootVC];
}

- (UINavigationController *)currentNavigationController {
    return [self currentViewController].navigationController;
}

- (UIViewController *)findTopMostViewController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        return [self findTopMostViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *svc = (UISplitViewController *)vc;
        if (svc.viewControllers.count > 0) {
            return [self findTopMostViewController:svc.viewControllers.lastObject];
        } else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *)vc;
        if (svc.viewControllers.count > 0) {
            return [self findTopMostViewController:svc.topViewController];
        } else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *)vc;
        if (svc.viewControllers.count > 0) {
            return [self findTopMostViewController:svc.selectedViewController];
        } else {
            return vc;
        }
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}

@end
