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

protocol MacawViewDelegate: class {
    func activateScrollView(enable: Bool)
    func setLastActiveShape(newShape: CustomShape)
    var shapesGroup: Group { get set }
    var activeTool: Annotation.Types { get set }
    var textColor: Color { get }
    var customTexts: [CustomText] { get set }
    var isKeyboardShowing: Bool { get }
    var lastActiveShape: CustomShape? { get set }
    var macawTextActive: Bool { get set }
    var macawView: MacawView { get set }
}

//protocol MacawViewDelegate {
//    var shapeTransformations: [Int:(dx:Double,dy:Double,scale:Double, angle:Double)] { get set }
//    func activateScrollView(enable: Bool)
//    func updatePlace(node: Node)
//    func setNewShape(shape: CustomShape)
//    var shapesGroup: Group { get set }
//    var activeTool: Tool { get set }
//    var stroke: Stroke { get }
//    var textColor: Color { get }
//    var inputTextView: UITextView { get }
//    var customTexts: [CustomText] { get set }
//    var isKeyboardShowing: Bool { get }
//    var lastActiveShape: CustomShape? { get set }
//}

class ViewController: UIViewController, MacawViewDelegate {
    
    var previousMacawHeight: CGFloat! //stores previous Macaw view height to be used on view redimensions
    var previousMacawWidth: CGFloat! //stores previous Macaw view width to be used on view redimensions
    
    var newMacawHeight: CGFloat? //stores new Macaw view height to be used on view redimensions
    var newMacawWidth: CGFloat? //stores new Macaw view width to be used on view redimensions
    
    var macawTextActive: Bool = false {
        didSet {
            if macawTextActive {
                inputTextView.becomeFirstResponder()
            } else {
                inputTextView.resignFirstResponder()
            }
        }
    }
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let inputTextView: UITextView = {
        let textView = UITextView()
        return textView
    }()
    
    let textColor = Color.red
    var textSize: Double = 12.0
    
    var group: Group! //Macaw group to store all shapes
    var lastActiveShape: CustomShape?
    var cropRect: Shape?
    var customTexts: [CustomText] = []
    
    var isKeyboardShowing: Bool = false
    
    var drawingActive: Bool = true { //puts canvas in front of shapes to draw on it, or shapes over canvas to be selected
        didSet {
            if oldValue != drawingActive {
                let first = group.contents.remove(at: 0)
                group.contents.append(first)
            }
        }
    }
    
    var isNewShape: Bool = true //global variable used for nerve and multiline shapes to determina if a new line or a new shape should be created
    
    var activeTool: Annotation.Types = .none
    
    var bottomConstraint: NSLayoutConstraint?
    
    var canvas: Shape! //rectangle shape where new shapes are drawn
    var macawView = MacawView()
    var shapesGroup = Group() //macaw group node where shapes are stored
    
//    weak var delegate: ExamImportViewControllerDelegate?
//    var selectedButton: ExamEditBaseView! //currently selected button; for interface purposes

    var lastActiveView: UIView?
    
//    @IBOutlet weak var backgroundView: UIView!
//    @IBOutlet weak var imageScrollView: UIScrollView!
//    @IBOutlet weak var examImage: UIImageView!
        
//    var imageMatrix: ImageMatrix!
//
//    var pencilShapesView: PencilShapesView!
//    var measureShapesView: MeasureShapesView!
//    var nerveOptionsView: NerveOptionsView!
//    var miniatureOptionsView: MiniatureOptionsView!
//    var odontogramOptionsView: OdontogramOptionsView!
//    var commentaryOptionsView: CommentaryOptionsView!
//    var implantOptionsView: ImplantOptionsView!
    var selectionView: UIView!
    
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
//    @IBOutlet weak var selectionButton: UIButton!
    var nerveButton = UIButton()
    var miniatureButton = UIButton()
        
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
        
    var lastSelectedButton: UIButton!
    
    let stroke = Stroke(fill: Color.red, width: 4.0)
    
    var redoShapes: [Node] = []
    
    var newShape: CustomShape!
    
    let image = #imageLiteral(resourceName: "Medical_X-Ray_imaging_AAR02_nevit")
    
    var backgroundView = UIView()
    
    var imageView = UIImageView()
       
    var newAnnotationId: Int = 0
    
