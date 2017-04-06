//
//  PluginInstance.m
//  Hybrid
//
//  Created by LZephyr on 2017/4/6.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "PluginInstance.h"

@interface PluginInstance()

@property (nonatomic) Class pluginClass;

@end

@implementation PluginInstance

@synthesize instance = _instance;

+ (PluginInstance *)instanceWithClass:(Class)pluginClass {
    return [[PluginInstance alloc] initWithClass:pluginClass];
}

- (instancetype)initWithClass:(Class)pluginClass {
    self = [super init];
    if (self) {
        _pluginClass = pluginClass;
        _isInitialized = NO;
    }
    return self;
}

- (id<PluginExport>)instance {
    if (!_instance) {
        _instance = [_pluginClass new];
        if ([_instance respondsToSelector:@selector(setup)]) {
            [_instance setup];
        }
    }
    
    return _instance;
}

@end
