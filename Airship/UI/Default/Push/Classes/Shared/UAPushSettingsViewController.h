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

#import <UIKit/UIKit.h>

enum {
    SectionPushEnabled = 0,
    SectionQuietTime   = 1,
    SectionCount       = 2
};

enum {
    PushEnabledSectionSwitchCell = 0,
    PushEnabledSectionRowCount   = 1
};

enum {
    QuietTimeSectionSwitchCell  = 0,
    QuietTimeSectionStartCell   = 1,
    QuietTimeSectionEndCell     = 2,
    QuietTimeSectionRowCount    = 3
};

@interface UAPushSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView  *tableView;
    
    IBOutlet UITableViewCell *pushEnabledCell;
    IBOutlet UISwitch *pushEnabledSwitch;
    
    IBOutlet UITableViewCell *quietTimeEnabledCell;
    IBOutlet UISwitch *quietTimeSwitch;
    UITableViewCell *fromCell;
    UITableViewCell *toCell;

    IBOutlet UIDatePicker *datePicker;
    CGRect pickerShownFrame, pickerHiddenFrame;
    
    NSString *timeFormat;
    
    BOOL dirty;
}

@property (nonatomic, retain)UITableView *tableView;
@property (nonatomic, retain)UIDatePicker *datePicker;

@property (nonatomic, retain)UITableViewCell *pushEnabledCell;
@property (nonatomic, retain)UISwitch *pushEnabledSwitch;

@property (nonatomic, retain)UITableViewCell *quietTimeEnabledCell;
@property (nonatomic, retain)UISwitch *quietTimeSwitch;
@property (nonatomic, retain)UITableViewCell *fromCell;
@property (nonatomic, retain)UITableViewCell *toCell;
@property (nonatomic, copy)NSString *timeFormat;


- (IBAction)quit;
- (IBAction)pickerValueChanged:(id)sender;
- (IBAction)switchValueChanged:(id)sender;

// Private Methods
- (void)initViews;
- (void)updateDatePicker:(BOOL)show;
- (void)updateQuietTime;

@end