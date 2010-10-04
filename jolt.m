#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/pwr_mgt/IOPMLib.h>

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	IOPMAssertionID assertionID;
	char c;
	
	// Default is no idle sleep
	CFStringRef assertion = kIOPMAssertionTypeNoIdleSleep;
	BOOL should_fork = NO;
	
	opterr = 0;
	while ((c = getopt(argc, (char **)argv, "df")) != -1) {
		switch (c) {
			case 'd':
				assertion = kIOPMAssertionTypeNoDisplaySleep;
				break;
			case 'f':
				should_fork = YES;
				break;
			case '?':
				NSLog(@"Usage: jolt [-d][-n]");
				NSLog(@"   -d : prevent display from sleeping (also prevents computer from sleeping");
				NSLog(@" by default, jolt will prevent the system from sleeping, but the display will sleep normally.");
				NSLog(@"   -f : fork from calling tty");
				NSLog(@" by default, jolt will block until killed, and writes its pid to /tmp/jolt.pid for killing");
				return(-1);
				break;
			default:
				break;
		}		
	}
	
	if (should_fork) {
		pid_t myPid = fork();
		if (myPid < 0)
			exit(1); // can't fork
		if (myPid > 0)
			exit(0); // parent exit
		
		// child
		setsid();		
	}

	IOReturn returnValue = IOPMAssertionCreateWithName(assertion, kIOPMAssertionLevelOn, CFSTR("Powered by Jolt"), &assertionID);
	
	if (returnValue == kIOReturnSuccess) {
		if (assertion == kIOPMAssertionTypeNoIdleSleep) {
			NSLog(@"Jolt Injected - System won't sleep");
		} else {
			NSLog(@"Jolt Injected - Display won't sleep");			
		}
		
	}
	
	// Wait to be killed
	pause();
	
    [pool drain];
    return 0;
}
