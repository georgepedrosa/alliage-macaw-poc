//
//  ColorSelectorPopup.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 20/04/21.
//  Copyright © 2021 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class ColorSelectorPopup: NibView {

    @IBOutlet weak var confirmationButton: UIButton!
    @IBOutlet weak var cancelationButton: UIButton!
    @IBOutlet weak var colorSelectorView: ColorSelectorView!

    var viewModel: ColorSelectorViewModel? {
        didSet {
            bindViewModel()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setupView() {
        confirmationButton.setTitle("Confirm", for: .normal)
        cancelationButton.setTitle("Cancel", for: .normal)

        view.layer.cornerRadius = 10
        confirmationButton.layer.cornerRadius = 5
        cancelationButton.layer.cornerRadius = 5

        colorSelectorView.delegate = self
    }

    private func bindViewModel() {
        viewModel?.selectedColorValue.bindAndFire { [weak self] colorValue in
            self?.colorSelectorView.selectedColor.backgroundColor = UIColor(rgb: colorValue)
        }
    }

    @IBAction func cancelation(_ sender: Any) {
        viewModel?.cancel()
    }

    @IBAction func confirmation(_sender: Any) {
        viewModel?.confirm()
    }
}

extension ColorSelectorPopup: ColorSelectorViewDelegate {

    func colorSelected(color: Int) {
        viewModel?.select(colorValue: color)
    }
}
