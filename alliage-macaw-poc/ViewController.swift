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
    case multiline
    case delete
    case selection
    case none
}

protocol MacawViewDelegate {
    var shapeTransformations: [Int:(dx:Double,dy:Double,scale:Double, angle:Double)] { get set }
    func activateScrollView(enable: Bool)
    func updatePlace(node: Node)
    func setNewShape(shape: CustomShape)
    var shapesGroup: Group { get set }
    var activeTool: Tool { get set }
    var stroke: Stroke { get }
    var textColor: Color { get }
    var inputTextView: UITextView { get }
    var customTexts: [CustomText] { get set }
    var isKeyboardShowing: Bool { get }
    var lastActiveShape: CustomShape? { get set }
}

class ViewController: UIViewController, MacawViewDelegate {
    
    var isNewShape: Bool = true
    
    var shapeActive: Bool = false
    
    var shapeTransformations: [Int:(dx:Double,dy:Double,scale:Double, angle:Double)] = [:]
    
    var transformHistory: [Int:(dx:Double,dy:Double,scale:Double, angle:Double)] = [:]
        
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
    @IBOutlet weak var multilineButton: UIButton!
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
    
    let stroke = Stroke(fill: Color.red, width: 4.0)
    let textColor = Color.red
    
    var group: Group!
    var canvas: Shape!
    var shapesGroup: Group = Group()
    var redoShapes: [Node] = []
    
