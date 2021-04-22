//
//  ColorSelectorPopup.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 20/04/21.
//  Copyright © 2021 Vitor Muniz. All rights reserved.
//

import Foundation
import Macaw

protocol ColorSelectorPopupDelegate: class {
    func colorSelected(color: Color, annotationId: Int?)
    func dismiss()
}

class ColorSelectorPopup: NibView {
    
    @IBOutlet weak var confirmationButton: UIButton!
    @IBOutlet weak var cancelationButton: UIButton!
    @IBOutlet weak var colorSelectorView: ColorSelectorView!
    
    weak var delegate: ColorSelectorPopupDelegate?
    var annotationId: Int!
    var width: Double!
    var colorValue: Int = 0xffffff
    var shapeHidden: Bool = false
        
    override func awakeFromNib() {
        super.awakeFromNib()
//        setupView()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
//    public init(frame: CGRect, isNerve: Bool) {
//        super.init(frame: frame)
//        setupView()
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        setupView()
    }
    
    func setupView() {
        
        confirmationButton.setTitle("Confirm", for: .normal)
        cancelationButton.setTitle("Cancel", for: .normal)
        
//        self.view.backgroundColor = App.Colors.extraLightBlue
        self.view.layer.cornerRadius = 10
        colorSelectorView.delegate = self

//        confirmationButton.backgroundColor = App.Colors.lightBlue
//        cancelationButton.backgroundColor = App.Colors.lightBlue
        confirmationButton.layer.cornerRadius = 5
        cancelationButton.layer.cornerRadius = 5
        
    }
    
    @IBAction func cancelation(_ sender: Any) {
        colorSelectorView.selectedColor.backgroundColor = .white
        colorValue = 0xffffff
        delegate?.dismiss()
    }
    
    @IBAction func confirmation(_sender: Any) {
        delegate?.colorSelected(color: Color(val: colorValue), annotationId: annotationId)
    }
}

extension ColorSelectorPopup: ColorSelectorViewDelegate {
    func colorSelected(color: Int) {
            colorValue = color
            colorSelectorView.selectedColor.backgroundColor = UIColor(rgb: color)
    }
}
