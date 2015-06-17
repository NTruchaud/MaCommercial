//
//  UIAppearance+Swift.h
//  MaCommercial
//
//  Created by iem on 09/06/2015.
//

#import <UIKit/UIKit.h>

@interface UIView (UIViewAppearance_Swift)
    // appearanceWhenContainedIn: is not available in Swift. This fixes that.
    + (instancetype)customAppearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end
