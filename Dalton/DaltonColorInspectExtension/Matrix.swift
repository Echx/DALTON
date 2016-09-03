//
//  Matrix.swift
//  Dalton
//
//  Created by DdMad on 3/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import Foundation

class Matrix {
    
    var maxtrix: [[Int]]
    
    init(matrix: [[Int]]) {
        self.maxtrix = matrix
    }
    
}

func * (lhs: Matrix, rhs: Matrix) -> Matrix {
    return lhs
}