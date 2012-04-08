#import <UIKit/UIKit.h>

/*
Platforms:

i386	Simulator

iPhone1,1    iPhone 1G
iPhone1,2    iPhone 3G
iPhone2,1    iPhone 3GS
iPhone3,1    iPhone 4
iPhone3,2    iPhone 4 Verizon
iPhone4,1    iPhone 4S

iPod1,1      iPod touch 1G
iPod2,1      iPod touch 2G
iPod3,1      iPod touch 3G
iPod4,1      iPod touch 4G

iPad1,1      iPad 1G
iPad2,1      iPad 2G WiFi
iPad2,2      iPad 2G GSM
iPad2,3      iPad 2G CDMA
iPad3,1      iPad 3G WiFi
iPad3,2      iPad 3G GSM
iPad3,3      iPad 3G CDMA
*/

@interface UIDevice(Hardware)
- (NSString *)platform;
@end

