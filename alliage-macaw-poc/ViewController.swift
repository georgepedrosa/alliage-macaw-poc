//
//  EventsExampleController.swift
//  Example
//
//  Created by Victor Sukochev on 02/03/2017.
//  Copyright © 2017 Exyte. All rights reserved.
//

import UIKit
import Macaw

class ViewController: UIViewController {
    
    var dx: Double = 0
    var dy: Double = 0
    var scale: Double = 1
    
    @IBOutlet weak var scrollview: UIScrollView!
    var macawView = MacawView()
    
    //var isPanelsSelect = false
    
    let stroke = Stroke(fill: Color.red, width: 1.0)
    var group: Group!
    override func viewDidLoad() {
        super.viewDidLoad()
        configMacawView()
        let backgroundPanel = Shape(form: Rect(x: 0, y: 0, w: 1024, h: 1024), fill: Color.clear, stroke: stroke)
        let panel = Shape(form: Circle(cx: 0, cy: 0, r: 100), fill: Color.clear, stroke: stroke)
        //let panel = Shape(form: Rect(x: 0, y: 0, w: 80.0, h: 120.0), fill: Color.clear, stroke: stroke)
        
//        panel.onTap { (event) in
//            print("on tap")
//            guard let node = event.node else { print("problem no pan")
//                return
//
//            }
//
//            let transform = Transform.scale(sx: 2, sy: 2)
//
//            node.placeVar.animate(to: transform, during: 0.6)
//
//
//            //node.place = node.place.scale(sx: 2, sy: 2)
//
//        }
        
        panel.onPan { event in
            
            print("on pan")

            guard let node = event.node else { print("problem no pan")
                return

            }
            
            self.scrollview.isScrollEnabled = false
            
            self.dx += event.dx
            self.dy += event.dy
            node.place = Transform.move(dx: self.dx, dy: self.dy).scale(sx: self.scale, sy: self.scale)

//            node.place = node.place.move(dx: event.dx, dy: event.dy)
//


            if event.count == 0 {
                self.scrollview.isScrollEnabled = true
            }
        }
        
        panel.onTouchReleased { _ in
            self.scrollview.isScrollEnabled = true
        }
        
        panel.onPinch { event in

            print("on pinch")

            guard let node = event.node else { print("problem no pan")
                return

            }
            
            self.scale *= event.scale
            node.place = Transform.move(dx: self.dx, dy: self.dy).scale(sx: self.scale, sy: self.scale)
            
            //let transform = Transform.scale(sx: event.scale, sy: event.scale)//.move(dx: node.bounds!.x, dy: node.bounds!.y)
            
            //node.place = node.place.scale(sx: event.scale, sy: event.scale)//.move(dx: node.bounds!.x, dy: node.bounds!.y)
            
//            node.bounds = node.bounds?.applying(.scale(sx: event.scale, sy: event.scale))
            //shape.form = node.bounds!.applying(transform)
            //node.bounds = node.bounds?.applying(transform)
            
            //print(node.bounds?.x)
            //print(node.bounds?.y)
            
            //print(event.scale)
//            shape.form = Rec
//            shape.form = Rect(x: shape.bounds!.x, y: shape.bounds!.y, w: shape.bounds!.x + event.scale, h: shape.bounds!.y + event.scale)
        }
        
        backgroundPanel.onTap { _ in
            self.scrollview.isScrollEnabled = true
        }
        
        group = Group(contents: [backgroundPanel,panel])

        macawView.node = group
        scrollview.bounces = false
        
    }
    
    func configMacawView(){
        let imageView = UIImageView()
        let image = #imageLiteral(resourceName: "Medical_X-Ray_imaging_AAR02_nevit")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollview.contentSize = CGSize(width: 1024, height: 1024)
        
        scrollview.addSubview(imageView)
        
        
        macawView.backgroundColor = .clear
        macawView.translatesAutoresizingMaskIntoConstraints = false
        scrollview.addSubview(macawView)
        
        macawView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        macawView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        macawView.widthAnchor.constraint(equalTo:imageView.widthAnchor).isActive = true
        macawView.heightAnchor.constraint(equalTo:imageView.heightAnchor).isActive = true
        
        
    }
    
//    @IBAction func onDelete(_ sender: Any) {
//        group.contents.popLast()
//    }
    
}
