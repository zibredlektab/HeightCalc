//
//  ViewController.swift
//  HeightCalc
//
//  Created by Max Batchelder on 7/24/22.
//

import UIKit

class ViewController: UIViewController {
    
    var supportitems: Set = [
        Item(id: 0, name: "2575", height: 16),
        Item(id:1, name:"babies flat", minheight:20, maxheight:36),
        Item(id:2, name:"babies with rollers", minheight:24, maxheight:40),
        Item(id:3, name:"standards flat", )
    ]
    

    // sticks heights are floor to mitchell on flat spreaders
    let babies = [20, 36]
    let standards = [36, 66]
    let rollers = 4
    let mitchelltolens = 16
    let lohat = 3
    let hihat = 6
    
    let sliderfrommitchell = 6
    let sliderfrombase = 4
    var usingslider = false
    
    var goalheight = 0
    var outputtext = ""
    
    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var heightRef: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sliderSwitch(_ sender: UISwitch) {
        usingslider = sender.isOn
    }
    func appleboxCalc(height: Int) -> String {
        var remainingheight = height;
        let number3: Int  = remainingheight / 20
        remainingheight -= number3 * 20
        let number2: Int = remainingheight / 12
        remainingheight -= number2 * 12
        let number1: Int = remainingheight / 8
        remainingheight -= number1 * 8
        let halves: Int = remainingheight / 4
        remainingheight -= halves * 4
        let quarters: Int = remainingheight / 2
        remainingheight -= quarters * 2
        var output = "";
        if (number3 != 0) {
            output += String(number3) + " applebox #3\n"
        }
        if (number2 != 0) {
            output += String(number2) + " applebox #2\n"
        }
        if (number1 != 0) {
            output += String(number1) + " applebox #1\n"
        }
        if (halves != 0) {
            output += String(halves) + " half-apple\n"
        }
        if (quarters != 0) {
            output += String(quarters) + " quarter-apple\n"
        }
        if (remainingheight != 0) {
            output += "1 pancake\n"
        }
        
        return output
    }
    
    
    
    @IBAction func HeightEdited(_ sender: UIButton) {
        let text: String = inputField.text!
        goalheight = Int(text) ?? 0
        print("\nnew height is " + String(goalheight))
        outputtext = ""
        let goalmitchell = goalheight - mitchelltolens // ground to mitchell mount
        let goalsliderbase = goalmitchell - sliderfrombase // ground to slider base (for applebox use)
        let goalslidermitchell = goalmitchell - sliderfrommitchell // ground to slider mitchell (for sticks use)
        var goal = goalmitchell // assume that we want to calculate from ground to head mitchell (no slider)
        heightRef.text = "(" + String(goalmitchell) + " inches to camera mitchell mount)"
        
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
        print("goalmitchell is " + String(goalmitchell))
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
        }
        
        outputLabel.text = outputtext
    }
    
}


class Item: Equatable, Hashable {
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.name == rhs.name
    }
    
    var id: Int
    var name: String
    var height: Int
    var minheight: Int
    var maxheight: Int
    
    init(id: Int, name: String, height: Int? = 0, minheight: Int? = 0, maxheight: Int? = 0) {
        self.id = id
        self.name = name
        self.height = height
        self.minheight = minheight
        self.maxheight = maxheight
    }
    
    
    var hashValue: Int {
        get {
            return id.hashValue << 15 + name.hashValue
        }
    }
}
