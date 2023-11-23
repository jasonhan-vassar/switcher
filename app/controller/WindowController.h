#import "private_apis/CGSSpace.h"
#import <Cocoa/Cocoa.h>
#import <ScreenCaptureKit/ScreenCaptureKit.h>

struct CppMembers;

@interface WindowController : NSWindowController <NSWindowDelegate> {
    struct CppMembers* cpp;
    NSWindow* window;

@private
    CGSSpace* space;
}

@property(nonatomic) bool isShown;

- (void)showWindow;
- (void)hideWindow;

@end
