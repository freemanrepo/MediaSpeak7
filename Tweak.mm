#import <AVFoundation/AVFoundation.h>
#import "SBMediaController.h"

NSString *nowPlayingTitle;

static BOOL enabled;
static BOOL speakArtist;
static BOOL speakAlbum;
static float speechRate;
// static NSString *voiceType;
static void reloadConfig() {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.freemanrepo.mediaspeak7.plist"];
	enabled = [[dict objectForKey:@"tweakEnabled"] boolValue];
	speakArtist = [[dict objectForKey:@"speakArtist"] boolValue];
	speakAlbum = [[dict objectForKey:@"speakAlbum"] boolValue];
	speechRate = [[dict objectForKey:@"speechRate"] floatValue];
	// voiceType = [dict objectForKey:@"voiceType"];
	// NSLog(@"%@", voiceType);
	[dict release];
}

@interface SBLockScreenViewController
- (void)welcomeMediaSpeak7;
@end

%hook SBMediaController

- (void)setNowPlayingInfo:(id)arg1
{
	%orig;
	if (enabled)
	{
		if ([self checkForInfoChange])
		{
			[self speakSongInfo];
		}
	}
}

%new
- (BOOL)checkForInfoChange
{
	BOOL infoChanged = NO;
	SBMediaController *mediaController = [%c(SBMediaController) sharedInstance];
	if ((mediaController.nowPlayingTitle != nowPlayingTitle) && ![mediaController.nowPlayingTitle isEqualToString:nowPlayingTitle]) {
		[nowPlayingTitle release];
		nowPlayingTitle = [mediaController.nowPlayingTitle copy];
		if (mediaController.nowPlayingTitle == nil) {
			infoChanged = NO;
		} else {
			infoChanged = YES;
		}
	}
	if (infoChanged)
	{
		return YES;
	} else
	{
		return NO;
	}
}

%new
- (void)speakSongInfo
{
	SBMediaController *mediaController = [%c(SBMediaController) sharedInstance];
	NSString *string = [NSString stringWithFormat:@"Now playing: %@", nowPlayingTitle];
	if (speakAlbum)
		string = [string stringByAppendingString:[NSString stringWithFormat:@" (%@)", mediaController.nowPlayingAlbum]];
	if (speakArtist)
		string = [string stringByAppendingString:[NSString stringWithFormat:@" by %@", mediaController.nowPlayingArtist]];
	AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
	synthesizer.delegate = self;
	AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:string];
	// if (voiceType)	utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:voiceType];
	if (speechRate)	[utterance setRate:speechRate];
	[synthesizer speakUtterance:utterance];
}

%new
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
	[self togglePlayPause];
}

%end

%hook SBLockScreenViewController
- (void)viewDidDisappear:(BOOL)fp8
{
    %orig;
    NSString *prefsPath = @"/private/var/mobile/Library/Preferences/com.freemanrepo.mediaspeak7.plist";
	NSMutableDictionary *prefsDict;
	prefsDict = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsPath];
    
	if (![prefsDict objectForKey:@"firstRespring"])
	{
        [prefsDict setObject:@"ya" forKey:@"firstRespring"];
        [prefsDict writeToFile:@"/private/var/mobile/Library/Preferences/com.freemanrepo.mediaspeak7.plist" atomically:YES];
        [self welcomeMediaSpeak7];
	}
	[prefsDict release];
}

%new
- (void)welcomeMediaSpeak7
{
    [[[UIAlertView alloc] initWithTitle:@"MediaSpeak7" message:@"Thanks for installing MediaSpeak7!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Configure MediaSpeak7", nil] show];
}

%new
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
	if (buttonIndex != [alertView cancelButtonIndex]) {
 		if([title isEqualToString:@"Configure MediaSpeak7"])
		{
			if (![[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/PreferenceOrganizer2.dylib"])
	            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=MediaSpeak7"]];
	        else
	            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Tweaks&path=MediaSpeak7"]];
		}
  	}
}
%end


%ctor 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	%init;
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadConfig, CFSTR("com.freemanrepo.mediaspeak7/reload"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	reloadConfig();
	[pool drain];
}