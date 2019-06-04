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
    
    var shapeTransformations: [Int:(dx:Double,dy:Double,scale:Double)] = [:]
    
    @IBOutlet weak var scrollview: UIScrollView!
    
    var macawView = MacawView()
    let stroke = Stroke(fill: Color.red, width: 1.0)
    var group: Group!
    
    var canvasActive: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configMacawView()
        createCanvas()
//        let backgroundPanel = Shape(form: Rect(x: 0, y: 0, w: 1024, h: 1024), fill: Color.clear, stroke: stroke)
//        let panel = Shape(form: Circle(cx: 0, cy: 0, r: 100), fill: Color.clear, stroke: stroke)
//
//        panel.onPan { event in
//
//            print("on pan")
//
//            guard let node = event.node else { print("problem on pan")
//                return
//
//            }
//
//            self.scrollview.isScrollEnabled = false
//
//            self.dx += event.dx
//            self.dy += event.dy
//            node.place = Transform.move(dx: self.dx, dy: self.dy).scale(sx: self.scale, sy: self.scale)
//
//            if event.count == 0 {
//                self.scrollview.isScrollEnabled = true
//            }
//        }
//
//        panel.onTouchReleased { _ in
//            self.scrollview.isScrollEnabled = true
//        }
//
//        panel.onPinch { event in
//
//            print("on pinch")
//
//            guard let node = event.node else { print("problem on pinch")
//                return
//
//            }
//
//            self.scale *= event.scale
//            node.place = Transform.move(dx: self.dx, dy: self.dy).scale(sx: self.scale, sy: self.scale)
//        }
//
//        backgroundPanel.onTap { _ in
//            self.scrollview.isScrollEnabled = true
//        }
//
//        group = Group(contents: [backgroundPanel,panel])
//
//        macawView.node = group
        
        
        
    }
    
    func createCanvas() {
        let canvas = Shape(form: Rect(x: 0, y: 0, w: 1024, h: 1024), fill: Color.clear, stroke: stroke)
        
        var startPoint = Point()
        var panel: Shape?
        
        var form: Locus?
        
        canvas.onTouchPressed { event in
            print("canvas.onTouchPressed")
            //self.scrollview.isScrollEnabled = true
            guard let loc = event.points.first?.location(in: .scene)  else {
                return
            }
            
            startPoint = loc
            
            panel = Shape(form: Rect(x: startPoint.x, y: startPoint.y, w: 0, h: 0), fill: Color.clear, stroke: self.stroke)
            
//            panel!.onPan { event in
//
//                if !self.canvasActive {
//
//                    print("panel!.onPan")
//
//                    guard let node = event.node else { print("problem on panel pan")
//                        return
//
//                    }
//
//                    self.scrollview.isScrollEnabled = false
//
//                    self.dx += event.dx
//                    self.dy += event.dy
//                    node.place = Transform.move(dx: self.dx, dy: self.dy).scale(sx: self.scale, sy: self.scale)
//
//                    if event.count == 0 {
//                        //self.scrollview.isScrollEnabled = true
//                    }
//
//                }
//            }
//
//            panel!.onTouchReleased { _ in
//                print("panel!.onTouchReleased")
//                //self.scrollview.isScrollEnabled = true
//            }
//
//            panel!.onPinch { event in
//
//                print("panel!.onPinch")
//
//                guard let node = event.node else { print("problem on panel pinch")
//                    return
//
//                }
//
//                self.scale *= event.scale
//                node.place = Transform.move(dx: self.dx, dy: self.dy).scale(sx: self.scale, sy: self.scale)
//            }
            
            var updatedGroup = self.group.contents
            updatedGroup.append(panel!)
            
            self.group.contents = updatedGroup
        }
        
        canvas.onTouchMoved { (event) in
            
            self.canvasActive = true
            
            print("canvas.onTouchMoved")
            
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            let width = loc.x - startPoint.x
            let height = loc.y - startPoint.y
            
            //self.dx += self.dx + width
            //self.dy += self.dy + height
            
            //panel!.place = Transform.move(dx: self.dx + width, dy: self.dy + height).scale(sx: self.scale, sy: self.scale)
            
            panel!.form = Rect(x: startPoint.x, y: startPoint.y, w: width, h: height)
            form = Rect(x: 0, y: 0, w: width, h: height)
            
        }
        
        canvas.onTouchReleased { (event) in
            
            self.group.contents.remove(at: self.group.contents.count - 1)
            
            let shape = Shape(form: form!, fill: Color.clear, stroke: self.stroke)
            shape.place = Transform.move(dx: startPoint.x, dy: startPoint.y).scale(sx: 1, sy: 1)
            
            self.shapeTransformations[shape.hash] = (startPoint.x,startPoint.y,1)
            
            shape.onPan { event in
                
                if !self.canvasActive {
                    
                    print("shape!.onPan")
                    
                    guard let node = event.node else { print("problem on panel pan")
                        return
                        
                    }
                    
                    self.scrollview.isScrollEnabled = false
                    
                    let transform = self.shapeTransformations[node.hash]
                    
                    let dx = transform!.dx + event.dx
                    let dy = transform!.dy + event.dy
                    let scale = transform!.scale
                    
                    self.shapeTransformations.updateValue((dx, dy, scale), forKey: node.hash)
                    
//                    self.dx += event.dx
//                    self.dy += event.dy
                    node.place = Transform.move(dx: dx, dy: dy).scale(sx: scale, sy: scale)
                    
                    print(dx)
                    print(dy)
                    
                    
                    
                    if event.count == 0 {
                        //self.scrollview.isScrollEnabled = true
                        
//                        self.group.contents.remove(at: self.group.contents.count - 1)
//
//                        let shape = Shape(form: form!, fill: Color.clear, stroke: self.stroke)
                    }
                    
                }
            }
            
            shape.onTouchReleased { _ in
                print("shape!.onTouchReleased")
                //self.scrollview.isScrollEnabled = true
            }
            
            shape.onPinch { event in
                
                //print("shape!.onPinch")
                
                guard let node = event.node else { print("problem on panel pinch")
                    return
                    
                }
                
                print(node.hash)
                
                let transform = self.shapeTransformations[node.hash]
                
                let dx = transform!.dx
                let dy = transform!.dy
                
                print(dx)
                print(dy)
                
                
                let scale = transform!.scale * event.scale
                print(scale)
                
                
                //print(scale)
                
                //self.scale *= event.scale
                
                self.shapeTransformations.updateValue((dx, dy, scale), forKey: node.hash)

                //node.place = Transform.move(dx: self.dx, dy: self.dy).scale(sx: scale, sy: scale)
                node.place = Transform.move(dx: dx, dy: dy).scale(sx: scale, sy: scale)
                

//                self.scale *= event.scale
//                node.place = Transform.move(dx: self.dx, dy: self.dy).scale(sx: self.scale, sy: self.scale)
                
            }
            
            var updatedGroup = self.group.contents
            updatedGroup.append(shape)
            self.group.contents = updatedGroup
            
            self.canvasActive = false
        }
        
//        backgroundPanel.onTouchPressed { (evento) in
//            self.createPanel()
//        }
        
        group = Group(contents: [canvas])
        
        macawView.node = group
        scrollview.bounces = false
    }
    
    func createPanel(location: Point) {
        
        

        
    }
    
    
    func configMacawView(){
        let imageView = UIImageView()
        let image = #imageLiteral(resourceName: "Medical_X-Ray_imaging_AAR02_nevit")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollview.contentSize = CGSize(width: 1024, height: 1024)
        scrollview.isScrollEnabled = false
        scrollview.bounces = false
        
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

