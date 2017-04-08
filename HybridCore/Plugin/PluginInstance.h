//
//  PluginInstance.h
//  Hybrid
//
//  Created by LZephyr on 2017/4/6.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RJBCommons.h"

@interface PluginInstance : NSObject<NSCopying>

/**
 插件的名字
 */
@property (nonatomic, readonly) NSString *pluginName;

/**
 获取该插件的实例，只有在首次使用时才会实例化
 */
@property (nonatomic, readonly) id<PluginExport> instance;

/**
 该插件是否已实例化
 */
@property (nonatomic, readonly) BOOL isInitialized;

/**
 获取该插件转换后的的JS代码
 */
@property (nonatomic, readonly) NSString *bridgedJs;

+ (PluginInstance *)instanceWithClass:(Class)pluginClass;

@end