    @IBAction func selectionTool(_ sender: UIButton) {
        setSelectionTool(activate: !sender.isSelected)
    }
    
    func setSelectionTool(activate: Bool) {
        if !activate {
            selectionButton.isSelected = false
            drawingActive = true
        } else {
            selectionButton.isSelected = true
            drawingActive = false
        }
        isNewShape = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupBackgroundView()
        setupMacawView()
        createCanvas()
        configInputContainer()
//        configMacawView()
//        createCanvas()
//
//        view.addSubview(messageInputContainerView)
//        messageInputContainerView.translatesAutoresizingMaskIntoConstraints = false
//        messageInputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        messageInputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        messageInputContainerView.heightAnchor.constraint(equalToConstant: 48).isActive = true
//
//        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
//        view.addConstraint(bottomConstraint!)
//
//        setupInputComponents()
//        configInputNotifications()
    }
    
    func setupScrollView() {
        activateScrollView(enable: false)
        scrollview.delegate = self
        scrollview.bounces = false
        scrollview.bouncesZoom = false
        scrollview.minimumZoomScale = 1.0
    }
    
    func setupBackgroundView() {
        scrollview.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.centerXAnchor.constraint(equalTo: scrollview.centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: scrollview.centerYAnchor).isActive = true
        backgroundView.widthAnchor.constraint(equalTo:scrollview.widthAnchor).isActive = true
        backgroundView.heightAnchor.constraint(equalTo:scrollview.heightAnchor).isActive = true
        
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollview.contentSize = CGSize(width: backgroundView.frame.width, height: backgroundView.frame.height)

        backgroundView.addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo:backgroundView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo:backgroundView.heightAnchor).isActive = true
    }
    
    func setupMacawView() {
        macawView.backgroundColor = .clear
        macawView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(macawView)
        
        macawView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        macawView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        macawView.widthAnchor.constraint(equalTo:imageView.widthAnchor).isActive = true
        macawView.heightAnchor.constraint(equalTo:imageView.heightAnchor).isActive = true
        
        canvas = Shape(form: Rect(x: 0, y: 0, w: Double(UIScreen.main.bounds.width), h: Double(UIScreen.main.bounds.height)), fill: Color.clear, stroke: Stroke(fill: Color.clear, width: 1.0))
        
        macawView.node = Group(contents: [shapesGroup, canvas])
    }
    
