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
        Item(name:"babies", minheight:20, maxheight:36, canuserollers: true),
        Item(name:"standards", minheight:36, maxheight:66, canuserollers:true),
        Item(name:"hi-hat", height: 6),
        Item(name:"lo-hat", height: 3),
        Item(name:"Fischer 11 standard head", minheight: 14, maxheight: 51, combineswith: ["18-inch riser", "6-inch riser"], canuseboxes: false),
        Item(name:"Fischer 11 low head", minheight: 3, maxheight:39, combineswith: ["6-inch riser", "18-inch riser"], canuseboxes: false)
        ]
    
    var supportaks: Array = [
        Item(name:"18-inch riser", height: 18),
        Item(name:"6-inch riser", height: 6),
        Item(name:"rolling spreaders", height: 4, canuseboxes: false),
        ]
        
    var cameraaks: Array = [
        Item(name:"none"),
        Item(name:"stormtrooper slider", height:6, heightonboxes: 4),
        Item(name:"8-ball slider", height:6, heightonboxes: 4),
        Item(name:"tango", height:2, canuseboxes:false),
        Item(name:"R-O", height:5, canuseboxes: false)
        ]
    
    var heads: Array = [
        Item(name:"2575", height: 16),
        Item(name:"Arrihead", height: 22)
        ]
    
    var rollerheight = 4
    
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
        for aksitem in cameraaks {
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
                if ((box.name == "full apple #2" || box.name == "full apple #3") && numberof > 1) {
                    // No more than 1x of full apple #2 or #3 is allowed
                    return "abort"
                }
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
        
        var aksheight : Int
        
        for supportitem in supportitems {
            
            print("\nChecking support: " + supportitem.name)
            
            aksheight = 0
            
            if (supportitem.name == "" && currentconfig.count == 0) {
                // only use the null (boxes-only) support option when a slider is in use
                print("Support is null, and we're not using a slider, pass.")
                continue
            }
            
            var justboxesokay = false
            
            for i in 0..<currentconfig.count {
                // configuration of aks is a *different height* depending on the support method, hence we have to recalculate this for every support method. TODO perhaps break support up into mitchell & non-mitchell to only have to calculate this twice?
                let aksindex = cameraaks.firstIndex(where: {$0.name == currentconfig[i]})
                if (aksindex != nil) {
                    print("using accessory " + currentconfig[i])
                    if (supportitem.name == "") {
                        if (cameraaks[aksindex ?? 0].canuseboxes) {
                            // flag that one of our support items can use boxes alone as support (ie a slider)
                            justboxesokay = true
                            print("accessory can use boxes")
                        }
                        aksheight += cameraaks[aksindex ?? 0].heightonboxes
                        print("calculating from boxes")
                    } else {
                        aksheight += cameraaks[aksindex ?? 0].height
                        print("calculating from mitchell")
                    }
                } else {
                    print ("current config specifies aks that is not available")
                }
            }
            
            if (supportitem.name == "" && !justboxesokay) {
                // no support items were found that can use only boxes as support, moving on...
                print("Can't continue, not allowed to work on just boxes")
                continue
            }
            
            goalsupportheight -= aksheight
            
            if (supportitem.canuserollers) {
                print("this support can use rolling spreaders")
                let checkoutput = checkSupport(height: goalsupportheight - rollerheight, support: supportitem, useboxes: false)
                if (checkoutput != "") {
                    outputtext += "rollers + " + checkoutput
                }
            }
            
            outputtext += checkSupport(height: goalsupportheight, support: supportitem);
            
            goalsupportheight += aksheight // reset the goal height for the next support item (in case support aks is a different height)
        }
        
        outputLabel.text = outputtext
    }
    
    
    
    
    func checkSupport (height: Int, support: Item, useboxes: Bool? = true) -> String {
        print("checking support: " + support.name + " for height " + String(height))
        var output = support.name
        var appleboxadditions = ""
        var boxesokay = useboxes ?? true
        
        /*
         EITHER:
         
         height >= support.height && support.minheight == 0 (height is greater than support height, and support is not variable in height)
         
         OR:
         
         height >= support.minheight (height is greater than or equal to minimum height on a variable-height support)
         
            AND EITHER:
         
            height <= support.maxheight (height is less than or equal to maximum height on a variable-height support)
         
            OR:
         
            height > support.maxheight && support.canuseboxes (height is greater than the support's maximum height, but this support can use boxes to get higher)
         
         
         */
        
        if ((height >= support.height && support.minheight == 0) || (height >= support.minheight && (height <= support.maxheight || (height > support.maxheight && support.canuseboxes && boxesokay)))) {
            
            print("height is greater than this support's minimum, and either less than its maximum or greater than its maximum but can use boxes")
            
            if (height > support.maxheight) {
                print("height is greater than this support's maximum")
                
               /* //TODO - support combinations (risers)
                if (support.combineswith.count > 0) {
                    print("support can combine")
                    for i in (startingindex ?? 0)..<support.combineswith.count {
                        // run through all possible combinations of accessories for this support item
                        let combinationindex = supportaks.firstIndex(where: {$0.name == support.combineswith[i]})
                        if (combinationindex != nil) {
                            // this accessory exists
                            let currentsupportaks = supportaks[combinationindex ?? 0]
                            print("checking combination with " + currentsupportaks.name)
                            let akscheck = checkSupport(height: height - currentsupportaks.height, support: support, startingindex: (startingindex ?? 0)+1) // check this support again, but with height minus the current accessory
                            if (akscheck != "") {
                                if (!currentsupportaks.canuseboxes) {
                                    boxesokay = false;
                                }
                                output += " + " + currentsupportaks.name
                            }
                        }
                    }
                } */
                
                if (support.canuseboxes && boxesokay) {
                    print ("we are allowed to use boxes, calculating for boxes")
                    // only use boxes when we have exceeded the maximum height of a given support
                    if (support.name != "") {
                        appleboxadditions += " + "
                    }
                    let appleboxstring = appleboxCalc(height: height - support.heightonboxes)
                    if (appleboxstring == "abort") {
                        // ridiculous number of apple boxes is called for, this support scheme doesn't work
                        return ""
                    }
                    appleboxadditions += appleboxstring
                } else {
                    print ("height is greater than maximum, and we can't use boxes in the current config")
                    return ""
                }
                
            } else {
                print ("height is less than this support's maximum")
            }
            
            output += appleboxadditions + "\n"
            return output
        }
        print ("out of range.")
        return ""
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
    var combineswith: Array<String>
    var canuseboxes: Bool // dollies cannot go on boxes
    var canuserollers: Bool
    
    init(name: String, height: Int? = 0, heightonboxes: Int? = nil, minheight: Int? = nil, maxheight: Int? = nil, combineswith: Array<String>? = nil, canuseboxes: Bool? = true, canuserollers: Bool? = false) {
        self.name = name
        self.height = height ?? 0
        self.minheight = minheight ?? self.height
        self.maxheight = maxheight ?? self.height
        self.heightonboxes = heightonboxes ?? self.maxheight
        self.combineswith = combineswith ?? []
        self.canuseboxes = canuseboxes ?? true
        self.canuserollers = canuserollers ?? false
    }
}
