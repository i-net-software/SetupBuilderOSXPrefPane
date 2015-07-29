//
//  Process.m
//  LaunchRocket
//
//  Created by Josh Butts on 1/24/14.
//  Copyright (c) 2014 Josh Butts. All rights reserved.
//

#import "Process.h"

@implementation Process

+ (NSString *)executableSudoName
{
    static NSString *sudoName;
    
    if ( sudoName == nil ) {
        NSString *plistPath = [NSString stringWithFormat:@"%@/Contents/Info.plist", [[NSBundle bundleForClass:[self class]] bundlePath]];
        NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        sudoName = [plist objectForKey:@"CFBundleExecutable"];
    }
    
    return sudoName;
}

-(NSString *) execute:(NSString *)command {
    NSLog(@"%@%@", @"Executing command: ", command);
    
    NSString *sudoHelperPath = [NSString stringWithFormat:@"%@/%@.app", [[NSBundle bundleForClass:[self class]] resourcePath], [Process executableSudoName]];
    NSMutableString *scriptSource = [NSMutableString stringWithFormat:@"tell application \"%@\"\n exec(\"%@\")\n end tell\n", sudoHelperPath, command];
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:scriptSource];
    NSDictionary *error;
    NSString *output = [[script executeAndReturnError:&error] stringValue];
    NSLog(@"Result of `%@` was %@", command, output);
    return output;
}

-(NSString *) executeSudo:(NSString *)command {
    NSLog(@"%@%@", @"Executing command with sudo: ", command);

    NSString *sudoHelperPath = [NSString stringWithFormat:@"%@/%@.app", [[NSBundle bundleForClass:[self class]] resourcePath], [Process executableSudoName]];
    NSMutableString *scriptSource = [NSMutableString stringWithFormat:@"tell application \"%@\"\n execsudo(\"%@\")\n end tell\n", sudoHelperPath, command];
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:scriptSource];
    NSDictionary *error;
    NSString *output = [[script executeAndReturnError:&error] stringValue];
    NSLog(@"Result of `sudo %@` was %@", command, output);
    return output;
}

+(void) killSudoHelper {
    NSLog(@"Killing helper");
    NSString *sudoHelperPath = [NSString stringWithFormat:@"%@/%@.app", [[NSBundle bundleForClass:[self class]] resourcePath], [Process executableSudoName]];
    NSString *scriptSource = [NSString stringWithFormat:@"tell application \"%@\"\n stopscript()\n end tell\n", sudoHelperPath];
    NSAppleScript *script = [[NSAppleScript new] initWithSource:scriptSource];
    [script executeAndReturnError:nil];
}


@end
