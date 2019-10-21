package com.ric.facebookshare;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.util.Log;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.share.Sharer;
import com.facebook.share.model.ShareContent;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.model.ShareMediaContent;
import com.facebook.share.model.ShareMessengerGenericTemplateContent;
import com.facebook.share.model.ShareMessengerGenericTemplateElement;
import com.facebook.share.model.ShareMessengerURLActionButton;
import com.facebook.share.widget.MessageDialog;
import com.facebook.share.widget.ShareDialog;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FacebookSharePlugin
 */
public class FacebookSharePlugin implements MethodCallHandler {
  private final Context context;
  private final Activity activity;
  private final CallbackManager callbackManager;
  private final String facebookPackageName = "com.facebook.orca";

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "facebook_share");
    channel.setMethodCallHandler(new FacebookSharePlugin(registrar));
  }

  private FacebookSharePlugin(Registrar registrar) {
    this.context = registrar.context();
    this.activity = registrar.activity();
    callbackManager = CallbackManager.Factory.create();

    registrar.addActivityResultListener(new PluginRegistry.ActivityResultListener() {
      @Override
      public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        callbackManager.onActivityResult(requestCode, resultCode, data);
        return true;
      }
    });
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("shareContent")) {
      String url = call.argument("url");
      String quote = call.argument("quote");

      shareContent(result, url, quote);
    } else if (call.method.equals("sendMessage")) {
      String urlActionTitle = call.argument("urlActionTitle");
      String url = call.argument("url");
      String title = call.argument("title");
      String subtitle = call.argument("subtitle");
      String imageUrl = call.argument("imageUrl");
      String pageId = call.argument("pageId");

      if (isPackageInstalled(this.context, facebookPackageName)) {
        sendMessage(result, urlActionTitle, url, title, subtitle, imageUrl, pageId);
      } else {
        result.error("Unavailable", "Messenger not Installed", null);
      }
    } else {
      result.notImplemented();
    }
  }

  private void shareContent(final Result result, String url, String quote) {
    ShareLinkContent.Builder builder = new ShareLinkContent.Builder();
    builder.setContentUrl(Uri.parse(url));
    if (quote != null && !quote.isEmpty()) builder.setQuote(quote);
    ShareDialog shareDialog = new ShareDialog(this.activity);
    shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {

      @Override
      public void onSuccess(Sharer.Result shareResult) {
        result.success(true);
      }

      @Override
      public void onCancel() {
        result.success(false);
      }

      @Override
      public void onError(FacebookException error) {
        result.error("FacebookException", error.getMessage(), null);
      }
    });
    shareDialog.show(builder.build(), ShareDialog.Mode.AUTOMATIC);
  }

  private void sendMessage(final Result result, String urlActionTitle, String url, String title, String subtitle, String imageUrl, String pageId) {
    ShareMessengerURLActionButton actionButton =
            new ShareMessengerURLActionButton.Builder()
                    .setTitle(urlActionTitle)
                    .setUrl(Uri.parse(url))
                    .build();

    ShareMessengerGenericTemplateElement.Builder genericTemplateElementBuilder =
            new ShareMessengerGenericTemplateElement.Builder();
    genericTemplateElementBuilder.setTitle(title);
    genericTemplateElementBuilder.setSubtitle(subtitle);

    if (imageUrl != null && !imageUrl.isEmpty()) genericTemplateElementBuilder.setImageUrl(Uri.parse(imageUrl));
    if (url != null && !url.isEmpty()) genericTemplateElementBuilder.setButton(actionButton);

    ShareMessengerGenericTemplateContent genericTemplateContent =
            new ShareMessengerGenericTemplateContent.Builder()
                    .setPageId(pageId) // Your page ID, required
                    .setGenericTemplateElement(genericTemplateElementBuilder.build())
                    .build();
    MessageDialog md = new MessageDialog(activity);
    md.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {

      @Override
      public void onSuccess(Sharer.Result shareResult) {
        result.success(true);
        Log.d("ricric", "onSuccess");
      }

      @Override
      public void onCancel() {
        result.success(false);
        Log.d("ricric", "onCancel");
      }

      @Override
      public void onError(FacebookException error) {
        result.success(false);
        Log.d("ricric", "error => " + error);
      }
    });
    if (md.canShow(genericTemplateContent)) {
//            md.show(activity, genericTemplateContent);
      MessageDialog.show(activity, genericTemplateContent);
    }
  }

  public static boolean isPackageInstalled(Context c, String targetPackage) {
    PackageManager pm = c.getPackageManager();
    try {
      PackageInfo info = pm.getPackageInfo(targetPackage, PackageManager.GET_META_DATA);
    } catch (PackageManager.NameNotFoundException e) {
      return false;
    }
    return true;
  }
}