//    func updateMacawViewConstraints() { //updates macaw view constraints after examImage constraints are changed; macawView covers only visible image, not black bars
//
//        newMacawHeight = examImage.calculateRectOfImageInImageView().height
//        newMacawWidth = examImage.calculateRectOfImageInImageView().width
//
//        macawView.snp.remakeConstraints { (make) in
//            make.centerX.equalTo(examImage.snp.centerX)
//            make.centerY.equalTo(examImage.snp.centerY)
//            make.height.equalTo(newMacawHeight!)
//            make.width.equalTo(newMacawWidth!)
//        }
//    }
    
    func configInputContainer() { //custom message container setup
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
        inputTextView.leadingAnchor.constraint(equalTo: messageInputContainerView.leadingAnchor, constant: 0).isActive = true
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
            
            isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification //storing keyboard state for future reference for text events
            
            if isKeyboardShowing {
                bottomConstraint?.constant = -keyboardFrame.height
                if macawTextActive {
                    self.messageInputContainerView.isHidden = false
                }
            } else {
                bottomConstraint?.constant = 0
                self.messageInputContainerView.isHidden = true
                macawTextActive = false
            }
            
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (completed) in
            }
        }
    }

    func createCanvas() {
        
        var newShape: CustomShape!
//        var timer: ParkBenchTimer!
        var startPoint = Point()
        var isLastPoint = false
        var lastCalibrationId: Int?
        
        // creating new shape during first touch on canvas
        canvas.onTouchPressed { [weak self] event in
            
            if self!.selectionButton.isSelected {
                if self!.lastActiveShape != nil {
                    self?.lastActiveShape?.isActive = false //deselects last shape
                    self?.lastActiveShape = nil
                }
                return
            }
            
            var stroke: Stroke!
            var stroke2: Stroke?
            
            guard let drawingType = self?.activeTool.drawingType() else { return }
            switch drawingType { //sets strokes based on selected tool
            case .pencil:
                stroke = Stroke(fill: Color(val: 0xffffff), width: 5.0)
            case .measure:
                stroke = Stroke(fill: Color(val: 0xffffff), width: 5.0)
            case .nerve:
                stroke = Stroke(fill: Color(val: 0xffffff), width: 5.0)
                stroke2 = Stroke(fill: Color(val: 0xffffff), width: 5.0+8.0)
            case .miniature, .implant:
                stroke = Stroke(fill: Color.white, width: 2.0, dashes: [5, 5])
            case .odontogram, .commentary:
                return
            }
            
            guard let loc = event.points.first?.location(in: .scene) else { return }
            startPoint = loc //stores initial touch point of new shape to be referenced on subsequent events
            
            if self!.isNewShape && self!.activeTool.drawingType()! != .miniature && self!.activeTool.drawingType()! != .implant && self!.activeTool != .calibration {
                self?.newAnnotationId += 1
            }
            
            //stores new shape to be referenced on subsequent events
            switch self!.activeTool {
            case .none:
                return
            case .miniature:
                let rectLocus = Rect(x: loc.x, y: loc.y, w: 0, h: 0)
                let stroke = Stroke(fill: Color.white, width: 2.0, dashes: [5, 5])
                
                if self!.cropRect != nil {
                    self?.cropRect!.form = rectLocus
                } else {
                    self?.cropRect = Shape(form: rectLocus, fill: Color(0xa3b7ec).with(a: 0.5), stroke: stroke)
                }
                self?.shapesGroup.contents.append(self!.cropRect!)
                return
            case .freeDrawing:
                newShape = FreeDrawing(startPoint: startPoint, lastPoint: startPoint, stroke: stroke, type: .freeDrawing, annotationId: self!.newAnnotationId)
            case .text:
                newShape = CustomText(text: "", startPoint: startPoint, lastPoint: startPoint, stroke: stroke, type: .text, annotationId: self!.newAnnotationId, comment: "")
            case .line:
                newShape = CustomLine(startPoint: startPoint, lastPoint: startPoint, stroke: stroke, type: .line, annotationId: self!.newAnnotationId, comment: "")
            case .ellipse:
                newShape = CustomEllipse(startPoint: startPoint, lastPoint: startPoint, stroke: stroke, type: .ellipse, annotationId: self!.newAnnotationId, comment: "")
            case .rect:
                newShape = CustomRect(startPoint: startPoint, lastPoint: startPoint, stroke: stroke, type: .rect, annotationId: self!.newAnnotationId, comment: "")
            case .arrow:
                newShape = Arrow(startPoint: startPoint, lastPoint: startPoint, stroke: stroke, type: .arrow, annotationId: self!.newAnnotationId, comment: "")
            case .protractor:
                newShape = Protractor(p0: startPoint, p1: startPoint, p2: startPoint, delegate: self!, stroke: stroke, type: .protractor, annotationId: self!.newAnnotationId, comment: "")
            case .implant:
//                if let calibration = self?.getSelectedCalibration()?.pixelsPerMilimeter {
//                    if let implant = self?.selectedImplant {
//                        let image = UIImage(data: implant.imagem_implante!.data)
//                        newShape = CustomImplant(startPoint: startPoint, lastPoint: startPoint, delegate: self, type: .implant, annotationId: nil, comment: "", image: image, idImplant: implant.id!, calibration: calibration, rotation: 0, implantType: implant, coordinateSystem: self!.coordinateSystem)
//                    } else {
//                        return
//                    }
//                } else {
                    return
//                }
            case .asterisk:
                newShape = Asterisk(startPoint: startPoint, lastPoint: startPoint, stroke: stroke, type: .asterisk, annotationId: self!.newAnnotationId, comment: "")
            case .arc:
                newShape = CustomArc(p0: startPoint, p1: startPoint, p2: startPoint, delegate: self!, stroke: stroke, type: .arc, annotationId: self!.newAnnotationId, comment: "")
            case .multiline:
//                if self!.isNewShape {
//                    newShape = Multiline(startPoint: startPoint, lastPoint: startPoint, stroke: stroke, coordinateSystem: self!.coordinateSystem, pixelsPerMilimeter: self!.getSelectedCalibration()?.pixelsPerMilimeter ?? 0, type: .multiline, annotationId: self!.newAnnotationId)
//                    self?.addNewAnnotation(shape: newShape)
//                    self?.commentaryOptionsView.selectedAnnotationId = newShape.annotationId
//                    self?.commentaryOptionsView.collectionView.reloadData()
//                    timer = ParkBenchTimer()
//                    isLastPoint = false
//                } else {
//                    if let multiline = newShape as? Multiline {
//                        let time = timer.stop()
//                        if time < 0.5 {
//                            self?.isNewShape = true
//                            isLastPoint = true
//                        } else {
//                            multiline.newPoint(point: startPoint)
//                            timer = ParkBenchTimer()
//                        }
//                    }
                    return
//                }
            case .nerve:
//                if self!.isNewShape {
//                    let outerStroke = stroke2!
//                    newShape = Nerve(startPoint: startPoint, lastPoint: startPoint, stroke: stroke, outerStroke: outerStroke, type: .nerve, annotationId: self!.newAnnotationId)
//                    self?.addNewAnnotation(shape: newShape)
//                    self?.commentaryOptionsView.selectedAnnotationId = newShape.annotationId
//                    self?.commentaryOptionsView.collectionView.reloadData()
//                    timer = ParkBenchTimer()
//                    isLastPoint = false
//                } else {
//                    if let nerve = newShape as? Nerve {
//                        let time = timer.stop()
//                        if time < 0.5 {
//                            self?.isNewShape = true
//                            isLastPoint = true
//                        } else {
//                            nerve.newPoint(point: startPoint)
//                            timer = ParkBenchTimer()
//                        }
//                    }
                    return
//                }
            case .ruler:
//                newShape = Ruler(startPoint: startPoint, lastPoint: startPoint, stroke: stroke, coordinateSystem: self!.coordinateSystem, pixelsPerMilimeter: self!.getSelectedCalibration()?.pixelsPerMilimeter ?? 0, type: .ruler, annotationId: self!.newAnnotationId, comment: "")
                return //remove
            case .calibration:
//                if let id = lastCalibrationId {
//                    self?.shapesGroup.contents.removeAll(where: { (node) -> Bool in
//                        node.hash == id
//                    })
//                }
//                newShape = CustomCalibration(startPoint: startPoint, lastPoint: startPoint, stroke: stroke, calibrationDelegate: self!, coordinateSystem: self!.coordinateSystem, type: .calibration, annotationId: -1, comment: "")
                return //remove
            }
            
            self?.setLastActiveShape(newShape: newShape)
            self?.shapesGroup.contents.append(newShape)
            
            if self!.activeTool != .multiline && self!.activeTool != .nerve && self!.activeTool != .freeDrawing && self!.activeTool != .calibration {
//                self?.addNewAnnotation(shape: newShape)
//                self?.commentaryOptionsView.selectedAnnotationId = newShape.annotationId
//                self?.commentaryOptionsView.collectionView.reloadData()
            }
        }
        
        // resizing new shape when moving first touch
        canvas.onTouchMoved { [weak self] (event) in
            if self!.activeTool == .none || self!.selectionButton.isSelected { return } //self.selectionButton.isSelected { return }
            
//            if self!.activeTool == .implant {
//                if self!.selectedImplant == nil || self!.getSelectedCalibration() == nil { return }
//            }
            
            guard let loc = event.points.first?.location(in: .scene) else { return }
            
//            if self!.activeTool == .miniature {
//                if loc.x < 0 || loc.y < 0 || loc.x > Double(self!.imageView.image.calculateRectOfImageInImageView().width) || loc.y > Double(self!.examImage.calculateRectOfImageInImageView().height) { return }
//
//                let width = loc.x - startPoint.x
//                let height = loc.y - startPoint.y
//
//                self?.cropRect!.form = Rect(x: startPoint.x, y: startPoint.y, w: width, h: height)
//                return
//            }
            newShape.updateForm(startPoint: startPoint, lastPoint: loc) //updates form of newly created shape while initial touch isn't released
            if self!.activeTool == .freeDrawing {
                startPoint = loc //Free Draw line creation: start point is the last touched point
            }
        }
        
        // leaving new shape on canvas when releasing first touch
        canvas.onTouchReleased { [weak self] (event) in
            
            if self!.selectionButton.isSelected { return }
            
            switch self!.activeTool {
            case .none, .miniature:
                return
            case .text:
                if self!.isKeyboardShowing {
                    self?.inputTextView.resignFirstResponder()
                    return
                }
//                let customText = CustomText(text: "", startPoint: startPoint, stroke: Stroke(fill: self.textColor, width: self.textSize), type: .text, annotationId: self.newAnnotationId, comment: "")
                let customText = newShape as! CustomText
                customText.delegate = self
                self?.customTexts.append(customText) //stores all created texts
                //                self.shapeTransformations[customText.hash] = (0,0, 1, 0)
                customText.setTransformEvents()
//                self.setNewShape(shape: customText)
                self?.macawTextActive = true
                self?.inputTextView.becomeFirstResponder() //always displays keyboard after creating text
//                self.addNewAnnotation(shape: customText)
//                self.commentaryOptionsView.selectedAnnotationId = customText.annotationId
//                self.commentaryOptionsView.collectionView.reloadData()
                
//                self.selectTool(tool: .selection, button: self.selectionButton)
                self?.setSelectionTool(activate: true)
            return //adds newly created text to shapes array and ignores subsequent events
            case .multiline:
                if let multiline = newShape as? Multiline {
                    if self!.isNewShape {
                        if isLastPoint {
                            self?.isNewShape = true
                            if multiline.points.count == 1 {
                                self?.shapesGroup.contents.removeAll(where: { (node) -> Bool in
                                    node.hash == multiline.hash
                                })
                            }
                            //self.selectTool(tool: .selection, button: self.selectionButton),
                            self?.setSelectionTool(activate: true)
                            return
                        } else {
                            //                            self.shapeTransformations[self.newShape.hash] = (0,0,1,0)
                            multiline.delegate = self
                            multiline.setTransformEvents()
                            self?.setTapEvent(node: newShape)
                            self?.isNewShape = false
                        }
                    } else {
                        return
                    }
                }
            case .nerve:
                if let nerve = newShape as? Nerve {
                    if self!.isNewShape {
                        if isLastPoint {
                            self?.isNewShape = true
                            if nerve.points.count == 1 {
                                self?.shapesGroup.contents.removeAll(where: { (node) -> Bool in
                                    node.hash == nerve.hash
                                })
                            }
                            self?.setSelectionTool(activate: true)
//                            self.selectTool(tool: .selection, button: self.selectionButton)
                            return
                        } else {
                            //                            self.shapeTransformations[self.newShape.hash] = (0,0,1,0)
                            nerve.delegate = self
                            nerve.setTransformEvents()
                            self?.setTapEvent(node: newShape)
                            self?.isNewShape = false
                        }
                    } else {
                        return
                    }
                }
            case .implant:
//                if self!.selectedImplant == nil || self!.getSelectedCalibration() == nil { return }
//                newShape.delegate = self
//                newShape.setTransformEvents()
//                self?.setTapEvent(node: newShape)
//                self?.setSelectionTool(activate: true)
                return
            default:
//                if let calibration = newShape as? CustomCalibration {
//                    self?.measurePixels(calibration.distance(calibration.p0, calibration.p1, scaled: true))
//                    lastCalibrationId = calibration.hash
//                }
                if let freeDrawing = newShape as? FreeDrawing {
//                    self?.addNewAnnotation(shape: freeDrawing)
                    self?.selectShape(node: freeDrawing)
                }
                newShape.delegate = self
                newShape.setTransformEvents()
                self?.setTapEvent(node: newShape)
                self?.setSelectionTool(activate: true)
                return
            }
        }
        
        group = Group(contents: [shapesGroup, canvas])
        macawView.node = group
        newShape = nil
    }
    
