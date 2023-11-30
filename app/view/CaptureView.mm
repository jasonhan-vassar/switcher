#import "CaptureView.h"
#import "model/capture_engine.h"
#import "util/log_util.h"
#import <Cocoa/Cocoa.h>
#import <OpenGL/gl3.h>

// http://philjordan.eu/article/mixing-objective-c-c++-and-objective-c++
@interface CaptureView () {
    capture_engine* cap_engine;
}
@end

@implementation CaptureView

- (id)initWithFrame:(NSRect)frame targetWindow:(SCWindow*)window {
    NSOpenGLPixelFormatAttribute attribs[] = {
        NSOpenGLPFAAllowOfflineRenderers,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAColorSize,
        32,
        NSOpenGLPFADepthSize,
        24,
        NSOpenGLPFAMultisample,
        1,
        NSOpenGLPFASampleBuffers,
        1,
        NSOpenGLPFASamples,
        4,
        NSOpenGLPFANoRecovery,
        NSOpenGLPFAOpenGLProfile,
        NSOpenGLProfileVersion3_2Core,
        0,
    };

    NSOpenGLPixelFormat* pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
    if (!pf) {
        custom_log(OS_LOG_TYPE_ERROR, @"capture-view", @"failed to create pixel format");
        return nil;
    }

    self = [super initWithFrame:frame pixelFormat:pf];
    if (self) {
        targetWindow = window;
        hasStarted = false;
    }
    return self;
}

- (void)prepareOpenGL {
    [super prepareOpenGL];

    [self.openGLContext makeCurrentContext];
    glEnable(GL_MULTISAMPLE);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    GLint opacity = 0;
    [self.openGLContext setValues:&opacity forParameter:NSOpenGLCPSurfaceOpacity];
#pragma clang diagnostic pop

    cap_engine = new capture_engine(self.openGLContext, self.frame, targetWindow);
}

- (void)startCapture {
    if (hasStarted) return;

    if (!cap_engine->start_capture()) {
        custom_log(OS_LOG_TYPE_ERROR, @"capture-view", @"start capture failed");
    } else {
        hasStarted = true;
    }
}

- (void)stopCapture {
    if (!hasStarted) return;

    if (!cap_engine->stop_capture()) {
        custom_log(OS_LOG_TYPE_ERROR, @"capture-view", @"stop capture failed");
    } else {
        hasStarted = false;
    }
}

- (void)update {
    [super update];
    [self.openGLContext update];
}

@end
