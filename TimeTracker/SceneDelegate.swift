//
//  SceneDelegate.swift
//  TimeTracker
//
//  Created by David Rynn on 10/22/19.
//  Copyright © 2019 David Rynn. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    var stopwatches: [Stopwatch] = getData()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(stopWatches: stopwatches)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
        startObservation()
    }
    
    func startObservation() {
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive(_:)), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func willResignActive(_ notification: Notification) {
        saveData(stopwatches: stopwatches)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    static func getData() -> [Stopwatch] {
        guard let stopWatchdict = UserDefaults.standard.value(forKey: "stopwatches") as? [[String: Any]] else { return [] }
        return stopWatchdict.compactMap {
            let id: UUID = UUID(uuidString: $0["id"] as! String) ?? UUID()
            let title: String = $0["title"] as? String ?? "invalid title"
            let sw = Stopwatch(id: id, title: title)
            sw.counter = $0["counter"] as? Int ?? 0
            return sw
        }

    }
    
    func saveData(stopwatches: [Stopwatch]) {
        let dict: NSArray = stopwatches.map {
            [ "id": ($0.id).uuidString,
              "title": $0.title as NSString,
              "counter": $0.counter
                ] as NSDictionary
        } as NSArray
        UserDefaults.standard.setValue(dict, forKey: "stopwatches")
    }


}

