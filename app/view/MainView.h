#import "controller/CaptureViewController.h"
#import "model/window_element.h"
#import <Cocoa/Cocoa.h>
#import <vector>

@interface MainView : NSVisualEffectView {
    NSSize size;
    CGFloat padding;
    CGFloat innerPadding;

    // TODO: somehow extract this from self.subviews?
@public
    std::vector<CaptureViewController*> capture_controllers;

    // TODO: think about moving these to a controller (e.g., WindowController)
@public
    int selectedIndex;
}

- (instancetype)initWithCaptureSize:(NSSize)size
                            padding:(CGFloat)padding
                       innerPadding:(CGFloat)innerPadding;

- (void)addCaptureSubview:(window_element)window_element;
- (void)addCaptureSubviewId:(CGWindowID)wid;
- (void)startCaptureSubviews;
- (void)stopCaptureSubviews;
- (void)cycleSelectedIndex;
- (void)focusSelectedIndex;
- (void)ahaha;

@end
