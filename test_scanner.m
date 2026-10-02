#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *hashString = @"5ac938489f039d35fdafa3";
        NSScanner *scanner = [NSScanner scannerWithString:hashString];
        unsigned long long bundleIDHash = 0;
        BOOL success = [scanner scanHexLongLong:&bundleIDHash];
        BOOL isAtEnd = [scanner isAtEnd];
        NSLog(@"Success: %d, isAtEnd: %d, value: %llu, scanLocation: %lu", success, isAtEnd, bundleIDHash, (unsigned long)scanner.scanLocation);
    }
    return 0;
}
