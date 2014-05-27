//
//  SettingsViewController.h
//  IPScanner
//
//  Created by pramesh on 2/7/14.
//  Copyright (c) 2014 pramesh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtIP;
//@property (weak, nonatomic) IBOutlet UIButton *btnUdid;
@property (weak, nonatomic) IBOutlet UILabel *lblWrist;
//@property (weak, nonatomic) IBOutlet UITextField *txtUniqueId;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
- (IBAction)btnSave:(id)sender;

//- (IBAction)btnUdid:(id)sender;

@end
