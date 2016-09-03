//
//  Matrix.swift
//  Dalton
//
//  Created by DdMad on 3/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import Foundation

public class Matrix {
    public var matrix: [[Double]]
    
    public init(matrix: [[Double]]) {
        self.matrix = matrix
    }
}

public func * (lhs: Matrix, rhs: Matrix) -> Matrix? {
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

public func + (lhs: Matrix, rhs: Matrix) -> Matrix? {
    if (lhs.matrix.count != rhs.matrix.count || lhs.matrix[0].count != rhs.matrix[0].count) {
        print("Illegal matrix dimensions!")
        return nil
    }
    
    var result:[[Double]] = [[Double]](count: lhs.matrix.count, repeatedValue:[Double](count: lhs.matrix[0].count, repeatedValue: 0))
    
    for i in 0 ..< result.count {
        for j in 0 ..< result[0].count {
            result[i][j] = lhs.matrix[i][j] + rhs.matrix[i][j]
        }
    }
    
    return Matrix(matrix: result)
}

public func - (lhs: Matrix, rhs: Matrix) -> Matrix? {
    if (lhs.matrix.count != rhs.matrix.count || lhs.matrix[0].count != rhs.matrix[0].count) {
        print("Illegal matrix dimensions!")
        return nil
    }
    
    var result:[[Double]] = [[Double]](count: lhs.matrix.count, repeatedValue:[Double](count: lhs.matrix[0].count, repeatedValue: 0))
    
    for i in 0 ..< result.count {
        for j in 0 ..< result[0].count {
            result[i][j] = lhs.matrix[i][j] - rhs.matrix[i][j]
        }
    }
    
    return Matrix(matrix: result)
}
