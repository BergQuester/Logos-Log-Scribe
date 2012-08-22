//
//  Logos_Log_ScribeAppDelegate.h
//  Logos Log Scribe
//
//  Created by Daniel Bergquist on 10/20/10.
//  Copyright 2010 Mountain Branch Creations. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Logos_Log_ScribeAppDelegate : NSObject <NSApplicationDelegate> {
	NSWindow *window;
	IBOutlet NSTextField *errorField;
    IBOutlet NSButton *onlyConsoleCheckbox;
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)createLogPackage:(id)sender;

@end
