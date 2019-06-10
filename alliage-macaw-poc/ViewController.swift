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
    case freeDraw
    case line
    case ellipse
    case rect
    case rectLine
    case arrow
    case asterisk
    case none
}

class ViewController: UIViewController {
    
    var shapeActive: Bool = false
    
    var shapeTransformations: [Int:(dx:Double,dy:Double,scale:Double, angle:Double, angleX:Double, angleY: Double)] = [:]
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var selectionButton: UIButton!
    
    var macawView = MacawView()
    let stroke = Stroke(fill: Color.red, width: 2.0)
    
    var group: Group!
    var canvas: Shape!
    var shapesGroup: Group = Group()
    var redoShapes: [Node] = []
    var newShape: CustomShape!
    
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
        //var panel: Node?
        
        // creating new shape during first touch on canvas
        canvas.onTouchPressed { event in
            
            guard let loc = event.points.first?.location(in: .scene)  else {
                return
            }
            
            startPoint = loc
            
            switch self.activeTool {
            case .freeDraw:
                self.newShape = FreeDrawing(startPoint: startPoint, lastPoint: startPoint)
            case .line:
                self.newShape = CustomLine(startPoint: startPoint, lastPoint: startPoint)
            case .ellipse:
                self.newShape = CustomEllipse(startPoint: startPoint, lastPoint: startPoint)
            case .rect:
                self.newShape = CustomRect(startPoint: startPoint, lastPoint: startPoint)
            case .arrow:
                self.newShape = Arrow(startPoint: startPoint, lastPoint: startPoint)
            case .rectLine:
                self.newShape = RectLine(startPoint: startPoint, lastPoint: startPoint)
            case .asterisk:
                self.newShape = Asterisk(startPoint: startPoint, lastPoint: startPoint)
            case .none:
                return
            }
            
            self.redoShapes = []
            self.group.contents.append(self.newShape)
        }
        
        // resizing new shape when moving first touch
        canvas.onTouchMoved { (event) in
                    
            //self.canvasActive = true
            
            if self.activeTool == .none {
                return
            }
            
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            self.newShape.updateForm(startPoint: startPoint, lastPoint: loc)
            
            if self.activeTool == .freeDraw {
                startPoint = loc
            }
        }
        
        // leaving new shape on canvas when releasing first touch
        canvas.onTouchReleased { (event) in
            
            guard self.activeTool != .none else { return }
            
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            if let _ = self.newShape as? FreeDrawing {
                let center = self.newShape.getCenter()
                self.shapeTransformations[self.newShape.hash] = (startPoint.x,startPoint.y,1, 0, center?.x ?? 0, center?.y ?? 0)
            } else {
                self.group.contents.removeLast()
                self.newShape.updateForm(startPoint: Point(0, 0), lastPoint: Point(loc.x - startPoint.x, loc.y - startPoint.y))
                self.newShape.activateCircleAction()
                self.newShape.place = Transform.move(dx: startPoint.x, dy: startPoint.y).scale(sx: 1, sy: 1)
                let center = self.newShape.getCenter()
                self.shapeTransformations[self.newShape.hash] = (startPoint.x,startPoint.y,1, 0, center?.x ?? 0, center?.y ?? 0)
            }

            self.newShape.onTap(f: { (event) in
                
                guard let node = event.node else { print("problem on panel pan")
                    return
                }
                
                self.shapeActive = !self.shapeActive
                
                if let customShape = node as? CustomShape {
                    
                    if self.shapeActive {
                        let stroke = Stroke(fill: Color.blue, width: 2.0)
                        customShape.updateStroke(stroke: stroke)
                    } else {
                        let stroke = Stroke(fill: Color.red, width: 2.0)
                        customShape.updateStroke(stroke: stroke)
                    }
                }
            })
            
            // moving existing shape
            self.newShape.onPan { event in
                
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
                    let angleX = transform!.angleX
                    let angleY = transform!.angleY
                    
                    let shape = node as! CustomShape
                    let center = shape.getCenter()
                    
                    node.place = Transform.move(dx: dx, dy: dy).scale(sx: scale, sy: scale).rotate(angle: angle, x: angleX, y: angleY)
                    
                    self.shapeTransformations.updateValue((dx, dy, scale, angle, angleX, angleY), forKey: node.hash)
                    
                }
            }
            
            // resizing existing shape
            self.newShape.onPinch { event in
                
                guard let node = event.node else { print("problem on panel pinch")
                    return
                }
                
                let transform = self.shapeTransformations[node.hash]
                let dx = transform!.dx
                let dy = transform!.dy
                let scale = transform!.scale * event.scale
                let angle = transform!.angle
                let angleX = transform!.angleX
                let angleY = transform!.angleY
                
                let shape = node as! CustomShape
                let center = shape.getCenter()
                
                node.place = Transform.move(dx: dx, dy: dy).scale(sx: scale, sy: scale).rotate(angle: angle, x: angleX, y: angleY)
                
                self.shapeTransformations.updateValue((dx, dy, scale, angle, angleX, angleY), forKey: node.hash)
                
                let newStroke = Stroke(fill: Color.red, width: self.stroke.width/scale)
                
                if let shape = node as? CustomShape {
                    shape.updateStroke(stroke: newStroke)
                }
            }
            
            self.newShape.onRotate { event in
                guard let node = event.node else { print("problem on panel rotate")
                    return
                }
                
                let shape = node as! CustomShape
                let center = shape.getCenter()
                
                let transform = self.shapeTransformations[node.hash]
                let dx = transform!.dx
                let dy = transform!.dy
                let scale = transform!.scale
                let angle = transform!.angle + event.angle
                let angleX = center?.x ?? 0
                let angleY = center?.y ?? 0
                
                node.place = Transform.move(dx: dx, dy: dy).scale(sx: scale, sy: scale).rotate(angle: angle, x: angleX, y: angleY)
                
                self.shapeTransformations.updateValue((dx, dy, scale, angle, angleX, angleY), forKey: node.hash)
            }
            
            self.shapesGroup.contents.append(self.newShape)
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
    
    @IBAction func freeDrawingTool(_ sender: UIButton) {
        activeTool = .freeDraw
    }
    @IBAction func activeLineTool(_ sender: UIButton) {
        activeTool = .line
    }
    @IBAction func activeRectTool(_ sender: UIButton) {
        activeTool = .rect
    }
    @IBAction func activeCircleTool(_ sender: Any) {
        activeTool = .ellipse
    }
    @IBAction func activeShapeTool(_ sender: Any) {
        activeTool = .rectLine
    }
    @IBAction func activeArrowTool(_ sender: Any) {
        activeTool = .arrow
    }
    @IBAction func activeAsteriskTool(_ sender: Any) {
        activeTool = .asterisk
    }
    @IBAction func activateSelectionTool(_ sender: Any) {
        selectionButton.isSelected = !selectionButton.isSelected
        let first = group.contents.remove(at: 0)
        group.contents.append(first)
    }
    @IBAction func undoTool(_ sender: Any) {
        if let undoneNode = shapesGroup.contents.popLast() {
            if let freeDrawing = undoneNode as? FreeDrawing {
                freeDrawing.deleteShape()
            }
            redoShapes.append(undoneNode)
        }
    }
    
    @IBAction func redoTool(_ sender: Any) {
        if let redoneNode = redoShapes.popLast() {
            if let freeDrawing = redoneNode as? FreeDrawing {
                freeDrawing.redoShape()
            }
            shapesGroup.contents.append(redoneNode)
        }
    }
    
}

//extension ViewController: UIScrollViewDelegate {
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return backgroundView
//    }
//}
