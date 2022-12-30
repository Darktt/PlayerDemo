//
//  DTPlayerControlConfiguration.h
//  PlayerDemo
//
//  Created by Eden on 2022/12/30.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface DTPlayerConfigurationGroup : NSObject

/// Volume value of configuration.
@property (assign, nonatomic) CGFloat volume;

@property (assign, nonatomic) CGFloat seek;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

@interface DTPlayerControlConfiguration : NSObject

@property (readonly, nonatomic) DTPlayerConfigurationGroup *gestureScale;

@property (readonly, nonatomic) DTPlayerConfigurationGroup *increament;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
