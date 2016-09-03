//
//  Matrix.swift
//  Dalton
//
//  Created by DdMad on 3/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import Foundation

class Matrix {
    var matrix: [[Double]]
    
    init(matrix: [[Double]]) {
        self.matrix = matrix
    }
}

func * (lhs: Matrix, rhs: Matrix) -> Matrix? {
    if (lhs.matrix[0].count != rhs.matrix.count) {
        print("Illegal matrix dimensions!")
        return nil
    }
    
    var result:[[Double]] = [[Double]](count: lhs.matrix.count, repeatedValue:[Double](count: rhs.matrix[0].count, repeatedValue: 0))
    
    for i in 0 ..< result.count {
        for j in 0 ..< result[0].count {
            for k in 0 ..< rhs.matrix.count {
                result[i][j] += lhs.matrix[i][k] * rhs.matrix[k][j]
            }
        }
    }
    
    return Matrix(matrix: result)
}