    var newShape: CustomShape!
    var lastActiveShape: CustomShape?
    
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
                activateScrollView(enable: true)
            } else {
                activateScrollView(enable: false)
            }
        }
    }
    
    var activeTool: Tool = .none {
        willSet {
            if newValue == .none {
                isNewShape = true
                freeButton.isSelected = false
                textButton.isSelected = false
                lineButton.isSelected = false
                rectButton.isSelected = false
                circleButton.isSelected = false
                protractorButton.isSelected = false
                arcButton.isSelected = false
                arrowButton.isSelected = false
                asteriskButton.isSelected = false
                multilineButton.isSelected = false
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
            
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame.height : 0 //sets inputView constraint according to keyboard height
            self.messageInputContainerView.isHidden = !self.messageInputContainerView.isHidden

            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (completed) in
            }
        }
    }

    func createCanvas() {
        self.canvas = Shape(form: Rect(x: 0, y: 0, w: Double(image.size.width), h: Double(image.size.height)), fill: Color.clear, stroke: Stroke(fill: Color.red, width: 2.0)) //creating background canvas
        
        var startPoint = Point()
        
        // creating new shape during first touch on canvas
        canvas.onTouchPressed { event in
            
            if self.selectionButton.isSelected {
                if self.lastActiveShape != nil {
                    self.lastActiveShape?.isActive = false
                    self.lastActiveShape = nil
                }
            }
            
            guard let loc = event.points.first?.location(in: .scene)  else { return }
            
            startPoint = loc //stores initial touch point of new shape to be referenced on subsequent events
            
            self.redoShapes = [] //creating new shape empties redo shapes array
            
            //stores new shape to be referenced on subsequent events
            switch self.activeTool {
            case .selection, .delete, .none:
                return
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
                self.newShape = Protractor(p0: startPoint, p1: startPoint, p2: startPoint, delegate: self, stroke: self.stroke)
            case .asterisk:
                self.newShape = Asterisk(startPoint: startPoint, lastPoint: startPoint, stroke: self.stroke)
            case .arc:
                self.newShape = CustomArc(p0: startPoint, p1: startPoint, p2: startPoint, delegate: self, stroke: self.stroke)
            case .multiline:
                if self.isNewShape {
                    self.newShape = Multiline(startPoint: startPoint, lastPoint: startPoint, stroke: self.stroke)
                } else {
                    if let multiline = self.newShape as? Multiline {
                        multiline.newPoint(point: startPoint)
                    }
                    return
                }
            }
            self.setNewShape(shape: self.newShape)
            self.shapesGroup.contents.append(self.newShape)
        }
        
        // resizing new shape when moving first touch
        canvas.onTouchMoved { (event) in
            if self.activeTool == .none || self.activeTool == .delete || self.activeTool == .text || self.activeTool == .multiline || self.selectionButton.isSelected { return }
            guard let loc = event.points.first?.location(in: .scene) else { return }
            self.newShape.updateForm(startPoint: startPoint, lastPoint: loc) //updates form of newly created shape while initial touch isn't released
            if self.activeTool == .freeDraw {
                startPoint = loc //Free Draw line creation: start point is the last touched point
            }
        }
        
        // leaving new shape on canvas when releasing first touch
        canvas.onTouchReleased { (event) in
            
            switch self.activeTool {
            case .none, .delete, .selection:
                return
            case .text:
                if self.isKeyboardShowing {
                    self.inputTextView.resignFirstResponder()
                    return
                }
                let customText = CustomText(text: "", startPoint: startPoint, color: self.textColor)
                customText.delegate = self
                self.customTexts.append(customText) //stores all created texts
                self.shapeTransformations[customText.hash] = (0,0, 1, 0)
                customText.setTransformEvents(startPoint: startPoint)
                self.setNewShape(shape: customText)
                self.inputTextView.becomeFirstResponder() //always displays keyboard after creating text
                return //adds newly created text to shapes array and ignores subsequent events
            case .multiline:
                if let multiline = self.newShape as? Multiline {
                    if self.isNewShape {
                        self.shapeTransformations[self.newShape.hash] = (0,0,1,0)
                        multiline.delegate = self
                        multiline.setTransformEvents()
                        self.setDeleteEvent(node: self.newShape)
                        self.isNewShape = false
                        //self.setNewShape(shape: self.newShape)
                    } else { return }
                }
            default:
                self.shapeTransformations[self.newShape.hash] = (0,0, 1, 0)
                self.newShape.delegate = self
                self.newShape.setTransformEvents()
                self.setDeleteEvent(node: self.newShape)
                //self.setNewShape(shape: self.newShape)
                return
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
            guard let node = event.node as? CustomShape else { print("problem on panel pan")
                return
            }
            if self.activeTool == .delete {
                self.shapesGroup.contents.removeAll(where: { (shape) -> Bool in
                    shape.hash == node.hash
                })
            } else {
                node.isActive = !node.isActive
                self.setNewShape(shape: node)
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
    
    func setNewShape(shape: CustomShape) {
        if shape.isActive {
            if self.lastActiveShape != nil {
                self.lastActiveShape!.isActive = false
            }
            self.lastActiveShape = shape
        } else {
            self.lastActiveShape = nil
        }
    }
    
    @IBAction func freeDrawingTool(_ sender: UIButton) {
        toolSelected()
        activeTool = .freeDraw
        freeButton.isSelected = true

//        if lastSelectedButton != freeButton {
//            if lastSelectedButton != nil {
//                lastSelectedButton.isSelected = false
//            }
//            freeButton.isSelected = true
//            lastSelectedButton = freeButton
//        }
    }
    
    @IBAction func textTool(_ sender: UIButton) {
        toolSelected()
        activeTool = .text
        textButton.isSelected = true
//        if lastSelectedButton != textButton {
//            if lastSelectedButton != nil {
//                lastSelectedButton.isSelected = false
//            }
//            textButton.isSelected = true
//            lastSelectedButton = textButton
//        }
    }
    
    @IBAction func activeLineTool(_ sender: UIButton) {
        toolSelected()
        activeTool = .line
        lineButton.isSelected = true

    }
    
    @IBAction func activeRectTool(_ sender: UIButton) {
        toolSelected()
        activeTool = .rect
        rectButton.isSelected = true
    }
    
    @IBAction func activeCircleTool(_ sender: Any) {
        toolSelected()
        activeTool = .ellipse
        circleButton.isSelected = true
    }
    
    @IBAction func activeShapeTool(_ sender: Any) {
        toolSelected()
        activeTool = .protractor
        protractorButton.isSelected = true
    }
    
    @IBAction func activeArrowTool(_ sender: Any) {
        toolSelected()
        activeTool = .arrow
        arrowButton.isSelected = true
    }
    
    @IBAction func activeAsteriskTool(_ sender: Any) {
        toolSelected()
        activeTool = .asterisk
        asteriskButton.isSelected = true
    }
    
    @IBAction func activateArcTool(_ sender: UIButton) {
        toolSelected()
        activeTool = .arc
        arcButton.isSelected = true
    }
    
    @IBAction func activateMultilineTool(_ sender: UIButton) {
        toolSelected()
        activeTool = .multiline
        multilineButton.isSelected = true
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
        
        isNewShape = true
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
        isNewShape = true
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
    
    func toolSelected() {
        activateScrollView(enable: false)
        activeTool = .none
        drawingActive = true
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
