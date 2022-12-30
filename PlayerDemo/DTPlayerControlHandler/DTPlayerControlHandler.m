//
//  DTPlayerControlHandler.m
//  PlayerDemo
//
//  Created by Eden on 2022/12/30.
//

@import UIKit;
#import "DTPlayerControlHandler.h"

typedef NS_ENUM(NSInteger, DTPlayerControlEvent){
    
    DTPlayerControlDefaultEvent = 0,
    
    DTPlayerControlVolumeEvent = 1,
    
    DTPlayerControlSeekEvent = 2,
};

#pragma mark - DTPlayerControlConfiguration -

@interface DTPlayerControlConfiguration (Private)

+ (instancetype)defaultConfiguration;

@end

#pragma mark - DTPlayerControlHandler -

@interface DTPlayerControlHandler ()

@property (strong, nonatomic) DTPlayerControlConfiguration *configuration;

@property (assign, nonatomic) DTPlayerControlEvent event;

@property (weak, nonatomic) UIGestureRecognizer *gestureRecognizer;

@end

@implementation DTPlayerControlHandler

+ (instancetype)controlHandlerWithDelegate:(id<DTPlayerControlHandlerDelegate>)delegate
{
    DTPlayerControlHandler *__autoreleasing handler = [[DTPlayerControlHandler alloc] init];
    
    return handler;
}

- (instancetype)init
{
    self = [super init];
    
    if (self == nil) {
        
        return nil;
    }
    
    DTPlayerControlConfiguration *configuration = [DTPlayerControlConfiguration defaultConfiguration];
    
    [self setConfiguration:configuration];
    
    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    self.gestureRecognizer.enabled = enabled;
}

- (BOOL)isEnabled
{
    return self.gestureRecognizer.enabled;
}

- (void)addToView:(UIView *)view
{
    if (self.gestureRecognizer != nil) {
        
        UIGestureRecognizer *gestureRecognizer = self.gestureRecognizer;
        
        // Remove from previous view.
        UIView *previousView = gestureRecognizer.view;
        [previousView removeGestureRecognizer:gestureRecognizer];
        
        // Add to new view.
        [view addGestureRecognizer:gestureRecognizer];
        return;
    }
    
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandlerWithSender:)];
    
    [view addGestureRecognizer:gestureRecognizer];
    [self setGestureRecognizer:gestureRecognizer];
}

#pragma mark - Actions -

- (void)panGestureHandlerWithSender:(UIPanGestureRecognizer *)sender
{
    UIGestureRecognizerState state = sender.state;
    UIView *view = sender.view;
    CGPoint velocity = [sender velocityInView:view];
    
    if (state != UIGestureRecognizerStateBegan) {
        
        // When not begin state.
        if (self.event == DTPlayerControlVolumeEvent) {
            
            [self volumeGestureHandlerWithSender:sender];
        } else {
            
            [self seekGestureHandlerWithSender:sender];
        }
        
        return;
    }
    
    // Begin state.
    CGFloat maximumVelocityOfDirection = fmax(fabs(velocity.x), fabs(velocity.y));
    DTPlayerControlEvent event = (maximumVelocityOfDirection == fabs(velocity.x)) ? DTPlayerControlSeekEvent : DTPlayerControlVolumeEvent;
    
    // Notify delegate
    if (event == DTPlayerControlVolumeEvent) {
        
        [self notifyWillChangeVolumeLevelDelegate];
    }
    
    if (event == DTPlayerControlSeekEvent) {
        
        [self notifyWillBeginSeekDelegate];
    }
    
    [self setEvent:event];
}

