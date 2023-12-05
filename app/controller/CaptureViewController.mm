#import "CaptureViewController.h"
#import "extensions/ScreenCaptureKit+InitWithId.h"
#import "private_apis/CGS.h"
#import "util/log_util.h"

// TODO: maybe get rid of this and merge with CaptureView.mm?
@implementation CaptureViewController

- (instancetype)initWithWindowId:(CGWindowID)wid
                            size:(CGSize)theSize
                    innerPadding:(CGFloat)innerPadding
                titleTextPadding:(CGFloat)titleTextPadding {
    self = [super init];
    if (self) {
        _wid = wid;
        size = theSize;

        CGRect viewFrame = NSMakeRect(0, 0, size.width + innerPadding * 2,
                                      size.height + innerPadding * 2 + titleTextPadding);
        CGRect captureFrame =
            NSMakeRect(innerPadding, innerPadding + titleTextPadding, size.width, size.height);

        NSStackView* stackView = [[NSStackView alloc] initWithFrame:viewFrame];
        stackView.wantsLayer = true;
        stackView.layer.cornerRadius = 9.0;

        // _captureView = [[CaptureView alloc] initWithFrame:captureFrame windowId:wid];
        // [stackView addSubview:_captureView];
        // _caCaptureView = [[CACaptureView alloc] initWithFrame:captureFrame windowId:wid];
        // [stackView addSubview:_caCaptureView];
        {
            SCStreamConfiguration* config = [[SCStreamConfiguration alloc] init];
            config.width = captureFrame.size.width * 2;
            config.height = captureFrame.size.height * 2;
            config.queueDepth = 8;
            config.showsCursor = false;
            config.pixelFormat = 'BGRA';
            config.colorSpaceName = kCGColorSpaceDisplayP3;

            SCWindow* targetWindow = [[SCWindow alloc] initWithId:wid];
            SCContentFilter* filter =
                [[SCContentFilter alloc] initWithDesktopIndependentWindow:targetWindow];

            _captureView = [[CapturePreview alloc] initWithFrame:captureFrame
                                                   configuration:config];
            [_captureView updateWithFilter:filter];
            [stackView addSubview:_captureView];
            // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
            //                ^{ [_captureView startCapture]; });
        }

        CFStringRef title;
        CGSCopyWindowProperty(CGSMainConnectionID(), wid, CFSTR("kCGSWindowTitle"), &title);
        titleText = [NSTextField labelWithString:(__bridge NSString*)title];
        titleText.frameOrigin = CGPointMake(innerPadding, 5);
        titleText.frameSize = CGSizeMake(size.width, 20);
        titleText.alignment = NSTextAlignmentCenter;
        // titleText.font = [NSFont systemFontOfSize:15];
        titleText.cell.lineBreakMode = NSLineBreakByTruncatingTail;
        [stackView addSubview:titleText];

        CGSConnectionID elementConnection;
        CGSGetWindowOwner(CGSMainConnectionID(), wid, &elementConnection);
        ProcessSerialNumber psn = ProcessSerialNumber();
        CGSGetConnectionPSN(elementConnection, &psn);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        FSRef fsRef;
        GetProcessBundleLocation(&psn, &fsRef);
        IconRef iconRef;
        GetIconRefFromFileInfo(&fsRef, 0, NULL, 0, NULL, kIconServicesNormalUsageFlag, &iconRef,
                               NULL);
        NSImage* icon = [[NSImage alloc] initWithIconRef:iconRef];
#pragma clang diagnostic pop

        iconView = [NSImageView imageViewWithImage:icon];
        iconView.frameSize = icon.size;
        iconView.frameOrigin = NSMakePoint(size.width - icon.size.width, 0);
        // iconView.wantsLayer = true;
        // iconView.layer.backgroundColor = NSColor.redColor.CGColor;
        [_captureView addSubview:iconView];

        self.view = stackView;
    }
    return self;
}

- (void)updateWithWindowId:(CGWindowID)wid {
    _wid = wid;

    SCWindow* targetWindow = [[SCWindow alloc] initWithId:wid];
    SCContentFilter* filter =
        [[SCContentFilter alloc] initWithDesktopIndependentWindow:targetWindow];
    [_captureView updateWithFilter:filter];

    CFStringRef title;
    CGSCopyWindowProperty(CGSMainConnectionID(), wid, CFSTR("kCGSWindowTitle"), &title);
    titleText.stringValue = (__bridge NSString*)title;

    CGSConnectionID elementConnection;
    CGSGetWindowOwner(CGSMainConnectionID(), wid, &elementConnection);
    ProcessSerialNumber psn = ProcessSerialNumber();
    CGSGetConnectionPSN(elementConnection, &psn);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    FSRef fsRef;
    GetProcessBundleLocation(&psn, &fsRef);
    IconRef iconRef;
    GetIconRefFromFileInfo(&fsRef, 0, NULL, 0, NULL, kIconServicesNormalUsageFlag, &iconRef, NULL);
    NSImage* icon = [[NSImage alloc] initWithIconRef:iconRef];
#pragma clang diagnostic pop
    iconView.image = icon;
}

- (void)highlight {
    self.view.layer.backgroundColor =
        [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.1f].CGColor;
}

- (void)unhighlight {
    self.view.layer.backgroundColor = CGColorGetConstantColor(kCGColorClear);
}

@end
