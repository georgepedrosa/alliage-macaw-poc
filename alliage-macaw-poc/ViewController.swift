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
    case text
    case line
    case ellipse
    case rect
    case protractor
    case arrow
    case asterisk
    case arc
    case delete
    case selection
    case none
}

protocol MacawViewDelegate: UIViewController {
    var shapeTransformations: [Int:(dx:Double,dy:Double,scale:Double, angle:Double)] { get set }
    func activateScrollView(enable: Bool)
    func updatePlace(node: Node)
    var shapesGroup: Group { get set }
    var activeTool: Tool { get set }
    var stroke: Stroke { get }
    var textColor: Color { get }
    var inputTextView: UITextView { get }
    var customTexts: [CustomText] { get set }
    var isKeyboardShowing: Bool { get set }
}

class ViewController: UIViewController, MacawViewDelegate {
    
    var shapeActive: Bool = false
    
    var shapeTransformations: [Int:(dx:Double,dy:Double,scale:Double, angle:Double)] = [:]
    
    var transformHistory: [Int:(dx:Double,dy:Double,scale:Double, angle:Double)] = [:]
    
    var macawActions: [MacawAction] = []
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var freeButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var lineButton: UIButton!
    @IBOutlet weak var rectButton: UIButton!
    @IBOutlet weak var circleButton: UIButton!
    @IBOutlet weak var protractorButton: UIButton!
    @IBOutlet weak var arcButton: UIButton!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var asteriskButton: UIButton!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var handButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var macawView = MacawView()
    
    var lastSelectedButton: UIButton!
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let inputTextView: UITextView = {
        let textView = UITextView()
        return textView
    }()
    
    let stroke = Stroke(fill: Color.red, width: 5.0)
    let textColor = Color.red
    
    var group: Group!
    var canvas: Shape!
    var shapesGroup: Group = Group()
    var redoShapes: [Node] = []
    
    var tempShapes: [Node] = []
    
    var newShape: CustomShape!
    
    var customTexts: [CustomText] = []
    var isKeyboardShowing: Bool = false
    
    var drawingActive: Bool = true {
        didSet {
            if oldValue != drawingActive {
                let first = group.contents.remove(at: 0)
                group.contents.append(first)
            }
        }
        willSet {
            if !newValue {
                //selectionButton.isSelected = true
                activateScrollView(enable: true)
            } else {
                //selectionButton.isSelected = false
                activateScrollView(enable: false)
            }
        }
    }
    
    var activeTool: Tool = .none {
        willSet {
            if newValue == .none {
                freeButton.isSelected = false
                textButton.isSelected = false
                lineButton.isSelected = false
                rectButton.isSelected = false
                circleButton.isSelected = false
                protractorButton.isSelected = false
                arcButton.isSelected = false
                arrowButton.isSelected = false
                asteriskButton.isSelected = false
                selectionButton.isSelected = false
                handButton.isSelected = false
                deleteButton.isSelected = false
            }
        }
    }
    let image = #imageLiteral(resourceName: "Medical_X-Ray_imaging_AAR02_nevit")
    var backgroundView = UIView()
    
    var bottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configMacawView()
        createCanvas()
        
