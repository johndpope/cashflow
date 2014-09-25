// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "EditMemoVC.h"
#import "AppDelegate.h"

@implementation EditMemoViewController
{
    IBOutlet UITextView *_textView;
}

+ (EditMemoViewController *)editMemoViewController:(id<EditMemoViewDelegate>)delegate title:(NSString*)title identifier:(NSInteger)id
{
    EditMemoViewController *vc = [[EditMemoViewController alloc]
                                      initWithNibName:@"EditMemoView"
                                      bundle:[NSBundle mainBundle]];
    vc.delegate = delegate;
    vc.title = title;
    vc.identifier = id;

    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (IS_IPAD) {
        CGSize s = self.preferredContentSize;
        s.height = 480;
        self.preferredContentSize = s;
    }
    
    //textView.placeholder = self.title;
    _textView.backgroundColor = [UIColor whiteColor];
	
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewWillAppear:(BOOL)animated
{
    _textView.text = _text;
    [_textView becomeFirstResponder];
    [super viewWillAppear:animated];

    // キーボード通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // キーボード通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

// キーボード表示時の処理
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (!IS_IPAD) {
        // キーボード領域を計算
        CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        keyboardRect = [[self.view superview] convertRect:keyboardRect fromView:nil];

        // テキストビューのフレーム
        CGRect frame = _textView.frame;
        
        // 重なっている領域を計算
        float overlap = MAX(0.0, CGRectGetMaxY(frame) - CGRectGetMinY(keyboardRect));
        frame.size.height -= overlap;
        _textView.frame = frame;
    }
}

// キーボード非表示時の処理
- (void)keyboardWillHide:(NSNotification *)notification
{
    if (!IS_IPAD) {
        /*
        CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        keyboardRect = [[self.view superview] convertRect:keyboardRect fromView:nil];
    
        CGRect frame = _textView.frame;
        frame.size.height += keyboardRect.size.height;
        _textView.frame = frame;
         */
    }
}

// 自動でテキストをスクロールさせる
// 参考: http://craigipedia.blogspot.jp/2013/09/last-lines-of-uitextview-may-scroll.html
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    [textView scrollRangeToVisible:textView.selectedRange];
}

- (void)doneAction
{
    self.text = _textView.text;
    [_delegate editMemoViewChanged:self identifier:_identifier];

    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
