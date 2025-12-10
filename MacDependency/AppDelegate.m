//
//  AppDelegate.m
//  MacDependency
//
//  Application delegate to handle auto-opening MacDependency binary
//  and command-line argument processing.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // Get command line arguments from NSProcessInfo
    NSArray<NSString *> *arguments = [[NSProcessInfo processInfo] arguments];

    // arguments[0] is the executable path, so check if there are additional args
    if (arguments.count > 1) {
        // User provided file path(s) as arguments
        [self openFilesFromCommandLine:arguments];
    } else {
        // No arguments - auto-open MacDependency binary itself
        [self openDefaultFile];
    }
}

- (void)openFilesFromCommandLine:(NSArray<NSString *> *)arguments {
    // Skip first argument (executable path)
    for (NSInteger i = 1; i < arguments.count; i++) {
        NSString *filePath = arguments[i];

        // Convert to absolute path if needed
        if (![filePath isAbsolutePath]) {
            NSString *currentDir = [[NSFileManager defaultManager] currentDirectoryPath];
            filePath = [currentDir stringByAppendingPathComponent:filePath];
        }

        NSURL *fileURL = [NSURL fileURLWithPath:filePath];

        // Use NSDocumentController to open the document
        [[NSDocumentController sharedDocumentController]
            openDocumentWithContentsOfURL:fileURL
                                 display:YES
                       completionHandler:^(NSDocument *document, BOOL wasAlreadyOpen, NSError *error) {
            if (error) {
                NSLog(@"Error opening file %@: %@", filePath, error.localizedDescription);
                // Show error dialog to user
                [[NSAlert alertWithError:error] runModal];
            }
        }];
    }
}

- (void)openDefaultFile {
    // Get path to the MacDependency executable inside Contents/MacOS/
    NSString *executablePath = [[NSBundle mainBundle] executablePath];

    NSURL *fileURL = [NSURL fileURLWithPath:executablePath];

    // Open the executable using NSDocumentController
    [[NSDocumentController sharedDocumentController]
        openDocumentWithContentsOfURL:fileURL
                             display:YES
                   completionHandler:^(NSDocument *document, BOOL wasAlreadyOpen, NSError *error) {
        if (error) {
            NSLog(@"Error opening default file: %@", error.localizedDescription);
            // Don't show error dialog here - user didn't explicitly request this
        }
    }];
}

// Don't interfere with normal document opening via Finder
- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    // Return NO to let NSDocumentController handle it normally
    return NO;
}

@end
