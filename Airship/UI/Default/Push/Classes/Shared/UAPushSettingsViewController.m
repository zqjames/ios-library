/*
 Copyright 2009-2010 Urban Airship Inc. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2. Redistributions in binaryform must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided withthe distribution.

 THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL URBAN AIRSHIP INC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UAPushSettingsViewController.h"
#import "UAPush.h"
#import "UAirship.h"


@implementation UAPushSettingsViewController

@synthesize tableView;
@synthesize datePicker;

@synthesize pushEnabledCell;
@synthesize pushEnabledSwitch;

@synthesize quietTimeEnabledCell;
@synthesize quietTimeSwitch;
@synthesize fromCell;
@synthesize toCell;
@synthesize timeFormat;

#pragma mark -
#pragma mark Lifecycle methods

- (void)dealloc {
    
    //TODO: this is horribly wrong
    
    self.pushEnabledSwitch = nil;
    
    [quietTimeSwitch release];
    [tableView release];
    [datePicker release];

    self.timeFormat = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [self initViews];
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    self.pushEnabledSwitch = nil;
    self.pushEnabledCell = nil;
    
    self.quietTimeSwitch = nil;
    self.quietTimeEnabledCell = nil;
    self.toCell = nil;
    self.fromCell = nil;
    
    self.tableView = nil;
    self.datePicker = nil;

    [super viewDidUnload];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (pushEnabledSwitch.on) {
        return SectionCount;
    } else {
        return SectionCount - 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionPushEnabled:
            return PushEnabledSectionRowCount;
        case SectionQuietTime:
        {
            if (pushEnabledSwitch.on && quietTimeSwitch.on) {
                return QuietTimeSectionRowCount;
            } else if (pushEnabledSwitch.on) {
                return 1;
            }
        }
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionQuietTime) {
        if (indexPath.row == QuietTimeSectionSwitchCell) {
            quietTimeEnabledCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return quietTimeEnabledCell;
        } else if (indexPath.row == QuietTimeSectionStartCell) {
            return fromCell;
        } else {
            return toCell;
        }
    } else if (indexPath.section == SectionPushEnabled) {
        return pushEnabledCell;
    }
    return nil;
}

#pragma mark -
#pragma mark UITableVieDelegate Methods
- (void)tableView:(UITableView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1 || indexPath.row == 2) {
        [self updateDatePicker:YES];
    } else {
        [self updateDatePicker:NO];
    }
}

#pragma mark -
#pragma mark logic

static NSString *cellID = @"QuietTimeCell";

- (void)initViews {
    self.title = @"Push Settings";
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                            target:self
                                                                                            action:@selector(quit)]
                                              autorelease];

    UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (type == UIRemoteNotificationTypeNone || ![UAPush shared].enabled) {
        pushEnabledSwitch.on = NO;
    } else {
        pushEnabledSwitch.on = YES;
    }

    if (self.timeFormat == nil) {
        self.timeFormat = @"hh:mm aaa";
    }
    
    fromCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    toCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    fromCell.textLabel.text = @"From";
    toCell.textLabel.text = @"To";

    
    NSDate *date1 = nil;
    NSDate *date2 = nil;
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    
    NSDictionary *quietTime = [[NSUserDefaults standardUserDefaults] objectForKey:kQuietTime];
    [formatter setDateFormat:@"HH:mm"];
    if (quietTime != nil) {
        UALOG(@"Quiet time dict found: %@ to %@", [quietTime objectForKey:@"start"], [quietTime objectForKey:@"end"]);
        quietTimeSwitch.on = YES;
        date1 = [formatter dateFromString:[quietTime objectForKey:@"start"]];
        date2 = [formatter dateFromString:[quietTime objectForKey:@"end"]];
    }
    
    if (date1 == nil || date2 == nil) {
        quietTimeSwitch.on = NO;
        date1 = [formatter dateFromString:@"00:00"];//default start
        date2 = [formatter dateFromString:@"06:00"];//default end //TODO: make defaults parameters
    }
    
    UALOG(@"Start: %@ End %@", date1, date2);

    [formatter setDateFormat:timeFormat];
    fromCell.detailTextLabel.text = [formatter stringFromDate:date1];
    toCell.detailTextLabel.text = [formatter stringFromDate:date2];

    NSDate *now = [[NSDate alloc] init];
    [datePicker setDate:now animated:YES];
    [now release];

    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGRect initBounds = datePicker.bounds;
    CGFloat statusBarOffset = [UIApplication sharedApplication].statusBarHidden ? 0 : 20;
    CGFloat navBarOffset = 0;
    if (self.navigationController && self.navigationController.isNavigationBarHidden == NO) {
        navBarOffset = 44;
    }
    pickerShownFrame = CGRectMake(0, screenBounds.size.height-initBounds.size.height-statusBarOffset-navBarOffset,
                                  screenBounds.size.width, initBounds.size.height);
    pickerHiddenFrame = CGRectMake(0, screenBounds.size.height-statusBarOffset-navBarOffset,
                                   screenBounds.size.width, initBounds.size.height);
    datePicker.frame = pickerHiddenFrame;
    [self.view setNeedsLayout];
}

- (IBAction)quit {
    
    if (dirty) {
        if (pushEnabledSwitch.on) {
            [self updateQuietTime];
        } else {
            [[UAPush shared] updateRegistration];
        }
        dirty = NO;
    }
    
    [UAPush closeApnsSettingsAnimated:YES];
}

- (IBAction)pickerValueChanged:(id)sender {

    dirty = YES;
    
    NSDate *date = [datePicker date];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:timeFormat];
    
    int row = [[self.tableView indexPathForSelectedRow] row];
    if (row == QuietTimeSectionStartCell) {
        fromCell.detailTextLabel.text = [formatter stringFromDate:date];
        [fromCell setNeedsLayout];
    } else if (row == QuietTimeSectionEndCell) {
        toCell.detailTextLabel.text = [formatter stringFromDate:date];
        [toCell setNeedsLayout];
    } else {
        NSDate *now = [[NSDate alloc] init];
        [datePicker setDate:now animated:YES];
        [now release];
        return;
    }
        
    //[self updateQuietTime];

}

- (IBAction)switchValueChanged:(id)sender {
    
    
//    if (sender == self.quietTimeSwitch) {
//        [self updateQuietTime];
//        [self updateDatePicker:NO];
//    } else if (sender == self.pushEnabledSwitch) {
//        
//        if (pushEnabledSwitch.on) {
//            UIRemoteNotificationType type
//                = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
//            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:type];
//        } else {
//            // Urban server will unregister this device token with apple server.
//            [[UAirship shared] unRegisterDeviceToken];
//        }
//        [self updateDatePicker:NO];
//    }
    
    dirty = YES;
    
    if (!quietTimeSwitch.on || !pushEnabledSwitch.on) {
        [self updateDatePicker:NO];
    }
    [self.tableView reloadData];

}

- (void)updateDatePicker:(BOOL)show {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    if (show) {
        datePicker.frame = pickerShownFrame;
    } else {
        datePicker.frame = pickerHiddenFrame;
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    }
    [UIView commitAnimations];

    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:timeFormat];
    NSString *fromString = fromCell.detailTextLabel.text;
    NSString *toString = toCell.detailTextLabel.text;

    int row = [[self.tableView indexPathForSelectedRow] row];
    if (row == 1 && [fromString length] != 0) {
        NSDate *fromDate = [formatter dateFromString:fromString];
        [datePicker setDate:fromDate animated:YES];
    } else if (row == 2 && [toString length] != 0) {
        NSDate *toDate = [formatter dateFromString:toString];
        [datePicker setDate:toDate animated:YES];
    }
}

- (void)updateQuietTime {
    
    if (quietTimeSwitch.on) {
        
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:timeFormat];
        
        NSString *fromString = fromCell.detailTextLabel.text;
        NSString *toString = toCell.detailTextLabel.text;
        NSDate *fromDate = [formatter dateFromString:fromString];
        NSDate *toDate = [formatter dateFromString:toString];
        
        UALOG(@"Start String: %@", fromString);
        UALOG(@"End String: %@", toString);
        
        [[UAPush shared] setQuietTimeFrom:fromDate to:toDate withTimeZone:[NSTimeZone localTimeZone]];
    } else {
        [[UAPush shared] disableQuietTime];
    }
    

}

@end