//
//  ViewController.m
//  IPScanner
//
//  Created by pramesh on 2/7/14.
//  Copyright (c) 2014 pramesh. All rights reserved.
//

#import "ViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "Reachability.h"

@interface ViewController ()

@end

@implementation ViewController{
    NSString *str;
    int rowNumber;
    NSString *myString;
    NSString *ipAddress;
}
uint16_t port = 5001;

@synthesize myTableView, btnScan, btnScanComputer, btnConnect, btnSend, btnWrist;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // check for wifi or internet connection
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == ReachableViaWiFi){
        NSLog(@"connected to WIFI");
    }
    else{
        UIAlertView *wifiAlert = [[UIAlertView alloc] initWithTitle:@"Not Connected" message:@"Could not connect to Server App, Try Again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [wifiAlert show];
    }
    
	arrBarcode = [[NSMutableArray alloc]init];
    
    myString = @"prameshshrestha|1|10123564789";
    
    // Set Title Image
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dfm_slogo.png"]];
    
    // Set background image
    UIImageView *img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"color_bg.png"]];
    [self.view addSubview:img];
    [self.view sendSubviewToBack:img];

    // Display btnScan
    UIImage * imgScan = [UIImage imageNamed:@"button_active.png"];
    [btnScan setBackgroundImage:imgScan forState:UIControlStateNormal];
    [btnScan setTitle:@"Scan" forState:UIControlStateNormal];
    
    // Display Scan Computer Button
    UIImage *imgScanComputer = [UIImage imageNamed:@"button_active.png"];
    [btnScanComputer setBackgroundImage:imgScanComputer forState:UIControlStateNormal];
    [btnScanComputer setTitle:@"Scan Computer" forState:UIControlStateNormal];
    
    // Display Connect
    UIImage *imgConnect = [UIImage imageNamed:@"button_active.png"];
    [btnConnect setBackgroundImage:imgConnect forState:UIControlStateNormal];
    [btnConnect setTitle:@"Connect to RST Scan" forState:UIControlStateNormal];
    
    // Display btnSend
    UIImage *imgSend = [UIImage imageNamed:@"button_active.png"];
    [btnSend setBackgroundImage:imgSend forState:UIControlStateNormal];
    [btnSend setTitle:@"Send Data" forState:UIControlStateNormal];
    
    // Display btnWrist
    UIImage *imgWrist = [UIImage imageNamed:@"button_active.png"];
    [btnWrist setBackgroundImage:imgWrist forState:UIControlStateNormal];
    [btnWrist setTitle:@"Wrist" forState:UIControlStateNormal];

    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    //get ip address of the device
    ipAddress= [self getIPAddress];
    NSLog(@"%@", ipAddress);
}

- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}
- (void) viewDidAppear:(BOOL)animated
{
    //host = self.txtServiceUrl.text;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *ip = [defaults objectForKey:@"ip"];
    NSString *uniqueId = [defaults objectForKey:@"uniqueId"];
    bool isWristEnabled = [defaults boolForKey:@"isWristEnabled"];
    
    if (!isWristEnabled){
        [btnWrist setHidden:YES];
    }
    else{
        [btnWrist setHidden:NO];
    }
    host = ip;
    udid = uniqueId;
}

// UITableView Delegate Methods
-(NSInteger)numberOfSectionsInTableView: (UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrBarcode count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell Identifier";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *barcode = [arrBarcode objectAtIndex:[indexPath row]];
    // Create custom color
    UIColor *color = [UIColor colorWithRed:0/255.0f green:150/255.0f blue:225/255.0f alpha:1.0f];
    cell.textLabel.textColor = color;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];    [cell.textLabel setText:barcode];
    [cell setBackgroundColor:[UIColor clearColor]];
    //UIButton *btn = [[UIButton alloc]init];
    //btn.frame = CGRectMake(200, 5.0, 50, 30);
    //btn.backgroundColor = [UIColor blackColor];
    //[btn setTitle:@"Send" forState:UIControlStateNormal];
    //[cell addSubview:btn];
    return cell;
}

