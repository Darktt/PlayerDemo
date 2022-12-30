//
//  DTPlayerControlConfiguration.m
//  PlayerDemo
//
//  Created by Eden on 2022/12/30.
//

#import "DTPlayerControlConfiguration.h"

#pragma mark - DTPlayerConfigurationGroup -

@interface DTPlayerConfigurationGroup ()

+ (instancetype)groupWithVolume:(CGFloat)volume seek:(CGFloat)seek;

@end

@implementation DTPlayerConfigurationGroup

+ (instancetype)groupWithVolume:(CGFloat)volume seek:(CGFloat)seek
{
    DTPlayerConfigurationGroup *__autoreleasing group = [[DTPlayerConfigurationGroup alloc] initWithVolume:volume seek:seek];
    
    return group;
}

- (instancetype)initWithVolume:(CGFloat)volume seek:(CGFloat)seek
{
    self = [super init];
    
    if (self == nil) {
        
        return nil;
    }
    
    [self setVolume:volume];
    [self setSeek:seek];
    
    return self;
}

@end

#pragma mark - DTPlayerControlConfiguration -

@interface DTPlayerControlConfiguration ()

@property (strong, nonatomic) DTPlayerConfigurationGroup *gestureScale;

@property (strong, nonatomic) DTPlayerConfigurationGroup *increament;

+ (instancetype)defaultConfiguration;

@end

@implementation DTPlayerControlConfiguration

+ (instancetype)defaultConfiguration
{
    DTPlayerControlConfiguration *__autoreleasing configuration = [[DTPlayerControlConfiguration alloc] _init];
    
    return configuration;
}

- (instancetype)_init
{
    self = [super init];
    
    if (self == nil) {
        
        return nil;
    }
    
    DTPlayerConfigurationGroup *gestureScale = [DTPlayerConfigurationGroup groupWithVolume:2.0f seek:1.0f];
    DTPlayerConfigurationGroup *increment = [DTPlayerConfigurationGroup groupWithVolume:0.01f seek:1.0f];
    
    [self setGestureScale:gestureScale];
    [self setIncreament:increment];
    
    return self;
}

@end
