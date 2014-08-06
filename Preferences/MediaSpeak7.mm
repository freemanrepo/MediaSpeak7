#import <Preferences/Preferences.h>
#import <UIKit/UIKit.h>
#import <Social/Social.h>

@interface MediaSpeak7ListController: PSListController {
}
@end

@implementation MediaSpeak7ListController
- (id)specifiers {
	if(_specifiers == nil) {
		UILongPressGestureRecognizer *shareLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
		UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];

		[rightButton addGestureRecognizer:shareLongPress];
		[shareLongPress release];
		[rightButton addTarget:self
		   action:@selector(tweetMe)
		                forControlEvents:UIControlEventTouchUpInside];
		[rightButton setBackgroundImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/MediaSpeak7.bundle/Heart@2x.png"] forState:UIControlStateNormal];

		rightButton.frame = CGRectMake(0.0, 0.0, 41.0, 40.0);
		UIBarButtonItem *rightBarButton =[[UIBarButtonItem alloc] initWithCustomView:rightButton];
		[[self navigationItem] setRightBarButtonItem: rightBarButton];
		[rightBarButton release];

		_specifiers = [[self loadSpecifiersFromPlistName:@"MediaSpeak7" target:self] retain];
	}
	return _specifiers;
}

- (void)donateBtn
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://freemanrepo.me/donate"]];
}

- (void)followTwitter
{
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:@"freemanrepo"]]];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:@"freemanrepo"]]];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:@"freemanrepo"]]];
	}
}

- (void)tweetMe
{

	NSString* initialText = @"I'm using MediaSpeak7 by @freemanrepo and I'm loving it!" ;
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
		SLComposeViewController *twitterComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
		[twitterComposer addURL:[NSURL URLWithString:@"http://github.com/freemanrepo/MediaSpeak7"]];
		[twitterComposer setInitialText:initialText];
		[twitterComposer setCompletionHandler:^(SLComposeViewControllerResult result) {
		        [self.parentController dismissModalViewControllerAnimated:YES];
		}];
		[self.parentController presentViewController:twitterComposer animated:YES completion:nil];

	}
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture {

	if ( gesture.state == UIGestureRecognizerStateBegan )
	{
		NSString* texttoshare =@"Check out MediaSpeak7 by Majd Alfhaily";
		NSURL *urlToShare = [NSURL URLWithString:@"http://github.com/freemanrepo/MediaSpeak7"];

		NSArray *activityItems = [NSArray arrayWithObjects:texttoshare,urlToShare,nil];
		UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
		[self.parentController presentViewController:activityVC animated:YES completion:nil];
	}
}

@end