- (void)volumeGestureHandlerWithSender:(UIPanGestureRecognizer *)sender
{
    UIGestureRecognizerState state = sender.state;
    UIView *view = sender.view;
    CGPoint point = [sender translationInView:view];
    CGFloat volumeLevel = self.volumeLevel;
    
    if (state == UIGestureRecognizerStateEnded) {
        
        [self setEvent:DTPlayerControlDefaultEvent];
        [self notifyWillChangeVolumeLevelDelegate];
    }
    
    if (state != UIGestureRecognizerStateChanged) {
        
        return;
    }
    
    CGFloat volumeGestureScale = self.configuration.gestureScale.volume;
    
    if (fabs(point.y) >= volumeGestureScale) {
        
        CGFloat multiple = fabs(point.y) / volumeGestureScale;
        CGFloat volumeIncrement = self.configuration.increament.volume;
        CGFloat addtionInterval = (point.y > 0.0f) ? -volumeIncrement : volumeIncrement;
        
        volumeLevel += (addtionInterval * multiple);
        volumeLevel = fmin(volumeLevel, 1.0f);
        volumeLevel = fmax(0.0, volumeLevel);
        
        [self setVolumeLevel:volumeLevel];
        [self notifyDidChangeVolumeLevelDelegate:volumeLevel];
        [sender setTranslation:CGPointZero inView:view];
    }
}

- (void)seekGestureHandlerWithSender:(UIPanGestureRecognizer *)sender
{
    UIGestureRecognizerState state = sender.state;
    UIView *view = sender.view;
    CGPoint point = [sender translationInView:view];
    CGFloat seekingInterval = self.playedInterval;
    
    if (state == UIGestureRecognizerStateEnded) {
        
        [self setEvent:DTPlayerControlDefaultEvent];
        [self notifyDidFinishSeekToSecondsDelegate:seekingInterval];
    }
    
    if (state != UIGestureRecognizerStateChanged) {
        
        return;
    }
    
    CGFloat seekGestureScale = self.configuration.gestureScale.seek;
    
    if (fabs(point.x) >= seekGestureScale) {
        
        CGFloat multiple = fabs(point.x) / seekGestureScale;
        CGFloat seekIncrement = self.configuration.increament.seek;
        CGFloat addtionInterval = (point.x > 0.0f) ? seekIncrement : -seekIncrement;
        
        seekingInterval += (addtionInterval * multiple);
        seekingInterval = fmin(seekingInterval, self.totalPlayInterval);
        seekingInterval = fmin(0.0f, seekingInterval);
        
        [self setPlayedInterval:seekingInterval];
        [self notifyDidSeekToSecondsDelegate:seekingInterval];
        [sender setTranslation:CGPointZero inView:view];
    }
}

#pragma mark - Notify Delegate -

- (void)notifyWillChangeVolumeLevelDelegate
{
    if (![self.delegate respondsToSelector:@selector(controlHandlerWillChangeVolumeLevel:)]) {
        
        return;
    }
    
    [self.delegate controlHandlerWillChangeVolumeLevel:self];
}

- (void)notifyDidChangeVolumeLevelDelegate:(CGFloat)level
{
    if (![self.delegate respondsToSelector:@selector(controlHandler:didChangeVolumeLevel:)]) {
        
        return;
    }
    
    [self.delegate controlHandler:self didChangeVolumeLevel:level];
}

- (void)notifyWillBeginSeekDelegate
{
    if (![self.delegate respondsToSelector:@selector(controlHandlerWithDelegate:)]) {
        
        return;
    }
    
    [self.delegate controlHandlerWillBeginSeek:self];
}

- (void)notifyDidSeekToSecondsDelegate:(CGFloat)seconds
{
    if (![self.delegate respondsToSelector:@selector(controlHandler:didSeekToSeconds:)]) {
        
        return;
    }
    
    [self.delegate controlHandler:self didSeekToSeconds:seconds];
}

- (void)notifyDidFinishSeekToSecondsDelegate:(CGFloat)seconds
{
    if (![self.delegate respondsToSelector:@selector(controlHandler:didFinishSeekToSeconds:)]) {
        
        return;
    }
    
    [self.delegate controlHandler:self didFinishSeekToSeconds:seconds];
}

@end
