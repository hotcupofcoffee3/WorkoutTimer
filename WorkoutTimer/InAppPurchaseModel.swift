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
        
        // Has to be converted to an NSObject
        let productToPurchase = product as NSObject
        
        // Converts the 'product', which will be the ProductID, into an 'SKPayment'
        let payment = SKPayment(product: productToPurchase as! SKProduct)
        
        // Adds the converted 'payment' above to the payment queue.
        paymentQueue.add(payment)
        
    }
    
}

// Necessary delegate for sending a products request
extension InAppPurchaseService: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        // Adds the products from the request into the 'products' array created above that takes 'SKProduct' objects.
        self.products = response.products
        
        // Cycles through the products that come back from the response.
        for product in response.products {
            
            print(product.localizedTitle)
            
        }
        
    }
    
}

// An observer to check to see what is happening and when it happens during purchase.
extension InAppPurchaseService: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        // Merely prints out the transaction states as they happen.
        for transaction in transactions {
            
            print("\(transaction.transactionState.status()): \(transaction.payment.productIdentifier)")
            
        }
        
    }
    
}

// Just a way to see exactly what went on in the transaction state.
// Is an extension of Apple's 'SKPaymentTransactionState' enum.
extension SKPaymentTransactionState {
    
    func status() -> String {
        
        switch self {
            
        case .deferred : return "Deferred"
        case .failed : return "Failed"
        case .purchased : return "Purchased"
        case .purchasing : return "Purchasing"
        case .restored : return "Restored"
            
        }
        
    }
    
}







