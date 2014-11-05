//
//  UIButton+OutsetLayers.m
//  TimesSquare
//
//  Created by Maxime Perreault on 2014-11-03.
//  Copyright (c) 2014 Square. All rights reserved.
//

#import "UIButton+OutsetLayers.h"
#import <objc/runtime.h>

static char const * const OutsetLayersKey = "outsetLayers";

@implementation UIButton(OutsetLayers)

@dynamic outsetLayers;

- (NSMutableArray*)outsetLayers{
    return objc_getAssociatedObject(self, OutsetLayersKey);
}

- (void)setOutsetLayers:(NSMutableArray *)outsetLayers{
    objc_setAssociatedObject(self, OutsetLayersKey, outsetLayers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



@end