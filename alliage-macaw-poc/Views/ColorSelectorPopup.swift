//
//  ColorSelectorPopup.swift
//  Alliage
//
//  Created by George Pedrosa on 09/10/19.
//  Copyright © 2019 LDS. All rights reserved.
//

import UIKit
import Macaw

protocol ColorSelectorPopupDelegate: class {
    func colorSelected(innerColor: Color, outerColor: Color?, annotationId: Int)
    func dismiss()
}

class ColorSelectorPopup: NibView {
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var innerColorSelectorView: ColorSelectorView!
    @IBOutlet weak var outerColorSelectorView: ColorSelectorView!
    @IBOutlet weak var colorSelector2Height: NSLayoutConstraint!
    
    weak var delegate: ColorSelectorPopupDelegate?
    var annotationId: Int!
    var width: Double!
    var innerColorValue: Int = 0xffffff
    var outerColorValue: Int = 0xffffff
    var shapeHidden: Bool = false
    
    var isNerve: Bool!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        setupView()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
//        setupView()
    }
    
    public init(frame: CGRect, isNerve: Bool) {
        super.init(frame: frame)
        self.isNerve = isNerve
        setupView(isNerve: isNerve)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        setupView()
    }
    
    func setupView(isNerve: Bool) {
        
        confirmButton.setTitle("Confirm", for: .normal)
        cancelButton.setTitle("Cancel", for: .normal)
        
        if isNerve {
            outerColorSelectorView.titleLabel.text = "Border color"
        }
        
        self.view.backgroundColor = App.Colors.extraLightBlue
        self.view.layer.cornerRadius = 10
        outerColorSelectorView.delegate = self

        confirmButton.backgroundColor = App.Colors.lightBlue
        cancelButton.backgroundColor = App.Colors.lightBlue
        confirmButton.layer.cornerRadius = 5
        cancelButton.layer.cornerRadius = 5
        
        if !isNerve { hideSecondSelector() } else {
            innerColorSelectorView.delegate = self
        }
    }
    @IBAction func cancel(_ sender: Any) {
        innerColorSelectorView.selectedColor.backgroundColor = .white
        outerColorValue = 0xffffff
        delegate?.dismiss()
    }
    
    @IBAction func confirm(_ sender: Any) {
        if isNerve {
            delegate?.colorSelected(innerColor: Color(val: innerColorValue), outerColor: Color(val: outerColorValue), annotationId: annotationId)
        } else {
            delegate?.colorSelected(innerColor: Color(val: outerColorValue), outerColor: nil, annotationId: annotationId)
        }
    }
    
    func hideSecondSelector() {
        colorSelector2Height.constant = 0
    }
}

extension ColorSelectorPopup: ColorSelectorViewDelegate {
    func colorSelected(color: Int, selector: ColorSelectorView) {
        switch selector {
        case innerColorSelectorView:
            innerColorValue = color
            innerColorSelectorView.selectedColor.backgroundColor = UIColor(rgb: color)
        case outerColorSelectorView:
            outerColorValue = color
            outerColorSelectorView.selectedColor.backgroundColor = UIColor(rgb: color)
        default:
            break
        }
    }
}
