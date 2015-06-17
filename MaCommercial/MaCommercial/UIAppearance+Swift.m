//
//  UIAppearance+Swift.m
//  MaCommercial
//
//  Created by iem on 09/06/2015.
//

#import "UIAppearance+Swift.h"

@implementation UIView (UIViewAppearance_Swift)
    + (instancetype)customAppearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
        return [self appearanceWhenContainedIn:containerClass, nil];
    }
@end
