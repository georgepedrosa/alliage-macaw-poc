//
//  EventsExampleController.swift
//  Example
//
//  Created by Victor Sukochev on 02/03/2017.
//  Copyright © 2017 Exyte. All rights reserved.
//

import UIKit
import Macaw

enum ShapeType {
    case rectLine
    case arrow
    case other
}

enum Tool {
    case line
    case circle
    case rect
    case rectLine
    case arrow
    case none
}

class ViewController: UIViewController {
    
    var shapeTransformations: [Int:(dx:Double,dy:Double,scale:Double, angle:Double)] = [:]
    
    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var selectionButton: UIButton!
    
    var macawView = MacawView()
    let stroke = Stroke(fill: Color.red, width: 2.0)
    
    var group: Group!
    var canvas: Shape!
    var shapesGroup: Group = Group()
    
    var canvasActive: Bool = false
    var activeTool: Tool = .none
    let image = #imageLiteral(resourceName: "Medical_X-Ray_imaging_AAR02_nevit")
    var backgroundView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configMacawView()
        createCanvas()
    }
    
    func createCanvas() {
        self.canvas = Shape(form: Rect(x: 0, y: 0, w: Double(image.size.width), h: Double(image.size.height)), fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0))
        
        var startPoint = Point()
        var panel: Node?
        var lastForm: Locus?
        var shapeType: ShapeType?
        
        // creating new shape during first touch on canvas
        canvas.onTouchPressed { event in
            
            guard let loc = event.points.first?.location(in: .scene)  else {
                return
            }
            
            startPoint = loc
            let locus: Locus
            switch self.activeTool {
                
            case .line:
                locus = Line(startPoint.x, startPoint.y, startPoint.x, startPoint.y)
                panel = Shape(form: locus, fill: Color.clear, stroke: self.stroke)
            case .circle:
                locus = Circle(cx: startPoint.x, cy: startPoint.y, r: 0)
                panel = Shape(form: locus, fill: Color.clear, stroke: self.stroke)
            case .rect:
                locus = Rect(x: startPoint.x, y: startPoint.y, w: 0, h: 0)
                panel = Shape(form: locus, fill: Color.clear, stroke: self.stroke)
            case .arrow:
                panel = Arrow(startPoint: startPoint, lastPoint: startPoint)
            case .rectLine:
                panel = RectLine(startPoint: startPoint, lastPoint: startPoint)
            case .none:
                return
            }
            
            self.group.contents.append(panel!)
        }
        
        // resizing new shape when moving first touch
        canvas.onTouchMoved { (event) in
            
            //self.canvasActive = true
            
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            let width = loc.x - startPoint.x
            let height = loc.y - startPoint.y
            
            let locus: Locus
            
            switch self.activeTool {
                
            case .line:
                locus = Line(startPoint.x, startPoint.y, loc.x, loc.y)
                lastForm = Line(0, 0, loc.x - startPoint.x, loc.y - startPoint.y)
                let shape = panel as! Shape
                shape.form = locus
                shapeType = .other
            case .circle:
                locus = Circle(cx: startPoint.x, cy: startPoint.y, r: width)
                lastForm = Circle(cx: 0, cy: 0, r: width)
                let shape = panel as! Shape
                shape.form = locus
                shapeType = .other
            case .rect:
                locus = Rect(x: startPoint.x, y: startPoint.y, w: width, h: height)
                lastForm = Rect(x: 0, y: 0, w: width, h: height)
                let shape = panel as! Shape
                shape.form = locus
                shapeType = .other
            case .arrow:
                let arrow = panel as! Arrow
                arrow.updateForm(startPoint: startPoint, lastPoint: loc)
                shapeType = .arrow
            case .rectLine:
                let rectLine = panel as! RectLine
                rectLine.changeShape(startPoint: startPoint, lastPoint: loc)
                shapeType = .rectLine
            case .none:
                return
            }
        }
        
        // leaving new shape on canvas when releasing first touch
        canvas.onTouchReleased { (event) in
            
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            guard self.activeTool != .none else { return }
            
            self.group.contents.remove(at: self.group.contents.count - 1)
            
            let shape: Node!
            
            switch shapeType! {
            case .other:
                shape = Shape(form: lastForm!, fill: Color.clear, stroke: self.stroke)
            case .rectLine:
                shape = RectLine(startPoint: Point(0, 0), lastPoint: Point(loc.x - startPoint.x, loc.y - startPoint.y))
            case .arrow:
                shape = Arrow(startPoint: Point(0, 0), lastPoint: Point(loc.x - startPoint.x, loc.y - startPoint.y))
            }
            
            shape.place = Transform.move(dx: startPoint.x, dy: startPoint.y).scale(sx: 1, sy: 1)
            
            self.shapeTransformations[shape.hash] = (startPoint.x,startPoint.y,1, 0)
            
            // moving existing shape
            shape.onPan { event in
                
                if !self.canvasActive {
                    guard let node = event.node else { print("problem on panel pan")
                        return
                    }
                    
                    //self.scrollview.isScrollEnabled = false
                    
                    let transform = self.shapeTransformations[node.hash]
                    
                    let dx = transform!.dx + event.dx
                    let dy = transform!.dy + event.dy
                    let scale = transform!.scale
                    let angle = transform!.angle
                    
                    self.shapeTransformations.updateValue((dx, dy, scale, angle), forKey: node.hash)
                    
                    node.place = Transform.move(dx: dx, dy: dy).scale(sx: scale, sy: scale).rotate(angle: angle)
                    
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
                let angle = transform!.angle
                
                self.shapeTransformations.updateValue((dx, dy, scale, angle), forKey: node.hash)
                node.place = Transform.move(dx: dx, dy: dy).scale(sx: scale, sy: scale).rotate(angle: angle)
                //shape.stroke = Stroke(fill: Color.red, width: self.stroke.width/scale)
            }
            
            shape.onRotate { event in
                guard let node = event.node else { print("problem on panel rotate")
                    return
                }
                
                let transform = self.shapeTransformations[node.hash]
                let dx = transform!.dx
                let dy = transform!.dy
                let scale = transform!.scale
                let angle = transform!.angle + event.angle
                
                self.shapeTransformations.updateValue((dx, dy, scale, angle), forKey: node.hash)
                node.place = Transform.move(dx: dx, dy: dy).scale(sx: scale, sy: scale).rotate(angle: angle)
            }
            
            self.shapesGroup.contents.append(shape)// = Group(contents: shape)
//            let macawGroup = self.macawView.node as! Group
//            macawGroup.contents.append(contentsOf: self.shapes)
            //self.group.contents.append(shape)
            self.canvasActive = false
        }
        
        group = Group(contents: [canvas, shapesGroup])
        macawView.node = group
        scrollview.bounces = false
    }
    
    func configMacawView(){
        
        scrollview.isScrollEnabled = false
        scrollview.bounces = false
        //scrollview.delegate = self
        
        scrollview.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.centerXAnchor.constraint(equalTo: scrollview.centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: scrollview.centerYAnchor).isActive = true
        backgroundView.widthAnchor.constraint(equalTo:scrollview.widthAnchor).isActive = true
        backgroundView.heightAnchor.constraint(equalTo:scrollview.heightAnchor).isActive = true
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollview.contentSize = image.size

        backgroundView.addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo:backgroundView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo:backgroundView.heightAnchor).isActive = true
        
        macawView.backgroundColor = .clear
        macawView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(macawView)
        
        macawView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        macawView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        macawView.widthAnchor.constraint(equalTo:imageView.widthAnchor).isActive = true
        macawView.heightAnchor.constraint(equalTo:imageView.heightAnchor).isActive = true
    }
    
    @IBAction func activeLineTool(_ sender: UIButton) {
        activeTool = .line
    }
    @IBAction func activeRectTool(_ sender: UIButton) {
        activeTool = .rect
    }
    @IBAction func activeCircleTool(_ sender: Any) {
        activeTool = .circle
    }
    @IBAction func activeShapeTool(_ sender: Any) {
        activeTool = .rectLine
    }
    @IBAction func activeArrowTool(_ sender: Any) {
        activeTool = .arrow
    }
    
    @IBAction func activateSelectionTool(_ sender: Any) {
        
        selectionButton.isSelected = !selectionButton.isSelected
        let first = group.contents.remove(at: 0)
        group.contents.append(first)
    }
    
}

//extension ViewController: UIScrollViewDelegate {
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return backgroundView
//    }
//}
