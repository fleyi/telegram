//
//  ConnectionStatusViewControllerView.m
//  Telegram
//
//  Created by keepcoder on 03.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ConnectionStatusViewControllerView.h"
#import "TGTimer.h"
#import "MessagesViewController.h"
@interface ConnectionStatusViewControllerView ()
@property (nonatomic,strong) TMTextField *field;
@property (nonatomic,strong) TGTimer *animationTimer;
@property (nonatomic,strong) NSColor *backgroundColor;
@property (nonatomic,assign) NSRect origin;
@property (nonatomic,assign) BOOL isShown;
@end


@implementation ConnectionStatusViewControllerView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.wantsLayer = YES;
        self.origin = frame;
        
        self.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin | NSViewMaxYMargin | NSViewMaxXMargin | NSViewMinXMargin;
        
        self.field = [TMTextField defaultTextField];
        
        
        [self.field setTextColor:DARK_BLACK];
        
        self.field.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin;
        
        [self.field setFont:[NSFont fontWithName:@"HelveticaNeue" size:15]];
        
        [self addSubview:self.field];
        
        _state = ConnectingStatusTypeNormal;
        
        
        
    }
    return self;
}

-(BOOL)isFlipped {
    return YES;
}


static NSString *stateString[5];
static NSColor *stateColor[5];

-(void)setState:(ConnectingStatusType)state {
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stateColor[ConnectingStatusTypeConnecting] = NSColorFromRGB(0xe8bc5d);
        stateColor[ConnectingStatusTypeConnected] = NSColorFromRGB(0x81d36e);
        stateColor[ConnectingStatusTypeWaitingNetwork] = NSColorFromRGB(0xff7d70);
        stateColor[ConnectingStatusTypeUpdating] = NSColorFromRGB(0xe8bc5d);
        stateColor[ConnectingStatusTypeNormal] = NSColorFromRGB(0x81d36e);
        
        stateString[ConnectingStatusTypeConnecting] = NSLocalizedString(@"Connecting.Connecting",nil);
        stateString[ConnectingStatusTypeConnected] = NSLocalizedString(@"Connecting.Connecting",nil);
        stateString[ConnectingStatusTypeWaitingNetwork] = NSLocalizedString(@"Connecting.WaitingNetwork",nil);
        stateString[ConnectingStatusTypeUpdating] = NSLocalizedString(@"Connecting.Updating",nil);
        stateString[ConnectingStatusTypeNormal] = NSLocalizedString(@"Connecting.Updating",nil);
    });
    

    
    [LoopingUtils runOnMainQueueAsync:^{
        
        ConnectingStatusType oldState = _state;
        if(state == _state)
            return;
        
        self->_state = state;
        
        self.backgroundColor = [NSColor whiteColor]; // stateColor[state];
        
        [self setString:stateString[state]];
        
        [self setNeedsDisplay:YES];
        
        if(_state == ConnectingStatusTypeNormal || (oldState == ConnectingStatusTypeNormal && (_state == ConnectingStatusTypeConnected))) {
            [self hideAfter:0.1 withState:ConnectingStatusTypeNormal];
            return;
        } else {
            if(!self.isShown) {
                [self show:YES];
            }
        }
        
       
        
        if(self.state != ConnectingStatusTypeConnected) {
            [self startAnimation];
        } else {
            
            [self hideAfter:0.1 withState:ConnectingStatusTypeConnected];
        }
    
        
    }];
}

- (void)hideAfter:(float)time withState:(ConnectingStatusType)state {
    [self stopAnimation];
    dispatch_after_seconds(time, ^{
        if(_state == state) {
            [self hide:YES];
        }
    });
}

- (void)hide:(BOOL)animated {
    if(self.isShown || !animated) {
        self.isShown = NO;
        [self.delegate hideConnectionController:animated];
    }
}

- (void)show:(BOOL)animated {
    if(!self.isShown || !animated) {
        self.isShown = YES;
        [self.delegate showConnectionController:animated];
    }
}

- (void)setString:(NSString *)string update:(BOOL)update {
    [self.field setStringValue:string];
    
    [self.field sizeToFit];
    
    if(update)
    {
        [self.field setCenterByView:self];
        
        self.field.frame = NSOffsetRect(self.field.frame, 0, -2);
    }
    
}

-(void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    [self setString:self.field.stringValue update:YES];
}

- (void)setFrameOrigin:(NSPoint)newOrigin {
    [super setFrameOrigin:newOrigin];
    [self setString:self.field.stringValue update:YES];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [self setString:self.field.stringValue update:YES];
}


- (void)setString:(NSString *)string {
    [self setString:string update:YES];
}

- (void)startAnimation {
    if(!self.animationTimer) {
        self.animationTimer = [[TGTimer alloc] initWithTimeout:0.35 repeat:YES completion:^{
            
            
            NSMutableString *string = [self.field.stringValue mutableCopy];
            
            if([[string substringFromIndex:string.length - 3] isEqualToString:@"..."]) {
                string = [[string substringToIndex:string.length-3] mutableCopy];
            }
            
            [string appendString:@"."];
            
            [self setString:string update:NO];
            
            
        } queue:dispatch_get_main_queue()];
        
        [self.animationTimer start];
    }

}

- (void)stopAnimation {
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}

- (void)drawRect:(NSRect)dirtyRect
{
   // [super drawRect:dirtyRect];

    [self.backgroundColor setFill];
    
    NSRectFill(NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height -1));
    
}

@end
