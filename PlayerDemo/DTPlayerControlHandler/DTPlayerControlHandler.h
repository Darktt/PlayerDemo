//
//  DTPlayerControlHandler.h
//  PlayerDemo
//
//  Created by Eden on 2022/12/30.
//

@import Foundation;
@import UIKit.UIView;
#import "DTPlayerControlConfiguration.h"

NS_ASSUME_NONNULL_BEGIN
@protocol DTPlayerControlHandlerDelegate;

@interface DTPlayerControlHandler : NSObject

@property (weak, nonatomic) id<DTPlayerControlHandlerDelegate> delegate;

@property (readonly, strong, nonatomic) DTPlayerControlConfiguration *configuration;

@property (assign, nonatomic) CGFloat volumeLevel;

@property (assign, nonatomic) NSTimeInterval totalPlayInterval;

@property (assign, nonatomic) NSTimeInterval playedInterval;

@property (readwrite, nonatomic, getter=isEnabled) BOOL enabled;

+ (instancetype)controlHandlerWithDelegate:(id<DTPlayerControlHandlerDelegate>)delegate;

- (void)addToView:(UIView *)view;

@end

@protocol DTPlayerControlHandlerDelegate <NSObject>

- (void)controlHandlerWillChangeVolumeLevel:(DTPlayerControlHandler *)handler;

- (void)controlHandler:(DTPlayerControlHandler *)handler didChangeVolumeLevel:(CGFloat)level;

- (void)controlHandlerWillBeginSeek:(DTPlayerControlHandler *)handler;

- (void)controlHandler:(DTPlayerControlHandler *)handler didSeekToSeconds:(NSTimeInterval)seconds;

- (void)controlHandler:(DTPlayerControlHandler *)handler didFinishSeekToSeconds:(NSTimeInterval)seconds;

@end

NS_ASSUME_NONNULL_END
