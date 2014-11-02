//
//  UIButton+Subtitle.m
//  bSporti
//
//  Created by Maxime Perreault on 2014-10-28.
//  Copyright (c) 2014 Maxime Perreault. All rights reserved.
//

#import "UIButton+Subtitle.h"
#import <objc/runtime.h>

static char const * const MainTitleKey = "mainTitle";
static char const * const SubTitleKey = "subTitle";

@implementation UIButton(Subtitle)

@dynamic mainTitle;
@dynamic subTitle;

- (UILabel*)mainTitle{
    return objc_getAssociatedObject(self, MainTitleKey);
}

- (UILabel*)subTitle{
    return objc_getAssociatedObject(self, SubTitleKey);
}

- (void)setMainTitle:(UILabel *)mainTitle{
    objc_setAssociatedObject(self, MainTitleKey, mainTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setSubTitle:(UILabel *)subTitle{
    objc_setAssociatedObject(self, SubTitleKey, subTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



@end
