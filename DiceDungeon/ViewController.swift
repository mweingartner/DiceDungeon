//
//  ViewController.swift
//  DiceDungeon
//
//  Created by Michael Weingartner on 10/3/25.
//

import Cocoa
import SpriteKit
import GameplayKit
import SwiftUI

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            // Create the scene programmatically
            let scene = GameScene(size: view.bounds.size)
            // Set the scale mode to resize with the window
            scene.scaleMode = .resizeFill
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}

extension ViewController {
    /// Creates a controller suitable for SwiftUI previews by wiring an SKView programmatically.
    static func makePreviewController() -> ViewController {
        let vc = ViewController(nibName: nil, bundle: nil)
        // Ensure view is loaded
        _ = vc.view
        if vc.skView == nil {
            let sk = SKView(frame: .zero)
            sk.translatesAutoresizingMaskIntoConstraints = false
            vc.view.addSubview(sk)
            NSLayoutConstraint.activate([
                sk.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
                sk.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
                sk.topAnchor.constraint(equalTo: vc.view.topAnchor),
                sk.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor)
            ])
            vc.skView = sk
        }
        // Mirror viewDidLoad behavior for previews
        if let view = vc.skView {
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .resizeFill
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
        return vc
    }
}
