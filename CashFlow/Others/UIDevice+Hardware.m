#import "UIDevice+Hardware.h"
#include <sys/sysctl.h>

@implementation UIDevice(Hardware)
- (NSString *)platform
{
    static NSString *_platform = nil;
    
    if (_platform == nil) {
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);

        char *buf = malloc(size);
        sysctlbyname("hw.machine", buf, &size, NULL, 0);
        
        _platform = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
        
        free(buf);
    }
    return _platform;
}

@end
