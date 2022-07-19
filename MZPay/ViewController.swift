//
//  ViewController.swift
//  MZPay
//
//  Created by 曾龙 on 2022/7/18.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func wechatPay(prepayId: String) {
        MZPay.payWechat(mchid: "", prepayId: prepayId, appid: "", appKey: "") {
            NSLog("支付成功")
        } failure: { reason in
            NSLog("支付失败")
        }
    }
    
    func aliPay(payURL: String) {
        MZPay.payAli(payURL: payURL, appScheme: "") {
            NSLog("支付成功")
        } failure: { reason in
            NSLog("支付失败")
        }
    }
}

