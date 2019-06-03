//
//  File.swift
//  alliage-macaw-poc
//
//  Created by George Pedrosa on 31/05/19.
//  Copyright © 2019 Vitor Muniz. All rights reserved.
//

import UIKit
import Macaw

class ViewController2: UIViewController {
    
    var macawView = MacawView()
    
    let stroke = Stroke(fill: Color.red, width: 1.0)
    var group: Group!
    override func viewDidLoad() {
        super.viewDidLoad()
        configMacawView()
        
        let square = Shape(form: Rect(x: 0, y: 0, w: 80.0, h: 120.0), fill: Color.clear, stroke: stroke)
        
        square.onPan { event in
            square.place = square.place.move(dx: event.dx, dy: event.dy)
        }
        
        macawView.node = square
        
    }
    
    func configMacawView(){
        let imageView = UIImageView()
        let image = #imageLiteral(resourceName: "Medical_X-Ray_imaging_AAR02_nevit")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo:view.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo:view.heightAnchor).isActive = true
        
        macawView.backgroundColor = .clear
        macawView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(macawView)
        
        macawView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        macawView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        macawView.widthAnchor.constraint(equalTo:imageView.widthAnchor).isActive = true
        macawView.heightAnchor.constraint(equalTo:imageView.heightAnchor).isActive = true
        
        
    }
}
