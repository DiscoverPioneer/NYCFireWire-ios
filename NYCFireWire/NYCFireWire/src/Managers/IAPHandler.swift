//
//  IAPHandler.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 3/30/19.
//  Copyright © 2019 Pioneer Mobile Applications, LLC. All rights reserved.
//

import Foundation
import StoreKit
import MerchantKit

//class IAPHandler {
//    static let shared = IAPHandler()
//
//    func purchaseMonthlySubscription() {
//        let purchase = merchant?.availablePurchasesTask().
//        print("PURCHASE = \(purchase)")
////        merchant?.commitPurchaseTask(for: <#T##Purchase#>)
////        let task = merchant.commitPurchaseTask(for: purchase)
////        task.onCompletion = { result in
////            switch result {
////            case .succeeded(_):
////                print("purchase completed")
////            case .failed(let error):
////                print("\(error)")
////            }
////        }
////
////        task.start()
//    }
//}

enum IAPHandlerAlertType{
    case disabled
    case restored
    case purchased

    func message() -> String{
        switch self {
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully bought this purchase!"
        }
    }
}

let AUTORENEW_SUBSCRIBE_PURCHASE_PRODUCT_ID = "com.nycfirewire.monthautorenew"

struct PioneerProduct {
    let id: String
    let price: String
}

protocol IAPHandlerDelegate {
    func purchaseTransactionComplete(success: Bool)
}

class IAPHandler: NSObject {
    static let shared = IAPHandler()
    var delegate: IAPHandlerDelegate?
//    let NON_CONSUMABLE_PURCHASE_PRODUCT_ID = "non.consumable"

    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var iapProducts = [SKProduct]()
    var allProducts = [PioneerProduct]()
    
    var purchaseStatusBlock: ((IAPHandlerAlertType) -> Void)?
    let merchant = (UIApplication.shared.delegate as? AppDelegate)!.merchant
    
    func isMonthlySubscriptionPurchased() -> Bool {
        
        if AppManager.shared.currentUser?.hasAdminAccess() == true || AppManager.shared.currentUser?.hasPremiumAccess() == true {
            print("Im an admin")
            return true
        }
        if let merchant = merchant, let product = merchant.product(withIdentifier: AUTORENEW_SUBSCRIBE_PURCHASE_PRODUCT_ID) {
            return merchant.state(for: product).isPurchased
        }
        return false
    }

    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }

    func purchaseMyProduct(index: Int){
        if iapProducts.count == 0 { return }

        if self.canMakePurchases() {
            let product = iapProducts[index]
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)

            print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier
        } else {
            purchaseStatusBlock?(.disabled)
        }
    }

    // MARK: - RESTORE PURCHASE
    func restorePurchase(){
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }


    // MARK: - FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts(){
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects: AUTORENEW_SUBSCRIBE_PURCHASE_PRODUCT_ID)
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
}

extension IAPHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver{
    // MARK: - REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        print("DID RECEIVE RESPONSE FOR PRODUCT REQUEST: \(response)")
        print(": \(response.invalidProductIdentifiers)")
        print(": \(response.products)")

        if (response.products.count > 0) {
            iapProducts = response.products
            allProducts.removeAll()
            for product in iapProducts{
                let numberFormatter = NumberFormatter()
                numberFormatter.formatterBehavior = .behavior10_4
                numberFormatter.numberStyle = .currency
                numberFormatter.locale = product.priceLocale
                guard let price1Str = numberFormatter.string(from: product.price) else {
                    return
                }
                print(product.localizedDescription + "\nfor just \(price1Str)")
                
                allProducts.append(PioneerProduct(id: product.productIdentifier, price: price1Str))
            }
        }
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        purchaseStatusBlock?(.restored)
    }

    // MARK:- IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    delegate?.purchaseTransactionComplete(success: true)
                    print("purchased")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseStatusBlock?(.purchased)
                    break

                case .failed:
                    print("failed")
                    delegate?.purchaseTransactionComplete(success: false)
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .restored:
                    print("restored")
                    delegate?.purchaseTransactionComplete(success: true)

                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break

                default: break
                }}}
    }
}
