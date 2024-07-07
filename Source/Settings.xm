#import "../YTLitePlus.h"
#import "../Tweaks/YouTubeHeader/YTSettingsViewController.h"
#import "../Tweaks/YouTubeHeader/YTSearchableSettingsViewController.h"
#import "../Tweaks/YouTubeHeader/YTSettingsSectionItem.h"
#import "../Tweaks/YouTubeHeader/YTSettingsSectionItemManager.h"
#import "../Tweaks/YouTubeHeader/YTUIUtils.h"
#import "../Tweaks/YouTubeHeader/YTSettingsPickerViewController.h"
// #import "AppIconOptionsController.h"

// Basic switch item
#define BASIC_SWITCH(title, description, key) \
    [YTSettingsSectionItemClass switchItemWithTitle:title \
        titleDescription:description \
        accessibilityIdentifier:nil \
        switchOn:IsEnabled(key) \
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) { \
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:key]; \
            return YES; \
        } \
        settingItemId:0]

static BOOL IsEnabled(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}
static int GetSelection(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}
static int contrastMode() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"lcm"];
}
static int appVersionSpoofer() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"versionSpoofer"];
}

@interface YTSettingsSectionItemManager (YTLitePlus)
- (void)updateYTLitePlusSectionWithEntry:(id)entry;
@end

extern NSBundle *YTLitePlusBundle();

// Add both YTLite and YTLitePlus to YouGroupSettings
static const NSInteger YTLitePlusSection = 788;
static const NSInteger YTLiteSection = 789;
%hook YTSettingsGroupData
+ (NSMutableArray <NSNumber *> *)tweaks {
    NSMutableArray <NSNumber *> *originalTweaks = %orig;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [originalTweaks addObject:@(YTLitePlusSection)];
        [originalTweaks addObject:@(YTLiteSection)];
    });

    return originalTweaks;
}
%end


// Settings
%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound)
        [mutableOrder insertObject:@(YTLitePlusSection) atIndex:insertIndex + 1];
    return mutableOrder;
}
%end

%hook YTSettingsSectionController

- (void)setSelectedItem:(NSUInteger)selectedItem {
    if (selectedItem != NSNotFound) %orig;
}

%end

%hook YTSettingsSectionItemManager
%new(v@:@)
- (void)updateYTLitePlusSectionWithEntry:(id)entry {
    NSMutableArray *sectionItems = [NSMutableArray array];
    NSBundle *tweakBundle = YTLitePlusBundle();
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];

    YTSettingsSectionItem *main = [%c(YTSettingsSectionItem)
    itemWithTitle:[NSString stringWithFormat:LOC(@"VERSION"), @(OS_STRINGIFY(TWEAK_VERSION))]
    titleDescription:LOC(@"VERSION_CHECK")
    accessibilityIdentifier:nil
    detailTextBlock:nil
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/Balackburn/YTLitePlus/releases/latest"]];
    }];
    [sectionItems addObject:main];

/*
    YTSettingsSectionItem *appIcon = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"CHANGE_APP_ICON")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            AppIconOptionsController *appIconController = [[AppIconOptionsController alloc] init];
            [settingsViewController.navigationController pushViewController:appIconController animated:YES];
            return YES;
        }
    ];
    [sectionItems addObject:appIcon];
*/

# pragma mark - Video Controls Overlay Options
    YTSettingsSectionItem *videoControlOverlayGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"VIDEO_CONTROLS_OVERLAY_OPTIONS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            BASIC_SWITCH(LOC(@"ENABLE_SHARE_BUTTON"), LOC(@"ENABLE_SHARE_BUTTON_DESC"), @"enableShareButton_enabled"),
            BASIC_SWITCH(LOC(@"ENABLE_SAVE_TO_PLAYLIST_BUTTON"), LOC(@"ENABLE_SAVE_TO_PLAYLIST_BUTTON_DESC"), @"enableSaveToButton_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_SHADOW_OVERLAY_BUTTONS"), LOC(@"HIDE_SHADOW_OVERLAY_BUTTONS_DESC"), @"hideVideoPlayerShadowOverlayButtons_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_RIGHT_PANEL"), LOC(@"HIDE_RIGHT_PANEL_DESC"), @"hideRightPanel_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_HEATWAVES"), LOC(@"HIDE_HEATWAVES_DESC"), @"hideHeatwaves_enabled"),
            BASIC_SWITCH(LOC(@"SEEK_ANYWHERE"), LOC(@"SEEK_ANYWHERE_DESC"), @"seekAnywhere_enabled")
        ];        
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"VIDEO_CONTROLS_OVERLAY_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:videoControlOverlayGroup];