// Set the identation for rows in UITableView
-(NSInteger) tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 5;
}

// Set the scroll in UITableView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = 10;
    if (y > h + reload_distance)
    {
        [self.myTableView reloadData];
    }
}

// Set the cell click
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    rowNumber = indexPath.row;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    str = cell.textLabel.text;
}

// Delete the data in each cell in UITableView
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [arrBarcode removeObjectAtIndex:indexPath.row];
        [self.myTableView reloadData];
    }
}

- (IBAction)btnScan:(id)sender {
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    ZBarImageScanner *scanner = reader.scanner;
    [scanner    setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    [self presentViewController:reader animated:YES completion:nil];
}

- (IBAction)btnScanComputer:(id)sender {
    ZBarReaderController *reeader = [ZBarReaderController new];
    reeader.readerDelegate = self;
    if ([ZBarReaderController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        reeader.sourceType = UIImagePickerControllerSourceTypeCamera;
    [reeader.scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    [self presentViewController:reeader animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)reeader didFinishPickingMediaWithInfo:(NSDictionary *)info{
    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for (symbol in results)
        break;
    //txtScannedBarcode.text = symbol.data;
    //str = txtScannedBarcode.text;
    str = symbol.data;
    if (symbol.data != nil){
        [arrBarcode addObject:str];
    }
    //resultImage.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.myTableView reloadData];
    [reeader dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnConnect:(id)sender {
    // Connect method goes here
    NSError *error = nil;
    if (![asyncSocket connectToHost:host onPort:port error:&error])
    {
       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Not Connected" message:@"Could not connect to Server App, Try Again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
       [alertView show];
        UIImage *imgNotConnected = [UIImage imageNamed:@"button_selected.png"];
        [btnConnect setBackgroundImage:imgNotConnected forState:UIControlStateNormal];
        [btnConnect setTitle:@"Not Connected" forState:UIControlStateNormal];
    }
}

- (IBAction)btnSend:(id)sender {
    NSString *string = [[NSString alloc] initWithFormat:@"%@",str];
    //NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    //[asyncSocket writeData:data withTimeout:-1 tag:0];
    [asyncSocket writeData:[myString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    //[asyncSocket readDataToData:[GCDAsyncSocket CRData] withTimeout:30.0 tag:0];
    //[asyncSocket didWriteDataWithTag:(long)string];
}

//GCDAsync Delegate method
-(void)socket:(GCDAsyncSocket*)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    [btnConnect setTitle:@"Connected" forState:UIControlStateNormal];
    [btnConnect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnConnect setEnabled:NO];
    [btnSend setEnabled:YES];
    NSLog(@"did connect to host");
    //UIAlertView *alertConnect = [[UIAlertView alloc] initWithTitle:@"Not Connected" message:@"Could not connect to Server App, Try Again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    //[alertConnect show];
}

-(void)socket:(GCDAsyncSocket*) sock didWriteDataWithTag:(long)tag{
    NSLog(@" did write data with tag %ld", tag);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Data Sent" message:@"Barcode has been successfully sent" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];}

-(void)socket:(GCDAsyncSocket*)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    NSLog(@"did accept new socket");
}

-(void)socket:(GCDAsyncSocket*)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    NSLog(@"did write partial data of length");
}

-(void)socketDidDisconnect:(GCDAsyncSocket*)sock withError:(NSError *)err
{
    NSLog(@"socket did disconnect with %@", err);
    UIAlertView *discoAlert = [[UIAlertView alloc]initWithTitle:@"Connection Error" message:@"Connection to the server failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [discoAlert show];
}

-(void)socketDidSecure:(GCDAsyncSocket*)sock{
    NSLog(@"socket did secure");
}

- (IBAction)btnWrist:(id)sender {
    // do something
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
