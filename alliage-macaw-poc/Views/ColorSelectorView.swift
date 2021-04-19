//
//  ColorSelectorView.swift
//  Alliage
//
//  Created by George Pedrosa on 09/10/19.
//  Copyright © 2019 LDS. All rights reserved.
//

import UIKit
import SnapKit

protocol ColorSelectorViewDelegate: class {
    func colorSelected(color: Int, selector: ColorSelectorView)
}

class ColorSelectorView: UIView {
    
    weak var delegate: ColorSelectorViewDelegate?
    
    @IBInspectable public var colorTitle: String = "" {
        didSet {
            titleLabel.text = colorTitle
        }
    }
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        return label
    }()
    
    var selectedColor: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(10)
        }
        self.addSubview(selectedColor)
        selectedColor.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().inset(10)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(selectedColor.snp.bottom).offset(5)
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(5)
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.shouldIgnoreScrollingAdjustment = true
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ColorSelectorCell")
    }
}

extension ColorSelectorView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return App.Colors.stringArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorSelectorCell", for: indexPath)
        let colorString = App.Colors.stringArray[indexPath.row]
        cell.backgroundColor = UIColor(rgb: Int(colorString, radix: 16)!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let colorString = App.Colors.stringArray[indexPath.row]
        let color = Int(colorString, radix: 16)!
        selectedColor.backgroundColor = UIColor(rgb: color)
        if let colorDelegate = delegate {
            colorDelegate.colorSelected(color: color, selector: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 20, height: 20)
    }
}
