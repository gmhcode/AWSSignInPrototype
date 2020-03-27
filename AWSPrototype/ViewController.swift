//
//  ViewController.swift
//  AWSPrototype
//
//  Created by Greg Hughes on 3/26/20.
//  Copyright © 2020 Greg Hughes. All rights reserved.
//

import UIKit
import AWSAppSync

class ViewController: UIViewController {

    var appSyncClient: AWSAppSyncClient?
    var discard: Cancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appSyncClient = appDelegate.appSyncClient
        
        runMutation()
        runQuery()
        subscribe()
    }
 
    
    func runQuery(){
        appSyncClient?.fetch(query: ListTodosQuery(), cachePolicy: .returnCacheDataAndFetch) {(result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            print("Query complete.")
            result?.data?.listTodos?.items!.forEach { print(($0?.name)! + "🚣🏻 " + ($0?.description)!) }
        }
    }
    
    func runMutation(){
        let mutationInput = CreateTodoInput(name: "Use AppSync", description:"Realtime and Offline")
        appSyncClient?.perform(mutation: CreateTodoMutation(input: mutationInput)) { [weak self] (result, error) in
            // ... do whatever error checking or processing you wish here
            self?.runQuery()
        }
    }
    func subscribe() {
        do {
            discard = try appSyncClient?.subscribe(subscription: OnCreateTodoSubscription(), resultHandler: { (result, transaction, error) in
                if let result = result {
                    
                    print("CreateTodo subscription data:" + result.data!.onCreateTodo!.name + " " + result.data!.onCreateTodo!.description!)
                } else if let error = error {
                    print(error.localizedDescription)
                }
            })
            print("Subscribed to CreateTodo Mutations.")
            } catch {
                print("Error starting subscription.")
            }
    }

}

