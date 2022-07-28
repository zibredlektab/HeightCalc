//
//  ViewController.swift
//  HeightCalc
//
//  Created by Max Batchelder on 7/24/22.
//

import UIKit

class ViewController: UIViewController {
    
    var appleboxes: Array = [
        Item(name: "full apple #3", height: 20),
        Item(name: "full apple #2", height: 12),
        Item(name: "full apple #1", height: 8),
        Item(name: "half-apple", height: 4),
        Item(name: "quarter-apple", height: 2),
        Item(name: "pancake", height: 1)
    ]
    
    var supportitems: Array = [
        Item(name: "", height: 0),
        Item(name:"rolling spreaders", height: 4, combineswith: ["babies", "standards"], accessory: true, canuseboxes: false),
        Item(name:"babies", minheight:20, maxheight:36, combineswith: ["rolling spreaders"]),
        Item(name:"standards", minheight:36, maxheight:66, combineswith: ["rolling spreaders"]),
        Item(name:"hi-hat", height: 6),
        Item(name:"lo-hat", height: 3),
        Item(name:"Fischer 11 standard head", minheight: 14, maxheight: 51, canuseboxes: false),
        Item(name:"Fischer 11 low head", minheight: 3, maxheight:39, canuseboxes: false)
    ]
    
    var aksitems: Array = [
        Item(name:"none"),
        Item(name:"stormtrooper slider", height:6, heightonboxes: 4),
        Item(name:"8-ball slider", height:6, heightonboxes: 4)
    ]
    
    var heads: Array = [
        Item(name:"2575", height: 16),
        Item(name:"Arrihead", height: 22)
    ]
    
/*
    // sticks heights are floor to mitchell on flat spreaders
    let babies = [20, 36]
    let standards = [36, 66]
    let rollers = 4
    let mitchelltolens = 16
    let lohat = 3
    let hihat = 6
    
    let sliderfrommitchell = 6
    let sliderfrombase = 4
    var usingslider = false*/
    
