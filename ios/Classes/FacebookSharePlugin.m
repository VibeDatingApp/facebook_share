#import "FacebookSharePlugin.h"
#import <FBSDKShareKit/FBSDKShareDialog.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKMessageDialog.h>

@implementation FacebookSharePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"facebook_share"
                                     binaryMessenger:[registrar messenger]];
    FacebookSharePlugin* instance = [[FacebookSharePlugin alloc] init];
    
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *method = call.method;
    NSString *url = call.arguments[@"url"];
    NSString *quote = call.arguments[@"quote"];
    
    if ([@"shareContent" isEqualToString:method]) {
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString: url];
        content.quote = quote;
        self.resultHandler = result;
        
        FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
        
        if ([UIApplication sharedApplication].keyWindow.rootViewController == (id)[NSNull null] )  {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"FlutterViewController"];
            UIWindow *window = [UIApplication sharedApplication].delegate.window;
            UINavigationController *x = [[UINavigationController alloc] initWithRootViewController:vc];
            window.rootViewController = x;
            dialog.fromViewController = x;
        } else {
            dialog.fromViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        }
        
        
        dialog.shareContent = content;
        dialog.delegate = self;
        dialog.mode = FBSDKShareDialogModeAutomatic;
        
        [dialog show];
        
    } else if ([@"sendMessage" isEqualToString:method]) {
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString: url];
        
        FBSDKMessageDialog *messageDialog = [[FBSDKMessageDialog alloc] init];
        messageDialog.shareContent = content;

        if ([messageDialog canShow]) {
            [messageDialog show];
        }   else {
            result([FlutterError errorWithCode:@"unavailable"
                                       message:@"not_installed"
                                       details:nil]);
        }
        // if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb-messenger://"]]) {
        //     self.resultHandler = result;
        //     [FBSDKMessageDialog showWithContent:content delegate:nil];
        // } else {
        //     result([FlutterError errorWithCode:@"unavailable"
        //                                message:@"not_installed"
        //                                details:nil]);
        // }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results{
    self.resultHandler(@YES);
    self.resultHandler = nil;
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    self.resultHandler(@NO);
    self.resultHandler = nil;
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    self.resultHandler([FlutterError errorWithCode:@"unavailable"
                                           message:error.localizedDescription
                                           details:nil]);
    self.resultHandler = nil;
}

@end
