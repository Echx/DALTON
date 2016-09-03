//
//  NamedColor.swift
//  Dalton
//
//  Created by Jiang Sheng on 4/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

import UIKit

enum NamedColor:String{
    case undefined = "UNDEFINED"
    case white = "WHITE"
    case gray = "GRAY"
    case black = "BLACK"
    case red = "RED"
    case salmon = "SALMON"
    case orange = "ORANGE"
    case pink = "PINK"
    case pinkLight = "LIGHT PINK"
    case pinkDark = "DARK PINK"
    case brown = "BROWN"
    case green = "GREEN"
    case greenLight = "LIGHT GREEN"
    case greenDark = "DARK GREEN"
    case blue = "BLUE"
    case blueLight = "LIGHT BLUE"
    case blueDark = "DARK BLUE"
    case purple = "PURPLE"
    case purpleLight = "LIGHT PURPLE"
    case yellow = "YELLOW"
    case yellowLight = "LIGHT YELLOW"
    case teal = "TEAL"
    case tealDark = "DARK TEAL"
}


enum colorAccuracy {
    case low
    case high
}

class ColorNamer: NSObject {
    
    var accuracy : colorAccuracy = colorAccuracy.low
    
    func rgbToColorName(color: UIColor) -> NamedColor {
        var result: NamedColor = NamedColor.undefined
        let triple = color.rgb()!
        let r = filter3(triple.red)
        let g = filter3(triple.green)
        let b = filter3(triple.blue)
        
        
        if(r == 1 && g == 1 &&  b == 1){
            result = NamedColor.white
        }
        if(r == 0.5 && g == 0.5 &&  b == 0.5){
            result = NamedColor.gray
        }
        if(r == 0 && g == 0 &&  b == 0){
            result = NamedColor.black
        }
        
        //MASTER RED
        if(r == 1 && g == 0 &&  b == 0){
            result = NamedColor.red
        }
        if(r == 1 && g == 0.5 &&  b == 0.5){
            if(accuracy == colorAccuracy.high){
                result = NamedColor.salmon
            }else if(accuracy == colorAccuracy.low){
                result = NamedColor.red
            }
        }
        if(r == 1 && g == 0.5 &&  b == 0){
            result = NamedColor.orange
        }
        if(r == 1 && g == 0 &&  b == 0.5){
            result = NamedColor.pink
        }
        if(r == 0.5 && g == 0 &&  b == 0){
            if(accuracy == colorAccuracy.high){
                result = NamedColor.brown
            }else if(accuracy == colorAccuracy.low){
                result = NamedColor.red
            }
        }
        
        //MASTER GREEN
        if(r == 0 && g == 1 &&  b == 0){
            result = NamedColor.green
        }
        if(r == 0.5 && g == 1 &&  b == 0){
            if(accuracy == colorAccuracy.high){
                result = NamedColor.greenLight
            }else if(accuracy == colorAccuracy.low){
                result = NamedColor.green
            }
        }
        if(r == 0 && g == 1 &&  b == 0.5){
            if(accuracy == colorAccuracy.high){
                result = NamedColor.greenLight
            }else if(accuracy == colorAccuracy.low){
                result = NamedColor.green
            }        }
        if(r == 0.5 && g == 1 &&  b == 0.5){
            if(accuracy == colorAccuracy.high){
                result = NamedColor.greenLight
            }else if(accuracy == colorAccuracy.low){
                result = NamedColor.green
            }
        }
        
        if(r == 0.0 && g == 0.5 && b == 0.0){
            if(accuracy == colorAccuracy.high){
                result = NamedColor.greenDark
            }else if(accuracy == colorAccuracy.low){
                result = NamedColor.green
            }
        }
        
        
        //MASTER BLUE
        if(r == 0 && g == 0 &&  b == 1){
            result = NamedColor.blue
        }
        if(r == 0.5 && g == 0 &&  b == 1){
            result = NamedColor.purple
        }
        if(r == 0 && g == 0.5 &&  b == 1){
            if(accuracy == colorAccuracy.high){
                result = NamedColor.blueLight
            }else if(accuracy == colorAccuracy.low){
                result = NamedColor.blue
            }
        }
        if(r == 0.5 && g == 0.5 &&  b == 1){
            if(accuracy == colorAccuracy.high){
                result = NamedColor.purpleLight
            }else if(accuracy == colorAccuracy.low){
                result = NamedColor.purple
            }
        }
        
        if(r == 0.0 && g == 0.0 && b == 0.5){
            if(accuracy == colorAccuracy.high){
                result = NamedColor.blueDark
            }else if(accuracy == colorAccuracy.low){
                result = NamedColor.blue
            }
        }
        
        
        //MASTER RED+GREEN
        if(r == 1 && g == 1 &&  b == 0){
            result = NamedColor.yellow
        }
        if(r == 1 && g == 1 &&  b == 0.5){
            if(accuracy == colorAccuracy.high){
                result = NamedColor.yellowLight
            }else if(accuracy == colorAccuracy.low){
                result = NamedColor.yellow
            }
        }
        if(r == 0.5 && g == 0.5 &&  b == 0){
            if(accuracy == colorAccuracy.high){
                result = NamedColor.greenDark
            }else if(accuracy == colorAccuracy.low){
                result = NamedColor.green
            }
        }
        
        //MASTER RED+BLUE
        if(r == 1 && g == 0 &&  b == 1){
            result = NamedColor.purple
        }
        if(r == 1 && g == 0.5 &&  b == 1){
            if(accuracy == colorAccuracy.high){
                result = NamedColor.pinkLight
            }else if(accuracy == colorAccuracy.low){
                result = NamedColor.pink
            }
        }
        if(r == 0.5 && g == 0.0 &&  b == 0.5){
            if(accuracy == colorAccuracy.high){
                result = NamedColor.pinkDark
            }else if(accuracy == colorAccuracy.low){
                result = NamedColor.pink
            }
        }
        
        //MASTER GREEN+BLUE
        if(r == 0 && g == 1 &&  b == 1){
            result = NamedColor.yellow
        }
        if(r == 0.5 && g == 1 &&  b == 1){
            if(accuracy == colorAccuracy.high){
                result = NamedColor.teal
            }else if(accuracy == colorAccuracy.low){
                result = NamedColor.blue
            }
        }
        if(r == 0.0 && g == 0.5 &&  b == 0.5){
            if(accuracy == colorAccuracy.high){
                result = NamedColor.tealDark
            }else if(accuracy == colorAccuracy.low){
                result = NamedColor.blue
            }
        }
        
        return result
    }
    
    //filter3, filter to round float (0.0-1.0) to nearest 0.0/0.5/1.0
    func filter3(val:CGFloat)->CGFloat{
        var f:CGFloat = val;
        
        let cutoffHigh:CGFloat = 0.70
        let cutoffLow:CGFloat = 0.20
        
        if (f >= cutoffHigh){
            f = 1.0
        }
        else if (f < cutoffHigh && f > cutoffLow){
            f = 0.5
        }
        else{
            f = 0.0
        }
        
        return f
    }
}

extension UIColor {
    func rgb() -> (red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            return (red:fRed, green:fGreen, blue:fBlue, alpha:fAlpha)
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}