//    func addNewAnnotation(shape: CustomShape) {
//
//        var color = "0xffffffff"
//
//        if let nerve = shape as? Nerve {
//            color = App.Colors.getColorString(nerve.outerStroke!.fill) + "&" + App.Colors.getColorString(nerve.stroke!.fill)
//        } else {
//            color = App.Colors.getColorString(shape.stroke!.fill)
//        }
//
//        var text = ""
//        if let textShape = shape as? CustomText {
//            text = textShape.textNode.text
//        }
//
//        let annotation = annotationMapper.mapAnnotation(from: shape, id_exame_fk: self.exam.id, id_anotacao: String(shape.annotationId), cor_anotacao: color, espessura_anotacao: shape.stroke.width, texto_anotacao: text, descricao_anotacao: shape.comment)
//        commentaryOptionsView.addAnnotation(annotation: annotation)
//    }
//
    func setTapEvent(node: CustomShape) {
        node.onTap(f: { [weak self] (event) in
            if self!.activeTool == .none && !self!.selectionButton.isSelected { return }
            guard let node = event.node as? CustomShape else { print("problem on panel tap")
                return
            }
            self?.selectShape(node: node)
        })
    }

    func selectShape(node: CustomShape) {
        node.isActive = !node.isActive
        if node.isActive {
            self.shapesGroup.contents.removeAll(where: { (shape) -> Bool in
                shape.hash == node.hash
            })
            self.shapesGroup.contents.append(node) //putting active shape at top of created shapes
//            if let implant = node as? CustomImplant {
//                macawView.bringSubviewToFront(implant.pinoImageView)
//            }
        }
        self.setLastActiveShape(newShape: node)
//        if node.isActive {
//            commentaryOptionsView.selectedAnnotationId = node.annotationId
//        } else {
//            if commentaryOptionsView.selectedAnnotationId == node.annotationId {
//                commentaryOptionsView.selectedAnnotationId = nil
//            }
//        }
//        commentaryOptionsView.collectionView.reloadData()
    }
    
    func activateScrollView(enable: Bool) {
        scrollview.isScrollEnabled = enable
        scrollview.pinchGestureRecognizer?.isEnabled = enable
    }
    
    func setLastActiveShape(newShape: CustomShape) { //deselects last selected shape and updates it with new shape
        if newShape.isActive {
            if self.lastActiveShape != nil {
                if self.lastActiveShape!.isHidden {
                    self.lastActiveShape!.isActive = false
                    self.lastActiveShape!.isHidden = true
                } else {
                    self.lastActiveShape!.isActive = false
                }
            }
            self.lastActiveShape = newShape
        } else {
            self.lastActiveShape = nil
        }
    }
    
    func measurePixels(_ d: Double) { //should be overriden by methods in iPhone and iPad report controllers
    }
    
