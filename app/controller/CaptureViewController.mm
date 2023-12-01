#import "CaptureViewController.h"
#import "private_apis/CGS.h"

// TODO: maybe get rid of this and merge with CaptureView.mm?
@implementation CaptureViewController

- (instancetype)initWithWindow:(window_element)window_element {
    self = [super init];
    if (self) {
        CGFloat padding = 15;
        CGFloat width = 280, height = 175;
        CGRect viewFrame = NSMakeRect(0, 0, width + padding * 2, height + padding * 2);
        CGRect captureFrame = NSMakeRect(padding, padding, width, height);

        NSStackView* stackView = [[NSStackView alloc] initWithFrame:viewFrame];
        stackView.wantsLayer = true;
        stackView.layer.cornerRadius = 9.0;

        captureView = [[CaptureView alloc] initWithFrame:captureFrame windowId:window_element.wid];
        [stackView addSubview:captureView];

        NSImageView* iconView = [NSImageView imageViewWithImage:window_element.icon];
        iconView.image.size = NSMakeSize(48, 48);
        iconView.frame = NSMakeRect(width - 48, 0, 48, 48);
        iconView.wantsLayer = true;
        // iconView.layer.backgroundColor = NSColor.redColor.CGColor;
        [captureView addSubview:iconView];

        // NSTextField* titleText = [NSTextField labelWithString:window.title];
        // titleText.frameOrigin = CGPointMake(0, 0);
        // titleText.frameSize = CGSizeMake(width, 20);
        // titleText.alignment = NSTextAlignmentCenter;
        // [stackView addSubview:titleText];

        self.view = stackView;
    }
    return self;
}

- (instancetype)initWithWindowId:(CGWindowID)wid
                            size:(CGSize)size
                    innerPadding:(CGFloat)innerPadding {
    self = [super init];
    if (self) {
        CGRect viewFrame =
            NSMakeRect(0, 0, size.width + innerPadding * 2, size.height + innerPadding * 2);
        CGRect captureFrame = NSMakeRect(innerPadding, innerPadding, size.width, size.height);

        NSStackView* stackView = [[NSStackView alloc] initWithFrame:viewFrame];
        stackView.wantsLayer = true;
        stackView.layer.cornerRadius = 9.0;

        captureView = [[CaptureView alloc] initWithFrame:captureFrame windowId:wid];
        [stackView addSubview:captureView];

        CFStringRef title;
        CGSCopyWindowProperty(_CGSDefaultConnection(), wid, CFSTR("kCGSWindowTitle"), &title);
        NSTextField* titleText = [NSTextField labelWithString:(__bridge NSString*)title];
        titleText.frameOrigin = CGPointMake(innerPadding, 0);
        titleText.frameSize = CGSizeMake(size.width, titleText.frame.size.height);
        titleText.alignment = NSTextAlignmentCenter;
        [stackView addSubview:titleText];

        self.view = stackView;
    }
    return self;
}

- (void)startCapture {
    [captureView startCapture];
}

- (void)stopCapture {
    [captureView stopCapture];
}

- (void)highlight {
    self.view.layer.backgroundColor =
        [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.15f].CGColor;
}

- (void)unhighlight {
    self.view.layer.backgroundColor = CGColorGetConstantColor(kCGColorClear);
}

@end