# pragma mark - App Settings Overlay Options
    YTSettingsSectionItem *appSettingsOverlayGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"APP_SETTINGS_OVERLAY_OPTIONS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            BASIC_SWITCH(LOC(@"HIDE_ACCOUNT_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableAccountSection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_AUTOPLAY_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableAutoplaySection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_TRYNEWFEATURES_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableTryNewFeaturesSection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_VIDEOQUALITYPREFERENCES_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableVideoQualityPreferencesSection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_NOTIFICATIONS_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableNotificationsSection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_MANAGEALLHISTORY_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableManageAllHistorySection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_YOURDATAINYOUTUBE_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableYourDataInYouTubeSection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_PRIVACY_SECTION"), LOC(@"APP_RESTART_DESC"), @"disablePrivacySection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_LIVECHAT_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableLiveChatSection_enabled")
        ];        
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"App Settings Overlay Options") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:appSettingsOverlayGroup];

# pragma mark - LowContrastMode
    YTSettingsSectionItem *lowContrastModeSection = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Low Contrast Mode")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (contrastMode()) {
                case 1:
                    return LOC(@"Hex Color");
                case 0:
                default:
                    return LOC(@"Default");
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"Default") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"lcm"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"Hex Color") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"lcm"];
                    [settingsViewController reloadData];
                    return YES;
                }]
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Low Contrast Mode") pickerSectionTitle:nil rows:rows selectedItemIndex:contrastMode() parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

# pragma mark - VersionSpooferLite
    YTSettingsSectionItem *versionSpooferSection = [YTSettingsSectionItemClass itemWithTitle:LOC(@"VERSION_SPOOFER_TITLE")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (appVersionSpoofer()) {
                case 1:
                    return @"v18.34.5 (Enable Library Tab)";
                case 2:
                    return @"v18.33.3 (Removes Playables)";
                case 3:
                    return @"v18.18.2 (Fixes YTClassicVideoQuality & YTSpeed)";
                case 4:
                    return @"v18.01.2 (First v18 Version)";
                case 5:
                    return @"v17.49.6 (Removes Rounded Miniplayer)";
                case 6:
                    return @"v17.38.10 (Fixes LowContrastMode)";
                case 7:
                    return @"v17.33.2 (Oldest Supported Version)";
                case 0:
                default:
                    return @"v18.49.3 (Last v18 Version)";
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.49.3 (Last v18 Version)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.34.5 (Enable Library Tab)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.33.3 (Removes Playables)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.18.2 (Fixes YTClassicVideoQuality & YTSpeed)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.01.2 (First v18 Version)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.49.6 (Removes Rounded Miniplayer)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.38.10 (Fixes LowContrastMode)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:6 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.33.2 (Oldest Supported Version)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:7 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }]
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:@"Version Spoofer Picker" pickerSectionTitle:nil rows:rows selectedItemIndex:appVersionSpoofer() parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

# pragma mark - Theme
    YTSettingsSectionItem *themeGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"THEME_OPTIONS")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (GetSelection(@"appTheme")) {
                case 1:
                    return LOC(@"OLED_DARK_THEME_2");
                case 2:
                    return LOC(@"OLD_DARK_THEME");
                case 0:
                default:
                    return LOC(@"DEFAULT_THEME");
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"DEFAULT_THEME") titleDescription:LOC(@"DEFAULT_THEME_DESC") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"appTheme"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"OLED_DARK_THEME") titleDescription:LOC(@"OLED_DARK_THEME_DESC") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"appTheme"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"OLD_DARK_THEME") titleDescription:LOC(@"OLD_DARK_THEME_DESC") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"appTheme"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                BASIC_SWITCH(LOC(@"OLED_KEYBOARD"), LOC(@"OLED_KEYBOARD_DESC"), @"oledKeyBoard_enabled"),
                BASIC_SWITCH(LOC(@"LOW_CONTRAST_MODE"), LOC(@"LOW_CONTRAST_MODE_DESC"), @"lowContrastMode_enabled"),
                lowContrastModeSection
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"THEME_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:GetSelection(@"appTheme") parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];
    [sectionItems addObject:themeGroup];

