//
//  SettingsViewController.m
//  IPScanner
//
//  Created by pramesh on 2/7/14.
//  Copyright (c) 2014 pramesh. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController{
    BOOL isWristEnabled;
}
@synthesize txtIP, btnSave;//, btnUdid, txtUniqueId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"color_bg.png"]];
    [self.view addSubview:img];
    [self.view sendSubviewToBack:img];
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dfm_slogo.png"]];
    // create a uiswitch programatically
    UISwitch *yourSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(240, 135, 0, 0)];
    [yourSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:yourSwitch];
    // Display btnSave
    UIImage *imgSave = [UIImage imageNamed:@"button_active.png"];
    [btnSave setBackgroundImage:imgSave forState:UIControlStateNormal];
    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    // Display btnUdid
    //UIImage *imgUdid = [UIImage imageNamed:@"button_active.png"];
    //[btnUdid setBackgroundImage:imgUdid forState:UIControlStateNormal];
    //[btnUdid setTitle:@"Generate Unique ID" forState:UIControlStateNormal];
    // nsuserdefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *ip = [defaults objectForKey:@"ip"];
    //NSString *uniqueId = [defaults objectForKey:@"uniqueId"];
    isWristEnabled = [defaults boolForKey:@"isWristEnabled"];
    txtIP.text = ip;
    //txtUniqueId.text = uniqueId;
    
    if (isWristEnabled){
        [yourSwitch setOn:YES animated:YES];
        //[yourSwitch isOn];
    }

}

-(void)changeSwitch:(id)sender{
    if ([sender isOn]){
        isWristEnabled = YES;
    }
    else{
        isWristEnabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)btnSave:(id)sender {
    [txtIP resignFirstResponder];
    //[txtUniqueId resignFirstResponder];
    
    // Save data using NSUserDefault
    NSString *ip = [txtIP text];
    //NSString *uniqueId = [txtUniqueId text];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:ip forKey:@"ip"];
    //[defaults setObject:uniqueId forKey:@"uniqueId"];
    //[defaults setBool:isWristEnabled forKey:@"isWristEnabled"];
    [defaults setBool:isWristEnabled forKey:@"isWristEnabled"];
    [defaults synchronize];
    UIAlertView *saveAlert = [[UIAlertView alloc]initWithTitle:@"Data Saved"
                                                       message:@"Data has been successfully saved" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [saveAlert show];
}

//- (IBAction)btnUdid:(id)sender {
    // create udid
    //CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    //CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    //NSString *uuid = [NSString stringWithString:(__bridge NSString *)
      //                uuidStringRef];
    //txtUniqueId.text = uuid;
//}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [txtIP resignFirstResponder];
    //[txtUniqueId resignFirstResponder];
    return true;
}

@end
