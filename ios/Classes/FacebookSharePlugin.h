#import <Flutter/Flutter.h>

@interface FacebookSharePlugin : NSObject<FlutterPlugin>
{
    FlutterResult _resultHandler;
}

@property(strong, nonatomic, readwrite) FlutterResult resultHandler;
@end
