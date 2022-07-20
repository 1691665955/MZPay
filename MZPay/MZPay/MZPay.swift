//
//  MZPay.swift
//  MZPay
//
//  Created by 曾龙 on 2022/7/19.
//

import UIKit
import CommonCrypto
import mapoc

public enum MZPayFailureReason {
    case Wechat_Uninstalled
    case Wechat_Unsupport
    case Ohter
}

public class MZPay: NSObject, WXApiDelegate {
    private static let shareInstance: MZPay = MZPay()
    
    private var paySuccess: (() -> Void)?
    private var payFailure: ((MZPayFailureReason) -> Void)?
    
    //MARK: - 微信支付
    
    /// 微信支付
    /// - Parameters:
    ///   - mchid: 商户ID
    ///   - prepayId: 订单ID
    ///   - appid: 微信开放平台appId
    ///   - appKey: 微信开放平台appKey
    ///   - success: 微信支付成功（再通过服务器获取真实支付结果）
    ///   - failure: 微信支付失败
    public static func payWechat(mchid: String, prepayId: String, appid: String, appKey: String, success: @escaping () -> Void, failure: @escaping (MZPayFailureReason) -> Void) {
        if !WXApi.isWXAppInstalled() {
            failure(.Wechat_Uninstalled)
            return
        }
        if !WXApi.isWXAppSupport() {
            failure(.Wechat_Unsupport)
            return
        }
        
        MZPay.shareInstance.paySuccess = success
        MZPay.shareInstance.payFailure = failure
        
        let date = Date()
        let timestamp = String.init(format: "%.0f", date.timeIntervalSince1970)
        
        let request = PayReq.init()
        request.partnerId = mchid
        request.prepayId = prepayId
        request.package = "Sign=WXPay"
        request.nonceStr = MZPay.nonceNo()
        request.timeStamp = UInt32(timestamp)!
        request.sign = MZPay.wechatSign(mchid: mchid, prepayId: prepayId, appid: appid, appKey: appKey, package: request.package, noncestr: request.nonceStr, timestamp: timestamp)
        WXApi.send(request) { success in
            if !success {
                failure(.Ohter)
            }
        }
    }
    
    /// 微信注册（在AppDelegate didFinishLaunchingWithOptions中调用）
    /// - Parameters:
    ///   - appid: 微信开放平台appId
    ///   - universalLink: 微信开放平台注册app是填入的通用链接，用于跳转至本app
    public static func registerWechat(appid: String, universalLink: String) {
        WXApi.registerApp(appid, universalLink: universalLink)
    }
    
    /// 处理跳转链接（在AppDelegate openURL中调用）
    /// - Parameter url: 跳转链接
    /// - Returns: 操作结果
    public static func handleOpenURL(_ url: URL) -> Bool {
        if url.host == "safepay" {
            AlipaySDK.defaultService().processOrder(withPaymentResult: url) { result in
                if String.init(format: "%@", (result?["resultStatus"] as? String) ?? "") == "9000" {
                    MZPay.shareInstance.paySuccess?()
                } else {
                    MZPay.shareInstance.payFailure?(.Ohter)
                }
            }
            return true
        } else if url.host == "platformapi" {
            AlipaySDK.defaultService().processAuth_V2Result(url) { result in
                if String.init(format: "%@", (result?["resultStatus"] as? String) ?? "") == "9000" {
                    MZPay.shareInstance.paySuccess?()
                } else {
                    MZPay.shareInstance.payFailure?(.Ohter)
                }
            }
             return true
        } else {
            return WXApi.handleOpen(url, delegate: MZPay.shareInstance)
        }
    }
    
    /// 处理通用链接（在AppDelegate continue中调用）
    /// - Parameter userActivity: 用户操作
    /// - Returns: 操作结果
    public static func handleOpenUniversalLink(_ userActivity: NSUserActivity) -> Bool {
        return WXApi.handleOpenUniversalLink(userActivity, delegate: MZPay.shareInstance)
    }
    
    //MARK: - 支付宝支付
    
    /// 支付宝支付
    /// - Parameters:
    ///   - payURL: 支付链接
    ///   - appScheme: 本应用的URL Schemes
    ///   - success: 支付成功
    ///   - failure: 支付失败
    public static func payAli(payURL: String, appScheme: String, success: @escaping () -> Void, failure: @escaping (MZPayFailureReason) -> Void) {
        MZPay.shareInstance.paySuccess = success
        MZPay.shareInstance.payFailure = failure
        
        AlipaySDK.defaultService().payOrder(payURL, fromScheme: appScheme) { result in
            if String.init(format: "%@", (result?["resultStatus"] as? String) ?? "") == "9000" {
                success()
            } else {
                failure(.Ohter)
            }
        }
    }
    
    //MARK: - Private
    private static func wechatSign(mchid: String, prepayId: String, appid: String, appKey: String, package: String, noncestr: String, timestamp: String) -> String {
        var signParams: Dictionary<String, Any> = Dictionary<String, Any>()
        signParams["appid"] = appid
        signParams["prepayid"] = prepayId
        signParams["partnerid"] = mchid
        signParams["package"] = package
        signParams["noncestr"] = noncestr
        signParams["timestamp"] = timestamp
        var contentString: String = ""
        let keys = signParams.keys.sorted()
        for key in keys {
            contentString += "\(key)=\(signParams[key] ?? "")&"
        }
        contentString += "key=\(appKey)"
        return MZPay.md5(contentString)
    }
    
    private static func md5(_ string: String) -> String {
        let str = string.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(string.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        return String(format: hash as String)
    }
    
    private static func nonceNo() -> String {
        let kNumber = 15
        let sourceString = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var result = ""
        
        for _ in 0..<kNumber {
            let index = Int(arc4random_uniform(UInt32(sourceString.count)))
            result.append(String(sourceString[sourceString.index(sourceString.startIndex, offsetBy: index)...sourceString.index(sourceString.startIndex, offsetBy: index)]))
        }
        return result
    }
    
    //MARK: - WXApiDelegate
    public func onResp(_ resp: BaseResp) {
        if resp.isKind(of: PayResp.self) {
            switch (resp.errCode) {
            case WXSuccess.rawValue:
                MZPay.shareInstance.paySuccess?()
            default:
                MZPay.shareInstance.payFailure?(.Ohter)
            }
        }
    }
}

