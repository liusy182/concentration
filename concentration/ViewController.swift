//
//  ViewController.swift
//  concentration
//
//  Created by liusy182 on 25/3/16.
//  Copyright © 2016 liusy182. All rights reserved.
//

import UIKit

enum Difficulty {
    case Easy, Medium, Hard
}

private extension ViewController {
    
    func setup() {
        view.backgroundColor = .whiteColor()
        buildButtonWithCenter(
            CGPoint(x: view.center.x, y: view.center.y/2.0),
            title: "EASY",
            color: .greenColor(),
            action: #selector(ViewController.onEasyTapped(_:)))
        
        buildButtonWithCenter(
            CGPoint(x: view.center.x, y: view.center.y),
            title: "MEDIUM",
            color: .yellowColor(),
            action: #selector(ViewController.onMediumTapped(_:)))
        
        buildButtonWithCenter(
            CGPoint(x: view.center.x, y: view.center.y*3.0/2.0),
            title: "HARD",
            color: .redColor(),
            action: #selector(ViewController.onHardTapped(_:)))
        
    }
    
    func buildButtonWithCenter(
        center: CGPoint,
        title: String,
        color: UIColor,
        action: Selector) {
        
        let button = UIButton()
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(.blackColor(), forState: .Normal)
        button.frame = CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: 200, height: 50))
        
        button.center = center
        button.backgroundColor = color
        button.addTarget(
            self,
            action: action,
            forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(button)
        
    }
}

// note: this is not private since cocoa runtime can only call
// internal or public methods
extension ViewController {
    func onEasyTapped(sender: UIButton) {
        newGameDifficulty(.Easy)
    }
    
    func onMediumTapped(sender: UIButton) {
        newGameDifficulty(.Medium)
    }
    
    func onHardTapped(sender: UIButton) {
        newGameDifficulty(.Hard)
    }
    
    func newGameDifficulty(difficulty: Difficulty) {
        switch difficulty {
        case .Easy:
            print("Easy")
        case .Medium:
            print("Medium")
        case .Hard:
            print("Hard")
        }
    }
}
    
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