        view.addSubview(messageInputContainerView)
        messageInputContainerView.translatesAutoresizingMaskIntoConstraints = false
        messageInputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        messageInputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        messageInputContainerView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        setupInputComponents()
        configInputNotifications()
        
    }
    
    func setupInputComponents() {
        messageInputContainerView.addSubview(inputTextView)
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.leadingAnchor.constraint(equalTo: messageInputContainerView.leadingAnchor, constant: 8).isActive = true
        inputTextView.trailingAnchor.constraint(equalTo: messageInputContainerView.trailingAnchor).isActive = true
        inputTextView.bottomAnchor.constraint(equalTo: messageInputContainerView.bottomAnchor).isActive = true
        inputTextView.topAnchor.constraint(equalTo: messageInputContainerView.topAnchor).isActive = true
        messageInputContainerView.isHidden = true
        inputTextView.delegate = self
    }
    
    func configInputNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification //storing keyboard state for future reference on text events
            
            if !isKeyboardShowing { //deactivates all text nodes if keyboard is dismissed
                for text in self.customTexts {
                text.isActive = false
                }
            }
            
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame.height : 0 //sets inputView constraint according to keyboard height
            self.messageInputContainerView.isHidden = !self.messageInputContainerView.isHidden

            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (completed) in
            }
        }
    }
    
    func distance(_ a: Point, _ b: Point) -> Double {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return Double(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func createCanvas() {
        self.canvas = Shape(form: Rect(x: 0, y: 0, w: Double(image.size.width), h: Double(image.size.height)), fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0)) //creating background canvas
        
        var startPoint = Point()
        
        // creating new shape during first touch on canvas
        canvas.onTouchPressed { event in
            
            if self.selectionButton.isSelected { return }
            
            guard let loc = event.points.first?.location(in: .scene)  else { return }
            
            startPoint = loc //stores initial touch point of new shape to be referenced on subsequent events
            
            self.redoShapes = [] //creating new shape empties redo shapes array
            
            //stores new shape to be referenced on subsequent events
            switch self.activeTool {
            case .freeDraw:
                self.newShape = FreeDrawing(startPoint: startPoint, lastPoint: startPoint, stroke: self.stroke)
            case .text:
                return //text shape only added to canvas after touch released event
            case .line:
                self.newShape = CustomLine(startPoint: startPoint, lastPoint: startPoint, stroke: self.stroke)
            case .ellipse:
                self.newShape = CustomEllipse(startPoint: startPoint, lastPoint: startPoint, stroke: self.stroke)
            case .rect:
                self.newShape = CustomRect(startPoint: startPoint, lastPoint: startPoint, stroke: self.stroke)
            case .arrow:
                self.newShape = Arrow(startPoint: startPoint, lastPoint: startPoint, stroke: self.stroke)
            case .protractor:
                self.newShape = Protractor(startPoint: startPoint, lastPoint: startPoint, stroke: self.stroke)
            case .asterisk:
                self.newShape = Asterisk(startPoint: startPoint, lastPoint: startPoint, stroke: self.stroke)
            case .arc:
                self.newShape = CustomArc(startPoint: startPoint, lastPoint: startPoint, stroke: self.stroke)
            case .selection:
                return
            case .delete:
                return
            case .none:
                return
            }
            self.shapesGroup.contents.append(self.newShape)
        }
        
        // resizing new shape when moving first touch
        canvas.onTouchMoved { (event) in
            //self.canvasActive = true
            if self.activeTool == .none || self.activeTool == .delete || self.activeTool == .text || self.selectionButton.isSelected { return }
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.newShape.updateForm(startPoint: startPoint, lastPoint: loc) //updates form of newly created shape while initial touch isn't released
            if self.activeTool == .freeDraw {
                startPoint = loc //Free Draw line creation: start point is the last touched point
            }
        }
        
        // leaving new shape on canvas when releasing first touch
        canvas.onTouchReleased { (event) in
            
            if self.activeTool == .none || self.activeTool == .delete || self.selectionButton.isSelected { return }
            
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
            if self.activeTool == .text { //special case for text behaviour and events
//                self.setTextEvents(startPoint: startPoint)
                
                let customText = CustomText(text: "", startPoint: startPoint, color: self.textColor)
                customText.delegate = self
                self.customTexts.append(customText) //stores all created texts
                self.inputTextView.becomeFirstResponder() //always displays keyboard after creating text
                self.shapeTransformations[customText.hash] = (0,0, 1, 0)
                
                customText.setTextEvents(startPoint: startPoint)
                
                return //adds newly created text to shapes array and ignores subsequent events
            } else
            if let protractor = self.newShape as? Protractor { //special case for protractor behaviour and events
                self.recreateShape(shape: protractor, startPoint: startPoint, loc: loc)
                protractor.p0 = startPoint
                protractor.p1 = loc
                let d = self.distance(startPoint, loc)
                let angle = atan2(loc.y - startPoint.y, loc.x - startPoint.x)
                let x2 = startPoint.x + d * cos(angle + Double.pi/4)
                let y2 = startPoint.y + d * sin(angle + Double.pi/4)
                protractor.p2 = Point(x: x2, y: y2)
                protractor.delegate = self
                protractor.setProtractorEvents()
                return //ignores subsequent events
            } else
            if let arc = self.newShape as? CustomArc {
                self.recreateShape(shape: arc, startPoint: startPoint, loc: loc)
                arc.p0 = startPoint
                arc.p1 = Point((loc.x + startPoint.x)/2, (loc.y + startPoint.y)/2)
                arc.p2 = loc
                arc.delegate = self
                arc.setArcEvents()
                //self.setArcEvents(arc: arc)
                return
            } else
            if let _ = self.newShape as? FreeDrawing {
                self.shapeTransformations[self.newShape.hash] = (0,0, 1, 0)
                //self.setDeleteEvent(node: freeDrawing)
                //return //ignores subsequent events
            } else if let line = self.newShape as? CustomLine {
                self.recreateShape(shape: line, startPoint: startPoint, loc: loc)
                line.startPoint = startPoint
                line.lastPoint = loc
                line.delegate = self
                line.setLineEvents()
                //self.setLineEvents(line: line)
                return
            } else if let _ = self.newShape as? Asterisk {
                self.shapeTransformations[self.newShape.hash] = (0,0,1,0)
            } else { //general shape creation and events
                self.recreateShape(shape: self.newShape, startPoint: startPoint, loc: loc)
            }
            
            self.setDeleteEvent(node: self.newShape)
            
            // moving existing shape
            self.newShape.onPan { event in
                //if !self.canvasActive {
                if self.activeTool == .none { return }
                guard let node = event.node else { print("problem on panel pan")
                    return
                }
                self.activateScrollView(enable: false)
                let transform = self.shapeTransformations[node.hash]
                self.shapeTransformations.updateValue((transform!.dx + event.dx, transform!.dy + event.dy, transform!.scale, transform!.angle), forKey: node.hash)
                self.updatePlace(node: node)
                self.activateScrollView(enable: true)
                
                //self.macawActions.append(MacawAction(nodeHash: node.hash, type: .pan, transformation: transform))
                //}
            }
            
            if let _ = self.newShape as? Asterisk {
                return
            }
            
            if let _ = self.newShape as? FreeDrawing {
                return
            }
            
            // resizing existing shape
            self.newShape.onPinch { event in
                
                if self.activeTool == .none { return }
                
                guard let node = event.node else { print("problem on panel pinch")
                    return
                }
                
                self.activateScrollView(enable: false)
                
                let transform = self.shapeTransformations[node.hash]
                self.shapeTransformations.updateValue((transform!.dx, transform!.dy, transform!.scale * event.scale, transform!.angle), forKey: node.hash)
                self.updatePlace(node: node)
                
                let newStroke = Stroke(fill: self.stroke.fill, width: self.stroke.width/(transform!.scale * event.scale))
                if let shape = node as? CustomShape {
                    shape.updateStroke(stroke: newStroke)
                }
                self.activateScrollView(enable: true)
            }
            
            self.newShape.onRotate { event in
                
                if self.activeTool == .none { return }
                
                guard let node = event.node else { print("problem on panel rotate")
                    return
                }
                self.activateScrollView(enable: false)
                
                let transform = self.shapeTransformations[node.hash]
                self.shapeTransformations.updateValue((transform!.dx, transform!.dy, transform!.scale, transform!.angle + event.angle), forKey: node.hash)
                self.updatePlace(node: node)
                self.activateScrollView(enable: true)
            }
        }
        
        group = Group(contents: [shapesGroup, canvas])
        macawView.node = group
    }
    
    func recreateShape(shape: CustomShape, startPoint: Point, loc: Point) {
        self.shapesGroup.contents.removeLast()
        shape.updateForm(startPoint: Point(0, 0), lastPoint: Point(loc.x - startPoint.x, loc.y - startPoint.y))
        shape.place = Transform.move(dx: startPoint.x, dy: startPoint.y).scale(sx: 1, sy: 1)
        self.shapeTransformations[self.newShape.hash] = (startPoint.x,startPoint.y, 1, 0)
        self.shapesGroup.contents.append(shape)
    }
    
    func setDeleteEvent(node: CustomShape) {
        node.onTap(f: { (event) in
            if self.activeTool == .none { return }
            guard let node = event.node else { print("problem on panel pan")
                return
            }
            if self.activeTool == .delete {
                self.shapesGroup.contents.removeAll(where: { (shape) -> Bool in
                    shape.hash == node.hash
                })
            }
        })
    }

    func updatePlace(node: Node) {
        let shape = node as! CustomShape
        let center = shape.getCenter()
        let transform = self.shapeTransformations[node.hash]
        node.place = Transform.move(dx: transform!.dx + center!.x, dy: transform!.dy + center!.y).scale(sx: transform!.scale, sy: transform!.scale).rotate(angle: transform!.angle).move(dx: -center!.x, dy: -center!.y)
    }

    func configMacawView(){
        
        activateScrollView(enable: false)
        scrollview.delegate = self
        scrollview.bounces = false
        scrollview.bouncesZoom = false
        scrollview.minimumZoomScale = 1.0
        
        scrollview.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.centerXAnchor.constraint(equalTo: scrollview.centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: scrollview.centerYAnchor).isActive = true
        backgroundView.widthAnchor.constraint(equalTo:scrollview.widthAnchor).isActive = true
        backgroundView.heightAnchor.constraint(equalTo:scrollview.heightAnchor).isActive = true
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollview.contentSize = CGSize(width: backgroundView.frame.width, height: backgroundView.frame.height)

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
    
    func activateScrollView(enable: Bool) {
        scrollview.isScrollEnabled = enable
        scrollview.pinchGestureRecognizer?.isEnabled = enable
    }
    
    @IBAction func freeDrawingTool(_ sender: UIButton) {
        activateScrollView(enable: false)
        activeTool = .none
        activeTool = .freeDraw
        freeButton.isSelected = true
        drawingActive = true
//        if lastSelectedButton != freeButton {
//            if lastSelectedButton != nil {
//                lastSelectedButton.isSelected = false
//            }
//            freeButton.isSelected = true
//            lastSelectedButton = freeButton
//        }
    }
    
    @IBAction func textTool(_ sender: UIButton) {
        activateScrollView(enable: false)
        activeTool = .none
        activeTool = .text
        textButton.isSelected = true
        drawingActive = true
//        if lastSelectedButton != textButton {
//            if lastSelectedButton != nil {
//                lastSelectedButton.isSelected = false
//            }
//            textButton.isSelected = true
//            lastSelectedButton = textButton
//        }
    }
    
    @IBAction func activeLineTool(_ sender: UIButton) {
        activateScrollView(enable: false)
        activeTool = .none
        activeTool = .line
        lineButton.isSelected = true
        drawingActive = true
    }
    
    @IBAction func activeRectTool(_ sender: UIButton) {
        activateScrollView(enable: false)
        activeTool = .none
        activeTool = .rect
        rectButton.isSelected = true
        drawingActive = true
    }
    
    @IBAction func activeCircleTool(_ sender: Any) {
        activateScrollView(enable: false)
        activeTool = .none
        activeTool = .ellipse
        circleButton.isSelected = true
        drawingActive = true
    }
    
    @IBAction func activeShapeTool(_ sender: Any) {
        activateScrollView(enable: false)
        activeTool = .none
        activeTool = .protractor
        protractorButton.isSelected = true
        drawingActive = true
    }
    
    @IBAction func activeArrowTool(_ sender: Any) {
        activateScrollView(enable: false)
        activeTool = .none
        activeTool = .arrow
        arrowButton.isSelected = true
        drawingActive = true
    }
    
    @IBAction func activeAsteriskTool(_ sender: Any) {
        activateScrollView(enable: false)
        activeTool = .none
        activeTool = .asterisk
        asteriskButton.isSelected = true
        drawingActive = true
    }
    
    @IBAction func activateArcTool(_ sender: UIButton) {
        activateScrollView(enable: false)
        activeTool = .none
        activeTool = .arc
        arcButton.isSelected = true
        drawingActive = true
    }
    
    @IBAction func activateSelectionTool(_ sender: Any) {
        activeTool = .none
        drawingActive = false
        activeTool = .selection
        selectionButton.isSelected = true
    }

    @IBAction func undoTool(_ sender: Any) {
//        if let undoneAction = macawActions.popLast() {
//            let node = group.contents.first { (node) -> Bool in
//                node.hash == undoneAction.nodeHash
//            }
//
//            if node != nil {
//
//                let shape = node as! CustomShape
//
//                if undoneAction.type == ActionType.create {
//
//                } else {
//
//                    let transformation = (dx: -undoneAction.transformation!.dx, dy: -undoneAction.transformation!.dy, scale: undoneAction.transformation!.scale, angle: undoneAction.transformation!.scale)
//                    shapeTransformations[shape.hash] = transformation
//                    updatePlace(node: shape)
//                }
//            }
//        }
        
        
        if let undoneNode = shapesGroup.contents.popLast() {
            if let freeDrawing = undoneNode as? FreeDrawing {
                freeDrawing.deleteShape()
            }
            if let text = undoneNode as? CustomText {
                text.deleteShape()
            }
            redoShapes.append(undoneNode)
        }
    }
    
    @IBAction func redoTool(_ sender: Any) {
        if let redoneNode = redoShapes.popLast() {
            if let freeDrawing = redoneNode as? FreeDrawing {
                freeDrawing.redoShape()
            }
            if let text = redoneNode as? CustomText {
                text.redoShape()
            }
            shapesGroup.contents.append(redoneNode)
        }
    }
    
    @IBAction func deleteTool(_ sender: UIButton) {
        activeTool = .none
        drawingActive = false
        activeTool = .delete
        deleteButton.isSelected = true
    }
}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return backgroundView
    }
}

extension ViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let customText = customTexts.last
        textView.text = customText?.textNode.text
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let customText = customTexts.last
        customText?.setText(text: textView.text ?? "")
    }
}