    var goalheight = 0
    var outputtext = ""
    var currenthead = "2575"
    var currentconfig : Array<String> = []
    
    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var heightRef: UILabel!
    @IBOutlet weak var headMenuButton: UIButton!
    @IBOutlet weak var aksMenuButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMenuActions()
    }
    
    func configureMenuActions() {
        headMenuButton.menu = headMenu
        headMenuButton.showsMenuAsPrimaryAction = true
        aksMenuButton.menu = aksMenu
        aksMenuButton.showsMenuAsPrimaryAction = true
    }
    
    var headmenuitems: [UIAction] {
        var output : Array<UIAction> = []
        for head in heads {
            output.append(UIAction(title: head.name, handler: {
                (action) in self.currenthead = head.name
                print("current head is " + head.name)}))
        }
        
        return output
    }
    
    var headMenu: UIMenu {
        return UIMenu(title: "Current Head", options: [], children: headmenuitems)
    }

    var aksmenuitems: [UIAction] {
        var output : Array<UIAction> = []
        for aksitem in aksitems {
            output.append(UIAction(title: aksitem.name, handler: {
                (action) in
                self.currentconfig.removeAll() //TODO manage more than one
                if (aksitem.name != "none") {
                    self.currentconfig.append(aksitem.name)
                }
            }))
        }
        
        return output
    }
    
    var aksMenu: UIMenu {
        return UIMenu(title: "Camera AKS", options: [], children: aksmenuitems)
    }

    
    
    func appleboxCalc(height: Int) -> String {
        var remainingheight = height;
        var output = ""
        var firstentry = true;
        
        for box in appleboxes {
            let numberof: Int = remainingheight / box.height
            if (numberof > 0) {
                remainingheight -= numberof * box.height
                var comma = ""
                if (!firstentry) {
                    comma = ", "
                } else {
                    firstentry = false
                }
                output += comma + String(numberof) + "x " + box.name
            }
        }
        
        return output
    }
    
    
    
    @IBAction func HeightEdited(_ sender: UIButton) {
        let text: String = inputField.text!
        goalheight = Int(text) ?? 0
        print("\nnew height is " + String(goalheight))
        outputtext = ""
        
        var mitchelltolens = 0
        let headindex = heads.firstIndex(where: {$0.name == currenthead})
        if (headindex != nil) {
            mitchelltolens = heads[headindex ?? 0].height
        } else {
            print ("current config specifies a head (" + currenthead + ") that is not an available option")
        }
        
        
        
        var goalsupportheight = goalheight - mitchelltolens
        
        heightRef.text = "(" + String(goalsupportheight) + " inches to primary mitchell mount)"
        
        print("goalsupportheight is " + String(goalsupportheight))
        
        var aksheight = 0
        
        for supportitem in supportitems {
            
            aksheight = 0
            
            if (supportitem.accessory) {
                // only use accessories in conjunction with other support items
                continue
                
            }
            
            
            if (supportitem.name == "" && currentconfig.count == 0) {
                // only use the null (boxes-only) support option when a slider is in use
                continue
            } else if (supportitem.name == "" && currentconfig.count > 0){
                // calculate slider height when using sliders on boxes
                print("calculating aks height from boxes")
                for i in 0..<currentconfig.count {
                    let aksindex = aksitems.firstIndex(where: {$0.name == currentconfig[i]})
                    if (aksindex != nil) {
                        aksheight = aksitems[aksindex ?? 0].heightonboxes
                    } else {
                        print ("current config specifies aks that is not available")
                    }
                }
            } else {
                // calculate slider height when using sliders on non-box support
                
                print("calculating aks height from sticks")
                for i in 0..<currentconfig.count {
                    let aksindex = aksitems.firstIndex(where: {$0.name == currentconfig[i]})
                    if (aksindex != nil) {
                        aksheight = aksitems[aksindex ?? 0].height
                    } else {
                        print ("current config specifies aks that is not available")
                    }
                }
            }
            
            goalsupportheight -= aksheight
            print ("goalsupportheight after aks is " + String(goalsupportheight))
            
            
            if ((goalsupportheight >= supportitem.height && supportitem.minheight == 0) || (goalsupportheight >= supportitem.minheight && (goalsupportheight <= supportitem.maxheight || (goalsupportheight > supportitem.maxheight && supportitem.canuseboxes)))) {
                
                var appleboxadditions = " "
                if (supportitem.canuseboxes && goalsupportheight > supportitem.maxheight) {
                    // only use boxes when we have exceeded the maximum height of a given support
                    if (supportitem.name != "") {
                        appleboxadditions += "+ "
                    }
                    appleboxadditions += appleboxCalc(height: goalsupportheight - supportitem.heightonboxes)
                }
                outputtext += supportitem.name + appleboxadditions + "\n"
            }
            
            goalsupportheight += aksheight
        }
        
        /*
        let goalmitchell = goalheight - mitchelltolens // ground to mitchell mount
        let goalsliderbase = goalmitchell - sliderfrombase // ground to slider base (for applebox use)
        let goalslidermitchell = goalmitchell - sliderfrommitchell // ground to slider mitchell (for sticks use)
        var goal = goalmitchell // assume that we want to calculate from ground to head mitchell (no slider)
        
        var stickscutoff = babies[0]; // the minimum height for sticks use, assuming no slider
        if (usingslider) {
            stickscutoff = babies[0] + sliderfrommitchell // add height of slider if we are using it
            if (goalmitchell >= stickscutoff) {
                goal = goalslidermitchell // calculate from ground to slider mitchell mount
            } else {
                goal = goalsliderbase // calculate from ground to slider base
            }
        }
        print("stickscutoff is " + String(stickscutoff))
        print("goalsliderbase is " + String(goalsliderbase))
        print("goalslidermitchell is " + String(goalslidermitchell))
        print("goal is " + String(goal))
        
        // at this point, use "goal" as point of calculation
        
        // first, figure out if we're within bounds
        if ((usingslider  && (goalslidermitchell < 0)) || (!usingslider && goalmitchell < lohat)) {
            // special case, the slider mitchell mount is the limiting factor in low cases - if it's below 0 then it's underground
            outputtext = "Too low for current configuration"
        } else if (goal > standards[1] + rollers){
            outputtext = "Too high for current configuration"
        } else {
            print("Height is within bounds")
            
            if (usingslider) {
                outputtext += "slider & \n"
            }
            
            if (goalmitchell >= stickscutoff) {
                print("Height is high enough to use sticks")
                if (goal >= babies[0] && goal < babies[0] + rollers) {
                    outputtext += "babies with flat spreaders"
                    // TODO calculate rise of sticks
                } else if (goal <= babies[1] + rollers && goal >= standards[0] && goal < standards[0] + rollers) {
                    outputtext += "babies with rollers,\nor standards with flat spreaders"
                } else if (goal <= babies[1] + rollers && goal < standards[0] + rollers) {
                    outputtext += "babies or standards with rollers"
                } else if (goal >= babies[0] + rollers && goal <= babies[1] + rollers) {
                    outputtext += "babies with rollers"
                } else if (goal >= standards[0] + rollers && goal <= standards[1] + rollers) {
                    outputtext += "standards with rollers"
                } else if (goal > standards[1]) {
                    outputtext += "standards with flat spreaders\n" + appleboxCalc(height: goal-standards[1])
                } else {
                    outputtext = "Error - height is within sticks range but doesn't fit a case..."
                }
            } else {
                if (usingslider) {
                    outputtext += appleboxCalc(height: goalsliderbase)
                } else {
                    if (goal >= lohat && goalmitchell < hihat) {
                        outputtext += "lo-hat"
                        if (goal - lohat > 0) {
                            outputtext += "\n" + appleboxCalc(height: goal - lohat)
                        }
                    } else if (goal >= hihat) {
                        outputtext += "hi-hat"
                        if (goal - hihat > 0) {
                            outputtext += "\n" + appleboxCalc(height: goal - hihat)
                        }
                    }
                }
            }
        }*/
        
        outputLabel.text = outputtext
    }
    
}


class Item {
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.name == rhs.name
    }
    
    var name: String
    var height: Int
    var heightonboxes: Int // sliders have a different height when used with boxes than they do on a mitchell mount
    var minheight: Int
    var maxheight: Int
    var combineswith: Set<String>
    var accessory: Bool // ie rolling spreaders, which can only be used with another support item
    var canuseboxes: Bool // dollies cannot go on boxes
    
    init(name: String, height: Int? = 0, heightonboxes: Int? = nil, minheight: Int? = nil, maxheight: Int? = nil, combineswith: Set<String>? = nil, accessory: Bool? = false, canuseboxes: Bool? = true) {
        self.name = name
        self.height = height ?? 0
        self.minheight = minheight ?? self.height
        self.maxheight = maxheight ?? self.height
        self.heightonboxes = heightonboxes ?? self.maxheight
        self.combineswith = combineswith ?? []
        self.accessory = accessory ?? false
        self.canuseboxes = canuseboxes ?? true
    }
}
