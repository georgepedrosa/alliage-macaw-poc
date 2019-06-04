//
//  EventsExampleController.swift
//  Example
//
//  Created by Victor Sukochev on 02/03/2017.
//  Copyright © 2017 Exyte. All rights reserved.
//

import UIKit
import Macaw


enum Tool {
    case circle
    case rect
    case none
}

class ViewController: UIViewController {
    
    var shapeTransformations: [Int:(dx:Double,dy:Double,scale:Double)] = [:]
    
    @IBOutlet weak var scrollview: UIScrollView!
    
    var macawView = MacawView()
    let stroke = Stroke(fill: Color.red, width: 1.0)
    var group: Group!
    var canvasActive: Bool = false
    var activeTool: Tool = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configMacawView()
        createCanvas()
    }
    
    func createCanvas() {
        let canvas = Shape(form: Rect(x: 0, y: 0, w: 2000, h: 2000), fill: Color.clear, stroke: stroke)
        
        var startPoint = Point()
        var panel: Shape?
        var lastForm: Locus?
        
        // creating new shape during first touch on canvas
        canvas.onTouchPressed { event in
            
            guard let loc = event.points.first?.location(in: .scene)  else {
                return
            }
            
            startPoint = loc
            let locus: Locus
            switch self.activeTool {
                
            case .circle:
                locus = Circle(cx: startPoint.x, cy: startPoint.y, r: 0)
            case .rect:
                locus = Rect(x: startPoint.x, y: startPoint.y, w: 0, h: 0)
            case .none:
                return
            }
            
            panel = Shape(form: locus, fill: Color.clear, stroke: self.stroke)
            self.group.contents.append(panel!)
        }
        
        // resizing new shape when moving first touch
        canvas.onTouchMoved { (event) in
            
            self.canvasActive = true
            
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            let width = loc.x - startPoint.x
            let height = loc.y - startPoint.y
            
            let locus: Locus
            
            switch self.activeTool {
                
            case .circle:
                locus = Circle(cx: startPoint.x, cy: startPoint.y, r: width)
                lastForm = Circle(cx: 0, cy: 0, r: width)
            case .rect:
                locus = Rect(x: startPoint.x, y: startPoint.y, w: width, h: height)
                lastForm = Rect(x: 0, y: 0, w: width, h: height)
            case .none:
                return
            }
            
            panel!.form = locus
           
        }
        
        // leaving new shape on canvas when releasing first touch
        canvas.onTouchReleased { (event) in
            guard self.activeTool != .none else { return }
                
                
            self.group.contents.remove(at: self.group.contents.count - 1)
            
            let shape = Shape(form: lastForm!, fill: Color.clear, stroke: self.stroke)
            shape.place = Transform.move(dx: startPoint.x, dy: startPoint.y).scale(sx: 1, sy: 1)
            
            self.shapeTransformations[shape.hash] = (startPoint.x,startPoint.y,1)
            
            // moving existing shape
            shape.onPan { event in
                
                if !self.canvasActive {
                    guard let node = event.node else { print("problem on panel pan")
                        return
                    }
                    
                    self.scrollview.isScrollEnabled = false
                    
                    let transform = self.shapeTransformations[node.hash]
                    
                    let dx = transform!.dx + event.dx
                    let dy = transform!.dy + event.dy
                    let scale = transform!.scale
                    
                    self.shapeTransformations.updateValue((dx, dy, scale), forKey: node.hash)
                    
                    node.place = Transform.move(dx: dx, dy: dy).scale(sx: scale, sy: scale)
                    
                }
            }
            
            // resizing existing shape
            shape.onPinch { event in
                
                guard let node = event.node else { print("problem on panel pinch")
                    return
                }
                
                let transform = self.shapeTransformations[node.hash]
                let dx = transform!.dx
                let dy = transform!.dy
                let scale = transform!.scale * event.scale
                self.shapeTransformations.updateValue((dx, dy, scale), forKey: node.hash)
                node.place = Transform.move(dx: dx, dy: dy).scale(sx: scale, sy: scale)
            }
            
            self.group.contents.append(shape)
            self.canvasActive = false
        }
        
        group = Group(contents: [canvas])
        macawView.node = group
        scrollview.bounces = false
    }
    
    func configMacawView(){
        let imageView = UIImageView()
        let image = #imageLiteral(resourceName: "Medical_X-Ray_imaging_AAR02_nevit")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollview.contentSize = CGSize(width: 2000, height: 2000)
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
    

    @IBAction func activeRectTool(_ sender: UIButton) {
        activeTool = .rect
    }
    
    
    @IBAction func activeCircleTool(_ sender: Any) {
        activeTool = .circle
    }
    
}