//    @objc func dismissColorSelector() {
//        self.dismiss()
//    }
    
    
    
    @IBAction func freeDrawingTool(_ sender: UIButton) {
        toolSelected()
        activeTool = .freeDrawing
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
    
//    @IBAction func activateSelectionTool(_ sender: Any) {
//        activeTool = .none
//        drawingActive = false
//        activeTool = .selection
//        selectionButton.isSelected = true
//    }
//
//    @IBAction func undoTool(_ sender: Any) {
////        if let undoneAction = macawActions.popLast() {
////            let node = group.contents.first { (node) -> Bool in
////                node.hash == undoneAction.nodeHash
////            }
////
////            if node != nil {
////
////                let shape = node as! CustomShape
////
////                if undoneAction.type == ActionType.create {
////
////                } else {
////
////                    let transformation = (dx: -undoneAction.transformation!.dx, dy: -undoneAction.transformation!.dy, scale: undoneAction.transformation!.scale, angle: undoneAction.transformation!.scale)
////                    shapeTransformations[shape.hash] = transformation
////                    updatePlace(node: shape)
////                }
////            }
////        }
//
//        isNewShape = true
//        if let undoneNode = shapesGroup.contents.popLast() {
//            if let freeDrawing = undoneNode as? FreeDrawing {
//                freeDrawing.deleteShape()
//            }
//            if let text = undoneNode as? CustomText {
//                text.deleteShape()
//            }
//            redoShapes.append(undoneNode)
//        }
//    }
//
//    @IBAction func redoTool(_ sender: Any) {
//        isNewShape = true
//        if let redoneNode = redoShapes.popLast() {
//            if let freeDrawing = redoneNode as? FreeDrawing {
//                freeDrawing.redoShape()
//            }
//            if let text = redoneNode as? CustomText {
//                text.redoShape()
//            }
//            shapesGroup.contents.append(redoneNode)
//        }
//    }
//
//    @IBAction func deleteTool(_ sender: UIButton) {
//        activeTool = .none
//        drawingActive = false
//        activeTool = .delete
//        deleteButton.isSelected = true
//    }
//
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
