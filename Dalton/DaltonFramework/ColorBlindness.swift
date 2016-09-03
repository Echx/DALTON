//
//  ColorBlindness.swift
//  Dalton
//
//  Created by Lei Mingyu on 3/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

public class ColorBlindness {
    public enum CBMode: Int {
        case None = 0, Red, Green, Blue, Blind
    }
    
    public static let colorMatrices: [Int: Matrix] = [
        CBMode.None.rawValue: Matrix(matrix: [[1, 0, 0], [0, 1, 0], [0, 0, 1]]),
        CBMode.Red.rawValue: Matrix(matrix: [[0, 2.02344, -2.52581], [0, 1, 0], [0, 0, 1]]),
        CBMode.Green.rawValue: Matrix(matrix: [[1, 0, 0], [0.494207, 0, 1.24827], [0, 0, 1]]),
        CBMode.Blue.rawValue: Matrix(matrix: [[1, 0, 0], [0, 1, 0], [-0.395913, 0.801109, 1]]),
        CBMode.Blind.rawValue: Matrix(matrix: [[0, 0, 0], [0, 0, 0], [0, 0, 0]])
    ]
    
    public class func getCBMatrix(colorMatrix: Matrix) -> Matrix {
        var matrices = [Matrix]()
        let LMSMatrix = Matrix(matrix: [[17.8824, 43.5161, 4.11935],
            [3.45565, 27.1554, 3.86714],
            [0.0299566, 0.184309, 1.46709]])
        
        matrices.insert(LMSMatrix, atIndex: 0)
        matrices.insert(colorMatrix, atIndex: 0)
        let RGBMatrix = Matrix(matrix: [[0.080944, -0.130504, 0.116721],
            [-0.0102485, 0.0540194, -0.113615],
            [-0.000365294, -0.00412163, 0.693513]])
        
        return matrices.reduce(RGBMatrix, combine: {($0 * $1)!})
    }
    
    public class func applyCBMatrix(filter: CIFilter, mode: Int) {
        let colorMatrix = colorMatrices[mode]
        let CBMatrix = getCBMatrix(colorMatrix!)
        let rVector = CIVector(x: CGFloat(CBMatrix.matrix[0][0]),
                               y: CGFloat(CBMatrix.matrix[0][1]),
                               z: CGFloat(CBMatrix.matrix[0][2]),
                               w: 0)
        let gVector = CIVector(x: CGFloat(CBMatrix.matrix[1][0]),
                               y: CGFloat(CBMatrix.matrix[1][1]),
                               z: CGFloat(CBMatrix.matrix[1][2]),
                               w: 0)
        let bVector = CIVector(x: CGFloat(CBMatrix.matrix[2][0]),
                               y: CGFloat(CBMatrix.matrix[2][1]),
                               z: CGFloat(CBMatrix.matrix[2][2]),
                               w: 0)
        filter.setValue(rVector, forKey: "inputRVector")
        filter.setValue(gVector, forKey: "inputGVector")
        filter.setValue(bVector, forKey: "inputBVector")
    }
}
