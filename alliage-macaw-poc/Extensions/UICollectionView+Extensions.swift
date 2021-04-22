//
//  UICollectionView+Extensions.swift
//  Alliage
//
//  Created by Vitor Muniz on 27/05/19.
//  Copyright © 2019 LDS. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to Dequeue Reusable Table View Cell")
        }
        return cell
    }
    
}


extension UICollectionView {
    
    func registerNibCell<T: UICollectionViewCell>(_ cellClass: T.Type) {
        self.register(UINib(nibName: T.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func registerCell<T: UICollectionViewCell>(_ cellClass: T.Type) {
        self.register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
}
