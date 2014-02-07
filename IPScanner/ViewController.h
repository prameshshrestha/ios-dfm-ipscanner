//
//  ViewController.h
//  IPScanner
//
//  Created by pramesh on 2/7/14.
//  Copyright (c) 2014 pramesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,ZBarReaderDelegate>{
    NSMutableArray *arrBarcode;
    GCDAsyncSocket *asyncSocket;
    NSString *host;
    NSString *port;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnScanComputer;
@property (weak, nonatomic) IBOutlet UIButton *btnConnect;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIButton *btnScan;
- (IBAction)btnScan:(id)sender;

- (IBAction)btnScanComputer:(id)sender;

- (IBAction)btnConnect:(id)sender;

- (IBAction)btnSend:(id)sender;

@end
