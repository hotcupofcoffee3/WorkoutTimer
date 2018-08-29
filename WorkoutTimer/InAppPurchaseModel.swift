//
//  InAppPurchaseModel.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 8/29/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import StoreKit

class InAppPurchaseService: NSObject {
    
    // Overrides the init() and makes it private, so that no other instance can be made.
    private override init() {}
    
    // Creates the singleton for it.
    static let shared = InAppPurchaseService()
    
    let keywords = Keywords()
    
    // Gets filled with the products from the product request called below.
    var products = [SKProduct]()
    
    // Gets set up with the payment that we send in the 'purchaseProduct' function below.
    let paymentQueue = SKPaymentQueue.default()
    
    func getProducts() {
        
        // Have to have the product id for the particular type of purchase, including the specific detail of the ID, the suffix added to the end of the app's bundle ID.
        let products: Set = [keywords.inAppPurchaseProductID]
        
        // Sets up a purchase request, and gives it the products that we set above.
        let request = SKProductsRequest(productIdentifiers: products)
        
        request.delegate = self
        request.start()
        
        // Adds the function and the class to the payment queue
        paymentQueue.add(self)
        
    }
    
    func purchaseProduct(product: String) {
        
        // Filters through the 'products' array that was filled with the 'productsRequest' function below, and checks to see if it matches the 'product' that is passed into this function. If it does, then that means that the 'productIdentifier' of the 'SKProduct' array matches what we put in, so then that gets added to the payment queue.
        guard let productToPurchase = products.filter({ $0.productIdentifier == product}).first else { return }
        
        // Converts the 'product', which will be the ProductID, into an 'SKPayment'
        let payment = SKPayment(product: productToPurchase)

        // Adds the converted 'payment' above to the payment queue.
        paymentQueue.add(payment)
        
    }
    
    func restorePurchases() {
        
        paymentQueue.restoreCompletedTransactions()
        
    }
    
    func inAppPurchaseAlert() -> UIAlertController {
        
        let alert = UIAlertController(title: "Unlock Multiple Routines", message: "Get an unlimited amount of customizable Routines for $1.99?", preferredStyle: .alert)
        
        let purchase = UIAlertAction(title: "Purchase for $1.99", style: .default) { (action) in
            
            self.purchaseProduct(product: self.keywords.inAppPurchaseProductID)
        
        }
        
        let restorePurchase = UIAlertAction(title: "Restore Purchase", style: .default) { (action) in

            self.restorePurchases()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(purchase)
        alert.addAction(restorePurchase)
        alert.addAction(cancel)
        
        return alert
        
    }
    
    func purchaseCongratulationsAlert() -> UIAlertController {
        
        let alert = UIAlertController(title: "Congratulations!", message: "You can now add as many routines as you'd like!", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK!", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        return alert
        
    }
    
}

// Necessary delegate for sending a products request
extension InAppPurchaseService: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        // Adds the products from the request into the 'products' array created above that takes 'SKProduct' objects.
        self.products = response.products
        
        // Cycles through the products that come back from the response.
//        for product in response.products {
//
//            print(product.localizedTitle)
//
//        }
        
    }
    
}

// An observer to check to see what is happening and when it happens during purchase.
extension InAppPurchaseService: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        // Merely prints out the transaction states as they happen.
        for transaction in transactions {
            
//            print("\(transaction.transactionState.status()): \(transaction.payment.productIdentifier)")
            if transaction.transactionState == .purchased || transaction.transactionState == .restored {
                
                UserDefaults.standard.set(true, forKey: keywords.isPurchasedKey)
            
            }
            switch transaction.transactionState {
                
            case .purchasing: break
            default: queue.finishTransaction(transaction)
                
            }
            
        }
        
    }
    
}

// Just a way to see exactly what went on in the transaction state.
// Is an extension of Apple's 'SKPaymentTransactionState' enum.
extension SKPaymentTransactionState {
    
    func status() -> String {
        
        switch self {
            
        case .deferred:
            return "Deferred"
            
        case .failed:
            return "Failed"
            
        case .purchased:
            return "Purchased"
            
        case .purchasing:
            return "Purchasing"
            
        case .restored:
            return "Restored"
            
        }
        
    }
    
}







