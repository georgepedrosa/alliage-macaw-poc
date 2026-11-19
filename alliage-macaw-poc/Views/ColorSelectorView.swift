//
//  ColorSelectorView.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 20/04/21.
//  Copyright © 2021 Vitor Muniz. All rights reserved.
//

import UIKit

protocol ColorSelectorViewDelegate: AnyObject {
    func colorSelected(color: Int)
}

/// Collection cell showing a single palette color.
final class ColorCell: UICollectionViewCell {

    func configure(with color: UIColor) {
        backgroundColor = color
    }
}

class ColorSelectorView: UIView {

    weak var delegate: ColorSelectorViewDelegate?

    private let palette = ColorPaletteViewModel()

    @IBInspectable public var colorTitle: String = "" {
        didSet {
            titleLabel.text = colorTitle
        }
    }

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        return label
    }()

    let selectedColor: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    let collectionView: UICollectionView = {
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

    private func setupView() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(10)
        }
        addSubview(selectedColor)
        selectedColor.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.leading.equalTo(titleLabel.snp.trailing).offset(5)
            make.size.equalTo(20)
        }
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(selectedColor.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(5)
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.shouldIgnoreScrollingAdjustment = true
        collectionView.registerCell(ColorCell.self)
    }
}

extension ColorSelectorView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        palette.numberOfColors
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ColorCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(with: palette.color(at: indexPath.row))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let colorValue = palette.colorValue(at: indexPath.row)
        selectedColor.backgroundColor = UIColor(rgb: colorValue)
        delegate?.colorSelected(color: colorValue)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 20, height: 20)
    }
}