# pragma mark - Copy of Playback in feeds section - @bhackel
    // This section is hidden in vanilla YouTube when using the new settings UI, so
    // we can recreate it here
    YTSettingsSectionItem *playbackInFeedsGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"PLAYBACK_IN_FEEDS")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (GetSelection(@"inline_muted_playback_enabled")) {
                case 3:
                    return LOC(@"PLAYBACK_IN_FEEDS_WIFI_ONLY");
                case 1:
                    return LOC(@"PLAYBACK_IN_FEEDS_OFF");
                case 2:
                default:
                    return LOC(@"PLAYBACK_IN_FEEDS_ALWAYS_ON");
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"PLAYBACK_IN_FEEDS_OFF") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"inline_muted_playback_enabled"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"PLAYBACK_IN_FEEDS_ALWAYS_ON") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"inline_muted_playback_enabled"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"PLAYBACK_IN_FEEDS_WIFI_ONLY") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"inline_muted_playback_enabled"];
                    [settingsViewController reloadData];
                    return YES;
                }],
            ];
            // It seems values greater than 3 act the same as Always On (Index 1)
            int (^getInlineSelection)() = ^int() {
                int selection = GetSelection(@"inline_muted_playback_enabled") - 1;
                return selection > 3 ? 1 : selection;
            };
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"PLAYBACK_IN_FEEDS") pickerSectionTitle:nil rows:rows selectedItemIndex:getInlineSelection() parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }
    ];

# pragma mark - Miscellaneous
    YTSettingsSectionItem *miscellaneousGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"MISCELLANEOUS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            playbackInFeedsGroup,
            // BASIC_SWITCH(LOC(@"NEW_SETTINGS_UI"), LOC(@"NEW_SETTINGS_UI_DESC"), @"newSettingsUI_enabled"), // disabled because YTLite is probably forcing it to NO
            BASIC_SWITCH(LOC(@"ENABLE_YT_STARTUP_ANIMATION"), LOC(@"ENABLE_YT_STARTUP_ANIMATION_DESC"), @"ytStartupAnimation_enabled"), 
            BASIC_SWITCH(LOC(@"HIDE_MODERN_INTERFACE"), LOC(@"HIDE_MODERN_INTERFACE_DESC"), @"ytNoModernUI_enabled"),
            BASIC_SWITCH(LOC(@"IPAD_LAYOUT"), LOC(@"IPAD_LAYOUT_DESC"), @"iPadLayout_enabled"),
            BASIC_SWITCH(LOC(@"IPHONE_LAYOUT"), LOC(@"IPHONE_LAYOUT_DESC"), @"iPhoneLayout_enabled"),
            BASIC_SWITCH(LOC(@"CAST_CONFIRM"), LOC(@"CAST_CONFIRM_DESC"), @"castConfirm_enabled"),
            BASIC_SWITCH(LOC(@"NEW_MINIPLAYER_STYLE"), LOC(@"NEW_MINIPLAYER_STYLE_DESC"), @"bigYTMiniPlayer_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_CAST_BUTTON"), LOC(@"HIDE_CAST_BUTTON_DESC"), @"hideCastButton_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_SPONSORBLOCK_BUTTON"), LOC(@"HIDE_SPONSORBLOCK_BUTTON_DESC"), @"hideSponsorBlockButton_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_HOME_TAB"), LOC(@"HIDE_HOME_TAB_DESC"), @"hideHomeTab_enabled"),
            BASIC_SWITCH(LOC(@"FIX_CASTING"), LOC(@"FIX_CASTING_DESC"), @"fixCasting_enabled"),
            BASIC_SWITCH(LOC(@"ENABLE_FLEX"), LOC(@"ENABLE_FLEX_DESC"), @"flex_enabled"),
            BASIC_SWITCH(LOC(@"APP_VERSION_SPOOFER_LITE"), LOC(@"APP_VERSION_SPOOFER_LITE_DESC"), @"enableVersionSpoofer_enabled"),    
            versionSpooferSection
        ];
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"MISCELLANEOUS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:miscellaneousGroup];

    if ([settingsViewController respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)])
        [settingsViewController setSectionItems:sectionItems forCategory:YTLitePlusSection title:@"YTLitePlus" icon:nil titleDescription:LOC(@"TITLE DESCRIPTION") headerHidden:YES];
    else
        [settingsViewController setSectionItems:sectionItems forCategory:YTLitePlusSection title:@"YTLitePlus" titleDescription:LOC(@"TITLE DESCRIPTION") headerHidden:YES];}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == YTLitePlusSection) {
        [self updateYTLitePlusSectionWithEntry:entry];
        return;
    }
    %orig;
}
%end
