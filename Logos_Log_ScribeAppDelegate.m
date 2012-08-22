//
//  Logos_Log_ScribeAppDelegate.m
//  Logos Log Scribe
//
//  Created by Daniel Bergquist on 10/20/10.
//  Copyright 2010 Mountain Branch Creations. All rights reserved.
//

#import "Logos_Log_ScribeAppDelegate.h"

@implementation Logos_Log_ScribeAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}

-(float)titleBarHeight
{
    NSRect frame = NSMakeRect (0, 0, 389, 100);
    
    NSRect contentRect = [NSWindow contentRectForFrameRect:frame
                                                 styleMask:NSTitledWindowMask];
    
    return (frame.size.height - contentRect.size.height);
}

-(void)setErrorString:(NSString*)error
{
    [errorField setStringValue:error];
    
    // Resize window
    NSRect frame = NSMakeRect (window.frame.origin.x, window.frame.origin.y, 389, 100);
    
    if ([error isEqual:@""])
    {
        [errorField setEnabled:NO];
        frame.size.height = 94.0 + [self titleBarHeight];
    } else {
        [errorField setEnabled:YES];
        frame.size.height = 141.0 + [self titleBarHeight];
    }
    
    // make sure the window's title bar stays put
    frame.origin.y = frame.origin.y + window.frame.size.height - frame.size.height;

    [[window animator] setFrame:frame display:YES];
}

-(void)awakeFromNib
{
    [self setErrorString:@""];
}

-(void)setError:(NSError*)error
{
	[self setErrorString:[error localizedDescription]];
}

-(BOOL)dumpConsoleToFileAtPath:(NSString*)consoleMessagesPath
{
    NSError *error = nil;
    
	// delete first
	if ([[NSFileManager defaultManager] fileExistsAtPath:consoleMessagesPath])
		[[NSFileManager defaultManager] removeItemAtPath:consoleMessagesPath error:&error];
	
	[[NSFileManager defaultManager] createFileAtPath:consoleMessagesPath contents:nil attributes:nil];
	
	// Dump Console Messages
	NSTask *dumpConsoleMessages = [[NSTask alloc] init];
	[dumpConsoleMessages setLaunchPath:@"/usr/bin/syslog"]; 
	[dumpConsoleMessages setArguments:[NSArray arrayWithObject:@"-C"]];
	
	if (error) {
		[self setError:error];
		[dumpConsoleMessages release];
		return NO;
	}
	
	NSFileHandle *consoleOut = [NSFileHandle fileHandleForWritingAtPath:consoleMessagesPath];
	if (!consoleOut) {
		[self setErrorString:@"File handle is nil."];
		[dumpConsoleMessages release];
		return NO;
	}
	
	[dumpConsoleMessages setStandardOutput:consoleOut];
	[dumpConsoleMessages launch];
	[dumpConsoleMessages waitUntilExit];
	[dumpConsoleMessages release];
	
	return YES;
}

-(void)gzipItemAtPath:(NSString*)path
{
    NSString *desktopPath = [@"~/Desktop" stringByExpandingTildeInPath];
    
    // Zip logs
	NSTask *zipLogs = [[[NSTask alloc] init] autorelease];
	[zipLogs setLaunchPath:@"/usr/bin/tar"];
    
    NSString *fileName = [NSString stringWithFormat:@"LogosLogs %@ %@.gz", NSFullUserName(), [[NSDate date] descriptionWithCalendarFormat:@"%Y%m%d-%H%M%S" timeZone:nil locale:nil]];

	[zipLogs setArguments:[NSArray arrayWithObjects:@"-czf", [desktopPath stringByAppendingPathComponent:fileName], [path lastPathComponent], nil]];
	[zipLogs setCurrentDirectoryPath:[path stringByDeletingLastPathComponent]];
	[zipLogs launch];
}

-(void)packageConsoleMessagesAndLogosLogs
{    
	// Create paths
	NSString *logosLogsDir = [@"~/Library/Application Support/Logos4/Logging" stringByExpandingTildeInPath];
		
	// Check and prep path
	NSString *consoleMessagesPath = [logosLogsDir stringByAppendingPathComponent:@"Console Messages.log"];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:logosLogsDir]){
		[self setErrorString:@"No Logos logs for this user. Please reproduce your issue with Logos first."];
		return;
	}
	
    if (![self dumpConsoleToFileAtPath:consoleMessagesPath])
        return;
    
    [self gzipItemAtPath:logosLogsDir];
    [self setErrorString:@""];
}

-(void)packageConsoleMessages
{
    NSString *tempFilePath = NSTemporaryDirectory();
    tempFilePath = [tempFilePath stringByAppendingPathComponent:@"Console Messages.log"];
        
    [self dumpConsoleToFileAtPath:tempFilePath];
    [self gzipItemAtPath:tempFilePath];
    [self setErrorString:@""];
}

-(IBAction)createLogPackage:(id)sender
{
    if ([onlyConsoleCheckbox state] == NSOnState)
        [self packageConsoleMessages];
    else
        [self packageConsoleMessagesAndLogosLogs];
}

@end
